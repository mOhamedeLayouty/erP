import React from 'react';
import { Routes, Route, Navigate, NavLink } from 'react-router-dom';
import { ApiProvider } from './api/ApiContext';
import { ToastProvider } from './components/Toast';
import Dashboard from './pages/Dashboard';
import JobOrders from './pages/JobOrders';
import Invoices from './pages/Invoices';
import Inventory from './pages/Inventory';
import WorkshopStock from './pages/WorkshopStock';
import InventoryRequests from './pages/InventoryRequests';
import InventoryReports from './pages/InventoryReports';
import Audit from './pages/Audit';
import Login from './pages/Login';
import MasterDataStores from './pages/MasterDataStores';

export default function App() {
  return (
    <ApiProvider>
      <ToastProvider>
        <div className="app-shell">
          <header className="topbar">
            <div className="topbar-title">
              <strong>ERP Workspace</strong>
              <span style={{ color: 'var(--m365-muted)' }}>Inventory Integration</span>
            </div>
            <div className="topbar-actions">
              <span>Operations Team</span>
              <NavLink to="/login" className="nav-link">
                Sign in
              </NavLink>
            </div>
          </header>
          <div className="app-body">
            <aside className="sidebar">
              <div className="nav-section">
                <span className="nav-section-title">Overview</span>
                <NavLink to="/dashboard" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Dashboard
                </NavLink>
                <NavLink to="/audit" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Audit
                </NavLink>
              </div>
              <div className="nav-section">
                <span className="nav-section-title">Operations</span>
                <NavLink to="/job-orders" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Job Orders
                </NavLink>
                <NavLink to="/invoices" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Invoices
                </NavLink>
                <NavLink to="/inventory" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Inventory
                </NavLink>
                <NavLink to="/workshop-stock" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Workshop ↔ Inventory
                </NavLink>
                <NavLink to="/inventory-requests" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Inventory Requests
                </NavLink>
                <NavLink to="/inventory-reports" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Inventory Reports
                </NavLink>
              </div>
              <div className="nav-section">
                <span className="nav-section-title">Master Data</span>
                <NavLink to="/master-data/stores" className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
                  Stores
                </NavLink>
              </div>
            </aside>
            <main className="content">
              <Routes>
                <Route path="/" element={<Navigate to="/dashboard" replace />} />
                <Route path="/dashboard" element={<Dashboard />} />
                <Route path="/login" element={<Login />} />
                <Route path="/job-orders" element={<JobOrders />} />
                <Route path="/invoices" element={<Invoices />} />
                <Route path="/inventory" element={<Inventory />} />
                <Route path="/workshop-stock" element={<WorkshopStock />} />
                <Route path="/inventory-requests" element={<InventoryRequests />} />
                <Route path="/inventory-reports" element={<InventoryReports />} />
                <Route path="/audit" element={<Audit />} />
                <Route path="/master-data/stores" element={<MasterDataStores />} />
                <Route path="*" element={<div>Not Found</div>} />
              </Routes>
            </main>
          </div>
        </div>
      </ToastProvider>
    </ApiProvider>
  );
}
