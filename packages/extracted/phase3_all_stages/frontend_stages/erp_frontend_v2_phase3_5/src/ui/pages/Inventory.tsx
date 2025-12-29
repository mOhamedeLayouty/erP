import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import JsonBox from '../components/JsonBox';
import Callout from '../components/Callout';

type Tab = 'stores'|'items'|'transfers'|'details'|'create';

export default function Inventory() {
  const api = useApi();
  const [tab, setTab] = useState<Tab>('stores');
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [transferHeaderPayload, setTransferHeaderPayload] = useState<string>(JSON.stringify({
    // IMPORTANT: use real locked column names from your DB header table
    transferid: "TR-001"
  }, null, 2));

  const [transferDetailPayload, setTransferDetailPayload] = useState<string>(JSON.stringify({
    // IMPORTANT: use real locked column names from your DB detail table
    transferid: "TR-001"
  }, null, 2));

  const [postTransferId, setPostTransferId] = useState("TR-001");

  async function load() {
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

  async function createHeader() {
    setBusy(true); setError(null);
    try {
      await api.post<any>('/api/inventory/transfers', JSON.parse(transferHeaderPayload));
      await load();
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setBusy(false); }
  }

  async function createDetail() {
    setBusy(true); setError(null);
    try {
      await api.post<any>('/api/inventory/transfer-details', JSON.parse(transferDetailPayload));
      await load();
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setBusy(false); }
  }

  async function postTransfer() {
    setBusy(true); setError(null);
    try {
      const res = await api.post<any>('/api/inventory/post-transfer', { transfer_id: postTransferId });
      alert(JSON.stringify(res, null, 2));
      await load();
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setBusy(false); }
  }

  useEffect(() => { if (tab !== 'create') load(); }, [tab, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Inventory</h3>

      <Callout title="تشغيل المخزن (Transfer Flow)">
        Create Header + Create Details + Post/Validate Transfer. لازم تبعت Payload بالأعمدة الحقيقية الموجودة في الـ locked schema.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        {(['stores','items','transfers','details','create'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} disabled={loading || busy || tab===t}>{t}</button>
        ))}
        {tab !== 'create' && <button onClick={load} disabled={loading || busy}>Refresh</button>}
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      {tab !== 'create' ? (
        <DataTable rows={rows} />
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Create Transfer Header</div>
            <div style={{ color: '#666', fontSize: 12, marginBottom: 8 }}>
              POST <code>/api/inventory/transfers</code>
            </div>
            <JsonBox value={transferHeaderPayload} onChange={setTransferHeaderPayload} rows={14} />
            <div style={{ marginTop: 10 }}>
              <button onClick={createHeader} disabled={busy}>Create Header</button>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Create Transfer Detail</div>
            <div style={{ color: '#666', fontSize: 12, marginBottom: 8 }}>
              POST <code>/api/inventory/transfer-details</code>
            </div>
            <JsonBox value={transferDetailPayload} onChange={setTransferDetailPayload} rows={14} />
            <div style={{ marginTop: 10 }}>
              <button onClick={createDetail} disabled={busy}>Create Detail</button>
            </div>
          </div>

          <div style={{ gridColumn: '1 / -1', border: '1px solid #eee', padding: 12, borderRadius: 10 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Post / Validate Transfer</div>
            <div style={{ color: '#666', fontSize: 12, marginBottom: 8 }}>
              POST <code>/api/inventory/post-transfer</code>
            </div>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
              <input value={postTransferId} onChange={(e) => setPostTransferId(e.target.value)} style={{ padding: 8, width: 260 }} />
              <button onClick={postTransfer} disabled={busy}>Post</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
