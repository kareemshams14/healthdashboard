import React from 'react';

/**
 * DoseAndWeightCharts renders simple SVG line charts illustrating
 * how dosage and weight change over time. The data here is static
 * for demonstration purposes but could easily be replaced with
 * values from props or a store.
 */
const DoseAndWeightCharts: React.FC = () => {
  // Example weekly dose (mg) and weight (kg) values
  const doseData = [0.25, 0.25, 0.5, 1, 1, 1.5];
  const weightData = [95, 94, 93, 92, 90, 89];

  const width = 320;
  const height = 160;
  const padding = 20;

  const doseMax = Math.max(...doseData);
  const doseMin = Math.min(...doseData);
  const weightMax = Math.max(...weightData);
  const weightMin = Math.min(...weightData);

  const linePoints = (data: number[], min: number, max: number) =>
    data
      .map((value, index) => {
        const x = padding + (index / (data.length - 1)) * (width - padding * 2);
        const y =
          padding + ((max - value) / (max - min)) * (height - padding * 2);
        return `${x},${y}`;
      })
      .join(' ');

  const dosePoints = linePoints(doseData, doseMin, doseMax);
  const weightPoints = linePoints(weightData, weightMin, weightMax);

  return (
    <div className="p-4 border rounded">
      <h2 className="text-lg font-semibold mb-2">Dose & Weight Charts</h2>
      <svg width={width} height={height} className="bg-white">
        <polyline
          fill="none"
          stroke="#1E90FF"
          strokeWidth="2"
          points={weightPoints}
        />
        <polyline
          fill="none"
          stroke="#FF6347"
          strokeWidth="2"
          points={dosePoints}
        />
      </svg>
      <div className="mt-1 flex space-x-2 text-sm">
        <div className="flex items-center space-x-1">
          <span className="inline-block w-3 h-3 bg-blue-500"></span>
          <span>Weight</span>
        </div>
        <div className="flex items-center space-x-1">
          <span className="inline-block w-3 h-3 bg-red-500"></span>
          <span>Dose</span>
        </div>
      </div>
    </div>
  );
};

export default DoseAndWeightCharts;
