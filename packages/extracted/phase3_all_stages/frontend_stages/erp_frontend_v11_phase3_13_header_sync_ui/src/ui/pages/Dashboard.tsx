import React from 'react';
import { useApi } from '../api/ApiContext';

export default function Dashboard() {
  const api = useApi();

  return (
    <div>
      <h3>Dashboard</h3>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <label>API Base URL</label>
        <input
          value={api.baseUrl}
          onChange={(e) => api.setBaseUrl(e.target.value)}
          style={{ padding: 8, width: 420 }}
        />
      </div>
      <p style={{ marginTop: 12, color: '#555' }}>
        Phase 3.4: UI binding started. RBAC & Users are deferred.
      </p>
    </div>
  );
}
