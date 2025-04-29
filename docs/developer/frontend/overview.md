# Module System

The dashboard uses a plugin-based modular architecture. Each feature is implemented as a self-contained module.

## Module Structure
- Vue component(s) for UI (in `components/`)
- Vuex store module (in `store/`)
- Optional routes/views
- API communication via shared service

## Registration
- Modules are registered in `src/modules/register.js`
- Each module exports an object with its config, store, and components
- The core app dynamically loads and registers modules at startup

## Adding a New Module
1. Create a new folder in `src/modules/`
2. Add your Vue component(s) in `components/`
3. Add a Vuex store module in `store/`
4. Export the module in `index.js`
5. Register it in `register.js` (or use auto-discovery)

## Example Module Export
```js
// src/modules/example/index.js
import store from './store';
import ExampleModule from './components/ExampleModule.vue';

export default {
  name: 'example',
  store,
  component: ExampleModule
};
```

## Module Guidelines
- Handle your own loading/error states
- Use the shared API service
- Follow UI/UX conventions for consistency
