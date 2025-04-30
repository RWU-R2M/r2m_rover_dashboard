# Frontend Overview


## Purpose
It's a web UI to watch and monitor the Raspberry pi. It talks to a backend API to show live data and run commands in the rapsberry pi.

## Tech Stack
- **Framework**: Vue.js 3 (Composition API)
- **State**: Vuex 4 (namespaced modules)
- **Routing**: Vue Router 4
- **HTTP**: Axios
- **UI**: Bulma (CSS)
- **Build**: Vite

## Basic Setup & Running
1.  Go to `frontend/`: `cd frontend`
2.  Install stuff: `npm install`
3.  Run dev server: `npm run dev` (usually at `http://localhost:3000`)

## Project Structure (`frontend/src/`)
- `main.js`: App starts here (Vue, Vuex, Router setup).
- `App.vue`: Main layout component.
- `assets/`: CSS (`styles/main.css`), images.
- `components/`: Shared Vue components (like `DashboardModule.vue`). Module-specific components live inside their module's folder.
- `modules/`: Feature modules (like `system`, `docker`). Each has `components/` and `store/`.
    - `register.js`: Exports a list of all available modules. The actual registration happens in `store/index.js`.
- `router/`: Page routing (`index.js`).
- `services/`: API client (`api.service.js`).
- `store/`: Vuex setup (`index.js`), global state (`modules/global.js`).
- `views/`: Top-level pages (like `Dashboard.vue`).

## More Info
- **API Interaction**: How the frontend uses the backend API. See [API Integration Guide](api-integration.md).
- **Modules**: How features are split into modules. See [Modules Guide](modules.md).
- **Testing**: Running and writing tests. See [Testing Guide](testing.md).

## License

[MIT License](LICENSE) # Assuming MIT, update if different

Made by: Luiz Mendonca