import Head from 'next/head';
import DoseAndWeightCharts from '../components/DoseAndWeightCharts';
import AdvancedHealthTools from '../components/AdvancedHealthTools';
import { AppStoreProvider } from '../store/useAppStore';

export default function Home() {
  return (
    <AppStoreProvider>
      <Head>
        <title>Weight Loss Planner Dashboard</title>
      </Head>
      <main className="p-6">
        <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
        <DoseAndWeightCharts />
        <AdvancedHealthTools />
      </main>
    </AppStoreProvider>
  );
}
