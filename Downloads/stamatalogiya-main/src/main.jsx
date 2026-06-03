import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';
import { store } from './store';
import App from './App';
import './styles/global.css';
import './styles/components.css';
import './styles/media.css';
import './styles/responsive.css';
import './styles/phones.css';
import './styles/admin.css';
import './styles/forum.css';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </StrictMode>,
);
