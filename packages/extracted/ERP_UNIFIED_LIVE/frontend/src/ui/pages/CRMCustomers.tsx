import React, { useEffect, useState } from 'react';
import { useApi } from '../api/ApiContext';

export default function CRMCustomers() {
  const api = useApi();
  const [rows, setRows] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    api
      .get<{ ok: boolean; data: any[] }>(`/api/crm/customers`)
      .then(r => {
        if (!alive) return;
        if (!r?.ok) return setError((r as any)?.message ?? 'Failed');
        setRows(r.data ?? []);
      })
      .catch(e => alive && setError(String(e)));
    return () => {
      alive = false;
    };
  }, [api]);

  return (
    <div className="p-4">
      <div className="text-xl font-semibold mb-2">CRM Customers</div>
      <div className="text-sm opacity-80 mb-4">
        Live read from DB via <code>/api/crm/customers</code>
      </div>

      {error && (
        <div className="p-3 rounded border border-red-300 bg-red-50 text-red-800 mb-3">
          {error}
        </div>
      )}

      <div className="overflow-auto border rounded">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="bg-gray-50">
              {Object.keys(rows[0] ?? {}).map(k => (
                <th key={k} className="text-left p-2 border-b">{k}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r, idx) => (
              <tr key={idx} className="odd:bg-white even:bg-gray-50">
                {Object.keys(rows[0] ?? {}).map(k => (
                  <td key={k} className="p-2 border-b whitespace-nowrap">{String((r as any)[k] ?? '')}</td>
                ))}
              </tr>
            ))}
            {!rows.length && (
              <tr>
                <td className="p-3 opacity-70">No data</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
