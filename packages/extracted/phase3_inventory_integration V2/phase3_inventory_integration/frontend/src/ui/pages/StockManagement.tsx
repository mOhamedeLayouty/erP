import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import Callout from '../components/Callout';
import DataTable from '../components/DataTable';
import { Button, Field, Select, TextInput, TextArea } from '../components/Form';
import { useToast } from '../components/Toast';

type Item = { item_id: string; item_name?: string; description?: string; store_id?: string; };
type Store = { store_id: string; store_name?: string; };
type Vendor = { vend_code: string; vend_name?: string; vend_name_a?: string; };

type Line = { item_id: string; qty: number; price?: number; exp?: string; notes?: string; };

function TabButton({ active, children, onClick }: any) {
  return (
    <button
      onClick={onClick}
      style={{
        padding: '8px 12px',
        borderRadius: 8,
        border: '1px solid #ddd',
        background: active ? '#f3f3f3' : 'white',
        cursor: 'pointer',
        marginRight: 8,
      }}
    >
      {children}
    </button>
  );
}

export default function StockManagement() {
  const api = useApi();
  const toast = useToast();

  const [tab, setTab] = useState<'po' | 'receipt' | 'issue' | 'transfer' | 'balance'>('po');

  const [items, setItems] = useState<Item[]>([]);
  const [stores, setStores] = useState<Store[]>([]);
  const [vendors, setVendors] = useState<Vendor[]>([]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // PO header
  const [poStore, setPoStore] = useState('');
  const [poVendor, setPoVendor] = useState('');
  const [poNotes, setPoNotes] = useState('');
  const [poLines, setPoLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);

  // Receipt header
  const [rcStore, setRcStore] = useState('');
  const [rcVendor, setRcVendor] = useState('');
  const [rcPoId, setRcPoId] = useState<string>('');
  const [rcNotes, setRcNotes] = useState('');
  const [rcLines, setRcLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);

  // Issue header
  const [isStore, setIsStore] = useState('');
  const [isType, setIsType] = useState('WS');
  const [isNotes, setIsNotes] = useState('');
  const [isLines, setIsLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);

  // Transfer header
  const [trFromStore, setTrFromStore] = useState('');
  const [trToLocation, setTrToLocation] = useState<string>('');
  const [trNotes, setTrNotes] = useState('');
  const [trLines, setTrLines] = useState<Line[]>([{ item_id: '', qty: 1, price: 0 }]);

  // Balance
  const [balStore, setBalStore] = useState('');
  const [balItem, setBalItem] = useState('');
  const [balRows, setBalRows] = useState<any[]>([]);

  const itemOptions = useMemo(() => items.map(i => ({ value: i.item_id, label: `${i.item_id} — ${i.item_name ?? ''}` })), [items]);
  const storeOptions = useMemo(() => stores.map(s => ({ value: s.store_id, label: `${s.store_id} — ${s.store_name ?? ''}` })), [stores]);
  const vendorOptions = useMemo(() => vendors.map(v => ({ value: v.vend_code, label: `${v.vend_code} — ${v.vend_name_a ?? v.vend_name ?? ''}` })), [vendors]);

  async function loadLookups() {
    setLoading(true);
    setError(null);
    try {
      const [it, st, vd] = await Promise.all([
        api.get<any>('/api/stock/items?limit=1000'),
        api.get<any>('/api/stock/stores?limit=500'),
        api.get<any>('/api/stock/vendors?limit=2000'),
      ]);
      setItems(it?.rows ?? []);
      setStores(st?.rows ?? []);
      setVendors(vd?.rows ?? []);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadLookups(); }, []);

  function updateLine(setter: any, lines: Line[], idx: number, patch: Partial<Line>) {
    const next = lines.map((l, i) => (i === idx ? { ...l, ...patch } : l));
    setter(next);
  }
  function addLine(setter: any, lines: Line[]) { setter([...lines, { item_id: '', qty: 1, price: 0 }]); }
  function removeLine(setter: any, lines: Line[], idx: number) { setter(lines.filter((_, i) => i !== idx)); }

  async function submitPO() {
    setLoading(true); setError(null);
    try {
      const header = { store_id: poStore, vend_code: poVendor, notes: poNotes };
      const lines = poLines.filter(l => l.item_id && l.qty);
      const r = await api.post<any>('/api/stock/ops/po', { header, lines });
      toast.success(`PO Created (buy_header=${r.buy_header})`);
      setPoNotes(''); setPoLines([{ item_id: '', qty: 1, price: 0 }]);
    } catch (e: any) { setError(e?.message ?? String(e)); }
    finally { setLoading(false); }
  }

  async function submitReceipt() {
    setLoading(true); setError(null);
    try {
      const header = { store_id: rcStore, vend_code: rcVendor || null, buy_headr: rcPoId ? Number(rcPoId) : null, notes: rcNotes };
      const lines = rcLines.filter(l => l.item_id && l.qty);
      const r = await api.post<any>('/api/stock/ops/receipt', { header, lines });
      toast.success(`Receipt Created (credit_header=${r.credit_header})`);
      setRcNotes(''); setRcLines([{ item_id: '', qty: 1, price: 0 }]); setRcPoId('');
    } catch (e: any) { setError(e?.message ?? String(e)); }
    finally { setLoading(false); }
  }

  async function submitIssue() {
    setLoading(true); setError(null);
    try {
      const header = { store_id: isStore, debit_type: isType, notes: isNotes };
      const lines = isLines.filter(l => l.item_id && l.qty);
      const r = await api.post<any>('/api/stock/ops/issue', { header, lines });
      toast.success(`Issue Created (debit_header=${r.debit_header})`);
      setIsNotes(''); setIsLines([{ item_id: '', qty: 1, price: 0 }]);
    } catch (e: any) { setError(e?.message ?? String(e)); }
    finally { setLoading(false); }
  }

  async function submitTransfer() {
    setLoading(true); setError(null);
    try {
      const header = { from_store_id: trFromStore, to_location_id: trToLocation, notes: trNotes };
      const lines = trLines.filter(l => l.item_id && l.qty);
      const r = await api.post<any>('/api/stock/ops/transfer', { header, lines });
      toast.success(`Transfer Created (credit_header=${r.credit_header})`);
      setTrNotes(''); setTrLines([{ item_id: '', qty: 1, price: 0 }]); setTrToLocation('');
    } catch (e: any) { setError(e?.message ?? String(e)); }
    finally { setLoading(false); }
  }

  async function loadBalance() {
    setLoading(true); setError(null);
    try {
      const qs = new URLSearchParams();
      if (balStore) qs.set('store_id', balStore);
      if (balItem) qs.set('item_id', balItem);
      const r = await api.get<any>(`/api/stock/ops/balance?${qs.toString()}`);
      setBalRows(r?.rows ?? []);
    } catch (e: any) { setError(e?.message ?? String(e)); }
    finally { setLoading(false); }
  }

  return (
    <div style={{ padding: 16 }}>
      <h2>Stock Control System — Workflows</h2>
      <p style={{ marginTop: 0, color: '#555' }}>
        Purchasing, Receipts (GRN), Issues, Transfers, and Balance Inquiry (Live via ODBC).
      </p>

      <div style={{ marginBottom: 12 }}>
        <TabButton active={tab === 'po'} onClick={() => setTab('po')}>Purchase Order</TabButton>
        <TabButton active={tab === 'receipt'} onClick={() => setTab('receipt')}>Receipt (GRN)</TabButton>
        <TabButton active={tab === 'issue'} onClick={() => setTab('issue')}>Issue</TabButton>
        <TabButton active={tab === 'transfer'} onClick={() => setTab('transfer')}>Transfer</TabButton>
        <TabButton active={tab === 'balance'} onClick={() => setTab('balance')}>Balance</TabButton>
        <Button style={{ marginLeft: 12 }} onClick={loadLookups} disabled={loading}>Reload Lookups</Button>
      </div>

      {error && <Callout kind="danger" title="Error">{error}</Callout>}
      {loading && <Callout kind="info" title="Working">Please wait…</Callout>}

      {tab === 'po' && (
        <section>
          <h3>Create Purchase Order</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <Field label="Store">
              <Select value={poStore} onChange={e => setPoStore(e.target.value)}>
                <option value="">-- select --</option>
                {storeOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Vendor">
              <Select value={poVendor} onChange={e => setPoVendor(e.target.value)}>
                <option value="">-- select --</option>
                {vendorOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Notes" style={{ gridColumn: '1 / -1' }}>
              <TextArea value={poNotes} onChange={e => setPoNotes(e.target.value)} />
            </Field>
          </div>

          <h4>Lines</h4>
          {poLines.map((ln, idx) => (
            <div key={idx} style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 2fr auto', gap: 8, marginBottom: 8 }}>
              <Select value={ln.item_id} onChange={e => updateLine(setPoLines, poLines, idx, { item_id: e.target.value })}>
                <option value="">-- item --</option>
                {itemOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
              <TextInput type="number" value={ln.qty} onChange={e => updateLine(setPoLines, poLines, idx, { qty: Number(e.target.value) })} />
              <TextInput type="number" value={ln.price ?? 0} onChange={e => updateLine(setPoLines, poLines, idx, { price: Number(e.target.value) })} />
              <TextInput placeholder="exp (optional)" value={ln.exp ?? ''} onChange={e => updateLine(setPoLines, poLines, idx, { exp: e.target.value })} />
              <Button onClick={() => removeLine(setPoLines, poLines, idx)} disabled={poLines.length === 1}>X</Button>
            </div>
          ))}
          <div style={{ display: 'flex', gap: 8 }}>
            <Button onClick={() => addLine(setPoLines, poLines)}>+ Add Line</Button>
            <Button onClick={submitPO} disabled={loading || !poStore || !poVendor}>Create PO</Button>
          </div>
        </section>
      )}

      {tab === 'receipt' && (
        <section>
          <h3>Create Receipt (GRN)</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
            <Field label="Store">
              <Select value={rcStore} onChange={e => setRcStore(e.target.value)}>
                <option value="">-- select --</option>
                {storeOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Vendor (optional)">
              <Select value={rcVendor} onChange={e => setRcVendor(e.target.value)}>
                <option value="">-- none --</option>
                {vendorOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Linked PO buy_header (optional)">
              <TextInput value={rcPoId} onChange={e => setRcPoId(e.target.value)} placeholder="e.g. 12345" />
            </Field>
            <Field label="Notes" style={{ gridColumn: '1 / -1' }}>
              <TextArea value={rcNotes} onChange={e => setRcNotes(e.target.value)} />
            </Field>
          </div>

          <h4>Lines</h4>
          {rcLines.map((ln, idx) => (
            <div key={idx} style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 2fr auto', gap: 8, marginBottom: 8 }}>
              <Select value={ln.item_id} onChange={e => updateLine(setRcLines, rcLines, idx, { item_id: e.target.value })}>
                <option value="">-- item --</option>
                {itemOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
              <TextInput type="number" value={ln.qty} onChange={e => updateLine(setRcLines, rcLines, idx, { qty: Number(e.target.value) })} />
              <TextInput type="number" value={ln.price ?? 0} onChange={e => updateLine(setRcLines, rcLines, idx, { price: Number(e.target.value) })} />
              <TextInput placeholder="exp (optional)" value={ln.exp ?? ''} onChange={e => updateLine(setRcLines, rcLines, idx, { exp: e.target.value })} />
              <Button onClick={() => removeLine(setRcLines, rcLines, idx)} disabled={rcLines.length === 1}>X</Button>
            </div>
          ))}
          <div style={{ display: 'flex', gap: 8 }}>
            <Button onClick={() => addLine(setRcLines, rcLines)}>+ Add Line</Button>
            <Button onClick={submitReceipt} disabled={loading || !rcStore}>Create Receipt</Button>
          </div>
        </section>
      )}

      {tab === 'issue' && (
        <section>
          <h3>Create Issue (Out)</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <Field label="Store">
              <Select value={isStore} onChange={e => setIsStore(e.target.value)}>
                <option value="">-- select --</option>
                {storeOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Debit Type">
              <Select value={isType} onChange={e => setIsType(e.target.value)}>
                <option value="WS">WS (Workshop)</option>
                <option value="SALE">SALE</option>
                <option value="ADJ">ADJ</option>
                <option value="OTHER">OTHER</option>
              </Select>
            </Field>
            <Field label="Notes" style={{ gridColumn: '1 / -1' }}>
              <TextArea value={isNotes} onChange={e => setIsNotes(e.target.value)} />
            </Field>
          </div>

          <h4>Lines</h4>
          {isLines.map((ln, idx) => (
            <div key={idx} style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 2fr auto', gap: 8, marginBottom: 8 }}>
              <Select value={ln.item_id} onChange={e => updateLine(setIsLines, isLines, idx, { item_id: e.target.value })}>
                <option value="">-- item --</option>
                {itemOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
              <TextInput type="number" value={ln.qty} onChange={e => updateLine(setIsLines, isLines, idx, { qty: Number(e.target.value) })} />
              <TextInput type="number" value={ln.price ?? 0} onChange={e => updateLine(setIsLines, isLines, idx, { price: Number(e.target.value) })} />
              <TextInput placeholder="exp (optional)" value={ln.exp ?? ''} onChange={e => updateLine(setIsLines, isLines, idx, { exp: e.target.value })} />
              <Button onClick={() => removeLine(setIsLines, isLines, idx)} disabled={isLines.length === 1}>X</Button>
            </div>
          ))}
          <div style={{ display: 'flex', gap: 8 }}>
            <Button onClick={() => addLine(setIsLines, isLines)}>+ Add Line</Button>
            <Button onClick={submitIssue} disabled={loading || !isStore}>Create Issue</Button>
          </div>
        </section>
      )}

      {tab === 'transfer' && (
        <section>
          <h3>Create Transfer</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <Field label="From Store">
              <Select value={trFromStore} onChange={e => setTrFromStore(e.target.value)}>
                <option value="">-- select --</option>
                {storeOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="To Location ID">
              <TextInput value={trToLocation} onChange={e => setTrToLocation(e.target.value)} placeholder="location_id_to" />
            </Field>
            <Field label="Notes" style={{ gridColumn: '1 / -1' }}>
              <TextArea value={trNotes} onChange={e => setTrNotes(e.target.value)} />
            </Field>
          </div>

          <h4>Lines</h4>
          {trLines.map((ln, idx) => (
            <div key={idx} style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 2fr auto', gap: 8, marginBottom: 8 }}>
              <Select value={ln.item_id} onChange={e => updateLine(setTrLines, trLines, idx, { item_id: e.target.value })}>
                <option value="">-- item --</option>
                {itemOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
              <TextInput type="number" value={ln.qty} onChange={e => updateLine(setTrLines, trLines, idx, { qty: Number(e.target.value) })} />
              <TextInput type="number" value={ln.price ?? 0} onChange={e => updateLine(setTrLines, trLines, idx, { price: Number(e.target.value) })} />
              <TextInput placeholder="exp (optional)" value={ln.exp ?? ''} onChange={e => updateLine(setTrLines, trLines, idx, { exp: e.target.value })} />
              <Button onClick={() => removeLine(setTrLines, trLines, idx)} disabled={trLines.length === 1}>X</Button>
            </div>
          ))}
          <div style={{ display: 'flex', gap: 8 }}>
            <Button onClick={() => addLine(setTrLines, trLines)}>+ Add Line</Button>
            <Button onClick={submitTransfer} disabled={loading || !trFromStore || !trToLocation}>Create Transfer</Button>
          </div>
        </section>
      )}

      {tab === 'balance' && (
        <section>
          <h3>Balance Inquiry</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr auto', gap: 12, alignItems: 'end' }}>
            <Field label="Store">
              <Select value={balStore} onChange={e => setBalStore(e.target.value)}>
                <option value="">-- any --</option>
                {storeOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Field label="Item">
              <Select value={balItem} onChange={e => setBalItem(e.target.value)}>
                <option value="">-- any --</option>
                {itemOptions.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </Select>
            </Field>
            <Button onClick={loadBalance} disabled={loading}>Load</Button>
          </div>

          <div style={{ marginTop: 12 }}>
            <DataTable rows={balRows} />
          </div>
        </section>
      )}
    </div>
  );
}
