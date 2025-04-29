# System Monitoring API Documentation

## API Base URL

```
http://localhost:5000
```

## Authentication

**Currently, the API does not implement authentication.**

## Configuration (.env File)

The API server can be configured using environment variables in a `.env` file. This allows you to enable or disable specific endpoints for security purposes and configure other security settings.

### Available Configuration Options

```properties
# Server Configuration
PORT=5000                      # Port the server listens on
FLASK_DEBUG=True               # Enable/disable debug mode

# API Route Configurations (true/false)
ENABLE_STATUS_ENDPOINT=true    # Base status endpoint (/)
ENABLE_SYSTEM_ENDPOINT=true    # System info endpoint (/api/system)
ENABLE_DOCKER_ENDPOINT=true    # Docker containers endpoint (/api/docker)
ENABLE_COMMAND_ENDPOINT=true   # Command execution endpoint (/api/execute)
ENABLE_SCRIPTS_ENDPOINT=true  # Custom scripts endpoints (/api/scripts)
ENABLE_PROCESSES_ENDPOINT=true # Process management endpoints (/api/processes)

# Security Settings
# Comma-separated list of allowed commands (empty = no restrictions)
COMMAND_WHITELIST=ls,df,ps,free,top,docker,cat,echo,hostname

# Maximum timeout for command execution in seconds
COMMAND_MAX_TIMEOUT=60

# Maximum timeout for script execution in seconds
SCRIPT_MAX_TIMEOUT=60
```

### Enabling/Disabling Endpoints

Set the corresponding environment variable to `true` to enable an endpoint or `false` to disable it. When an endpoint is disabled, requests to that endpoint will receive a 404 Not Found response.

### Command Whitelist

The `COMMAND_WHITELIST` setting controls which commands can be executed through the `/api/execute` endpoint. Only the base command (first word) is checked against the whitelist. For example, if `ls` is in the whitelist, then commands like `ls -la` or `ls /home` will be allowed.

If the whitelist is empty, all commands will be allowed (not recommended for safety).

## Response Format

All API responses are in JSON format. Successful requests typically return HTTP status code 200 with a JSON response body. Failed requests return appropriate HTTP error codes (4xx for client errors, 5xx for server errors) with a JSON body containing error information.

Standard error response format:
```json
{
  "error": "Error message describing what went wrong"
}
```

## Endpoint: Server Status

Provides basic information about the server status.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_STATUS_ENDPOINT` environment variable.

### Request

```
GET /
```

### Response

#### Success Response (200 OK)

```json
{
  "status": "running",
  "server_time": "2025-04-28 12:34:56",
  "message": "REST API server is running"
}
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| status | string | Current status of the server, typically "running" |
| server_time | string | Current server time in "YYYY-MM-DD HH:MM:SS" format |
| message | string | Human-readable status message |

---

## Endpoint: System Statistics

Retrieves detailed system resource statistics including CPU, memory, disk usage, and network information.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_SYSTEM_ENDPOINT` environment variable.

### Request

```
GET /api/system
```

### Response

#### Success Response (200 OK)

```json
{
  "cpu": {
    "total_percent": 12.5,
    "per_core": [10.2, 15.3, 12.0, 12.5],
    "cores": 4,
    "physical_cores": 2
  },
  "memory": {
    "total": 16777216000,
    "available": 8388608000,
    "used": 8388608000,
    "percent": 50.0
  },
  "disk": {
    "total": 1099511627776,
    "used": 549755813888,
    "free": 549755813888,
    "percent": 50.0
  },
  "network": {
    "eth0": {
      "bytes_sent": 1024000,
      "bytes_recv": 2048000,
      "packets_sent": 1000,
      "packets_recv": 2000
    },
    "wlan0": {
      "bytes_sent": 512000,
      "bytes_recv": 1024000,
      "packets_sent": 500,
      "packets_recv": 1000
    }
  }
}
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| cpu.total_percent | float | Overall CPU usage percentage (0-100) |
| cpu.per_core | array of float | CPU usage percentage for each core |
| cpu.cores | integer | Number of logical CPU cores |
| cpu.physical_cores | integer | Number of physical CPU cores |
| memory.total | integer | Total physical memory in bytes |
| memory.available | integer | Available memory in bytes |
| memory.used | integer | Used memory in bytes |
| memory.percent | float | Memory usage percentage (0-100) |
| disk.total | integer | Total disk space in bytes |
| disk.used | integer | Used disk space in bytes |
| disk.free | integer | Free disk space in bytes |
| disk.percent | float | Disk usage percentage (0-100) |
| network | object | Object containing network interface statistics |
| network.{interface} | object | Statistics for a specific network interface |
| network.{interface}.bytes_sent | integer | Total bytes sent by the interface |
| network.{interface}.bytes_recv | integer | Total bytes received by the interface |
| network.{interface}.packets_sent | integer | Total packets sent by the interface |
| network.{interface}.packets_recv | integer | Total packets received by the interface |

---

## Endpoint: Docker Containers Information

Retrieves information about Docker containers running on the system.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_DOCKER_ENDPOINT` environment variable.

### Request

```
GET /api/docker
```

### Response

#### Success Response (200 OK)

```json
{
  "containers": [
    {
      "ID": "123abc456def",
      "Names": "web-server",
      "Image": "nginx:latest",
      "Command": "nginx -g 'daemon off;'",
      "Created": "2023-04-01 00:00:00",
      "Status": "Up 10 days",
      "Ports": "80/tcp, 443/tcp",
      "Size": "128MB",
      "Networks": "bridge",
      "State": "running"
    }
  ]
}
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| containers | array | Array of container objects |
| containers[].ID | string | Docker container ID |
| containers[].Names | string | Container name |
| containers[].Image | string | Container image name and tag |
| containers[].Command | string | Command running in the container |
| containers[].Created | string | Creation timestamp |
| containers[].Status | string | Container status (e.g., "Up 10 days") |
| containers[].Ports | string | Exposed ports |
| containers[].Size | string | Container size information |
| containers[].Networks | string | Networks the container is connected to |
| containers[].State | string | Container state (running, exited, etc.) |

---

## Endpoint: Command Execution

Executes a specified command on the server and returns the result. This endpoint accepts POST requests with a JSON body containing the command to execute.

**Configurable**: 
- This endpoint can be enabled/disabled using the `ENABLE_COMMAND_ENDPOINT` environment variable.
- Commands that can be executed are restricted by the `COMMAND_WHITELIST` setting in the `.env` file.
- The maximum allowed timeout is controlled by the `COMMAND_MAX_TIMEOUT` setting.

### Request

```
POST /api/execute
```

#### Request Body

```json
{
  "command": "ls -la /home",
  "timeout": 30
}
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| command | string | Yes | The command to execute on the server (must be in the whitelist) |
| timeout | integer | No | Maximum execution time in seconds (capped by COMMAND_MAX_TIMEOUT) |

---

## Endpoint: List Available Scripts

Lists all available custom scripts that can be executed via the API. This provides information about the scripts' capabilities, input requirements, and expected outputs.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_SCRIPTS_ENDPOINT` environment variable.

### Request

```
GET /api/scripts
```

---

## Endpoint: Execute Custom Script

Executes a custom script with optional input parameters and returns the result. This endpoint is used to run user-defined scripts that have been configured on the server.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_SCRIPTS_ENDPOINT` environment variable.

### Request

```
POST /api/scripts/{script_name}
```

---

## Endpoint: List Processes

Lists all tracked script processes, both running and completed. This endpoint provides a way to monitor asynchronous scripts that were started via the `/api/scripts/{script_name}` endpoint.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_PROCESSES_ENDPOINT` environment variable.

### Request

```
GET /api/processes
```

---

## Endpoint: Get Process Status

Gets the status of a specific process by its ID. This endpoint provides detailed information about a script process, whether it's still running or has completed.

**Configurable**: This endpoint can be enabled/disabled using the `ENABLE_PROCESSES_ENDPOINT` environment variable.

### Request

```
GET /api/processes/{process_id}
```

---

## Script Configuration

Scripts are configured using YAML or JSON files in the `config/scripts/` directory. Each script must have its own configuration file that defines:

- The script name and description
- The path to the script file (relative to the `scripts/` directory)
- Whether the script accepts input parameters
- How input is passed to the script (JSON via stdin or as environment variables)
- Whether the script runs synchronously or asynchronously
- The expected output format (for documentation)

---

## Process Management

The server includes a built-in process management system for asynchronous scripts:

1. When an asynchronous script is started, it's assigned a unique process ID
2. The server maintains a registry of all running and recently completed processes
3. A background thread continuously monitors running processes to detect when they finish
4. When a process completes, its status is updated and it's kept in memory for one hour
5. After one hour, completed processes are removed from memory
6. The status of any tracked process can be queried via the `/api/processes/{process_id}` endpoint
7. A list of all tracked processes can be obtained via the `/api/processes` endpoint