# Installation Guide

This guide describes how to install and set up the Web Dashboard Stats system.

## Prerequisites
- Python 3.8+
- Docker
- (Node.js 16+ - only needed for frontend development, not for regular usage with Docker)

## Using the Management Script (Recommended)

The easiest way to install and run the system is using the provided management script:

1. Install dependencies and set up the system:
   ```sh
   ./manage.sh install
   ```

2. Start both backend and frontend:
   ```sh
   ./manage.sh start-all
   ```

3. When you're done, stop everything:
   ```sh
   ./manage.sh stop-all
   ```

4. To see all available commands:
   ```sh
   ./manage.sh help
   ```

## Accessing the Dashboard
With the management script, access the dashboard at `http://localhost:8080`.

## Manual Setup (Alternative)

### Backend Setup
1. Navigate to the `localbackend/` directory.
2. Install Python dependencies:
   ```sh
   pip install -r requirements.txt
   ```
3. Manual start the backend server:
   ```sh
   python app.py
   ```

### Frontend Setup 
1. Navigate to the `frontend/` directory.
2. Install Node.js dependencies:
   ```sh
   npm install
   ```
3. Start the frontend development server:
   ```sh
   npm run dev
   ```

When running manually, access the dashboard at `http://localhost:3000` (or the port shown in the terminal).

