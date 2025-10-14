#!/bin/bash

# Twitter Algorithm Swift 6.1+ - Comprehensive Build, Test & Run Script
# Handles backend/frontend separation with full testing and execution

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="TwitterAlgorithm"
BACKEND_TARGETS="TwitterAlgorithmCore TwitterAlgorithmML"
FRONTEND_TARGETS="TwitterAlgorithmUI"
DEMO_TARGET="TwitterAlgorithmDemo"
TEST_TARGETS="TwitterAlgorithmCoreTests TwitterAlgorithmMLTests TwitterAlgorithmUITests"

# Build configuration
BUILD_CONFIG="debug"
BUILD_DIR=".build"
OUTPUT_DIR="output"
LOG_DIR="logs"

# Create necessary directories
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Check Swift installation
check_swift() {
    log_info "Checking Swift installation..."
    if ! command -v swift &> /dev/null; then
        log_error "Swift is not installed or not in PATH"
        exit 1
    fi
    
    SWIFT_VERSION=$(swift --version | head -n1)
    log_success "Swift found: $SWIFT_VERSION"
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    swift package clean
    rm -rf "$BUILD_DIR"
    rm -rf "$OUTPUT_DIR"/*
    log_success "Build artifacts cleaned"
}

# Resolve dependencies
resolve_dependencies() {
    log_info "Resolving Swift package dependencies..."
    swift package resolve
    log_success "Dependencies resolved"
}

# Run tests for specific targets
run_tests() {
    local test_type="$1"
    log_header "🧪 Running $test_type Tests"
    
    case "$test_type" in
        "backend")
            log_info "Testing backend components (Core + ML)..."
            swift test --targets "$BACKEND_TARGETS" --parallel
            ;;
        "frontend")
            log_info "Testing frontend components (UI)..."
            swift test --targets "$FRONTEND_TARGETS" --parallel
            ;;
        "all")
            log_info "Running all tests..."
            swift test --parallel
            ;;
        "core")
            log_info "Testing core algorithm components..."
            swift test --targets TwitterAlgorithmCoreTests --parallel
            ;;
        "ml")
            log_info "Testing machine learning components..."
            swift test --targets TwitterAlgorithmMLTests --parallel
            ;;
        "ui")
            log_info "Testing UI components..."
            swift test --targets TwitterAlgorithmUITests --parallel
            ;;
        *)
            log_error "Unknown test type: $test_type"
            return 1
            ;;
    esac
    
    log_success "$test_type tests completed successfully"
}

# Build specific targets
build_targets() {
    local build_type="$1"
    log_header "🔨 Building $build_type Components"
    
    case "$build_type" in
        "backend")
            log_info "Building backend components..."
            swift build --targets "$BACKEND_TARGETS" --configuration "$BUILD_CONFIG"
            ;;
        "frontend")
            log_info "Building frontend components..."
            swift build --targets "$FRONTEND_TARGETS" --configuration "$BUILD_CONFIG"
            ;;
        "all")
            log_info "Building all components..."
            swift build --configuration "$BUILD_CONFIG"
            ;;
        "demo")
            log_info "Building demo application..."
            swift build --targets "$DEMO_TARGET" --configuration "$BUILD_CONFIG"
            ;;
        *)
            log_error "Unknown build type: $build_type"
            return 1
            ;;
    esac
    
    log_success "$build_type build completed"
}

# Run the demo application
run_demo() {
    local run_mode="$1"
    log_header "🚀 Running Twitter Algorithm Demo"
    
    # Build demo first
    build_targets "demo"
    
    case "$run_mode" in
        "interactive")
            log_info "Starting interactive demo..."
            swift run "$DEMO_TARGET" --interactive
            ;;
        "batch")
            log_info "Starting batch processing demo..."
            swift run "$DEMO_TARGET" --batch --input data/sample.json
            ;;
        "server")
            log_info "Starting server mode..."
            swift run "$DEMO_TARGET" --server --port 8080
            ;;
        "default")
            log_info "Starting default demo..."
            swift run "$DEMO_TARGET"
            ;;
        *)
            log_warning "Unknown run mode: $run_mode, using default"
            swift run "$DEMO_TARGET"
            ;;
    esac
}

# Run backend services
run_backend() {
    local service_type="$1"
    log_header "⚙️ Starting Backend Services"
    
    case "$service_type" in
        "recommendation")
            log_info "Starting recommendation service..."
            swift run "$DEMO_TARGET" --service recommendation --port 8081
            ;;
        "ml")
            log_info "Starting ML inference service..."
            swift run "$DEMO_TARGET" --service ml --port 8082
            ;;
        "all")
            log_info "Starting all backend services..."
            swift run "$DEMO_TARGET" --service all --port 8080
            ;;
        *)
            log_warning "Unknown service type: $service_type, using recommendation"
            swift run "$DEMO_TARGET" --service recommendation --port 8081
            ;;
    esac
}

# Run frontend UI
run_frontend() {
    local ui_mode="$1"
    log_header "🎨 Starting Frontend UI"
    
    case "$ui_mode" in
        "swiftui")
            log_info "Starting SwiftUI interface..."
            swift run "$DEMO_TARGET" --ui swiftui --port 3000
            ;;
        "cocoa")
            log_info "Starting Cocoa application..."
            swift run TwitterAlgorithmCocoa
            ;;
        "web")
            log_info "Starting web interface..."
            swift run "$DEMO_TARGET" --ui web --port 3001
            ;;
        "desktop")
            log_info "Starting desktop application..."
            swift run "$DEMO_TARGET" --ui desktop
            ;;
        *)
            log_warning "Unknown UI mode: $ui_mode, using SwiftUI"
            swift run "$DEMO_TARGET" --ui swiftui --port 3000
            ;;
    esac
}

# Performance testing
run_performance_tests() {
    log_header "⚡ Running Performance Tests"
    
    log_info "Running algorithm performance benchmarks..."
    swift run "$DEMO_TARGET" --benchmark
    
    log_success "Performance tests completed"
}

# Generate documentation
generate_docs() {
    log_header "📚 Generating Documentation"
    
    log_info "Generating Swift documentation..."
    swift package --allow-writing-to-directory docs generate-documentation --target TwitterAlgorithmCore --output docs
    
    log_info "Building LaTeX documentation..."
    if [ -d "docs" ]; then
        cd docs
        ./build-docs.sh all
        cd ..
        log_success "LaTeX documentation generated"
    else
        log_warning "docs directory not found, skipping LaTeX generation"
    fi
}

# Show help
show_help() {
    echo -e "${CYAN}Twitter Algorithm Swift 6.1+ - Build, Test & Run Script${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  test [TYPE]           Run tests (backend|frontend|all|core|ml|ui)"
    echo "  build [TYPE]          Build components (backend|frontend|all|demo)"
    echo "  run [MODE]            Run demo (interactive|batch|server|default)"
    echo "  backend [SERVICE]      Run backend services (recommendation|ml|all)"
    echo "  frontend [UI]         Run frontend UI (swiftui|web|desktop)"
    echo "  performance           Run performance tests"
    echo "  docs                  Generate documentation"
    echo "  clean                 Clean build artifacts"
    echo "  all                   Run full pipeline (test + build + run)"
    echo "  help                  Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 test all           # Run all tests"
    echo "  $0 build backend      # Build backend only"
    echo "  $0 run interactive    # Run interactive demo"
    echo "  $0 backend all        # Start all backend services"
    echo "  $0 frontend swiftui   # Start SwiftUI frontend"
    echo "  $0 all               # Full pipeline"
    echo ""
}

# Full pipeline
run_full_pipeline() {
    log_header "🎯 Running Full Pipeline"
    
    # 1. Clean and setup
    clean_build
    resolve_dependencies
    
    # 2. Test everything
    run_tests "all"
    
    # 3. Build everything
    build_targets "all"
    
    # 4. Performance tests
    run_performance_tests
    
    # 5. Generate documentation
    generate_docs
    
    # 6. Start services
    log_info "Starting backend services in background..."
    run_backend "all" &
    BACKEND_PID=$!
    
    sleep 2
    
    log_info "Starting frontend UI..."
    run_frontend "swiftui" &
    FRONTEND_PID=$!
    
    log_success "Full pipeline completed!"
    log_info "Backend PID: $BACKEND_PID"
    log_info "Frontend PID: $FRONTEND_PID"
    log_info "Use 'kill $BACKEND_PID $FRONTEND_PID' to stop services"
}

# Main execution
main() {
    local command="$1"
    local option="$2"
    
    # Check Swift installation first
    check_swift
    
    case "$command" in
        "test")
            run_tests "${option:-all}"
            ;;
        "build")
            build_targets "${option:-all}"
            ;;
        "run")
            run_demo "${option:-default}"
            ;;
        "backend")
            run_backend "${option:-recommendation}"
            ;;
        "frontend")
            run_frontend "${option:-swiftui}"
            ;;
        "performance")
            run_performance_tests
            ;;
        "docs")
            generate_docs
            ;;
        "clean")
            clean_build
            ;;
        "all")
            run_full_pipeline
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            log_error "No command specified"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
