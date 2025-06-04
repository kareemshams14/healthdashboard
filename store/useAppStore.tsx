import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface HealthData {
  weightData: number[];
  doseData: number[];
  addWeight: (value: number) => void;
  addDose: (value: number) => void;
  userInfo: UserInfo | null;
  setUserInfo: (info: UserInfo) => void;
}

export interface UserInfo {
  name: string;
  email: string;
  phone: string;
  currentWeight: number;
  height: number;
  goalWeight: number;
  startDate: string;
  gender?: string;
  age?: number;
  activityLevel?: string;
}

const AppStoreContext = createContext<HealthData | undefined>(undefined);

export function AppStoreProvider({ children }: { children: ReactNode }) {
  const [weightData, setWeightData] = useState<number[]>([180, 178, 176, 175]);
  const [doseData, setDoseData] = useState<number[]>([0.25, 0.25, 0.5, 0.5]);
  const [userInfo, setUserInfoState] = useState<UserInfo | null>(null);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem('userInfo');
      if (stored) {
        try {
          setUserInfoState(JSON.parse(stored));
        } catch {
          localStorage.removeItem('userInfo');
        }
      }
    }
  }, []);

  const addWeight = (value: number) => setWeightData(prev => [...prev, value]);
  const addDose = (value: number) => setDoseData(prev => [...prev, value]);
  const setUserInfo = (info: UserInfo) => {
    setUserInfoState(info);
    if (typeof window !== 'undefined') {
      localStorage.setItem('userInfo', JSON.stringify(info));
    }
  };

  return (
    <AppStoreContext.Provider value={{ weightData, doseData, addWeight, addDose, userInfo, setUserInfo }}>
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
