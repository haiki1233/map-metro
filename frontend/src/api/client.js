import axios from 'axios';

const configuredBaseUrl = import.meta.env.VITE_API_BASE_URL || '/api';
const apiBaseUrl = configuredBaseUrl.replace(/\/+$/, '').endsWith('/api')
  ? configuredBaseUrl.replace(/\/+$/, '')
  : `${configuredBaseUrl.replace(/\/+$/, '')}/api`;

export const apiClient = axios.create({
  baseURL: apiBaseUrl,
  timeout: 10000,
});
