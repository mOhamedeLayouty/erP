import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import { ServiceCenterProvider } from "./state/serviceCenter";
import PageShell from "./components/PageShell";
import CustomersPage from "./pages/CustomersPage";
import CustomerDetailsPage from "./pages/CustomerDetailsPage";
import CallDetailsPage from "./pages/CallDetailsPage";

export default function App() {
  return (
    <ServiceCenterProvider>
      <PageShell>
        <Routes>
          <Route path="/" element={<Navigate to="/customers" replace />} />
          <Route path="/customers" element={<CustomersPage />} />
          <Route path="/customers/:customerId" element={<CustomerDetailsPage />} />
          <Route path="/calls/:callId" element={<CallDetailsPage />} />
          <Route path="*" element={<div>Not Found</div>} />
        </Routes>
      </PageShell>
    </ServiceCenterProvider>
  );
}
