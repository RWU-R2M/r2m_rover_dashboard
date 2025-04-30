# Backend Usage Guide

This guide explains how to use the backend REST API and custom script system. 

---

## API Base URL

```
http://localhost:5000
```

---

## Configuration (.env File)

Configure the backend using a `.env` file in the localbackend directory. Example options:

```
PORT=5000                      # Port the server listens on
FLASK_DEBUG=True               # Enable/disable debug mode
ENABLE_STATUS_ENDPOINT=true    # Enable / endpoint
ENABLE_SYSTEM_ENDPOINT=true    # Enable /api/system
ENABLE_DOCKER_ENDPOINT=true    # Enable /api/docker
ENABLE_COMMAND_ENDPOINT=true   # Enable /api/execute
ENABLE_SCRIPTS_ENDPOINT=true  # Enable /api/scripts
ENABLE_PROCESSES_ENDPOINT=true # Enable /api/processes
COMMAND_WHITELIST=ls,df,ps,free,top,docker,cat,echo,hostname
COMMAND_MAX_TIMEOUT=60
SCRIPT_MAX_TIMEOUT=60
```

- Set each ENABLE_* variable to true/false to enable/disable endpoints.
- Only commands in COMMAND_WHITELIST can be run via /api/execute.
- Max timeouts are enforced for commands and scripts.

---

## API Endpoints

### 1. Server Status
- **GET /**
- Returns server status and time.

### 2. System Statistics
- **GET /api/system**
- Returns CPU, memory, disk, and network stats.

### 3. Docker Containers
- **GET /api/docker**
- Lists Docker containers (if Docker is installed).

### 4. Command Execution
- **POST /api/execute**
- Body: `{ "command": "ls -la", "timeout": 30 }`
- Runs a whitelisted shell command.

### 5. List Scripts
- **GET /api/scripts**
- Lists all available custom scripts.

### 6. Execute Script
- **POST /api/scripts/{script_name}**
- Runs a configured script. Input/output depends on script config.

### 7. List Processes
- **GET /api/processes**
- Lists running and recent async script processes.

### 8. Get Process Status
- **GET /api/processes/{process_id}**
- Gets status/result of a specific process.

---

## Custom Scripts System

### Script Directory
- Place scripts in `localbackend/scripts/`.
- Example/demo scripts are in `localbackend/scripts/examples/`.
- Production scripts should be in the root of `scripts/`.

### Script Configuration
- Each script needs a YAML config in `localbackend/config/scripts/`.
- Example config:

```yaml
name: "long-task"
description: "Run a long-running task in the background"
script_path: "examples/example_long_task.py"
endpoint: "long-task"
accepts_input: true
input_method: "json"
async: true
input_schema:
  type: object
  properties:
    duration:
      type: number
      description: "Duration in seconds"
  required:
    - duration
```

- `name`: Used in API calls and must be unique.
- `script_path`: Path relative to `scripts/`.
- `endpoint`: Used as the POST endpoint under `/api/scripts/`.
- `accepts_input`: If true, script can receive input.
- `input_method`: "json" (via stdin) or "env" (environment variables).
- `async`: If true, script runs in background and is tracked as a process.
- `input_schema`: (optional) JSON Schema for input validation and frontend UI.
- `expected_output`: (optional) Document expected output for frontend/docs.

### Script Input/Output Conventions
- Synchronous scripts: Output valid JSON to stdout.
- Asynchronous scripts: No output required; status/result is tracked.
- Scripts accepting input: Read from stdin (if `input_method: json`) or environment variables (if `input_method: env`).

### Example API Calls

- Run system status script:
  ```bash
  curl -X POST http://localhost:5000/api/scripts/example-system-status
  ```
- Run long task script:
  ```bash
  curl -X POST http://localhost:5000/api/scripts/long-task \
    -H "Content-Type: application/json" \
    -d '{"duration": 60}'
  ```

---

## Process Management
- Async scripts are assigned a process ID and tracked.
- Use `/api/processes` to list all processes.
- Use `/api/processes/{process_id}` to get status/result.
- Completed processes are kept for 1 hour.

---

## Best Practices
- Always validate input in your scripts.
- For sync scripts, always output valid JSON.
- Use error handling and logging.
- Keep scripts focused and simple.

---

## Security Notes
- Only whitelisted commands can be run via `/api/execute`.
- Disable endpoints you do not need.
- No authentication is enabled do not expose the API to untrusted networks.

---

For more details on project structure and setup, see the [overview](overview.md).
