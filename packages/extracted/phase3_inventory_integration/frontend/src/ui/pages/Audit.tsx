import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';
import Callout from '../components/Callout';
import { Button } from '../components/Form';
import { useToast } from '../components/Toast';

export default function Audit() {
  const api = useApi();
  const toast = useToast();
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [auto, setAuto] = useState(false);

  async function load() {
    setLoading(true); setError(null);
    try {
      const res = await api.get<any>('/api/audit/events');
      setRows(res.data ?? res);
    } catch (e: any) {
      const msg = e?.message ?? String(e);
      setError(msg);
      toast.push({ type: 'error', message: msg });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  useEffect(() => {
    if (!auto) return;
    const t = setInterval(load, 2500);
    return () => clearInterval(t);
  }, [auto, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Audit</h3>

      <Callout title="مراقبة التشغيل">
        أي عمليات POST/PUT/PATCH/DELETE بتتسجل في backend في <code>audit.ndjson</code>. هنا بنعرض آخر Events.
      </Callout>

      <div style={{ display: 'flex', gap: 8, marginBottom: 10, alignItems: 'center', flexWrap: 'wrap' }}>
        <Button onClick={load} disabled={loading}>Refresh</Button>
        <label style={{ display: 'flex', gap: 6, alignItems: 'center', color: '#666' }}>
          <input type="checkbox" checked={auto} onChange={(e) => setAuto(e.target.checked)} />
          Auto refresh
        </label>
      </div>

      {error && <pre style={{ color: 'crimson', whiteSpace: 'pre-wrap' }}>{error}</pre>}
      <div style={{ marginTop: 12 }}>
        <DataTable rows={rows} />
      </div>
    </div>
  );
}
