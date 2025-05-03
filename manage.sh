#!/bin/bash
# Master script for ROS Web Dashboard maintenance tasks
# This script provides a unified entry point for testing, optimization, and documentation tasks

# Set colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/localbackend"
TEST_DIR="$BACKEND_DIR/test"
VENV_PATH="$BACKEND_DIR/venv" # Define venv path
PYTHON_EXEC="$VENV_PATH/bin/python" # Define Python executable in venv
PIP_EXEC="$VENV_PATH/bin/pip" # Define pip executable in venv

# Docker settings for frontend
FRONTEND_IMAGE_NAME="ros-web-dashboard-frontend"
FRONTEND_CONTAINER_NAME="ros-frontend-container"
FRONTEND_PORT=8080 # Host port to map to container's port 80

# Print banner
function print_banner() {
    echo -e "${BLUE}=========================================================${NC}"
    echo -e "${BLUE}               ROS Web Dashboard Tools                   ${NC}"
    echo -e "${BLUE}=========================================================${NC}"
    echo ""
}

# Print section header
function print_section() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
    echo -e "${YELLOW}-----------------------------------------------------${NC}"
}

# Check if a command exists
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if the backend server is running
function check_backend_running() {
    if curl -s http://localhost:5000/api/system > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if the frontend container is running
function check_frontend_container_running() {
    if docker ps -q -f name="^/${FRONTEND_CONTAINER_NAME}$" | grep -q .; then
        return 0 # Running
    else
        return 1 # Not running
    fi
}

# Check if the backend virtual environment exists and is usable
function check_venv() {
    if [ ! -f "$PYTHON_EXEC" ] || [ ! -f "$PIP_EXEC" ]; then
        echo -e "${RED}Error: Backend Python virtual environment not found or incomplete.${NC}"
        echo "Please run './manage.sh install' first to set it up."
        return 1
    fi
    return 0
}

# Run backend tests
function run_backend_tests() {
    print_section "Running Backend Tests"
    
    if ! check_venv; then return 1; fi

    # Check if backend server is running
    if ! check_backend_running; then
        echo -e "${RED}Error: Backend server is not running.${NC}"
        echo "Please start the backend server before running tests."
        echo "  cd $BACKEND_DIR"
        echo "  python app.py"
        return 1
    fi
    
    # Run the comprehensive test suite using venv python
    echo "Running comprehensive backend tests..."
    cd "$TEST_DIR" || exit
    "$PYTHON_EXEC" run_all_tests.py
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backend tests completed successfully!${NC}"
    else
        echo -e "${RED}Some backend tests failed. Please check the log for details.${NC}"
    fi
}

# Function to run backend endpoint disabling tests
function run_backend_disable_tests() {
    print_section "Running Backend Endpoint Disabling Tests"
    
    if ! check_venv; then return 1; fi

    # Use the Python version of the endpoint disabling tests
    DISABLE_TEST_SCRIPT="$TEST_DIR/test_endpoint_disabling.py"
    if [ -f "$DISABLE_TEST_SCRIPT" ]; then
        echo "Running endpoint disabling tests (this will start/stop the server multiple times)..."
        cd "$TEST_DIR" || exit
        # Use venv python
        "$PYTHON_EXEC" test_endpoint_disabling.py
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Backend endpoint disabling tests completed successfully!${NC}"
        else
            echo -e "${RED}Some backend endpoint disabling tests failed. Please check the output above for details.${NC}"
        fi
    else
        echo -e "${RED}Error: Endpoint disabling test script not found at $DISABLE_TEST_SCRIPT${NC}"
        return 1
    fi
}

# Run frontend tests
function run_frontend_tests() {
    print_section "Running Frontend Tests (Docker)"

    # Check if Docker is installed
    if ! command_exists docker; then
        echo -e "${RED}Error: Docker is not installed or not running.${NC}"
        echo "Please install and start Docker to run frontend tests in a container."
        return 1
    fi

    # Define a tag for the test stage image
    TEST_STAGE_IMAGE="${FRONTEND_IMAGE_NAME}-test-stage"

    echo "Building frontend test stage image (silently)..."
    cd "$PROJECT_ROOT" || exit # Docker build context is project root for frontend Dockerfile
    # Build using the --quiet flag to suppress build output
    docker build --quiet --target build-stage -t "$TEST_STAGE_IMAGE" "$FRONTEND_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to build frontend test stage image. Run without silencing for details.${NC}"
        # Attempt to show build logs on failure by running without --quiet
        docker build --target build-stage -t "$TEST_STAGE_IMAGE" "$FRONTEND_DIR"
        return 1
    fi

    echo "Running frontend tests inside a Docker container..."
    # Run npm install silently (redirecting stdout and stderr), then run npm test
    docker run --rm \
        -v "$FRONTEND_DIR":/app \
        --workdir /app \
        "$TEST_STAGE_IMAGE" sh -c "npm install --silent > /dev/null 2>&1 && npm test"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Frontend tests completed successfully inside Docker!${NC}"
    else
        echo -e "${RED}Frontend tests failed inside Docker. Please check the output above.${NC}"
        return 1
    fi

    # Clean up the test stage image
    echo "Removing temporary test stage image..."
    docker rmi "$TEST_STAGE_IMAGE" &>/dev/null
}

# Start backend server
function start_backend() {
    print_section "Starting Backend Server"
    
    if ! check_venv; then return 1; fi

    if check_backend_running; then
        echo -e "${YELLOW}Backend server is already running.${NC}"
        return 0
    fi
    
    cd "$BACKEND_DIR" || exit
    echo "Starting backend server in the background using venv..."
    # Store PID in a temporary file for stopping later
    # Use venv python
    "$PYTHON_EXEC" app.py &
    SERVER_PID=$!
    echo $SERVER_PID > "$PROJECT_ROOT/.backend_pid" 
    
    # Wait for server to start
    echo "Waiting for server to start..."
    for i in {1..10}; do
        if check_backend_running; then
            echo -e "${GREEN}Backend server started successfully!${NC}"
            echo "Server running with PID: $SERVER_PID. Access API at http://localhost:5000"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}Failed to start backend server.${NC}"
    # Clean up PID file if server failed to start
    rm -f "$PROJECT_ROOT/.backend_pid"
    return 1
}

# Stop backend server
function stop_backend() {
    print_section "Stopping Backend Server"
    PID_FILE="$PROJECT_ROOT/.backend_pid"
    if [ -f "$PID_FILE" ]; then
        BACKEND_PID=$(cat "$PID_FILE")
        if ps -p $BACKEND_PID > /dev/null; then
            echo "Stopping backend server (PID: $BACKEND_PID)..."
            kill $BACKEND_PID
            # Wait a bit for the process to terminate
            sleep 2 
            if ps -p $BACKEND_PID > /dev/null; then
                 echo -e "${YELLOW}Backend server (PID: $BACKEND_PID) did not stop gracefully, attempting force kill...${NC}"
                 kill -9 $BACKEND_PID
            fi
            echo -e "${GREEN}Backend server stopped.${NC}"
        else
            echo -e "${YELLOW}Backend server process (PID: $BACKEND_PID) not found.${NC}"
        fi
        rm -f "$PID_FILE"
    else
        echo -e "${YELLOW}Backend server PID file not found. Was it started with manage.sh?${NC}"
        # Fallback attempt: try to find and kill the process by command using venv python path
        echo "Attempting to find and kill backend process by name..."
        # Use the specific python path in pkill pattern
        pkill -f "$PYTHON_EXEC app.py" 
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Attempted to stop backend process by name.${NC}"
        else
            echo -e "${YELLOW}Could not find backend process running.${NC}"
        fi
    fi
}

# Start frontend using Docker
function start_frontend() {
    print_section "Starting Frontend Server (Docker)"

    if ! command_exists docker; then
        echo -e "${RED}Error: Docker is not installed or not running.${NC}"
        echo "Please install and start Docker to run the frontend container."
        return 1
    fi

    if check_frontend_container_running; then
        echo -e "${YELLOW}Frontend container '$FRONTEND_CONTAINER_NAME' is already running.${NC}"
        echo "Access it at http://localhost:$FRONTEND_PORT"
        return 0
    fi

    # Clean up any lingering container with the same name
    docker rm -f "$FRONTEND_CONTAINER_NAME" &>/dev/null

    echo "Building frontend Docker image '$FRONTEND_IMAGE_NAME'..."
    cd "$PROJECT_ROOT" || exit
    docker build -t "$FRONTEND_IMAGE_NAME" "$FRONTEND_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to build frontend Docker image.${NC}"
        return 1
    fi
    echo -e "${GREEN}Frontend image built successfully.${NC}"

    echo "Starting frontend container '$FRONTEND_CONTAINER_NAME'..."
    # Run without --rm flag so we can see logs even if it exits
    # Add --add-host for Linux compatibility with host.docker.internal
    # Use host's IP address as an alternative for host.docker.internal
    HOST_IP=$(hostname -I | awk '{print $1}')
    echo "Using host IP: $HOST_IP for backend connectivity"
    
    # First try without removing the container - so we can check logs
    docker run -d --name "$FRONTEND_CONTAINER_NAME" \
        --add-host=host.docker.internal:host-gateway \
        -e BACKEND_HOST="$HOST_IP" \
        -p "$FRONTEND_PORT":80 \
        "$FRONTEND_IMAGE_NAME"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start frontend container.${NC}"
        return 1
    fi

    # Check if container is still running after 3 seconds
    sleep 3 
    
    if check_frontend_container_running; then
         echo -e "${GREEN}Frontend container started successfully!${NC}"
         echo "Access the dashboard at: http://localhost:$FRONTEND_PORT"
    else
         echo -e "${RED}Frontend container failed to start or exited unexpectedly.${NC}"
         # Print the logs to help with debugging
         echo -e "${YELLOW}Container logs:${NC}"
         docker logs "$FRONTEND_CONTAINER_NAME"
         echo -e "${YELLOW}End of container logs${NC}"
         echo "Attempting to fix potential networking issues..."
         
         # Try again with an alternative approach - use the direct host IP
         echo "Trying alternative approach with host IP..."
         docker rm -f "$FRONTEND_CONTAINER_NAME" &>/dev/null
         
         # Create a custom nginx config to use the host IP directly
         echo "Modifying nginx configuration to use direct host IP: $HOST_IP"
         cat > "$FRONTEND_DIR/nginx.temp.conf" << EOF
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy API requests to the backend server using direct host IP
    location /api/ {
        proxy_pass http://$HOST_IP:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
         
         # Build a new image with the temporary config
         echo "Building temporary image with direct IP configuration..."
         docker build -t "${FRONTEND_IMAGE_NAME}-temp" \
             --build-arg NGINX_CONF_FILE=nginx.temp.conf \
             -f - "$FRONTEND_DIR" << EOF
FROM $FRONTEND_IMAGE_NAME
COPY nginx.temp.conf /etc/nginx/conf.d/default.conf
EOF

         # Run with the new image and explicit network settings
         echo "Starting container with modified configuration..."
         docker run -d --rm --name "$FRONTEND_CONTAINER_NAME" \
             -p "$FRONTEND_PORT":80 \
             "${FRONTEND_IMAGE_NAME}-temp"
         
         sleep 3
         if check_frontend_container_running; then
             echo -e "${GREEN}Frontend container started successfully with alternate configuration!${NC}"
             echo "Access the dashboard at: http://localhost:$FRONTEND_PORT"
         else
             echo -e "${RED}All attempts to start frontend container failed.${NC}"
             echo -e "${YELLOW}Final container logs:${NC}"
             docker logs "$FRONTEND_CONTAINER_NAME"
             echo -e "${YELLOW}End of container logs${NC}"
             echo -e "${RED}Cleaning up temporary files...${NC}"
             rm -f "$FRONTEND_DIR/nginx.temp.conf"
             docker rm -f "$FRONTEND_CONTAINER_NAME" &>/dev/null
             return 1
         fi
         # Clean up the temporary file
         rm -f "$FRONTEND_DIR/nginx.temp.conf"
    fi

    return 0
}

# Stop frontend Docker container
function stop_frontend() {
    print_section "Stopping Frontend Server (Docker)"

    if ! command_exists docker; then
        echo -e "${RED}Error: Docker is not installed or not running.${NC}"
        return 1
    fi

    # Also remove the temporary image if it exists
    TEMP_IMAGE="${FRONTEND_IMAGE_NAME}-temp"
    if docker images "$TEMP_IMAGE" --quiet | grep -q .; then
        echo "Removing temporary frontend image..."
        docker rmi "$TEMP_IMAGE" &>/dev/null
    fi

    if check_frontend_container_running; then
        echo "Stopping frontend container '$FRONTEND_CONTAINER_NAME'..."
        docker stop "$FRONTEND_CONTAINER_NAME" &>/dev/null
        docker rm -f "$FRONTEND_CONTAINER_NAME" &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Frontend container stopped and removed successfully.${NC}"
        else
            echo -e "${RED}Failed to stop frontend container.${NC}"
        fi
    else
        echo -e "${YELLOW}Frontend container '$FRONTEND_CONTAINER_NAME' is not running.${NC}"
        # Still try to remove it in case it exists but is stopped
        docker rm -f "$FRONTEND_CONTAINER_NAME" &>/dev/null
    fi
}

# Start both backend and frontend
function start_all() {
    start_backend
    # Only start frontend if backend started successfully
    if [ $? -eq 0 ]; then
        start_frontend
    else
        echo -e "${RED}Backend failed to start, skipping frontend startup.${NC}"
    fi
}

# Stop both backend and frontend
function stop_all() {
    stop_frontend
    stop_backend
}

# Restart both backend and frontend
function restart_all() {
    print_section "Restarting All Services"
    
    echo "Stopping all services first..."
    stop_all
    
    echo "Starting all services again..."
    start_all
    
    echo -e "${GREEN}Restart completed!${NC}"
}

# Install required dependencies
function install_dependencies() {
    print_section "Installing Dependencies"
    
    # Check for python3
    if ! command_exists python3; then
        echo -e "${RED}Error: python3 is not installed. Please install Python 3.${NC}"
        return 1
    fi

    # Check if venv module is available (often needs python3-venv package)
    if ! python3 -m venv --help > /dev/null 2>&1; then
         echo -e "${RED}Error: Python 'venv' module not found.${NC}"
         echo "Please install it (e.g., 'sudo apt install python3-venv' on Debian/Ubuntu)."
         return 1
    fi

    echo "Setting up Python virtual environment for backend..."
    cd "$BACKEND_DIR" || exit
    
    # Create venv if it doesn't exist
    if [ ! -d "$VENV_PATH" ]; then
        echo "Creating virtual environment in $VENV_PATH..."
        python3 -m venv "$VENV_PATH"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to create virtual environment.${NC}"
            return 1
        fi
        echo -e "${GREEN}Virtual environment created successfully.${NC}"
    else
        echo "Virtual environment already exists at $VENV_PATH."
    fi

    # Check if pip exists in venv
    if [ ! -f "$PIP_EXEC" ]; then
        echo -e "${RED}Error: pip not found in the virtual environment ($PIP_EXEC).${NC}"
        echo "The virtual environment might be corrupted. Try removing the '$VENV_PATH' directory and running install again."
        return 1
    fi

    echo "Installing/updating Python dependencies using venv pip..."
    "$PIP_EXEC" install -r requirements.txt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully installed/updated backend Python dependencies in venv${NC}"
    else
        echo -e "${RED}Failed to install Python dependencies using venv. Please check errors above.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Dependencies installation completed!${NC}"
    echo "You can now start the system with: $0 start-all"
}

# Generate documentation
function generate_docs() {
    print_section "Generating Documentation"
    
    if ! check_venv; then return 1; fi

    # Create documentation directory if it doesn't exist
    DOCS_DIR="$PROJECT_ROOT/docs"
    mkdir -p "$DOCS_DIR"
    
    # Generate API documentation
    echo "Generating API documentation..."
    cd "$BACKEND_DIR" || exit
    
    # Copy existing API documentation
    if [ -f "API_DOCUMENTATION.md" ]; then
        cp "API_DOCUMENTATION.md" "$DOCS_DIR/"
        echo -e "${GREEN}Copied API documentation to $DOCS_DIR/API_DOCUMENTATION.md${NC}"
    fi
    
    # Generate module documentation if pydoc is available in venv
    echo "Generating Python module documentation using venv python..."
    mkdir -p "$DOCS_DIR/python_modules"
    # Use python from venv to run pydoc module
    "$PYTHON_EXEC" -m pydoc -w app
    "$PYTHON_EXEC" -m pydoc -w app.routes
    "$PYTHON_EXEC" -m pydoc -w app.utils
    # Check if html files were created before moving
    if ls app*.html 1> /dev/null 2>&1; then
        mv app*.html "$DOCS_DIR/python_modules/"
        echo -e "${GREEN}Generated Python module documentation in $DOCS_DIR/python_modules/${NC}"
    else
        echo -e "${YELLOW}Failed to generate Python module documentation. Check pydoc output.${NC}"
    fi
    
    # Generate frontend documentation
    echo "Generating frontend documentation..."
    cd "$FRONTEND_DIR" || exit
    
    # Copy existing documentation
    if [ -d "docs" ]; then
        mkdir -p "$DOCS_DIR/frontend"
        cp -r docs/* "$DOCS_DIR/frontend/"
        echo -e "${GREEN}Copied frontend documentation to $DOCS_DIR/frontend/${NC}"
    fi
    
    echo -e "${GREEN}Documentation generation completed!${NC}"
    echo "Documentation available in: $DOCS_DIR"
}

# Print help
function print_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  help                   Display this help message"
    echo "  install                Install required Python dependencies"
    echo "  start-backend          Start the backend server (runs in background)"
    echo "  stop-backend           Stop the backend server"
    echo "  start-frontend         Build and start the frontend server using Docker"
    echo "  stop-frontend          Stop the frontend Docker container"
    echo "  start-all              Start both backend and frontend (Docker) servers"
    echo "  stop-all               Stop both backend and frontend (Docker) servers"
    echo "  restart-all            Restart both backend and frontend (Docker) servers"
    echo "  test-backend           Run backend functional tests (requires server running) AND endpoint disabling tests"
    echo "  test-backend-disable   Run only the backend endpoint disabling tests (starts/stops server)"
    echo "  test-frontend          Run frontend tests (uses Docker container)"
    echo "  test-all               Run all backend and frontend tests"
    echo "  docs                   Generate documentation"
    echo ""
}

# Main function
function main() {
    print_banner
    
    if [ $# -eq 0 ]; then
        print_help
        exit 0
    fi
    
    case "$1" in
        help)
            print_help
            ;;
        install)
            install_dependencies
            ;;
        start-backend)
            start_backend
            ;;
        stop-backend)
            stop_backend
            ;;
        start-frontend)
            start_frontend
            ;;
        stop-frontend)
            stop_frontend
            ;;
        start-all)
            start_all
            ;;
        stop-all)
            stop_all
            ;;
        restart-all)
            restart_all
            ;;
        test-backend)
            run_backend_tests # Run functional tests first
            if [ $? -eq 0 ]; then # Only run disable tests if functional tests pass
                run_backend_disable_tests # Then run disable tests
            else
                echo -e "${RED}Skipping endpoint disabling tests due to functional test failures.${NC}"
            fi
            ;;
        test-backend-disable)
            run_backend_disable_tests
            ;;
        test-frontend)
            run_frontend_tests
            ;;
        test-all)
            run_backend_tests
            if [ $? -eq 0 ]; then
                run_backend_disable_tests
            else
                echo -e "${RED}Skipping endpoint disabling tests due to functional test failures.${NC}"
            fi
            run_frontend_tests
            ;;
        docs)
            generate_docs
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$1'${NC}"
            print_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"