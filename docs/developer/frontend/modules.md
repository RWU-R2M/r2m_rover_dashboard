# Developer Guide: Adding New Modules

This guide explains how to add a new feature module to the ROS Web Dashboard frontend.

## 1. Create the Module Directory
- In `src/modules/`, create a new folder (e.g., `myfeature/`).
- Add a `components/` subfolder for Vue components.
- Add a `store/` subfolder for Vuex store logic.

## 2. Implement the Vue Component
- Create your main module component in `components/` (e.g., `MyFeatureModule.vue`).
- Follow UI/UX conventions (see `UI_UX_DECISIONS.md`).
- Use props, emits, and slots as needed for flexibility.

## 3. Implement the Store
- In `store/`, create `index.js` for Vuex state, actions, mutations, and getters.
- Handle loading and error states consistently.

## 4. API Integration
- Use the shared API service (`src/services/api.service.js`) for all HTTP requests.
- Document any new endpoints in the module README.

## 5. Register the Module
- In `src/modules/register.js`, import and add your module to the registry.
- Export an object with at least `{ name, store, component }`.

## 6. Add Documentation
- Create a `README.md` in your module folder.
- Document the module's purpose, API usage, UI, store, and extensibility.

## 7. Add Tests
- Write unit tests for the store and component.
- Add integration tests for API communication.

## 8. UI Integration
- The dashboard will automatically include registered modules.
- Test the module in the dashboard grid and minimized bar.

## Example Module Export
```js
// src/modules/myfeature/index.js
import store from './store';
import MyFeatureModule from './components/MyFeatureModule.vue';

export default {
  name: 'myfeature',
  store,
  component: MyFeatureModule
};
```

## See Also
- [MODULE_SYSTEM.md](MODULE_SYSTEM.md)
- [UI_UX_DECISIONS.md](UI_UX_DECISIONS.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
