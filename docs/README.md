# Documentation

Welcome to the documentation for the project. Below is the table of contents to help you navigate through the documentation.

## Table of Contents

### Getting Started
- [Installation](getting-started/installation.md)
- [Architecture](getting-started/architecture.md)
- [Management Script](#management-script)


### Developer Documentation
#### Frontend
- [Overview](developer/frontend/overview.md)
- [Modules](developer/frontend/modules.md)
- [API Integration](developer/frontend/api-integration.md)
- [UI/UX Decisions](developer/frontend/ui-ux-decisions.md)
- [Testing](developer/frontend/testing.md)

#### Backend
- [Overview](developer/backend/overview.md)
- [API Reference](developer/backend/api.md)
- [Scripts](developer/backend/scripts.md)
- [Testing](developer/backend/testing.md)

## Management Script

The project includes a comprehensive management script (`manage.sh`) that simplifies installation, running, and testing the application.

### Key features
- Start/stop backend and frontend servers
- Build and run the frontend in Docker
- Test both frontend and backend components
- Generate documentation

### Basic usage
```bash
# Install dependencies
./manage.sh install

# Start everything
./manage.sh start-all

# Stop everything
./manage.sh stop-all

# Display help and all available commands
./manage.sh help
```

For more details, run `./manage.sh help` to see all available commands.

## License

[MIT License](LICENSE) # Assuming MIT, update if different


Made by: Luiz Mendonca