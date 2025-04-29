# API Integration Guide

This document explains how the frontend communicates with the backend REST API.

## API Service Layer
- All API calls are made via `src/services/api.service.js`.
- Uses Axios for HTTP requests.
- Handles errors, timeouts, and retries.
- Supports both synchronous and asynchronous script execution.

## Main Endpoints Used
- `GET /api/system` — System statistics (CPU, memory, disk, network)
- `GET /api/docker` — Docker containers info
- `POST /api/execute` — Execute whitelisted system commands
- `GET /api/scripts` — List available custom scripts
- `POST /api/scripts/<script_name>` — Execute a custom script
- `GET /api/processes` — List running/completed script processes
- `GET /api/processes/<process_id>` — Get status of a specific process

## Error Handling
- All API errors are caught and logged
- User-friendly error messages are displayed
- Retry logic is implemented for transient errors

## Asynchronous Operations
- Async scripts return a process ID
- The frontend polls `/api/processes/<process_id>` to monitor status
- Output is displayed when available

## Configuration
- API base URL and timeout are set via environment variables
- See `.env` or `VITE_API_BASE_URL` and `VITE_API_TIMEOUT`

## Example Usage
```js
import apiService from '@/services/api.service';

// Get system stats
const stats = await apiService.getSystemStatus();

// Run a command
const result = await apiService.executeCommand('df -h');

// List scripts
const scripts = await apiService.getScripts();

// Run a script (async)
const runResult = await apiService.runScript('long-task', { duration: 30 });
if (runResult.process_id) {
  // Poll for status
  const status = await apiService.getProcessDetails(runResult.process_id);
}
```
