import React, { createContext, useContext, useMemo, useState } from 'react';
import { http } from './http';

type ApiCtx = {
  baseUrl: string;
  setBaseUrl: (v: string) => void;
  token: string | null;
  setToken: (v: string | null) => void;
  get: <T>(path: string) => Promise<T>;
  post: <T>(path: string, body: any) => Promise<T>;
  // low-level access for downloads / non-json
  raw: (path: string, init?: RequestInit) => Promise<Response>;
};

const Ctx = createContext<ApiCtx | null>(null);

export function ApiProvider({ children }: { children: React.ReactNode }) {
  const [baseUrl, setBaseUrl] = useState<string>(import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080');
  const [token, setTokenState] = useState<string | null>(localStorage.getItem('access_token'));

  const api = useMemo<ApiCtx>(() => ({
    baseUrl,
    setBaseUrl,
    token,
    setToken: (v) => {
      setTokenState(v);
      if (v) localStorage.setItem('access_token', v);
      else localStorage.removeItem('access_token');
    },
    get: (path) => http(`${baseUrl}${path}`, { token }),
    post: (path, body) => http(`${baseUrl}${path}`, { method: 'POST', token, body }),
    raw: async (path, init) => {
      const headers = new Headers(init?.headers as any);
      if (token) headers.set('Authorization', `Bearer ${token}`);
      // Caller decides how to read the response (blob/text/json)
      return await fetch(`${baseUrl}${path}`, { ...(init ?? {}), headers });
    }
  }), [baseUrl, token]);

  return <Ctx.Provider value={api}>{children}</Ctx.Provider>;
}

export function useApi() {
  const v = useContext(Ctx);
  if (!v) throw new Error('ApiProvider missing');
  return v;
}
