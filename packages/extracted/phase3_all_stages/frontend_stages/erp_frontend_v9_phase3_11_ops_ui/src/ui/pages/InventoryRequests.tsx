import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button, Field, TextInput, Select } from '../components/Form';
import { useToast } from '../components/Toast';

type Tab = 'issue' | 'return';

export default function InventoryRequests() {
  const api = useApi();
  const toast = useToast();

  const [tab, setTab] = useState<Tab>('issue');
  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);
  const [selectedLine, setSelectedLine] = useState<any | null>(null);

  // Filters
  const [fStore, setFStore] = useState('');
  const [fJob, setFJob] = useState('');
  const [fStatus, setFStatus] = useState(''); // 0/1/2
  const [fPost, setFPost] = useState('');     // y/n
  const [fFrom, setFFrom] = useState('');
  const [fTo, setFTo] = useState('');

  // Reject note + bulk ids
  const [rejectNote, setRejectNote] = useState('');
  const [bulkLineIds, setBulkLineIds] = useState(''); // "1,2,3"

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function buildQuery() {
    const q: any = {};
    if (fStore) q.store_id = fStore;
    if (fJob) q.joborderid = fJob;
    if (fStatus !== '') q.status = fStatus;
    if (fPost) q.post_flag = fPost;
    if (fFrom) q.from = fFrom;
    if (fTo) q.to = fTo;
    const qs = new URLSearchParams(q).toString();
    return qs ? `?${qs}` : '';
  }

  async function load() {
    setLoading(true); setError(null);
    try {
      const base = tab === 'issue' ? '/api/inventory/issue-requests' : '/api/inventory/return-requests';
      const res = await api.get<any>(base + buildQuery());
      setRows(res.data ?? res);
      setSelected(null);
      setSelectedLine(null);
      setDetails([]);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setLoading(false); }
  }

  async function loadDetails(row: any) {
    setBusy(true); setError(null);
    setSelectedLine(null);
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

  async function headerAction(act: 'approve'|'reject'|'post'|'unpost') {
    if (!selected) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true); setError(null);
    try {
      const id = tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/action`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/action`;
      await api.post<any>(path, { action: act });
      toast.push({ type: 'success', message: `Header action: ${act} on #${id}` });
      await load();
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function lineAction(act: 'approve'|'reject') {
    if (!selected) return toast.push({ type: 'error', message: 'Select request row first' });
    if (!selectedLine) return toast.push({ type: 'error', message: 'Select line first' });

    setBusy(true); setError(null);
    try {
      const headerId = tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
      const lineId = tab === 'issue' ? Number(selectedLine?.debit_detail) : Number(selectedLine?.credit_detail);

      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/lines/${encodeURIComponent(String(lineId))}/action`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/lines/${encodeURIComponent(String(lineId))}/action`;

      const payload: any = { action: act };
      if (act === 'reject') {
        payload.reason = 'lost_of_sales';
        if (rejectNote) payload.note = rejectNote;
      }

      await api.post<any>(path, payload);
      toast.push({ type: 'success', message: `Line ${act} done (#${lineId})` });
      setRejectNote('');
      await loadDetails(selected);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function approveAllLines() {
    if (!selected) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true); setError(null);
    try {
      const headerId = tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/lines/approve-all`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/lines/approve-all`;
      await api.post<any>(path, {});
      toast.push({ type: 'success', message: `Approved all lines for #${headerId}` });
      await loadDetails(selected);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  function parseBulkIds(): number[] {
    return (bulkLineIds || '')
      .split(',')
      .map(x => x.trim())
      .filter(Boolean)
      .map(x => Number(x))
      .filter(n => Number.isFinite(n) && n > 0);
  }

  async function bulkReject() {
    if (!selected) return toast.push({ type: 'error', message: 'Select request row first' });
    const ids = parseBulkIds();
    if (!ids.length) return toast.push({ type: 'error', message: 'Enter line ids like 1,2,3' });

    setBusy(true); setError(null);
    try {
      const headerId = tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/lines/reject`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/lines/reject`;
      await api.post<any>(path, { line_ids: ids, reason: 'lost_of_sales', note: rejectNote || undefined });
      toast.push({ type: 'success', message: `Rejected ${ids.length} line(s) for #${headerId}` });
      setBulkLineIds('');
      setRejectNote('');
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

      <Callout title="Phase 3.11 (Ops)">
        Filters + Approve All Lines + Bulk Reject (lost_of_sales). Posting remains on header (Phase 3.9).
      </Callout>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
        <div style={{ fontWeight: 900, marginBottom: 8 }}>Filters</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, minmax(120px, 1fr))', gap: 10 }}>
          <Field label="Store"><TextInput value={fStore} onChange={(e) => setFStore(e.target.value)} placeholder="1" /></Field>
          <Field label="JobOrderID"><TextInput value={fJob} onChange={(e) => setFJob(e.target.value)} placeholder="JOB-123" /></Field>
          <Field label="Status">
            <Select value={fStatus} onChange={(e) => setFStatus(e.target.value)}>
              <option value="">(any)</option>
              <option value="0">Pending</option>
              <option value="1">Approved</option>
              <option value="2">Rejected</option>
            </Select>
          </Field>
          <Field label="Post Flag">
            <Select value={fPost} onChange={(e) => setFPost(e.target.value)}>
              <option value="">(any)</option>
              <option value="n">Not Posted</option>
              <option value="y">Posted</option>
            </Select>
          </Field>
          <Field label="From"><TextInput type="date" value={fFrom} onChange={(e) => setFFrom(e.target.value)} /></Field>
          <Field label="To"><TextInput type="date" value={fTo} onChange={(e) => setFTo(e.target.value)} /></Field>
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 10, flexWrap: 'wrap' }}>
          <Button onClick={() => setTab('issue')} disabled={tab==='issue' || busy || loading}>Issue</Button>
          <Button onClick={() => setTab('return')} disabled={tab==='return' || busy || loading}>Return</Button>
          <Button onClick={load} disabled={busy || loading}>Apply</Button>
          <Button onClick={() => { setFStore(''); setFJob(''); setFStatus(''); setFPost(''); setFFrom(''); setFTo(''); }} disabled={busy || loading}>Clear</Button>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: 14, alignItems: 'start' }}>
        <div>
          <div style={{ color: '#666', fontSize: 12, marginBottom: 6 }}>Requests (click row)</div>
          <DataTable rows={rows} onRowClick={(r) => { setSelected(r); loadDetails(r); }} />
        </div>

        <div>
          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Details (click line)</div>
            <DataTable rows={details} onRowClick={(r) => setSelectedLine(r)} />
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Header Actions</div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={() => headerAction('approve')} disabled={busy}>Approve</Button>
              <Button onClick={() => headerAction('reject')} disabled={busy}>Reject</Button>
              <Button onClick={() => headerAction('post')} disabled={busy}>Post</Button>
              <Button onClick={() => headerAction('unpost')} disabled={busy}>Unpost</Button>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Line Ops</div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="Reject note (optional)"><TextInput value={rejectNote} onChange={(e) => setRejectNote(e.target.value)} /></Field>
              <Field label="Bulk line ids (comma)"><TextInput value={bulkLineIds} onChange={(e) => setBulkLineIds(e.target.value)} placeholder="1,2,3" /></Field>
            </div>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 10 }}>
              <Button onClick={() => lineAction('approve')} disabled={busy}>Approve Selected Line</Button>
              <Button onClick={() => lineAction('reject')} disabled={busy}>Reject Selected Line</Button>
              <Button onClick={approveAllLines} disabled={busy}>Approve All Lines</Button>
              <Button onClick={bulkReject} disabled={busy}>Bulk Reject (IDs)</Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
