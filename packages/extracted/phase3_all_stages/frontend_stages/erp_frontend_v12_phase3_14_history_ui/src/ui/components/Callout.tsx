import React from 'react';

export default function Callout({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ border: '1px solid #eee', background: '#fafafa', padding: 12, borderRadius: 10, marginBottom: 12 }}>
      <div style={{ fontWeight: 700, marginBottom: 6 }}>{title}</div>
      <div style={{ color: '#555', fontSize: 13 }}>{children}</div>
    </div>
  );
}
