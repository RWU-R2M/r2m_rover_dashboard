# Installation Guide

This guide describes how to install and set up the Web Dashboard Stats system.

## Prerequisites
- Python 3.8+
- Node.js 16+
- Docker (optional, for Docker monitoring)

## Backend Setup
1. Navigate to the `localbackend/` directory.
2. Install Python dependencies:
   ```sh
   pip install -r requirements.txt
   ```
3. Start the backend server:
   ```sh
   python app.py
   ```

## Frontend Setup (TODO! test docker setup)
1. Navigate to the `frontend/` directory.
2. Install Node.js dependencies:
   ```sh
   npm install
   ```
3. Start the frontend development server:
   ```sh
   npm run dev
   ```

## Accessing the Dashboard
Open your browser and go to `http://localhost:3000` (or the port shown in the terminal) to access the dashboard.

