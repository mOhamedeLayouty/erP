import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Field, TextInput, Select, Button } from '../components/Form';
import { useToast } from '../components/Toast';

type Tab = 'stores'|'items'|'transfers'|'details'|'transfer_flow';

export default function Inventory() {
  const api = useApi();
  const toast = useToast();

  const [tab, setTab] = useState<Tab>('stores');
  const [rows, setRows] = useState<any[]>([]);
  const [stores, setStores] = useState<any[]>([]);
  const [items, setItems] = useState<any[]>([]);

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Transfer flow form (best-effort keys, backend will ignore unknown columns)
  const [transferId, setTransferId] = useState('TR-001');
  const [fromStore, setFromStore] = useState('');
  const [toStore, setToStore] = useState('');
  const [selectedItem, setSelectedItem] = useState('');
  const [qty, setQty] = useState(1);

  const storeKeys = useMemo(() => {
    const sample = stores[0] ?? {};
    const idKey = Object.keys(sample).find(k => k.toLowerCase().includes('store') && k.toLowerCase().includes('id')) || 'store_id';
    const nameKey = Object.keys(sample).find(k => k.toLowerCase().includes('name')) || idKey;
    return { idKey, nameKey };
  }, [stores]);

  const itemKeys = useMemo(() => {
    const sample = items[0] ?? {};
    const idKey = Object.keys(sample).find(k => k.toLowerCase().includes('item')) || 'ItemID';
    const nameKey = Object.keys(sample).find(k => k.toLowerCase().includes('name')) || idKey;
    return { idKey, nameKey };
  }, [items]);

  async function loadList() {
    setLoading(true); setError(null);
    try {
      const path = tab === 'stores' ? '/api/inventory/stores'
        : tab === 'items' ? '/api/inventory/items'
        : tab === 'transfers' ? '/api/inventory/transfers'
        : tab === 'details' ? '/api/inventory/transfer-details'
        : null;

      if (!path) { setRows([]); return; }
      const res = await api.get<any>(path);
      setRows(res.data ?? res);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  async function loadLookups() {
    try {
      const s = await api.get<any>('/api/inventory/stores');
      setStores(Array.isArray(s?.data ?? s) ? (s.data ?? s) : []);
    } catch { setStores([]); }
    try {
      const it = await api.get<any>('/api/inventory/items');
      setItems(Array.isArray(it?.data ?? it) ? (it.data ?? it) : []);
    } catch { setItems([]); }
  }

  useEffect(() => {
    loadLookups();
  }, [api.baseUrl, api.token]);

  useEffect(() => {
    if (tab !== 'transfer_flow') loadList();
  }, [tab, api.baseUrl, api.token]);

  async function createHeader() {
    if (!transferId.trim()) return toast.push({ type: 'error', message: 'transferId required' });
    setBusy(true); setError(null);
    try {
      // we send multiple common keys; backend will take only locked columns
      const payload: any = {
        transferid: transferId.trim(),
        TransferID: transferId.trim(),
        VoucherID: transferId.trim(),
        from_store: fromStore || undefined,
        to_store: toStore || undefined
      };
      await api.post<any>('/api/inventory/transfers', payload);
      toast.push({ type: 'success', message: `Transfer header created: ${transferId}` });
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function createDetail() {
    if (!transferId.trim()) return toast.push({ type: 'error', message: 'transferId required' });
    setBusy(true); setError(null);
    try {
      const payload: any = {
        transferid: transferId.trim(),
        TransferID: transferId.trim(),
        VoucherID: transferId.trim(),
        ItemID: selectedItem || undefined,
        Qty: qty
      };
      await api.post<any>('/api/inventory/transfer-details', payload);
      toast.push({ type: 'success', message: 'Transfer detail created' });
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function postTransfer() {
    if (!transferId.trim()) return toast.push({ type: 'error', message: 'transferId required' });
    setBusy(true); setError(null);
    try {
      const res = await api.post<any>('/api/inventory/post-transfer', { transfer_id: transferId.trim() });
      toast.push({ type: 'success', message: `Post result: ${JSON.stringify(res?.data ?? res)}` });
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  return (
    <div>
      <h3>Inventory</h3>

      <Callout title="Phase 3.6 (تشغيل مخزن)">
        ركّزنا على تشغيل الـ Transfer Flow ب Form بدل JSON، مع Lookups (Stores/Items) قدر الإمكان.
        ملاحظة: الأعمدة النهائية Locked في الـ DB—الباك اند هيعمل filter للأعمدة غير المعروفة.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        {(['stores','items','transfers','details','transfer_flow'] as const).map(t => (
          <Button key={t} onClick={() => setTab(t)} disabled={loading || busy || tab===t}>{t}</Button>
        ))}
        {tab !== 'transfer_flow' && <Button onClick={loadList} disabled={loading || busy}>Refresh</Button>}
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      {tab !== 'transfer_flow' ? (
        <DataTable rows={rows} />
      ) : (
        <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
          <div style={{ fontWeight: 800, marginBottom: 10 }}>Transfer Flow</div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Field label="Transfer ID *">
              <TextInput value={transferId} onChange={(e) => setTransferId(e.target.value)} />
            </Field>
            <Field label="Qty">
              <TextInput type="number" value={qty} onChange={(e) => setQty(Number(e.target.value))} />
            </Field>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Field label="From Store">
              <Select value={fromStore} onChange={(e) => setFromStore(e.target.value)}>
                <option value="">(select)</option>
                {stores.map((s, i) => {
                  const id = String(s[storeKeys.idKey] ?? '');
                  const name = String(s[storeKeys.nameKey] ?? id);
                  return <option key={i} value={id}>{id} - {name}</option>;
                })}
              </Select>
            </Field>
            <Field label="To Store">
              <Select value={toStore} onChange={(e) => setToStore(e.target.value)}>
                <option value="">(select)</option>
                {stores.map((s, i) => {
                  const id = String(s[storeKeys.idKey] ?? '');
                  const name = String(s[storeKeys.nameKey] ?? id);
                  return <option key={i} value={id}>{id} - {name}</option>;
                })}
              </Select>
            </Field>
          </div>

          <Field label="Item">
            <Select value={selectedItem} onChange={(e) => setSelectedItem(e.target.value)}>
              <option value="">(select)</option>
              {items.map((it, i) => {
                const id = String(it[itemKeys.idKey] ?? '');
                const name = String(it[itemKeys.nameKey] ?? id);
                return <option key={i} value={id}>{id} - {name}</option>;
              })}
            </Select>
          </Field>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <Button onClick={createHeader} disabled={busy}>1) Create Header</Button>
            <Button onClick={createDetail} disabled={busy}>2) Add Detail</Button>
            <Button onClick={postTransfer} disabled={busy}>3) Post/Validate</Button>
            <Button onClick={loadLookups} disabled={busy}>Reload lookups</Button>
          </div>

          <div style={{ color: '#666', fontSize: 12, marginTop: 10 }}>
            Endpoints: <code>/api/inventory/transfers</code>, <code>/api/inventory/transfer-details</code>, <code>/api/inventory/post-transfer</code>
          </div>
        </div>
      )}
    </div>
  );
}
