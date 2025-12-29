import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button } from '../components/Form';
import { useToast } from '../components/Toast';

type Tab = 'issue' | 'return';

export default function InventoryRequests() {
  const api = useApi();
  const toast = useToast();

  const [tab, setTab] = useState<Tab>('issue');
  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);
  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    setLoading(true); setError(null);
    try {
      const path = tab === 'issue' ? '/api/inventory/issue-requests' : '/api/inventory/return-requests';
      const res = await api.get<any>(path);
      setRows(res.data ?? res);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setLoading(false); }
  }

  async function loadDetails(row: any) {
    setBusy(true); setError(null);
    try {
      const id = tab === 'issue' ? Number(row?.debit_header) : Number(row?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/details`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/details`;
      const res = await api.get<any>(path);
      setDetails(res.data ?? res);
    } catch (e: any) {
      setDetails([]);
      setError(e?.message ?? String(e));
    } finally { setBusy(false); }
  }

  async function action(act: 'approve'|'reject'|'post'|'unpost') {
    if (!selected) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true); setError(null);
    try {
      const id = tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/action`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/action`;
      await api.post<any>(path, { action: act });
      toast.push({ type: 'success', message: `Action: ${act} on #${id}` });
      await load();
      await loadDetails(selected);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  useEffect(() => { load(); }, [tab, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Inventory Requests</h3>

      <Callout title="Phase 3.8 (طلبات الصرف/الارتجاع)">
        دي شاشة التشغيل الأساسية للـ Inventory: مراجعة الطلبات (Workshop Requests) + تفاصيلها + Actions (Approve/Reject/Post).
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        <Button onClick={() => setTab('issue')} disabled={tab==='issue' || busy || loading}>Issue Requests</Button>
        <Button onClick={() => setTab('return')} disabled={tab==='return' || busy || loading}>Return Requests</Button>
        <Button onClick={load} disabled={busy || loading}>Refresh</Button>
        <div style={{ color: '#666', alignSelf: 'center' }}>
          Selected: <b>{tab === 'issue' ? (selected?.debit_header ?? '(none)') : (selected?.credit_header ?? '(none)')}</b>
        </div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: 14, alignItems: 'start' }}>
        <div>
          <DataTable
            rows={rows}
            onRowClick={(r) => {
              setSelected(r);
              loadDetails(r);
            }}
          />
        </div>

        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Details</div>
            <DataTable rows={details} />
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Actions</div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={() => action('approve')} disabled={busy}>Approve</Button>
              <Button onClick={() => action('reject')} disabled={busy}>Reject</Button>
              <Button onClick={() => action('post')} disabled={busy}>Post</Button>
              <Button onClick={() => action('unpost')} disabled={busy}>Unpost</Button>
            </div>
            <div style={{ color: '#666', fontSize: 12, marginTop: 8 }}>
              Actions update <code>status</code> and <code>post_flag</code> in request headers.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
