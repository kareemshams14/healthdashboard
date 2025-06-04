import React from 'react';
import Head from 'next/head';
import AdvancedHealthTools from '../components/AdvancedHealthTools';
import DoseAndWeightCharts from '../components/DoseAndWeightCharts';
import PageLayout from '../components/PageLayout';

const HomePage: React.FC = () => {
  return (
    <PageLayout>
      <Head>
        <title>Health Dashboard</title>
        <meta name="description" content="Track your weight loss progress" />
      </Head>
      <div className="space-y-8">
        <DoseAndWeightCharts />
        <AdvancedHealthTools />
      </div>
    </PageLayout>
  );
};

export default HomePage;
