# Frontend Modules Guide

## Concept
Features (System Status, Docker, etc.) are separate **modules** in `src/modules/`. This keeps things organized and easy to change.

## Module Structure
A typical module (`src/modules/myfeature/`):
- **`index.js`**: Entry point. Exports module definition (name, store, components).
- **`components/`**: Vue components for this module (e.g., `MyFeatureModule.vue`).
- **`store/`**: Vuex store logic (`index.js`).
    - `index.js`: Namespaced Vuex module (`state`, `mutations`, `actions`, `getters`).
    - `index.test.js` (Recommended): Store unit tests.
- **`README.md`** (Recommended): Module-specific docs.

## State Management (Vuex)
Each module has its own **namespaced Vuex module** (`store/index.js`).
- **Namespacing**: `namespaced: true` keeps state/actions local (e.g., `dispatch('system/fetchData')`).
- **Structure**: Standard Vuex: `state`, `mutations` (sync state changes), `actions` (async, API calls), `getters` (computed state).
- **Global State**: Modules can use global state (`src/store/modules/global.js`) via root dispatch (e.g., `dispatch('global/setError', ..., { root: true })`). Global handles app-wide things (loading, errors, layout).

## Module Registration
1.  Each module's `index.js` exports its definition.
2.  `src/modules/register.js` imports all these definitions and exports them as an array (`registeredModules`).
3.  `src/store/index.js` imports this array and dynamically registers each module's store with Vuex when the app starts.

**Example `index.js` Export:**
```js
// src/modules/system/index.js
import store from './store';
import SystemStatusModule from './components/SystemStatusModule.vue';

export default {
  name: 'system', // Unique ID
  store,         // Vuex module
  // Components used by this module
  components: {
    'system-status-module': SystemStatusModule
    // Add other components specific to this module here
  }
};
```

**Example Registration Snippet:**
```js
// src/modules/register.js
import systemModule from './system';
import dockerModule from './docker';
// ... import others

const registeredModules = [ systemModule, dockerModule /* ... */ ];
export default registeredModules;

// src/store/index.js (Simplified)
import { createStore } from 'vuex';
import globalStore from './modules/global';
import registeredModules from '@/modules/register';

const store = createStore({
  modules: {
    global: globalStore
    // Modules are registered below
  }
});

// Dynamically register modules
registeredModules.forEach(module => {
  if (module.store) {
    store.registerModule(module.name, module.store);
  }
});

export default store;
```

## Adding a New Module
1. Create folder in `src/modules/`.
2. Add components in `components/`.
3. Add namespaced store in `store/`.
4. Create `index.js` exporting `{ name, store, components }`.
5. Import and add to `registeredModules` in `src/modules/register.js`.
6. Add tests.
7. Add a `README.md` (good practice).

See Also:
- [Frontend Overview](overview.md)
- [API Integration Guide](api-integration.md)
