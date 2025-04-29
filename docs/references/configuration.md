# Configuration Guide

## Environment Variables
- `VITE_API_BASE_URL`: Backend API URL (default: http://localhost:5000)
- `VITE_API_TIMEOUT`: API request timeout in ms (default: 15000)
- `VITE_REFRESH_INTERVAL`: Dashboard auto-refresh interval in ms (default: 5000)
- `VITE_DASHBOARD_TITLE`: Dashboard title (default: "ROS Web Dashboard")
- `VITE_ENABLE_ROS_BRIDGE`: Enable ROS Bridge integration (default: false)

## User Preferences
- Stored in `localStorage`
- Includes refresh interval, dashboard layout, last selected page/module

## Runtime Configuration
- Modules can expose their own settings
- Global settings available in the settings view
