import React from 'react';

export function Field({ label, children, hint }: { label: string; children: React.ReactNode; hint?: string }) {
  return (
    <div style={{ marginBottom: 10 }}>
      <div style={{ fontSize: 12, color: '#666', marginBottom: 4 }}>{label}</div>
      {children}
      {hint && <div style={{ fontSize: 11, color: '#888', marginTop: 4 }}>{hint}</div>}
    </div>
  );
}

export function TextInput(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      {...props}
      style={{
        width: '100%',
        padding: '10px 10px',
        borderRadius: 10,
        border: '1px solid #ddd',
        ...(props.style ?? {})
      }}
    />
  );
}

export function Select(props: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select
      {...props}
      style={{
        width: '100%',
        padding: '10px 10px',
        borderRadius: 10,
        border: '1px solid #ddd',
        background: '#fff',
        ...(props.style ?? {})
      }}
    />
  );
}

export function Button(props: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      {...props}
      style={{
        padding: '10px 12px',
        borderRadius: 10,
        border: '1px solid #ddd',
        background: '#fff',
        cursor: 'pointer',
        ...(props.style ?? {})
      }}
    />
  );
}
