# System Monitoring REST API

A Flask-based REST API server for monitoring system resources, Docker containers, executing system commands and customs scripts. Modular and easy to add up functionality !

## Features

- System resource monitoring (CPU, memory, disk, network)
- Docker container monitoring
- Command execution endpoint for running system commands
- Custom script execution via API endpoints with process management
- Automatic cleanup and monitoring of finished asynchronous processes of script
- System shutdown and reboot control (via API)
- JSON response format
- Error handling and logging
- Configurable Features via environment variables

## Requirements
-> See requirements.txt

-> because this executes system commands on the bash it ideally **shouldn't** run in a docker container

## Installation

1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure environment variables:
   Create a `.env` file in the `localbackend` directory. See the [Configuration section in the Backend Usage Guide](backend_usage.md#configuration-env-file) for details on available variables.

3. Run the server:
   ```bash
   python app.py
   ```

## Configuration

The server is configured using environment variables in the `.env` file. You can enable/disable endpoints, set command whitelists, and configure timeouts.

**For a detailed explanation of all configuration options, see the [Configuration section in the Backend Usage Guide](backend_usage.md#configuration-env-file).**

## Custom Scripts

The server supports executing custom scripts through the API, allowing you to extend functionality without modifying core code. Scripts are placed in `localbackend/scripts/` and configured via YAML files in `localbackend/config/scripts/`.

**For detailed instructions on creating, configuring, and executing custom scripts, including input/output handling and process management, see the [Custom Scripts System section in the Backend Usage Guide](backend_usage.md#custom-scripts-system).**

## API Endpoints

The API provides endpoints for system monitoring, Docker info, command execution, and script management.

**For a complete list of endpoints, request/response formats, and examples, see the [API Endpoints section in the Backend Usage Guide](backend_usage.md#api-endpoints).**

## Security Considerations

⚠️ **Warning**: The command execution, script execution, and system control (shutdown/reboot) endpoints can pose significant security risks.

- Use the `COMMAND_WHITELIST` setting.
- Disable unused endpoints.
- Verify custom scripts.
- Implement proper authentication/authorization if needed (currently none).
- Avoid exposing the server directly to untrusted networks.

**See the [Security Notes in the Backend Usage Guide](backend_usage.md#security-notes) for more details.**

## Project Structure

```
localbackend/
├── app.py                  # Main application entry point
├── requirements.txt        # Python dependencies
├── .env                    # Environment configuration (example)
├── app/
│   ├── __init__.py
│   ├── routes.py
│   └── utils.py
├── scripts/
│   ├── emergency_stop.py
│   └── examples/
│       └── ...             # Example scripts
├── config/
│   └── scripts/
│       └── ...             # Script configuration files
├── test/
│   ├── run_all_tests.py
│   └── test_results.log
└── ...
```

## Development

### Adding new endpoints
(Usually not needed; prefer adding custom scripts)

1. Define a Resource class in `app/routes.py`.
2. Add it to `api_resources`.
3. Implement utility functions in `app/utils.py`.
4. Add `.env` config if needed.
5. Write tests.
6. Update documentation ([Backend Usage Guide](backend_usage.md)).

### Adding new custom scripts

1. Create script in `scripts/`.
2. Create config in `config/scripts/`.
3. Follow input/output conventions.

**See the [Custom Scripts System section in the Backend Usage Guide](backend_usage.md#custom-scripts-system) for details.**

## Testing

The backend includes a comprehensive test suite to verify API functionality.

### Using `manage.sh`

The easiest way to run tests is using the main project management script:

```bash
./manage.sh test-backend
```

This command will:
1. Check if the backend server is running (it needs to be running for the tests).
2. Execute the test script `localbackend/test/run_all_tests.py`.
3. Report the results and log them to `localbackend/test/test_results.log`.

You can also run both frontend and backend tests using:

```bash
./manage.sh test-all
```

### Running Manually

Alternatively, you can run the test script directly:

1.  **Ensure the backend server is running:**
    ```bash
    cd localbackend
    python app.py &
    cd .. 
    ```
2.  **Navigate to the test directory and run the script:**
    ```bash
    cd localbackend/test
    python run_all_tests.py
    ```

The script `run_all_tests.py` covers:
- Basic API endpoint availability and structure.
- Process management (starting async scripts, checking status, completion).
- Script execution (sync and async, with/without input).
- Docker endpoint functionality.
- Command execution endpoint (whitelisting).
- API error handling (invalid requests, non-existent resources).


**Don't forget to include your own tests if you add more features later.**
- Avoid tests that have a very limited scope; focus on testing complete behaviors rather than isolated unit tests for trivial functions.

- If you are fixing an issue, try to figure out why the issue was not detected in the previous tests and then once you fix the issue also modify the tests, so it checks also for that issue.

## Further Documentation

For detailed API usage, configuration, and script management, refer to the **[Backend Usage Guide](backend_usage.md)**.

## License

[MIT License](LICENSE) # Assuming MIT, update if different

Made by: Luiz Mendonca
