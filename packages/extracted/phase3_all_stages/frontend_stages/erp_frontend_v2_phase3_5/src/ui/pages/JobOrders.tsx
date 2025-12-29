import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import JsonBox from '../components/JsonBox';
import Callout from '../components/Callout';

type Action = 'start'|'finish'|'cancel'|'control_ok'|'stock_approve';

export default function JobOrders() {
  const api = useApi();
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<any | null>(null);

  const [createPayload, setCreatePayload] = useState<string>(JSON.stringify({
    JobOrderID: "TEST-001",
    CustomerID: "",
    EqptID: "",
    OrderType: "",
    OrderStatus: "NEW",
    notes: "",
    service_center: 1,
    location_id: 1,
    sales_rep: ""
  }, null, 2));

  async function load() {
    setLoading(true); setError(null);
    try {
      const res = await api.get<any>('/api/job-orders');
      const data = res.data ?? res;
      setRows(Array.isArray(data) ? data : []);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  async function createJobOrder() {
    setBusy(true); setError(null);
    try {
      const body = JSON.parse(createPayload);
      await api.post<any>('/api/job-orders', body);
      await load();
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setBusy(false);
    }
  }

  async function runAction(action: Action) {
    if (!selected?.JobOrderID) {
      setError('Select a job order row first.');
      return;
    }
    setBusy(true); setError(null);
    try {
      await api.post<any>(`/api/job-orders/${encodeURIComponent(selected.JobOrderID)}/action`, { action });
      await load();
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  const selectedId = selected?.JobOrderID ?? '(none)';

  return (
    <div>
      <h3>Job Orders</h3>

      <Callout title="تشغيل أوامر الشغل (أهم مرحلة)">
        List + Create + Workflow Actions. الصلاحيات مؤجلة؛ لو backend شغال بـ <code>DEFER_RBAC=true</code> مش هتقف.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
        <button onClick={load} disabled={loading || busy}>Refresh</button>
        <div style={{ color: '#666', alignSelf: 'center' }}>Selected: <b>{selectedId}</b></div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: 14, alignItems: 'start' }}>
        <div>
          <DataTable rows={rows} onRowClick={setSelected} />
        </div>

        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10, marginBottom: 12 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Create Job Order</div>
            <JsonBox value={createPayload} onChange={setCreatePayload} rows={14} />
            <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              <button onClick={createJobOrder} disabled={busy}>Create</button>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Workflow Actions (selected row)</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              <button onClick={() => runAction('start')} disabled={busy}>start</button>
              <button onClick={() => runAction('finish')} disabled={busy}>finish</button>
              <button onClick={() => runAction('cancel')} disabled={busy}>cancel</button>
              <button onClick={() => runAction('control_ok')} disabled={busy}>control_ok</button>
              <button onClick={() => runAction('stock_approve')} disabled={busy}>stock_approve</button>
            </div>
            <div style={{ color: '#666', fontSize: 12, marginTop: 8 }}>
              Endpoint: <code>/api/job-orders/:JobOrderID/action</code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
