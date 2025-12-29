import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';
import DataTable from '../components/DataTable';

export default function Cars() {
  const api = useApi();
  const [tab, setTab] = useState<'vehicles' | 'customers' | 'sales-docs'>('vehicles');
  const [rows, setRows] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    setError(null);
    api
      .get<{ ok: boolean; data: any[] }>(`/api/cars/${tab}`)
      .then((r) => {
        if (!alive) return;
        if (!r?.ok) return setError((r as any)?.message ?? 'Failed');
        setRows(r.data ?? []);
      })
      .catch((e) => alive && setError(String(e)))
      .finally(() => alive && setLoading(false));

    return () => {
      alive = false;
    };
  }, [api, tab]);

  return (
    <div className="p-4">
      <div className="text-xl font-semibold mb-2">Cars</div>
      <div className="text-sm opacity-80 mb-4">Live read from <code>/api/cars</code>.</div>

      <div className="flex flex-wrap gap-2 mb-3">
        {([
          { key: 'vehicles', label: 'Vehicles' },
          { key: 'customers', label: 'Customers' },
          { key: 'sales-docs', label: 'Sales Docs' }
        ] as const).map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={
              tab === t.key
                ? 'px-3 py-1.5 rounded bg-blue-600 text-white'
                : 'px-3 py-1.5 rounded border'
            }
          >
            {t.label}
          </button>
        ))}
      </div>

      {error && (
        <div className="p-3 rounded border border-red-300 bg-red-50 text-red-800 mb-3">
          {error}
        </div>
      )}

      {loading ? <div>Loading...</div> : <DataTable rows={rows} />}
    </div>
  );
}
