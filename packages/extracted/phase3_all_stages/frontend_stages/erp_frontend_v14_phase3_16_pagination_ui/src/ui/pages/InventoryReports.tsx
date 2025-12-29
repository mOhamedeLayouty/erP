import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button, Field, TextInput, Select } from '../components/Form';
import { useToast } from '../components/Toast';

type Tab = 'lost' | 'balances' | 'card' | 'posted';

export default function InventoryReports() {
  const api = useApi();
  const toast = useToast();
  const [tab, setTab] = useState<Tab>('lost');

  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [header, setHeader] = useState<any | null>(null);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [storeId, setStoreId] = useState('1');
  const [itemId, setItemId] = useState('');
  const [docType, setDocType] = useState<'issue'|'return'>('issue');
  const [docNo, setDocNo] = useState('');

  async function load() {
    setLoading(true); setError(null);
    try {
      if (tab === 'lost') {
        const res = await api.get<any>('/api/inventory/lost-sales');
        setRows(res.data ?? res);
        setDetails([]); setHeader(null);
      } else if (tab === 'balances') {
        const res = await api.get<any>('/api/inventory/balances');
        setRows(res.data ?? res);
        setDetails([]); setHeader(null);
      } else if (tab === 'card') {
        if (!itemId) return toast.push({ type: 'error', message: 'Enter item_id first' });
        const res = await api.get<any>(`/api/inventory/item-card?store_id=${encodeURIComponent(storeId)}&item_id=${encodeURIComponent(itemId)}`);
        setRows(res.data ?? res);
        setDetails([]); setHeader(null);
      } else if (tab === 'posted') {
        if (!docNo) return toast.push({ type: 'error', message: 'Enter doc no first' });
        const path = docType === 'issue'
          ? `/api/inventory/posted-issue/${encodeURIComponent(docNo)}`
          : `/api/inventory/posted-return/${encodeURIComponent(docNo)}`;
        const res = await api.get<any>(path);
        const data = res.data ?? res;
        setHeader(data.header ?? null);
        setDetails(data.details ?? []);
        setRows([]);
      }
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setLoading(false); }
  }

  useEffect(() => { load(); }, [tab, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Inventory Reports</h3>
      <Callout title="Phase 3.10 (Visibility)">
        تقارير تشغيل المخزن: Lost of Sales + Balances + Item Card + View Posted Docs.
      </Callout>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 10 }}>
        <Button onClick={() => setTab('lost')} disabled={tab==='lost' || loading}>Lost of Sales</Button>
        <Button onClick={() => setTab('balances')} disabled={tab==='balances' || loading}>Balances</Button>
        <Button onClick={() => setTab('card')} disabled={tab==='card' || loading}>Item Card</Button>
        <Button onClick={() => setTab('posted')} disabled={tab==='posted' || loading}>Posted Doc</Button>
        <Button onClick={load} disabled={loading}>Refresh</Button>
      </div>

      {tab === 'card' && (
        <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginBottom: 10 }}>
          <Field label="Store">
            <TextInput value={storeId} onChange={(e) => setStoreId(e.target.value)} />
          </Field>
          <Field label="Item ID">
            <TextInput value={itemId} onChange={(e) => setItemId(e.target.value)} placeholder="ITM-01" />
          </Field>
          <div style={{ alignSelf: 'end' }}>
            <Button onClick={load} disabled={loading}>Load Card</Button>
          </div>
        </div>
      )}

      {tab === 'posted' && (
        <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginBottom: 10 }}>
          <Field label="Doc Type">
            <Select value={docType} onChange={(e) => setDocType(e.target.value as any)}>
              <option value="issue">Issue (Debit)</option>
              <option value="return">Return (Credit)</option>
            </Select>
          </Field>
          <Field label="Doc No">
            <TextInput value={docNo} onChange={(e) => setDocNo(e.target.value)} placeholder="123" />
          </Field>
          <div style={{ alignSelf: 'end' }}>
            <Button onClick={load} disabled={loading}>Load Doc</Button>
          </div>
        </div>
      )}

      {tab !== 'posted' && <DataTable rows={rows} />}

      {tab === 'posted' && (
        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Header</div>
            <DataTable rows={header ? [header] : []} />
          </div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Details</div>
            <DataTable rows={details} />
          </div>
        </div>
      )}
    </div>
  );
}
