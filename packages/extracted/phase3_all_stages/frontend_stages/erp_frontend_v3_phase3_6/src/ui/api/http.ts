export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

export class HttpError extends Error {
  constructor(public status: number, message: string, public body?: any) {
    super(message);
  }
}

export async function http<T>(url: string, options: {
  method?: HttpMethod;
  token?: string | null;
  body?: any;
} = {}): Promise<T> {
  const res = await fetch(url, {
    method: options.method ?? 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(options.token ? { Authorization: `Bearer ${options.token}` } : {})
    },
    body: options.body !== undefined ? JSON.stringify(options.body) : undefined
  });

  const text = await res.text();
  const data = text ? (() => { try { return JSON.parse(text); } catch { return text; } })() : null;

  if (!res.ok) {
    throw new HttpError(res.status, typeof data === 'string' ? data : (data?.message ?? 'Request failed'), data);
  }
  return data as T;
}
