import React from 'react';
import { Button } from './Form';

export default function HistoryPanel({ rows, onClose }: { rows: any[]; onClose: () => void }) {
  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.35)', zIndex: 9999 }} onClick={onClose}>
      <div style={{ position: 'absolute', right: 0, top: 0, height: '100%', width: '520px', background: '#fff', padding: 14, overflow: 'auto' }} onClick={(e) => e.stopPropagation()}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <div style={{ fontWeight: 900 }}>Request History</div>
          <Button onClick={onClose}>Close</Button>
        </div>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Time</th>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Action</th>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Line</th>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Reason</th>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Note</th>
              <th style={{ border: '1px solid #eee', padding: 6 }}>Actor</th>
            </tr>
          </thead>
          <tbody>
            {(rows || []).map((r, idx) => (
              <tr key={idx}>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.at_time ?? '')}</td>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.action ?? '')}</td>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.line_id ?? '')}</td>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.reason ?? '')}</td>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.note ?? '')}</td>
                <td style={{ border: '1px solid #eee', padding: 6, fontSize: 12 }}>{String(r.actor ?? '')}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
