import React from 'react';

type TableProps = {
  headers: string[];
  rows: Array<Array<React.ReactNode>>;
};

export default function Table({ headers, rows }: TableProps) {
  return (
    <table className="m365-table">
      <thead>
        <tr>
          {headers.map((header) => (
            <th key={header}>{header}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {rows.map((row, index) => (
          <tr key={`${index}-${row.length}`}>
            {row.map((cell, cellIndex) => (
              <td key={`${index}-${cellIndex}`}>{cell}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
