# Web Dashboard Stats

A web-based dashboard for monitoring and managing system resources, Docker containers, and custom scripts.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Architecture](#architecture)
- [Usage](#usage)
- [Developer Guide](#developer-guide)

## Overview
A dashboard for real-time system monitoring and management, featuring:
- System resource statistics (CPU, memory, disk, network)
- Docker container management
- Custom script execution and process tracking

## Installation
The easiest way to set up the system is using our management script:

```bash
# Install dependencies
./manage.sh install

# Start both backend and frontend (Docker)
./manage.sh start-all
```

Then access the dashboard at http://localhost:8080

For detailed instructions and alternative setup options, see [docs/getting-started/installation.md](docs/getting-started/installation.md).

## Architecture
See [docs/getting-started/architecture.md](docs/getting-started/architecture.md) for an overview of the system architecture.

## Usage

### Using the management script (recommended)
```bash
# Start everything
./manage.sh start-all

# When done, stop everything
./manage.sh stop-all

# See all available commands
./manage.sh help
```



## Developer Guide
See the `docs/developer/` directory for contributing, backend, and frontend development guides.