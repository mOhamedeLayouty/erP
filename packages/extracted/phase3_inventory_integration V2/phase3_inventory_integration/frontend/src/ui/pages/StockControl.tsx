import React, { useEffect, useMemo, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button, Field, Select, TextInput } from '../components/Form';
import { useToast } from '../components/Toast';

type TablesMap = Record<string, string>;

export default function StockControl() {
  const api = useApi();
  const toast = useToast();

  const [tables, setTables] = useState<TablesMap>({});
  const [tableKey, setTableKey] = useState<string>('items');
  const [columns, setColumns] = useState<string[]>([]);
  const [limit, setLimit] = useState(200);
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Write helpers (best-effort)
  const [pk, setPk] = useState<string>('');
  const [pkValue, setPkValue] = useState<string>('');
  const [jsonBody, setJsonBody] = useState<string>('{}');

  const tableKeys = useMemo(() => Object.keys(tables), [tables]);

  async function loadTables() {
    try {
      const res = await api.get<any>('/api/stock/meta/tables');
      const m = res?.tables ?? res?.data?.tables ?? res?.data ?? res;
      setTables(m ?? {});
      const first = Object.keys(m ?? {})[0];
      if (first && !tableKey) setTableKey(first);
    } catch {
      setTables({});
    }
  }

  async function loadColumns(key: string) {
    try {
      const res = await api.get<any>(`/api/stock/meta/${key}/columns`);
      const cols = res?.columns ?? res?.data?.columns ?? res?.data ?? res;
      setColumns(Array.isArray(cols) ? cols : []);
      if (!pk && Array.isArray(cols) && cols.length) setPk(cols[0]);
    } catch {
      setColumns([]);
    }
  }

  async function loadRows() {
    if (!tableKey) return;
    setLoading(true);
    setError(null);
    try {
      const res = await api.get<any>(`/api/stock/${tableKey}?limit=${limit}`);
      setRows(res?.data ?? res?.data?.data ?? res?.data ?? res);
    } catch (e: any) {
      setError(e?.message ?? String(e));
      setRows([]);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTables();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [api.baseUrl, api.token]);

  useEffect(() => {
    if (!tableKey) return;
    loadColumns(tableKey);
    loadRows();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tableKey]);

  async function doInsert() {
    try {
      const body = JSON.parse(jsonBody || '{}');
      const res = await api.post<any>(`/api/stock/${tableKey}`, body);
      toast.push({ type: 'success', message: `Inserted. ${JSON.stringify(res?.data ?? res)}` });
      loadRows();
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    }
  }

  async function doUpdate() {
    try {
      if (!pk.trim() || !pkValue.trim()) return toast.push({ type: 'error', message: 'pk + id required' });
      const body = JSON.parse(jsonBody || '{}');
      const res = await api.put<any>(`/api/stock/${tableKey}?pk=${encodeURIComponent(pk)}&id=${encodeURIComponent(pkValue)}`, body);
      toast.push({ type: 'success', message: `Updated. ${JSON.stringify(res?.data ?? res)}` });
      loadRows();
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    }
  }

  async function doDelete() {
    try {
      if (!pk.trim() || !pkValue.trim()) return toast.push({ type: 'error', message: 'pk + id required' });
      const res = await api.del<any>(`/api/stock/${tableKey}?pk=${encodeURIComponent(pk)}&id=${encodeURIComponent(pkValue)}`);
      toast.push({ type: 'success', message: `Deleted. ${JSON.stringify(res?.data ?? res)}` });
      loadRows();
    } catch (e: any) {
      toast.push({ type: 'error', message: e?.message ?? String(e) });
    }
  }

  return (
    <div>
      <h3>Stock Control System (Inventory كامل)</h3>
      <Callout title="موديول المخازن الحقيقي">
        ده موديول مستقل عن ورشة الصيانة: Items / Stores / Vendors / Purchasing / Stock Movements / Balances.
        الواجهة هنا بتشتغل Live عبر ODBC، وبأمان: بتسمح فقط بالجداول المصرّح بها.
      </Callout>

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'end' }}>
        <Field label="Table">
          <Select value={tableKey} onChange={(e) => setTableKey(e.target.value)}>
            {tableKeys.map((k) => (
              <option key={k} value={k}>{k} → {tables[k]}</option>
            ))}
          </Select>
        </Field>
        <Field label="Limit">
          <TextInput type="number" value={limit} onChange={(e) => setLimit(Number(e.target.value))} />
        </Field>
        <Button onClick={loadRows} disabled={loading}>Refresh</Button>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}

      <DataTable rows={rows} />

      <div style={{ marginTop: 16, borderTop: '1px solid #eee', paddingTop: 12 }}>
        <div style={{ fontWeight: 800, marginBottom: 8 }}>Write (Insert/Update/Delete)</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'end' }}>
          <Field label="PK column">
            <Select value={pk} onChange={(e) => setPk(e.target.value)}>
              {columns.map((c) => <option key={c} value={c}>{c}</option>)}
            </Select>
          </Field>
          <Field label="PK value (id)">
            <TextInput value={pkValue} onChange={(e) => setPkValue(e.target.value)} />
          </Field>
          <Button onClick={doInsert}>Insert</Button>
          <Button onClick={doUpdate}>Update</Button>
          <Button onClick={doDelete}>Delete</Button>
        </div>
        <Field label="JSON body (only allowed columns will be used)">
          <textarea
            value={jsonBody}
            onChange={(e) => setJsonBody(e.target.value)}
            rows={6}
            style={{ width: '100%', fontFamily: 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace', borderRadius: 12, padding: 10, border: '1px solid #ddd' }}
          />
        </Field>
        <div style={{ color: '#666', fontSize: 12 }}>
          Endpoints: <code>/api/stock/meta/tables</code>, <code>/api/stock/:tableKey</code>
        </div>
      </div>
    </div>
  );
}
