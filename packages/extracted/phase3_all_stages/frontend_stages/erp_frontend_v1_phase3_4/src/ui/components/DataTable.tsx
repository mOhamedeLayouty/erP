import React from 'react';

export default function DataTable({ rows }: { rows: any[] }) {
  if (!rows?.length) return <div>No data</div>;
  const cols = Object.keys(rows[0]);

  return (
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
          {rows.map((r, i) => (
            <tr key={i}>
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
  );
}
