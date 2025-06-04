import React, { useState } from 'react';

/**
 * AdvancedHealthTools renders a small collection of utilities
 * helpful when tracking weight loss. Currently this component
 * provides a simple BMI calculator.
 */
const AdvancedHealthTools: React.FC = () => {
  const [weight, setWeight] = useState<number | ''>('');
  const [height, setHeight] = useState<number | ''>('');

  const bmi =
    typeof weight === 'number' && typeof height === 'number' && height > 0
      ? (weight / (height * height)).toFixed(2)
      : null;

  return (
    <div className="p-4 border rounded">
      <h2 className="text-lg font-semibold mb-2">BMI Calculator</h2>
      <div className="flex flex-col space-y-2 max-w-xs">
        <label className="flex flex-col">
          <span className="text-sm">Weight (kg)</span>
          <input
            className="border p-1"
            type="number"
            value={weight}
            onChange={(e) => setWeight(e.target.value === '' ? '' : parseFloat(e.target.value))}
          />
        </label>
        <label className="flex flex-col">
          <span className="text-sm">Height (m)</span>
          <input
            className="border p-1"
            type="number"
            value={height}
            onChange={(e) => setHeight(e.target.value === '' ? '' : parseFloat(e.target.value))}
          />
        </label>
        {bmi && (
          <div className="pt-2 text-sm">
            <span className="font-medium">BMI:</span> {bmi}
          </div>
        )}
      </div>
    </div>
  );
};

export default AdvancedHealthTools;
