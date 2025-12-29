import React, { createContext, useContext, useMemo, useState } from 'react';

type Toast = { id: string; type: 'success'|'error'|'info'; message: string };

type ToastCtx = {
  push: (t: Omit<Toast, 'id'>) => void;
};

const Ctx = createContext<ToastCtx | null>(null);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const api = useMemo<ToastCtx>(() => ({
    push: (t) => {
      const id = `${Date.now()}-${Math.random()}`;
      const toast: Toast = { id, ...t };
      setToasts((x) => [toast, ...x].slice(0, 5));
      setTimeout(() => setToasts((x) => x.filter((y) => y.id !== id)), 3500);
    }
  }), []);

  return (
    <Ctx.Provider value={api}>
      {children}
      <div style={{
        position: 'fixed', right: 12, bottom: 12, display: 'flex',
        flexDirection: 'column', gap: 8, zIndex: 9999, width: 360, maxWidth: 'calc(100vw - 24px)'
      }}>
        {toasts.map(t => (
          <div key={t.id} style={{
            border: '1px solid #eee', borderRadius: 12, padding: 12,
            background: '#fff', boxShadow: '0 8px 30px rgba(0,0,0,0.08)'
          }}>
            <div style={{ fontWeight: 700, marginBottom: 4 }}>
              {t.type.toUpperCase()}
            </div>
            <div style={{ color: '#444', fontSize: 13, whiteSpace: 'pre-wrap' }}>
              {t.message}
            </div>
          </div>
        ))}
      </div>
    </Ctx.Provider>
  );
}

export function useToast() {
  const v = useContext(Ctx);
  if (!v) throw new Error('ToastProvider missing');
  return v;
}
