# Architecture Overview

## Modular System

- Each dashboard feature is a self-contained module in `src/modules/`
- Modules include:
  - Vue components (UI)
  - Vuex store (state management)
  - API communication via shared service
- Modules register themselves at runtime via `modules/register.js`

## Store Structure

- Uses Vuex with modules for each feature
- Global store (`store/modules/global.js`) manages dashboard pages, refresh, and global state
- Each module has its own store for local state (e.g., `system/store/index.js`)

## API Service Layer

- All API calls go through `src/services/api.service.js`
- Handles:
  - Base URL and timeout from environment variables
  - Error handling and logging
  - Methods for each backend endpoint (system, docker, scripts, processes, commands)

## UI Layer

- Bulma CSS for layout and styling
- Chart.js for data visualization (system stats, etc.)
- FontAwesome for icons
- Responsive design for desktop/tablet

## Data Flow

1. UI triggers Vuex action (e.g., `fetchData`)
2. Action calls API service
3. On success, mutation updates state; on error, error state is set
4. Components reactively update based on state

## Extending the Dashboard

- Add a new module in `src/modules/`
- Implement store, components, and (optionally) routes
- Register the module in `modules/register.js`
- Document the module in `docs/modules/<module>.md`

## Error Handling

- All API errors are caught and logged
- User-friendly error messages are displayed in the UI
- Retry logic can be added in the API service or store actions

## See Also
- [docs/modules/](modules/) for module details
- [docs/testing.md](../testing.md) for testing strategy
- [docs/configuration.md](../configuration.md) for configuration options
