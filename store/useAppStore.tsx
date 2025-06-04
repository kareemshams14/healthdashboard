import React, { createContext, useContext, useState, ReactNode } from 'react';

interface HealthData {
  weightData: number[];
  doseData: number[];
  addWeight: (value: number) => void;
  addDose: (value: number) => void;
}

const AppStoreContext = createContext<HealthData | undefined>(undefined);

export function AppStoreProvider({ children }: { children: ReactNode }) {
  const [weightData, setWeightData] = useState<number[]>([180, 178, 176, 175]);
  const [doseData, setDoseData] = useState<number[]>([0.25, 0.25, 0.5, 0.5]);

  const addWeight = (value: number) => setWeightData(prev => [...prev, value]);
  const addDose = (value: number) => setDoseData(prev => [...prev, value]);

  return (
    <AppStoreContext.Provider value={{ weightData, doseData, addWeight, addDose }}>
      {children}
    </AppStoreContext.Provider>
  );
}

export const useAppStore = () => {
  const context = useContext(AppStoreContext);
  if (!context) {
    throw new Error('useAppStore must be used within an AppStoreProvider');
  }
  return context;
};
