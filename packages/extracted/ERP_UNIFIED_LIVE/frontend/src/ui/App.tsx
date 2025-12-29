import React from 'react';
import { Routes, Route, Navigate, Link } from 'react-router-dom';
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
import CRMCustomers from './pages/CRMCustomers';
import Login from './pages/Login';

export default function App() {
  return (
    <ApiProvider>
      <ToastProvider>
        <div style={{ fontFamily: 'system-ui', padding: 16, maxWidth: 1200, margin: '0 auto' }}>
          <header style={{ display: 'flex', gap: 12, alignItems: 'center', marginBottom: 16, flexWrap: 'wrap' }}>
            <h2 style={{ margin: 0 }}>ERP Web Client</h2>
            <nav style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
              <Link to="/dashboard">Dashboard</Link>
              <Link to="/job-orders">Job Orders</Link>
              <Link to="/invoices">Invoices</Link>
              <Link to="/inventory">Inventory</Link>
              <Link to="/workshop-stock">Workshop ↔ Inventory</Link>
              <Link to="/inventory-requests">Inventory Requests</Link>
              <Link to="/inventory-reports">Inventory Reports</Link>
              <Link to="/audit">Audit</Link>
              <Link to="/crm/customers">CRM Customers</Link>
            </nav>
            <div style={{ marginLeft: 'auto' }}>
              <Link to="/login">Login</Link>
            </div>
          </header>

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
            <Route path="/crm/customers" element={<CRMCustomers />} />
            <Route path="*" element={<div>Not Found</div>} />
          </Routes>
        </div>
      </ToastProvider>
    </ApiProvider>
  );
}
