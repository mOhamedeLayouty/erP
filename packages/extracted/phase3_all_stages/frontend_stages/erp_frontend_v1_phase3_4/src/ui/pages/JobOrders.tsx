import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';

export default function JobOrders() {
  const api = useApi();
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    setLoading(true); setError(null);
    try {
      const res = await api.get<any>('/api/job-orders');
      setRows(res.data ?? res);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [api.baseUrl, api.token]);

  return (
    <div>
      <h3>Job Orders</h3>
      <button onClick={load} disabled={loading}>Refresh</button>
      {error && <pre style={{ color: 'crimson' }}>{error}</pre>}
      <div style={{ marginTop: 12 }}>
        <DataTable rows={rows} />
      </div>
    </div>
  );
}
