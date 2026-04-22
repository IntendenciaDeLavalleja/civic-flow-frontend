import { createRoot } from 'react-dom/client';
import './styles/Global.css';
import Router from './router/Router';
import { QueryClientProvider } from '@tanstack/react-query';
import queryClient from './api/queryClient';

const root = document.getElementById('root');
if (!root) throw new Error('Root element not found');

createRoot(root).render(
  <QueryClientProvider client={queryClient}>
    <Router />
  </QueryClientProvider>
);
