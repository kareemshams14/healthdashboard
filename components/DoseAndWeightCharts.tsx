import React from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import { useAppStore } from '../store/useAppStore';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

const DoseAndWeightCharts = () => {
  const { weightData, doseData } = useAppStore();

  const labels = weightData.map((_, i) => `Week ${i + 1}`);
  const data = {
    labels,
    datasets: [
      {
        label: 'Weight (lb)',
        data: weightData,
        borderColor: 'rgb(59, 130, 246)',
        backgroundColor: 'rgba(59, 130, 246, 0.5)',
      },
      {
        label: 'Dose (mg)',
        data: doseData,
        borderColor: 'rgb(16, 185, 129)',
        backgroundColor: 'rgba(16, 185, 129, 0.5)',
      },
    ],
  };

  return <Line data={data} />;
};

export default DoseAndWeightCharts;
