const API_BASE = (import.meta.env.VITE_API_BASE || "http://localhost:8080").replace(/\/$/, "");

export class ApiError extends Error {
  status: number;
  payload: any;
  constructor(message: string, status: number, payload: any) {
    super(message);
    this.status = status;
    this.payload = payload;
  }
}

function headers(serviceCenter: number, locationId?: number | null) {
  const h: Record<string, string> = {
    "Content-Type": "application/json",
    "X-Service-Center": String(serviceCenter)
  };
  if (locationId != null) h["X-Location-Id"] = String(locationId);
  return h;
}

async function parse(res: Response) {
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new ApiError(data?.error?.message || "Request failed", res.status, data);
  return data;
}

export async function apiGet<T>(path: string, serviceCenter: number, locationId?: number | null): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, { headers: headers(serviceCenter, locationId) });
  return (await parse(res)) as T;
}

export async function apiPost<T>(path: string, body: any, serviceCenter: number, locationId?: number | null): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "POST",
    headers: headers(serviceCenter, locationId),
    body: JSON.stringify(body ?? {})
  });
  return (await parse(res)) as T;
}

export async function apiPut<T>(path: string, body: any, serviceCenter: number, locationId?: number | null): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "PUT",
    headers: headers(serviceCenter, locationId),
    body: JSON.stringify(body ?? {})
  });
  return (await parse(res)) as T;
}

export async function apiDelete<T>(path: string, serviceCenter: number, locationId?: number | null): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "DELETE",
    headers: headers(serviceCenter, locationId),
  });
  return (await parse(res)) as T;
}
