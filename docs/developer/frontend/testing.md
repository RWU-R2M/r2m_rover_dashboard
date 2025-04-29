# Testing Strategy

## Types of Tests
- **Unit Tests**: For Vuex store logic, utility functions, and API service
- **Component Tests**: For Vue components (UI, props, events)
- **Integration Tests**: For API communication and module interaction

## Tools
- [Vitest](https://vitest.dev/) for unit/component tests
- Mocking for API responses

## Running Tests
```bash
npm run test
```

## Coverage
- Minimum 70% code coverage required
- Coverage reports generated with `npm run test:coverage`

## Test Coverage (as of 2025-04-29)
- **API Service**: Basic test for system status fetch with axios mock
- **Global Store**: Test for SET_LOADING mutation
- **Docker Store**: Tests for setting containers and loading state
- **Terminal Store**: Tests for output, appending output, and command history
- **Scripts Store**: Tests for setting scripts, processes, and loading state
- **Control Store**: Tests for system status, performing action, and error state
- **SystemStatusModule Component**: Renders with mock store

## Best Practices
- Mock API calls in tests
- Test error and loading states
- Use descriptive test names
- Place test files alongside code using `.test.js`/`.test.vue` naming

## Example Test Files Added
- `src/services/api.service.test.js`
- `src/store/modules/global.test.js`
- `src/modules/docker/store/index.test.js`
- `src/modules/terminal/store/index.test.js`
- `src/modules/scripts/store/index.test.js`
- `src/modules/control/store/index.test.js`
- `src/modules/system/components/SystemStatusModule.test.js`

## How to Add More Tests
- For new modules, add a `.test.js` file next to the store or component
- Use Vitest and Vue Test Utils for component tests
- Mock API responses as needed

---

**Recent Changes (2025-04-29):**
- Added minimal tests for all core store modules and API service
- Added a component test for SystemStatusModule
- Fixed test mocks to match actual implementation
- All tests now pass with `npm run test`
