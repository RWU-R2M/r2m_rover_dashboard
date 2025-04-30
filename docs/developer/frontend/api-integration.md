# API Integration Guide

How the frontend talks to the backend API.

## API Service (`src/services/api.service.js`)
All backend communication goes through `api.service.js`.

**Key Features:**
- **Axios**: Uses Axios, configured with base URL (`VITE_API_BASE_URL`) and timeout (`VITE_API_TIMEOUT`). The service automatically adds the `/api` prefix to endpoint paths.
- **Methods**: Provides helpers like `getSystemStatus`, `executeCommand`, `runScript`, etc., plus generic `get`, `post`.
- **Error Handling**: Catches Axios errors, logs them, formats a standard error object (`{ message, details }`).
- **Caching**: Simple cache for GET requests (e.g., `getSystemStatus(useCache, cacheTTL)`). Reduces repeated requests. *Note: Refreshing very quickly might return cached data instead of doing many multiple requests.*
- **Cache Clearing**: `clearCache(endpoint)` method to manually clear cache, useful after POST/PUT actions.
- **Async Scripts**: `runScript` handles async tasks, returning process IDs; `getProcessDetails` polls for status.

## Main Endpoints Used
The service calls these backend endpoints (remember, `/api` is added automatically):
- `GET /system`: System stats (`getSystemStatus()`).
- `GET /docker`: Docker info (`getContainers()`).
- `POST /execute`: Run commands (`executeCommand()`).
- `GET /scripts`: List scripts (`getScripts()`).
- `POST /scripts/<script_name>`: Run a script (`runScript()`).
- `GET /processes`: List script processes (`getProcesses()`).
- `GET /processes/<process_id>`: Get script status (`getProcessDetails()`).
- `POST /control/reboot`: Reboot system (`apiService.post('/control/reboot')`).
- `POST /control/shutdown`: Shutdown system (`apiService.post('/control/shutdown')`).

*See backend docs for full API details.*

## Error Handling Flow
1. `api.service.js` makes request.
2. Axios error occurs (network, bad status).
3. Service catches, logs, formats error object.
4. Service throws/returns formatted error.
5. Vuex action catches, commits `SET_ERROR` in module state.
6. Component shows error from state.

## Config
- **API URL**: `VITE_API_BASE_URL` in `.env` (e.g., `http://localhost:5000`).
- **Timeout**: `VITE_API_TIMEOUT` in `.env` (milliseconds, default 10000).

## Example Usage (Vuex action)
```js
// From src/modules/system/store/index.js
import apiService from '@/services/api.service';

const actions = {
  async fetchData({ commit }) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    try {
      // Get system info, use cache (5 sec TTL)
      const systemData = await apiService.getSystemStatus(true, 5000);
      commit('SET_SYSTEM_DATA', systemData);
    } catch (error) {
      // Commit formatted error from api.service
      commit('SET_ERROR', {
        message: `Failed to fetch system info: ${error.message || 'Unknown'}`,
        details: error.details
      });
    } finally {
      commit('SET_LOADING', false);
    }
  }
};
```
