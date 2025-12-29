import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button, Field, TextInput, Select } from '../components/Form';
import { useToast } from '../components/Toast';
import HistoryPanel from '../components/HistoryPanel';

type Tab = 'issue' | 'return';

function downloadBlob(filename: string, contentType: string, data: string) {
  const blob = new Blob([data], { type: contentType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export default function InventoryRequests() {
  const api = useApi();
  const toast = useToast();

  const [tab, setTab] = useState<Tab>('issue');
  const [rows, setRows] = useState<any[]>([]);
  const [details, setDetails] = useState<any[]>([]);
  const [summary, setSummary] = useState<any | null>(null);
  const [postCheck, setPostCheck] = useState<any | null>(null);

  const [selected, setSelected] = useState<any | null>(null);
  const [selectedLine, setSelectedLine] = useState<any | null>(null);

  const [historyOpen, setHistoryOpen] = useState(false);
  const [historyRows, setHistoryRows] = useState<any[]>([]);

  // Filters
  const [fStore, setFStore] = useState('');
  const [fJob, setFJob] = useState('');
  const [fStatus, setFStatus] = useState(''); // 0/1/2
  const [fPost, setFPost] = useState('');     // y/n
  const [fFrom, setFFrom] = useState('');
  const [fTo, setFTo] = useState('');

  // Reject note + ids fallback + checkbox selection
  const [rejectNote, setRejectNote] = useState('');
  const [bulkLineIds, setBulkLineIds] = useState(''); // "1,2,3"
  const [checked, setChecked] = useState<Record<string, boolean>>({});

  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const headerId = useMemo(() => {
    if (!selected) return null;
    return tab === 'issue' ? Number(selected?.debit_header) : Number(selected?.credit_header);
  }, [selected, tab]);

  const checkedIds = useMemo(() => {
    const ids: number[] = [];
    for (const k of Object.keys(checked)) if (checked[k]) ids.push(Number(k));
    return ids.filter(n => Number.isFinite(n) && n > 0);
  }, [checked]);

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
      setSummary(null);
      setPostCheck(null);
      setChecked({});
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally { setLoading(false); }
  }

  async function loadSummary(id: number) {
    try {
      const sumPath = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/summary`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/summary`;
      const sumRes = await api.get<any>(sumPath);
      setSummary(sumRes.data ?? sumRes);
    } catch {
      setSummary(null);
    }
  }

  async function loadCanPost(id: number) {
    try {
      const canPath = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/can-post`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/can-post`;
      const canRes = await api.get<any>(canPath);
      setPostCheck(canRes.data ?? canRes);
    } catch {
      setPostCheck(null);
    }
  }

  async function loadDetails(row: any) {
    setBusy(true); setError(null);
    setSelectedLine(null);
    setChecked({});
    setSummary(null);
    setPostCheck(null);
    try {
      const id = tab === 'issue' ? Number(row?.debit_header) : Number(row?.credit_header);
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(id))}/details`
        : `/api/inventory/return-requests/${encodeURIComponent(String(id))}/details`;
      const res = await api.get<any>(path);
      setDetails(res.data ?? res);
      await loadSummary(id);
      await loadCanPost(id);
    } catch (e: any) {
      setDetails([]);
      setSummary(null);
      setPostCheck(null);
      setError(e?.message ?? String(e));
    } finally { setBusy(false); }
  }

  async function headerAction(act: 'approve'|'reject'|'post'|'unpost') {
    if (!selected || !headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true); setError(null);
    try {
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/action`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/action`;
      await api.post<any>(path, { action: act });
      toast.push({ type: 'success', message: `Header action: ${act} on #${headerId}` });
      await load();
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function lineAction(act: 'approve'|'reject') {
    if (!selected || !headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    if (!selectedLine) return toast.push({ type: 'error', message: 'Select line first' });

    setBusy(true); setError(null);
    try {
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
    if (!selected || !headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true); setError(null);
    try {
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

  function parseBulkIdsFallback(): number[] {
    return (bulkLineIds || '')
      .split(',')
      .map(x => x.trim())
      .filter(Boolean)
      .map(x => Number(x))
      .filter(n => Number.isFinite(n) && n > 0);
  }

  async function bulkReject() {
    if (!selected || !headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    const ids = checkedIds.length ? checkedIds : parseBulkIdsFallback();
    if (!ids.length) return toast.push({ type: 'error', message: 'Select lines by checkbox or enter ids like 1,2,3' });

    setBusy(true); setError(null);
    try {
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/lines/reject`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/lines/reject`;
      await api.post<any>(path, { line_ids: ids, reason: 'lost_of_sales', note: rejectNote || undefined });
      toast.push({ type: 'success', message: `Rejected ${ids.length} line(s) for #${headerId}` });
      setBulkLineIds('');
      setRejectNote('');
      setChecked({});
      await loadDetails(selected);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      toast.push({ type: 'error', message: msg });
      setError(msg);
    } finally { setBusy(false); }
  }

  async function exportCsv() {
    if (!headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    try {
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/export.csv`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/export.csv`;
      const res = await api.raw(path, { method: 'GET' });
      const text = await res.text();
      downloadBlob(`${tab}_request_${headerId}.csv`, 'text/csv', text);
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    }
  }

  function openPrint() {
    if (!headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    const path = tab === 'issue'
      ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/print`
      : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/print`;
    window.open(api.baseUrl + path, '_blank');
  }

  async function syncHeader() {
    if (!headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    setBusy(true);
    try {
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/sync`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/sync`;
      await api.post<any>(path, {});
      toast.push({ type: 'success', message: 'Header status synced from lines' });
      await loadSummary(headerId);
      await loadCanPost(headerId);
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    } finally {
      setBusy(false);
    }
  }

  async function fetchHistory() {
    if (!headerId) return toast.push({ type: 'error', message: 'Select request row first' });
    try {
      const path = tab === 'issue'
        ? `/api/inventory/issue-requests/${encodeURIComponent(String(headerId))}/history`
        : `/api/inventory/return-requests/${encodeURIComponent(String(headerId))}/history`;
      const res = await api.get<any>(path);
      setHistoryRows(res.data ?? res);
      setHistoryOpen(true);
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    }
  }

  useEffect(() => { load(); }, [tab, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Inventory Requests</h3>

      {historyOpen && (
        <HistoryPanel rows={historyRows} onClose={() => setHistoryOpen(false)} />
      )}

      <Callout title="Phase 3.15 (Posting Guards)">
        قبل الـ Post فيه Check (Header Approved + No Pending Lines + Not Posted). UI بتعرض Can Post + Reason.
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
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Details | Header: {headerId ?? '-'}</div>

            {summary && (
              <div style={{ color: '#666', fontSize: 12, marginBottom: 6 }}>
                Lines: <b>{summary.total}</b> | Approved: <b>{summary.approved}</b> | Rejected: <b>{summary.rejected}</b> | Pending: <b>{summary.pending}</b>
              </div>
            )}

            {postCheck && (
              <div style={{ color: postCheck.ok ? '#0a7' : '#c33', fontSize: 12, marginBottom: 10 }}>
                Can Post: <b>{String(postCheck.ok)}</b>{postCheck.reason ? ` | Reason: ${postCheck.reason}` : ''}
              </div>
            )}

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 10 }}>
              <Button onClick={() => {
                const all: any = {};
                for (const r of details) {
                  const id = tab === 'issue' ? r?.debit_detail : r?.credit_detail;
                  if (id) all[String(id)] = true;
                }
                setChecked(all);
              }} disabled={!details.length}>Select All</Button>
              <Button onClick={() => setChecked({})} disabled={!details.length}>Clear</Button>
              <div style={{ color: '#666', alignSelf: 'center' }}>
                Selected lines: <b>{checkedIds.length}</b>
              </div>
            </div>

            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr>
                  <th style={{ border: '1px solid #eee', padding: 6, width: 42 }}></th>
                  <th style={{ border: '1px solid #eee', padding: 6 }}>Line</th>
                  <th style={{ border: '1px solid #eee', padding: 6 }}>Item</th>
                  <th style={{ border: '1px solid #eee', padding: 6 }}>Qty</th>
                  <th style={{ border: '1px solid #eee', padding: 6 }}>Status</th>
                </tr>
              </thead>
              <tbody>
                {details.map((r) => {
                  const id = tab === 'issue' ? r?.debit_detail : r?.credit_detail;
                  const item = r?.item_id ?? r?.ItemID ?? r?.item ?? '';
                  const qty = r?.qty ?? r?.Qty ?? r?.quantity ?? '';
                  const st = r?.status ?? '';
                  const key = String(id ?? '');
                  return (
                    <tr key={key} onClick={() => setSelectedLine(r)} style={{ cursor: 'pointer' }}>
                      <td style={{ border: '1px solid #eee', padding: 6, textAlign: 'center' }} onClick={(e) => e.stopPropagation()}>
                        <input type="checkbox" checked={!!checked[key]} onChange={(e) => setChecked(prev => ({ ...prev, [key]: e.target.checked }))} />
                      </td>
                      <td style={{ border: '1px solid #eee', padding: 6 }}>{String(id ?? '')}</td>
                      <td style={{ border: '1px solid #eee', padding: 6 }}>{String(item)}</td>
                      <td style={{ border: '1px solid #eee', padding: 6 }}>{String(qty)}</td>
                      <td style={{ border: '1px solid #eee', padding: 6 }}>{String(st)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12, marginBottom: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Header Actions</div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button onClick={() => headerAction('approve')} disabled={busy}>Approve</Button>
              <Button onClick={() => headerAction('reject')} disabled={busy}>Reject</Button>
              <Button onClick={() => headerAction('post')} disabled={busy}>Post</Button>
              <Button onClick={() => headerAction('unpost')} disabled={busy}>Unpost</Button>
              <Button onClick={exportCsv} disabled={busy}>Export CSV</Button>
              <Button onClick={openPrint} disabled={busy}>Print</Button>
              <Button onClick={syncHeader} disabled={busy}>Sync Header</Button>
              <Button onClick={async () => { if (headerId) await loadCanPost(headerId); }} disabled={busy}>Check Post</Button>
              <Button onClick={fetchHistory} disabled={busy}>History</Button>
            </div>
          </div>

          <div style={{ border: '1px solid #eee', padding: 12, borderRadius: 12 }}>
            <div style={{ fontWeight: 900, marginBottom: 8 }}>Line Ops</div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="Reject note (optional)"><TextInput value={rejectNote} onChange={(e) => setRejectNote(e.target.value)} /></Field>
              <Field label="IDs fallback (comma)"><TextInput value={bulkLineIds} onChange={(e) => setBulkLineIds(e.target.value)} placeholder="1,2,3" /></Field>
            </div>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 10 }}>
              <Button onClick={() => lineAction('approve')} disabled={busy}>Approve Selected Line</Button>
              <Button onClick={() => lineAction('reject')} disabled={busy}>Reject Selected Line</Button>
              <Button onClick={approveAllLines} disabled={busy}>Approve All Lines</Button>
              <Button onClick={bulkReject} disabled={busy}>Reject Selected (or IDs) lost_of_sales</Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
