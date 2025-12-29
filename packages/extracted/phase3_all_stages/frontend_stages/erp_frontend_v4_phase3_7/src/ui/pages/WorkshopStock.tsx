import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Field, TextInput, Select, Button } from '../components/Form';
import { useToast } from '../components/Toast';

type Line = { item_id: string; qty: number; price?: number; notes?: string };

export default function WorkshopStock() {
  const api = useApi();
  const toast = useToast();

  const [jobOrders, setJobOrders] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);
  const [stores, setStores] = useState<any[]>([]);
  const [items, setItems] = useState<any[]>([]);

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Issue (صرف)
  const [issueStoreId, setIssueStoreId] = useState('');
  const [issueLines, setIssueLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);
  const [issueNotes, setIssueNotes] = useState('');

  // Return (ارتجاع)
  const [returnStoreId, setReturnStoreId] = useState('');
  const [returnLines, setReturnLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);
  const [returnNotes, setReturnNotes] = useState('');

  const storeKeys = useMemo(() => {
    const s = stores[0] ?? {};
    const idKey = Object.keys(s).find(k => k.toLowerCase().includes('store') && k.toLowerCase().includes('id')) || 'store_id';
    const nameKey = Object.keys(s).find(k => k.toLowerCase().includes('name')) || idKey;
    return { idKey, nameKey };
  }, [stores]);

  const itemKeys = useMemo(() => {
    const s = items[0] ?? {};
    const idKey = Object.keys(s).find(k => k.toLowerCase().includes('item')) || 'ItemID';
    const nameKey = Object.keys(s).find(k => k.toLowerCase().includes('name')) || idKey;
    return { idKey, nameKey };
  }, [items]);

  async function load() {
    setLoading(true); setError(null);
    try {
      const [jo, st, it] = await Promise.all([
        api.get<any>('/api/job-orders'),
        api.get<any>('/api/inventory/stores'),
        api.get<any>('/api/inventory/items')
      ]);
      setJobOrders(Array.isArray(jo?.data ?? jo) ? (jo.data ?? jo) : []);
      setStores(Array.isArray(st?.data ?? st) ? (st.data ?? st) : []);
      setItems(Array.isArray(it?.data ?? it) ? (it.data ?? it) : []);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  function updateIssueLine(i: number, patch: Partial<Line>) {
    setIssueLines((prev) => {
      const next = [...prev];
      next[i] = { ...next[i], ...patch };
      return next;
    });
  }
  function addIssueLine() {
    setIssueLines((x) => [...x, { item_id: '', qty: 1, price: 0 }]);
  }
  function removeIssueLine(i: number) {
    setIssueLines((x) => x.filter((_, idx) => idx !== i));
  }

  function updateReturnLine(i: number, patch: Partial<Line>) {
    setReturnLines((prev) => {
      const next = [...prev];
      next[i] = { ...next[i], ...patch };
      return next;
    });
  }
  function addReturnLine() {
    setReturnLines((x) => [...x, { item_id: '', qty: 1, price: 0 }]);
  }
  function removeReturnLine(i: number) {
    setReturnLines((x) => x.filter((_, idx) => idx !== i));
  }

  async function submitIssue() {
    const id = selected?.JobOrderID;
    if (!id) return toast.push({ type: 'error', message: 'Select JobOrder first' });
    if (!issueStoreId) return toast.push({ type: 'error', message: 'Select Store for Issue' });
    const lines = issueLines.filter(l => l.item_id && Number(l.qty) > 0);
    if (!lines.length) return toast.push({ type: 'error', message: 'Add at least 1 valid issue line' });

    setBusy(true); setError(null);
    try {
      await api.post<any>(`/api/workshop/job-orders/${encodeURIComponent(String(id))}/issue`, {
        store_id: Number(issueStoreId),
        notes: issueNotes || undefined,
        lines
      });
      toast.push({ type: 'success', message: `Issued ${lines.length} line(s) for JobOrder ${id}` });
      setIssueNotes('');
      setIssueLines([{ item_id: '', qty: 1, price: 0 }]);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function submitReturn() {
    const id = selected?.JobOrderID;
    if (!id) return toast.push({ type: 'error', message: 'Select JobOrder first' });
    if (!returnStoreId) return toast.push({ type: 'error', message: 'Select Store for Return' });
    const lines = returnLines.filter(l => l.item_id && Number(l.qty) > 0);
    if (!lines.length) return toast.push({ type: 'error', message: 'Add at least 1 valid return line' });

    setBusy(true); setError(null);
    try {
      await api.post<any>(`/api/workshop/job-orders/${encodeURIComponent(String(id))}/return`, {
        store_id: Number(returnStoreId),
        notes: returnNotes || undefined,
        lines
      });
      toast.push({ type: 'success', message: `Returned ${lines.length} line(s) for JobOrder ${id}` });
      setReturnNotes('');
      setReturnLines([{ item_id: '', qty: 1, price: 0 }]);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  return (
    <div>
      <h3>Workshop ↔ Inventory</h3>

      <Callout title="Phase 3.7 (صرف/ارتجاع مرتبط بالـ Workshop)">
        دي أهم علاقة تشغيل: أي صرف قطع للـ Job Order لازم يطلع من المخزن (Debit)، وأي ارتجاع يرجع للمخزن (Credit).
        هنا بنبعت عمليات تشغيل على endpoints مخصصة للـ Workshop.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        <Button onClick={load} disabled={loading || busy}>Reload</Button>
        <div style={{ color: '#666', alignSelf: 'center' }}>
          Selected JobOrder: <b>{selected?.JobOrderID ?? '(none)'}</b>
        </div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: 14, alignItems: 'start' }}>
        <div>
          <div style={{ marginBottom: 8, color: '#666', fontSize: 12 }}>
            Click JobOrder row to operate Issue/Return.
          </div>
          <DataTable rows={jobOrders} onRowClick={setSelected} />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Issue (صرف من المخزن)</div>

            <Field label="Store *">
              <Select value={issueStoreId} onChange={(e) => setIssueStoreId(e.target.value)}>
                <option value="">(select)</option>
                {stores.map((s, i) => {
                  const id = String(s[storeKeys.idKey] ?? '');
                  const name = String(s[storeKeys.nameKey] ?? id);
                  return <option key={i} value={id}>{id} - {name}</option>;
                })}
              </Select>
            </Field>

            {issueLines.map((l, idx) => (
              <div key={idx} style={{ border: '1px solid #f0f0f0', borderRadius: 12, padding: 10, marginBottom: 10 }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1.3fr 0.7fr', gap: 10 }}>
                  <Field label="Item *">
                    <Select value={l.item_id} onChange={(e) => updateIssueLine(idx, { item_id: e.target.value })}>
                      <option value="">(select)</option>
                      {items.map((it, i) => {
                        const id = String(it[itemKeys.idKey] ?? '');
                        const name = String(it[itemKeys.nameKey] ?? id);
                        return <option key={i} value={id}>{id} - {name}</option>;
                      })}
                    </Select>
                  </Field>
                  <Field label="Qty *">
                    <TextInput type="number" value={l.qty} onChange={(e) => updateIssueLine(idx, { qty: Number(e.target.value) })} />
                  </Field>
                </div>

                <Field label="Price (optional)">
                  <TextInput type="number" value={l.price ?? 0} onChange={(e) => updateIssueLine(idx, { price: Number(e.target.value) })} />
                </Field>

                <div style={{ display: 'flex', gap: 8 }}>
                  <Button onClick={() => removeIssueLine(idx)} disabled={busy}>Remove</Button>
                </div>
              </div>
            ))}

            <Field label="Notes">
              <TextInput value={issueNotes} onChange={(e) => setIssueNotes(e.target.value)} />
            </Field>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={addIssueLine} disabled={busy}>Add Line</Button>
              <Button onClick={submitIssue} disabled={busy}>Submit Issue</Button>
            </div>

            <div style={{ color: '#666', fontSize: 12, marginTop: 8 }}>
              POST <code>/api/workshop/job-orders/:JobOrderID/issue</code>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Return (ارتجاع للمخزن)</div>

            <Field label="Store *">
              <Select value={returnStoreId} onChange={(e) => setReturnStoreId(e.target.value)}>
                <option value="">(select)</option>
                {stores.map((s, i) => {
                  const id = String(s[storeKeys.idKey] ?? '');
                  const name = String(s[storeKeys.nameKey] ?? id);
                  return <option key={i} value={id}>{id} - {name}</option>;
                })}
              </Select>
            </Field>

            {returnLines.map((l, idx) => (
              <div key={idx} style={{ border: '1px solid #f0f0f0', borderRadius: 12, padding: 10, marginBottom: 10 }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1.3fr 0.7fr', gap: 10 }}>
                  <Field label="Item *">
                    <Select value={l.item_id} onChange={(e) => updateReturnLine(idx, { item_id: e.target.value })}>
                      <option value="">(select)</option>
                      {items.map((it, i) => {
                        const id = String(it[itemKeys.idKey] ?? '');
                        const name = String(it[itemKeys.nameKey] ?? id);
                        return <option key={i} value={id}>{id} - {name}</option>;
                      })}
                    </Select>
                  </Field>
                  <Field label="Qty *">
                    <TextInput type="number" value={l.qty} onChange={(e) => updateReturnLine(idx, { qty: Number(e.target.value) })} />
                  </Field>
                </div>

                <Field label="Price (optional)">
                  <TextInput type="number" value={l.price ?? 0} onChange={(e) => updateReturnLine(idx, { price: Number(e.target.value) })} />
                </Field>

                <div style={{ display: 'flex', gap: 8 }}>
                  <Button onClick={() => removeReturnLine(idx)} disabled={busy}>Remove</Button>
                </div>
              </div>
            ))}

            <Field label="Notes">
              <TextInput value={returnNotes} onChange={(e) => setReturnNotes(e.target.value)} />
            </Field>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={addReturnLine} disabled={busy}>Add Line</Button>
              <Button onClick={submitReturn} disabled={busy}>Submit Return</Button>
            </div>

            <div style={{ color: '#666', fontSize: 12, marginTop: 8 }}>
              POST <code>/api/workshop/job-orders/:JobOrderID/return</code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
