# Architecture Overview

This document provides an overview of the architecture for the Web Dashboard Stats system.

## Components
- **Frontend**: Vue.js SPA (Single Page Application) for the dashboard UI.
- **Backend**: Flask-based REST API for system monitoring, Docker management, and script execution.
- **Custom Scripts**: User-defined scripts managed and executed by the backend.

## Directory Structure
- `frontend/`: Vue.js application source code
- `localbackend/`: Flask backend source code
- `config/scripts/`: Configuration files for custom scripts
- `docs/`: Documentation

## Data Flow
1. The frontend communicates with the backend via REST API endpoints.
2. The backend collects system stats, manages Docker containers, and executes scripts.
3. Results are returned to the frontend and displayed in the dashboard.

## Backend Structure
- `app.py`: Entry point for the Flask server
- `app/routes.py`: API endpoint implementations
- `app/utils.py`: Utility functions for system and process management
- `config/scripts/`: Script configuration files
- `scripts/`: Script source files

## Frontend Structure
- `src/`: Main source code
- `src/modules/`: Dashboard modules (system, docker, scripts, etc.)
- `src/services/`: API service layer
- `src/store/`: State management
