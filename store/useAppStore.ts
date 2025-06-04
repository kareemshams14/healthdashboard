import { create } from 'zustand';

/**
 * Global application store.
 *
 * Usage:
 * ```tsx
 * const { dosages, addDose } = useAppStore();
 * ```
 */
interface DoseEntry {
  date: string;
  amount: number;
}

interface WeightEntry {
  date: string;
  weight: number;
}

interface Projection {
  targetDate: string;
  expectedWeight: number;
}

interface AppState {
  /** Recorded medication dosages */
  dosages: DoseEntry[];
  /** Logged weight entries */
  weights: WeightEntry[];
  /** Calculated weight projections */
  projections: Projection[];

  /** Add a new dose entry */
  addDose: (entry: DoseEntry) => void;
  /** Add a weight measurement */
  addWeight: (entry: WeightEntry) => void;
  /** Replace projection data */
  setProjections: (projections: Projection[]) => void;
}

export const useAppStore = create<AppState>((set) => ({
  dosages: [],
  weights: [],
  projections: [],
  addDose: (entry) => set((state) => ({ dosages: [...state.dosages, entry] })),
  addWeight: (entry) => set((state) => ({ weights: [...state.weights, entry] })),
  setProjections: (projections) => set({ projections }),
}));
