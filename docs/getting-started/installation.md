# User Guide: ROS Web Dashboard

Welcome to the ROS Web Dashboard! This guide explains how to use each feature of the dashboard to monitor and control your ROS-based rover system.

---

## Dashboard Overview
- The dashboard is organized into modules, each providing a specific set of features.
- You can drag, resize, minimize, and restore modules in the main dashboard view.
- Minimized modules appear in the left sidebar and can be restored with a click.

---

## Modules & Features

### 1. System Status Module
- **Purpose:** View real-time CPU, memory, disk, and network statistics.
- **How to Use:**
  - See usage bars and indicators for system health.
  - Click the refresh button to update data manually.
  - Data auto-refreshes every few seconds (configurable).

### 2. Docker Container Module
- **Purpose:** Monitor and control Docker containers running on the system.
- **How to Use:**
  - View a list of containers with status indicators (green=running, red=stopped).
  - Click on a container for more details.
  - Use start/stop/restart buttons to control containers.

### 3. Command Terminal Module
- **Purpose:** Execute whitelisted system commands and view output.
- **How to Use:**
  - Enter a command or select a preset.
  - View output in the terminal area.
  - Access command history for previous commands.
  - Use the emergency stop button for critical actions.

### 4. Script Management Module
- **Purpose:** List, run, and monitor custom scripts.
- **How to Use:**
  - Select a script from the list.
  - Enter required parameters if needed.
  - Run the script and monitor its status/output.
  - Async scripts show progress and can be monitored in the process list.

### 5. Control Panel Module
- **Purpose:** Access critical system controls (emergency stop, reboot, shutdown).
- **How to Use:**
  - Use the emergency stop for immediate halt.
  - Use reboot/shutdown buttons for system management.
  - Confirm actions in dialogs to prevent accidental triggers.

---

## General Tips
- **Auto-Refresh:** Most modules auto-refresh; you can change the interval in settings.
- **Error Handling:** Errors are shown as notifications; retry or check your connection if needed.
- **Layout:** Drag and resize modules to customize your dashboard. Reset layout from the dashboard menu if needed.
- **Settings:** Access global settings from the top bar for refresh intervals and preferences.

---

## Troubleshooting
- If the dashboard is not updating, check your backend connection and API status.
- Use the reset layout option if modules are not displaying correctly.
- For persistent issues, check browser console logs or contact your system administrator.

---

For more details, see the module-specific documentation or contact your system administrator.