# Scripts Directory

## Overview

This directory contains scripts that can be executed via the REST API. Scripts in this directory are automatically discovered and made available through the `/api/scripts` endpoint when properly configured.

## Script Categories

- **Example Scripts**: Located in the `examples/` subdirectory, these are demonstration scripts only and not intended for production use.
- **Production Scripts**: Scripts in the root of this directory should be used for actual system operations.

## Example Scripts

The following example scripts are provided for demonstration purposes:

- `examples/example_system_status.py`: Shows how to return system information synchronously
- `examples/example_long_task.py`: Demonstrates a long-running asynchronous task

These scripts show the proper format for both synchronous and asynchronous script execution through the API.

## Creating Your Own Scripts

To add your own scripts:

1. Create a new script file in this directory
2. Create a YAML configuration file in `../config/scripts/` directory
3. Ensure your script follows the input/output conventions:
   - For synchronous scripts: Output valid JSON to stdout
   - For async scripts: No specific output requirements
   - For scripts accepting input: Read from stdin or environment variables

See the example scripts as templates for implementing your own functionality.

## Script Configuration

Each script requires a configuration file in the `../config/scripts/` directory with the following structure:

```yaml
name: "script-name"              # Name used in API calls
description: "Script description" # Human-readable description
script_path: "script_file.py"    # Path relative to the scripts directory
endpoint: "custom-endpoint"      # Custom endpoint path segment (used in /api/scripts/<endpoint>)
accepts_input: true/false        # Whether the script accepts input
input_method: "json"             # How input is passed (json or env). Default is json.
async: true/false                # Whether the script runs asynchronously. Default is false.
# Documentation of expected input format using JSON Schema
input_schema:
  type: object
  properties:
    param1:
      type: string
      description: "Description of param1"
    param2:
      type: number
      description: "Description of param2"
      default: 10 # Optional default value
  required:
    - param1 # Optional list of required parameters
# Documentation of expected output format (for synchronous scripts)
expected_output:
  success: "boolean"
  message: "string"
  data: "object"
```

**Important:** The `input_schema` must follow the JSON Schema structure with `type: object` and a `properties` key defining the parameters. The frontend relies on this structure to generate input fields.

## Examples

### System Status Script

The example System Status script configuration:

```yaml
name: "example-system-status"    # Note: This matches the actual configuration
description: "EXAMPLE: Get detailed system status information"
script_path: "examples/example_system_status.py"
endpoint: "status"               # Endpoint is "status"
accepts_input: false
async: false
expected_output: {
  "status": "string",
  "cpu_temp": "number",
  "uptime": "string",
  "hostname": "string",
  "platform": "string",
  "cpu_cores": "number"
}
```

API call:
```bash
curl -X POST http://localhost:5000/api/scripts/example-system-status
```

### Long Task Script

The Long Task script configuration:

```yaml
name: "long-task"
description: "EXAMPLE: Run a long-running task in the background"
script_path: "examples/example_long_task.py"
endpoint: "task"
accepts_input: true
input_method: "json"
async: true
input_schema:
  type: object
  properties:
    duration:
      type: number
      description: "Duration of the task in seconds"
  required:
    - duration
```

API call:
```bash
curl -X POST http://localhost:5000/api/scripts/long-task \
  -H "Content-Type: application/json" \
  -d '{"duration": 60}'
```

## Best Practices

1. Include comprehensive error handling in your scripts
2. For synchronous scripts, always return valid JSON
3. Validate all input parameters
4. Include detailed logging for debugging
5. Keep scripts focused on a single responsibility
