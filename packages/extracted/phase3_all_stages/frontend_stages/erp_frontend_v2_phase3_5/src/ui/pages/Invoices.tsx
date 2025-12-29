import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import JsonBox from '../components/JsonBox';
import Callout from '../components/Callout';

export default function Invoices() {
  const api = useApi();
  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [fullPayload, setFullPayload] = useState<string>(JSON.stringify({
    header: {
      InvoiceID: "INV-001",
      CustomerID: "",
      EqptID: "",
      JobOrderID: "",
      Status: "NEW",
      user_id: "SYSTEM"
    },
    details: [
      {
        InvoiceID: "INV-001",
        ItemID: "",
        Qty: 1,
        UnitPrice: 0,
        LineTotal: 0
      }
    ]
  }, null, 2));

  async function load() {
    setLoading(true); setError(null);
    try {
      const res = await api.get<any>('/api/invoicing/invoices');
      const data = res.data ?? res;
      setRows(Array.isArray(data) ? data : []);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  async function loadDetails(invoiceId: string) {
    setBusy(true); setError(null);
    try {
      const res = await api.get<any>(`/api/invoicing/invoices/${encodeURIComponent(invoiceId)}/details`);
      const data = res.data ?? res;
      setDetails(Array.isArray(data) ? data : []);
    } catch (e: any) {
      setError(e?.message ?? String(e));
      setDetails([]);
    } finally {
      setBusy(false);
    }
  }

  async function createInvoiceFull() {
    setBusy(true); setError(null);
    try {
      const body = JSON.parse(fullPayload);
      await api.post<any>('/api/invoicing/invoice-full', body);
      await load();
      const invId = body?.header?.InvoiceID;
      if (invId) await loadDetails(String(invId));
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  const selectedId = selected?.InvoiceID ?? '(none)';

  return (
    <div>
      <h3>Invoices</h3>

      <Callout title="تشغيل الفواتير">
        List + Details + Create Invoice Full (Header + Details).
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
        <button onClick={load} disabled={loading || busy}>Refresh</button>
        <div style={{ color: '#666', alignSelf: 'center' }}>Selected: <b>{selectedId}</b></div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: 14, alignItems: 'start' }}>
        <div>
          <div style={{ marginBottom: 10, color: '#666', fontSize: 12 }}>
            Click an invoice row to load details.
          </div>
          <DataTable
            rows={rows}
            onRowClick={(r) => {
              setSelected(r);
              if (r?.InvoiceID) loadDetails(String(r.InvoiceID));
            }}
          />
        </div>

        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10, marginBottom: 12 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Invoice Details (selected)</div>
            <DataTable rows={details} />
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 10 }}>
            <div style={{ fontWeight: 700, marginBottom: 6 }}>Create Invoice Full</div>
            <div style={{ color: '#666', fontSize: 12, marginBottom: 8 }}>
              POST <code>/api/invoicing/invoice-full</code>
            </div>
            <JsonBox value={fullPayload} onChange={setFullPayload} rows={16} />
            <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              <button onClick={createInvoiceFull} disabled={busy}>Create</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
