import React, { useState } from 'react';
import { useApi } from '../api/ApiContext';

export default function Login() {
  const api = useApi();
  const [token, setToken] = useState(api.token ?? '');

  return (
    <div>
      <h3>Login (Deferred)</h3>
      <p style={{ color: '#555' }}>
        Users & permissions will be implemented at end of project. For now paste an access token to unblock UI testing.
      </p>

      <textarea
        value={token}
        onChange={(e) => setToken(e.target.value)}
        rows={6}
        style={{ width: '100%', padding: 10 }}
        placeholder="Paste Bearer token here"
      />

      <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
        <button onClick={() => api.setToken(token.trim() || null)}>Save</button>
        <button onClick={() => { api.setToken(null); setToken(''); }}>Logout</button>
      </div>
    </div>
  );
}
