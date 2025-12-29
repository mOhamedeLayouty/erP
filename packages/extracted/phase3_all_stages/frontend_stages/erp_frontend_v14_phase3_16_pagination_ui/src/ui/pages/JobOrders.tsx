import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Field, TextInput, Button } from '../components/Form';
import { useToast } from '../components/Toast';

type Action = 'start'|'finish'|'cancel'|'control_ok'|'stock_approve';

export default function JobOrders() {
  const api = useApi();
  const toast = useToast();

  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<any | null>(null);

  // Form state
  const [JobOrderID, setJobOrderID] = useState('TEST-001');
  const [CustomerID, setCustomerID] = useState('');
  const [EqptID, setEqptID] = useState('');
  const [OrderType, setOrderType] = useState('');
  const [notes, setNotes] = useState('');
  const [service_center, setServiceCenter] = useState('1');
  const [location_id, setLocationId] = useState('1');
  const [sales_rep, setSalesRep] = useState('');

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
    if (!JobOrderID.trim()) {
      toast.push({ type: 'error', message: 'JobOrderID is required' });
      return;
    }
    setBusy(true); setError(null);
    try {
      const body = {
        JobOrderID: JobOrderID.trim(),
        CustomerID: CustomerID || undefined,
        EqptID: EqptID || undefined,
        OrderType: OrderType || undefined,
        OrderStatus: 'NEW',
        notes: notes || undefined,
        service_center: Number(service_center || 1),
        location_id: Number(location_id || 1),
        sales_rep: sales_rep || undefined
      };
      await api.post<any>('/api/job-orders', body);
      toast.push({ type: 'success', message: `Job Order created: ${body.JobOrderID}` });
      await load();
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  async function runAction(action: Action) {
    const id = selected?.JobOrderID;
    if (!id) {
      toast.push({ type: 'error', message: 'Select a job order row first.' });
      return;
    }
    setBusy(true); setError(null);
    try {
      await api.post<any>(`/api/job-orders/${encodeURIComponent(String(id))}/action`, { action });
      toast.push({ type: 'success', message: `Action applied: ${action} on ${id}` });
      await load();
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  return (
    <div>
      <h3>Job Orders</h3>

      <Callout title="Phase 3.6 (تشغيل فعلي)">
        بدل JSON الخام: Form حقيقي + Validation بسيط + Toasts.
        الصلاحيات مؤجلة؛ لو backend شغال بـ <code>DEFER_RBAC=true</code> مش هتقف.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        <Button onClick={load} disabled={loading || busy}>Refresh</Button>
        <div style={{ color: '#666', alignSelf: 'center' }}>
          Selected: <b>{selected?.JobOrderID ?? '(none)'}</b>
        </div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.15fr 0.85fr', gap: 14, alignItems: 'start' }}>
        <div>
          <DataTable rows={rows} onRowClick={setSelected} />
        </div>

        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 800, marginBottom: 8 }}>Create Job Order</div>

            <Field label="JobOrderID *">
              <TextInput value={JobOrderID} onChange={(e) => setJobOrderID(e.target.value)} />
            </Field>
            <Field label="CustomerID">
              <TextInput value={CustomerID} onChange={(e) => setCustomerID(e.target.value)} />
            </Field>
            <Field label="EqptID">
              <TextInput value={EqptID} onChange={(e) => setEqptID(e.target.value)} />
            </Field>
            <Field label="OrderType">
              <TextInput value={OrderType} onChange={(e) => setOrderType(e.target.value)} />
            </Field>
            <Field label="notes">
              <TextInput value={notes} onChange={(e) => setNotes(e.target.value)} />
            </Field>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="service_center">
                <TextInput value={service_center} onChange={(e) => setServiceCenter(e.target.value)} />
              </Field>
              <Field label="location_id">
                <TextInput value={location_id} onChange={(e) => setLocationId(e.target.value)} />
              </Field>
            </div>

            <Field label="sales_rep">
              <TextInput value={sales_rep} onChange={(e) => setSalesRep(e.target.value)} />
            </Field>

            <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              <Button onClick={createJobOrder} disabled={busy}>Create</Button>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 800, marginBottom: 8 }}>Workflow Actions (selected row)</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              <Button onClick={() => runAction('start')} disabled={busy}>start</Button>
              <Button onClick={() => runAction('finish')} disabled={busy}>finish</Button>
              <Button onClick={() => runAction('cancel')} disabled={busy}>cancel</Button>
              <Button onClick={() => runAction('control_ok')} disabled={busy}>control_ok</Button>
              <Button onClick={() => runAction('stock_approve')} disabled={busy}>stock_approve</Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
