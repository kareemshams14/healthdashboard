import React, { useState } from 'react';
import { useAppStore, UserInfo } from '../store/useAppStore';

const UserIntakeForm = () => {
  const { setUserInfo } = useAppStore();
  const [formData, setFormData] = useState<UserInfo>({
    name: '',
    email: '',
    phone: '',
    currentWeight: 0,
    height: 0,
    goalWeight: 0,
    startDate: '',
    gender: '',
    age: undefined,
    activityLevel: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'currentWeight' || name === 'height' || name === 'goalWeight' || name === 'age' ? Number(value) : value,
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setUserInfo(formData);
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w-2xl mx-auto bg-white shadow-lg rounded-lg p-6 md:p-8 space-y-6"
    >
      <header className="text-center">
        <h2 className="text-2xl font-bold text-sky-700">Tell us about yourself</h2>
        <p className="text-sm text-slate-600">
          Please fill in the information below to start planning your progress
        </p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-slate-700">
            Full Name
          </label>
          <input
            id="name"
            name="name"
            value={formData.name}
            onChange={handleChange}
            placeholder="Jane Doe"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-slate-700">
            Email
          </label>
          <input
            id="email"
            name="email"
            type="email"
            value={formData.email}
            onChange={handleChange}
            placeholder="you@example.com"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-slate-700">
            Phone
          </label>
          <input
            id="phone"
            name="phone"
            type="tel"
            value={formData.phone}
            onChange={handleChange}
            placeholder="(555) 123-4567"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="startDate" className="block text-sm font-medium text-slate-700">
            Start Date
          </label>
          <input
            id="startDate"
            name="startDate"
            type="date"
            value={formData.startDate}
            onChange={handleChange}
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="currentWeight" className="block text-sm font-medium text-slate-700">
            Current Weight (lb)
          </label>
          <input
            id="currentWeight"
            name="currentWeight"
            type="number"
            value={formData.currentWeight}
            onChange={handleChange}
            placeholder="180"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="height" className="block text-sm font-medium text-slate-700">
            Height (inches)
          </label>
          <input
            id="height"
            name="height"
            type="number"
            value={formData.height}
            onChange={handleChange}
            placeholder="65"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="goalWeight" className="block text-sm font-medium text-slate-700">
            Goal Weight (lb)
          </label>
          <input
            id="goalWeight"
            name="goalWeight"
            type="number"
            value={formData.goalWeight}
            onChange={handleChange}
            placeholder="150"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="gender" className="block text-sm font-medium text-slate-700">
            Gender
          </label>
          <input
            id="gender"
            name="gender"
            value={formData.gender}
            onChange={handleChange}
            placeholder="Gender"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div>
          <label htmlFor="age" className="block text-sm font-medium text-slate-700">
            Age
          </label>
          <input
            id="age"
            name="age"
            type="number"
            value={formData.age ?? ''}
            onChange={handleChange}
            placeholder="30"
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          />
        </div>
        <div className="md:col-span-2">
          <label
            htmlFor="activityLevel"
            className="block text-sm font-medium text-slate-700"
          >
            Activity Level
          </label>
          <select
            id="activityLevel"
            name="activityLevel"
            value={formData.activityLevel}
            onChange={handleChange}
            className="mt-1 block w-full rounded-md border-slate-300 shadow-sm focus:border-sky-500 focus:ring-sky-500 p-2"
          >
            <option value="">Select activity level</option>
            <option value="sedentary">Sedentary</option>
            <option value="light">Light</option>
            <option value="moderate">Moderate</option>
            <option value="active">Active</option>
          </select>
        </div>
      </div>

      <button
        type="submit"
        className="w-full bg-sky-600 hover:bg-sky-700 text-white font-semibold py-2 px-4 rounded-md shadow"
      >
        Continue
      </button>
    </form>
  );
};

export default UserIntakeForm;
