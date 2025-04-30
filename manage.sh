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

# Run backend tests
function run_backend_tests() {
    print_section "Running Backend Tests"
    
    # Check if backend server is running
    if ! check_backend_running; then
        echo -e "${RED}Error: Backend server is not running.${NC}"
        echo "Please start the backend server before running tests."
        echo "  cd $BACKEND_DIR"
        echo "  python app.py"
        return 1
    fi
    
    # Run the comprehensive test suite
    echo "Running comprehensive backend tests..."
    cd "$TEST_DIR" || exit
    python run_all_tests.py
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backend tests completed successfully!${NC}"
    else
        echo -e "${RED}Some backend tests failed. Please check the log for details.${NC}"
    fi
}

# Function to run backend endpoint disabling tests
function run_backend_disable_tests() {
    print_section "Running Backend Endpoint Disabling Tests"
    
    # Use the Python version of the endpoint disabling tests
    DISABLE_TEST_SCRIPT="$TEST_DIR/test_endpoint_disabling.py"
    if [ -f "$DISABLE_TEST_SCRIPT" ]; then
        echo "Running endpoint disabling tests (this will start/stop the server multiple times)..."
        cd "$TEST_DIR" || exit
        python test_endpoint_disabling.py
        
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
    print_section "Running Frontend Tests"
    
    # Check if Node.js and npm are installed
    if ! command_exists npm; then
        echo -e "${RED}Error: npm is not installed.${NC}"
        echo "Please install Node.js and npm to run frontend tests."
        return 1
    fi
    
    cd "$FRONTEND_DIR" || exit
    
    # Run frontend tests if they exist
    if [ -f "package.json" ] && grep -q "\"test\":" "package.json"; then
        echo "Running frontend tests..."
        npm test
    else
        echo -e "${YELLOW}No frontend tests defined in package.json.${NC}"
        echo "Consider adding test scripts to your package.json file."
    fi
}

# Start backend server
function start_backend() {
    print_section "Starting Backend Server"
    
    if check_backend_running; then
        echo -e "${YELLOW}Backend server is already running.${NC}"
        return 0
    fi
    
    cd "$BACKEND_DIR" || exit
    echo "Starting backend server in the background..."
    python app.py &
    SERVER_PID=$!
    
    # Wait for server to start
    echo "Waiting for server to start..."
    for i in {1..10}; do
        if check_backend_running; then
            echo -e "${GREEN}Backend server started successfully!${NC}"
            echo "Server running with PID: $SERVER_PID"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}Failed to start backend server.${NC}"
    return 1
}

# Start frontend development server
function start_frontend() {
    print_section "Starting Frontend Development Server"
    
    if ! command_exists npm; then
        echo -e "${RED}Error: npm is not installed.${NC}"
        echo "Please install Node.js and npm to run the frontend server."
        return 1
    fi
    
    cd "$FRONTEND_DIR" || exit
    echo "Starting frontend development server..."
    npm run dev
}

# Optimize codebase (run linting and formatting)
function optimize_codebase() {
    print_section "Optimizing Codebase"
    
    cd "$PROJECT_ROOT" || exit
    
    # Frontend optimization
    if [ -d "$FRONTEND_DIR" ]; then
        echo "Optimizing frontend code..."
        cd "$FRONTEND_DIR" || exit
        
        if command_exists npm; then
            if grep -q "\"lint\":" "package.json"; then
                echo "Running frontend linting..."
                npm run lint
            else
                echo "No lint script found in package.json"
            fi
            
            if grep -q "\"format\":" "package.json"; then
                echo "Running frontend code formatting..."
                npm run format
            fi
        else
            echo -e "${YELLOW}npm not found, skipping frontend optimization${NC}"
        fi
    fi
    
    # Backend optimization
    if [ -d "$BACKEND_DIR" ]; then
        echo "Optimizing backend code..."
        cd "$BACKEND_DIR" || exit
        
        if command_exists pylint; then
            echo "Running pylint on backend code..."
            pylint app.py app/*.py
        fi
        
        if command_exists black; then
            echo "Formatting backend code with black..."
            black app.py app/*.py
        elif command_exists autopep8; then
            echo "Formatting backend code with autopep8..."
            autopep8 --in-place --aggressive --aggressive app.py app/*.py
        else
            echo -e "${YELLOW}No Python formatter found. Consider installing black or autopep8.${NC}"
        fi
    fi
    
    echo -e "${GREEN}Code optimization completed!${NC}"
}

# Generate documentation
function generate_docs() {
    print_section "Generating Documentation"
    
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
    
    # Generate module documentation if pydoc is available
    if command_exists pydoc3; then
        echo "Generating Python module documentation..."
        mkdir -p "$DOCS_DIR/python_modules"
        pydoc3 -w app
        pydoc3 -w app.routes
        pydoc3 -w app.utils
        mv app*.html "$DOCS_DIR/python_modules/"
        echo -e "${GREEN}Generated Python module documentation in $DOCS_DIR/python_modules/${NC}"
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

# Check system dependencies
function check_dependencies() {
    print_section "Checking System Dependencies"
    
    # Check Node.js and npm
    if command_exists node; then
        NODE_VERSION=$(node --version)
        echo -e "Node.js: ${GREEN}Installed${NC} ($NODE_VERSION)"
    else
        echo -e "Node.js: ${RED}Not installed${NC}"
    fi
    
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        echo -e "npm: ${GREEN}Installed${NC} ($NPM_VERSION)"
    else
        echo -e "npm: ${RED}Not installed${NC}"
    fi
    
    # Check Python
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version)
        echo -e "Python: ${GREEN}Installed${NC} ($PYTHON_VERSION)"
    else
        echo -e "Python: ${RED}Not installed${NC}"
    fi
    
    # Check Docker
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version)
        echo -e "Docker: ${GREEN}Installed${NC} ($DOCKER_VERSION)"
    else
        echo -e "Docker: ${RED}Not installed${NC}"
    fi
    
    # Check flask
    if python3 -c "import flask" 2>/dev/null; then
        FLASK_VERSION=$(python3 -c "import flask; print(flask.__version__)")
        echo -e "Flask: ${GREEN}Installed${NC} ($FLASK_VERSION)"
    else
        echo -e "Flask: ${RED}Not installed${NC}"
    fi
    
    # Check code quality tools
    if command_exists pylint; then
        echo -e "pylint: ${GREEN}Installed${NC}"
    else
        echo -e "pylint: ${YELLOW}Not installed${NC} (recommended for Python code quality)"
    fi
    
    if command_exists black; then
        echo -e "black: ${GREEN}Installed${NC}"
    else
        echo -e "black: ${YELLOW}Not installed${NC} (recommended for Python code formatting)"
    fi
}

# Print help
function print_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  help                   Display this help message"
    echo "  start-backend          Start the backend server"
    echo "  start-frontend         Start the frontend development server"
    echo "  start-all              Start both backend and frontend servers"
    echo "  test-backend           Run backend functional tests (requires server running) AND endpoint disabling tests"
    echo "  test-backend-disable   Run only the backend endpoint disabling tests (starts/stops server)"
    echo "  test-frontend          Run frontend tests"
    echo "  test-all               Run all backend and frontend tests"
    echo "  optimize               Run code optimization tasks"
    echo "  docs                   Generate documentation"
    echo "  check                  Check system dependencies"
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
        start-backend)
            start_backend
            ;;
        start-frontend)
            start_frontend
            ;;
        start-all)
            start_backend
            if [ $? -eq 0 ]; then
                start_frontend
            fi
            ;;
        test-backend)
            run_backend_tests # Run functional tests first
            if [ $? -eq 0 ]; then # Only run disable tests if functional tests pass
                run_backend_disable_tests # Then run disable tests
            else
                echo -e "${RED}Skipping endpoint disabling tests due to functional test failures.${NC}"
            fi
            ;;
        test-backend-disable) # New command
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
        optimize)
            optimize_codebase
            ;;
        docs)
            generate_docs
            ;;
        check)
            check_dependencies
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