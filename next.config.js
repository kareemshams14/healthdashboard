// File: next.config.js

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  trailingSlash: true,
  images: {
    unoptimized: true, // Required for GitHub Pages export
  },
  output: 'export', // Enables static export
};

module.exports = nextConfig;
