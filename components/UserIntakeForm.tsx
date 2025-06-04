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
    <form onSubmit={handleSubmit} className="space-y-4 p-4 max-w-md mx-auto">
      <h2 className="text-xl font-bold">Tell us about yourself</h2>
      <input name="name" value={formData.name} onChange={handleChange} placeholder="Name" className="border p-2 w-full" />
      <input name="email" value={formData.email} onChange={handleChange} placeholder="Email" className="border p-2 w-full" />
      <input name="phone" value={formData.phone} onChange={handleChange} placeholder="Phone" className="border p-2 w-full" />
      <input name="currentWeight" type="number" value={formData.currentWeight} onChange={handleChange} placeholder="Current weight" className="border p-2 w-full" />
      <input name="height" type="number" value={formData.height} onChange={handleChange} placeholder="Height (inches)" className="border p-2 w-full" />
      <input name="goalWeight" type="number" value={formData.goalWeight} onChange={handleChange} placeholder="Goal weight" className="border p-2 w-full" />
      <input name="startDate" type="date" value={formData.startDate} onChange={handleChange} className="border p-2 w-full" />
      <input name="gender" value={formData.gender} onChange={handleChange} placeholder="Gender" className="border p-2 w-full" />
      <input name="age" type="number" value={formData.age ?? ''} onChange={handleChange} placeholder="Age" className="border p-2 w-full" />
      <select name="activityLevel" value={formData.activityLevel} onChange={handleChange} className="border p-2 w-full">
        <option value="">Activity level</option>
        <option value="sedentary">Sedentary</option>
        <option value="light">Light</option>
        <option value="moderate">Moderate</option>
        <option value="active">Active</option>
      </select>
      <button type="submit" className="bg-blue-500 text-white px-4 py-2">Continue</button>
    </form>
  );
};

export default UserIntakeForm;
