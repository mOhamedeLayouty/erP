import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';

export default function Inventory() {
  const api = useApi();
  const [tab, setTab] = useState<'stores'|'items'|'transfers'|'details'>('stores');
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    setLoading(true); setError(null);
    try {
      const path = tab === 'stores' ? '/api/inventory/stores'
        : tab === 'items' ? '/api/inventory/items'
        : tab === 'transfers' ? '/api/inventory/transfers'
        : '/api/inventory/transfer-details';
      const res = await api.get<any>(path);
      setRows(res.data ?? res);
    } catch (e: any) {
      setError(e?.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [tab, api.baseUrl, api.token]);

  return (
    <div>
      <h3>Inventory</h3>
      <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
        {(['stores','items','transfers','details'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} disabled={loading || tab===t}>{t}</button>
        ))}
        <button onClick={load} disabled={loading}>Refresh</button>
      </div>
      {error && <pre style={{ color: 'crimson' }}>{error}</pre>}
      <DataTable rows={rows} />
    </div>
  );
}
