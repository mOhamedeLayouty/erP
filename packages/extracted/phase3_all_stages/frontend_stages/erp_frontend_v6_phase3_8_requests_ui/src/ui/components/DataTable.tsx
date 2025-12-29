import React, { useMemo, useState } from 'react';

type Props = {
  rows: any[];
  onRowClick?: (row: any) => void;
  defaultFilter?: string;
};

export default function DataTable({ rows, onRowClick, defaultFilter = '' }: Props) {
  const [filter, setFilter] = useState(defaultFilter);

  const filtered = useMemo(() => {
    if (!rows?.length) return [];
    const q = filter.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) => JSON.stringify(r).toLowerCase().includes(q));
  }, [rows, filter]);

  if (!rows?.length) return <div>No data</div>;
  const cols = Object.keys(rows[0]);

  return (
    <div>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 8 }}>
        <input
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          placeholder="Search..."
          style={{ padding: 8, width: 320 }}
        />
        <div style={{ color: '#666', fontSize: 12 }}>
          {filtered.length} / {rows.length}
        </div>
      </div>

      <div style={{ overflow: 'auto', border: '1px solid #ddd', borderRadius: 8 }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr>
              {cols.map((c) => (
                <th key={c} style={{ textAlign: 'left', padding: 8, borderBottom: '1px solid #eee', whiteSpace: 'nowrap' }}>
                  {c}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((r, i) => (
              <tr
                key={i}
                onClick={onRowClick ? () => onRowClick(r) : undefined}
                style={onRowClick ? { cursor: 'pointer' } : undefined}
              >
                {cols.map((c) => (
                  <td key={c} style={{ padding: 8, borderBottom: '1px solid #f3f3f3', whiteSpace: 'nowrap' }}>
                    {String(r[c] ?? '')}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
