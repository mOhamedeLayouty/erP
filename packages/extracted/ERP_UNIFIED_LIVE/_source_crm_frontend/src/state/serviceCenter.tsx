import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { apiGet } from "../utils/api";

export type ServiceCenter = { service_center: number; name: string };

type Ctx = {
  serviceCenters: ServiceCenter[];
  serviceCenter: number | null;
  setServiceCenter: (n: number) => void;
  refreshServiceCenters: () => Promise<void>;
};

const ServiceCenterContext = createContext<Ctx | null>(null);
const LS_KEY = "crm.service_center";

export function ServiceCenterProvider({ children }: { children: React.ReactNode }) {
  const defaultSc = Number(import.meta.env.VITE_DEFAULT_SERVICE_CENTER || 1);

  const [serviceCenter, setServiceCenterState] = useState<number | null>(() => {
    const raw = localStorage.getItem(LS_KEY);
    const v = raw ? Number(raw) : defaultSc;
    return Number.isFinite(v) ? v : defaultSc;
  });

  const [serviceCenters, setServiceCenters] = useState<ServiceCenter[]>([]);

  const setServiceCenter = (n: number) => {
    setServiceCenterState(n);
    localStorage.setItem(LS_KEY, String(n));
  };

  const refreshServiceCenters = async () => {
    const headerSc = serviceCenter ?? defaultSc;
    const data = await apiGet<{ service_centers: ServiceCenter[] }>("/meta/service-centers", headerSc);
    setServiceCenters(data.service_centers || []);
    if (data.service_centers?.length) {
      const exists = data.service_centers.some(x => x.service_center === (serviceCenter ?? defaultSc));
      if (!exists) setServiceCenter(data.service_centers[0].service_center);
    }
  };

  useEffect(() => { refreshServiceCenters().catch(() => {}); }, []);

  const value = useMemo<Ctx>(() => ({
    serviceCenters,
    serviceCenter,
    setServiceCenter,
    refreshServiceCenters
  }), [serviceCenters, serviceCenter]);

  return <ServiceCenterContext.Provider value={value}>{children}</ServiceCenterContext.Provider>;
}

export function useServiceCenter() {
  const ctx = useContext(ServiceCenterContext);
  if (!ctx) throw new Error("useServiceCenter must be used within ServiceCenterProvider");
  return ctx;
}
