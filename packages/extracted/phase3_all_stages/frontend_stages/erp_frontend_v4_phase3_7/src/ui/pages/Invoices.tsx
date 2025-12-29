import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Field, TextInput, Select, Button } from '../components/Form';
import { useToast } from '../components/Toast';

type Line = {
  InvoiceID: string;
  ItemID?: string;
  Qty: number;
  UnitPrice: number;
  LineTotal: number;
};

export default function Invoices() {
  const api = useApi();
  const toast = useToast();

  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);

  const [items, setItems] = useState<any[]>([]);

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Header form
  const [InvoiceID, setInvoiceID] = useState('INV-001');
  const [CustomerID, setCustomerID] = useState('');
  const [EqptID, setEqptID] = useState('');
  const [JobOrderID, setJobOrderID] = useState('');
  const [Status, setStatus] = useState('NEW');

  // Lines
  const [lines, setLines] = useState<Line[]>([
    { InvoiceID: 'INV-001', ItemID: '', Qty: 1, UnitPrice: 0, LineTotal: 0 }
  ]);

  const itemOptions = useMemo(() => {
    const idKey = items.length ? (Object.keys(items[0]).find(k => k.toLowerCase().includes('item')) ?? 'ItemID') : 'ItemID';
    const nameKey = items.length ? (Object.keys(items[0]).find(k => k.toLowerCase().includes('name')) ?? idKey) : idKey;
    return { idKey, nameKey };
  }, [items]);

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

  async function loadItems() {
    try {
      const res = await api.get<any>('/api/inventory/items');
      const data = res.data ?? res;
      setItems(Array.isArray(data) ? data : []);
    } catch {
      // keep optional
    }
  }

  useEffect(() => {
    load();
    loadItems();
  }, [api.baseUrl, api.token]);

  function recalc(i: number, patch: Partial<Line>) {
    setLines((prev) => {
      const next = [...prev];
      const cur = { ...next[i], ...patch };
      cur.InvoiceID = InvoiceID;
      cur.LineTotal = Number(cur.Qty || 0) * Number(cur.UnitPrice || 0);
      next[i] = cur;
      return next;
    });
  }

  function addLine() {
    setLines((x) => [...x, { InvoiceID, ItemID: '', Qty: 1, UnitPrice: 0, LineTotal: 0 }]);
  }

  function removeLine(i: number) {
    setLines((x) => x.filter((_, idx) => idx !== i));
  }

  async function createInvoiceFull() {
    if (!InvoiceID.trim()) {
      toast.push({ type: 'error', message: 'InvoiceID is required' });
      return;
    }
    if (!lines.length) {
      toast.push({ type: 'error', message: 'Add at least 1 line' });
      return;
    }

    setBusy(true); setError(null);
    try {
      const header: any = {
        InvoiceID: InvoiceID.trim(),
        CustomerID: CustomerID || undefined,
        EqptID: EqptID || undefined,
        JobOrderID: JobOrderID || undefined,
        Status: Status || undefined,
        user_id: 'SYSTEM'
      };

      // Send lines with basic keys (locked columns filtering is handled by backend)
      const detailsPayload = lines.map((l) => ({
        InvoiceID: InvoiceID.trim(),
        ItemID: l.ItemID || undefined,
        Qty: Number(l.Qty || 0),
        UnitPrice: Number(l.UnitPrice || 0),
        LineTotal: Number(l.LineTotal || 0)
      }));

      await api.post<any>('/api/invoicing/invoice-full', { header, details: detailsPayload });
      toast.push({ type: 'success', message: `Invoice created: ${InvoiceID}` });
      await load();
      await loadDetails(InvoiceID.trim());
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div>
      <h3>Invoices</h3>

      <Callout title="Phase 3.6 (تشغيل فواتير)">
        Create Invoice Full ب Form حقيقي + Lines add/remove + اختيار Item (لو items endpoint متاح).
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
        <Button onClick={load} disabled={loading || busy}>Refresh</Button>
        <div style={{ color: '#666', alignSelf: 'center' }}>Selected: <b>{selected?.InvoiceID ?? '(none)'}</b></div>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.05fr 0.95fr', gap: 14, alignItems: 'start' }}>
        <div>
          <div style={{ marginBottom: 10, color: '#666', fontSize: 12 }}>
            Click invoice row to load details.
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
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 800, marginBottom: 8 }}>Invoice Details (selected)</div>
            <DataTable rows={details} />
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 800, marginBottom: 8 }}>Create Invoice Full</div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="InvoiceID *">
                <TextInput value={InvoiceID} onChange={(e) => { setInvoiceID(e.target.value); setLines(ls => ls.map(x => ({ ...x, InvoiceID: e.target.value }))); }} />
              </Field>
              <Field label="Status">
                <TextInput value={Status} onChange={(e) => setStatus(e.target.value)} />
              </Field>
            </div>

            <Field label="CustomerID">
              <TextInput value={CustomerID} onChange={(e) => setCustomerID(e.target.value)} />
            </Field>
            <Field label="EqptID">
              <TextInput value={EqptID} onChange={(e) => setEqptID(e.target.value)} />
            </Field>
            <Field label="JobOrderID">
              <TextInput value={JobOrderID} onChange={(e) => setJobOrderID(e.target.value)} />
            </Field>

            <div style={{ fontWeight: 800, margin: '10px 0 6px' }}>Lines</div>
            {lines.map((l, idx) => (
              <div key={idx} style={{ border: '1px solid #f0f0f0', padding: 10, borderRadius: 12, marginBottom: 10 }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: 10 }}>
                  <Field label="ItemID">
                    <Select value={l.ItemID ?? ''} onChange={(e) => recalc(idx, { ItemID: e.target.value })}>
                      <option value="">(select)</option>
                      {items.map((it, i) => {
                        const id = String(it[itemOptions.idKey] ?? '');
                        const name = String(it[itemOptions.nameKey] ?? id);
                        return <option key={i} value={id}>{id} - {name}</option>;
                      })}
                    </Select>
                  </Field>
                  <Field label="Qty">
                    <TextInput type="number" value={l.Qty} onChange={(e) => recalc(idx, { Qty: Number(e.target.value) })} />
                  </Field>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  <Field label="UnitPrice">
                    <TextInput type="number" value={l.UnitPrice} onChange={(e) => recalc(idx, { UnitPrice: Number(e.target.value) })} />
                  </Field>
                  <Field label="LineTotal">
                    <TextInput type="number" value={l.LineTotal} readOnly />
                  </Field>
                </div>

                <div style={{ display: 'flex', gap: 8 }}>
                  <Button onClick={() => removeLine(idx)} disabled={busy}>Remove line</Button>
                </div>
              </div>
            ))}

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={addLine} disabled={busy}>Add line</Button>
              <Button onClick={createInvoiceFull} disabled={busy}>Create Invoice</Button>
            </div>

            <div style={{ color: '#666', fontSize: 12, marginTop: 8 }}>
              Endpoint: <code>/api/invoicing/invoice-full</code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
