#!/bin/bash

# Twitter Algorithm Swift 6.1+ - Quick Start Script
# Simplified commands for common operations

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Quick commands
case "$1" in
    "test")
        log_info "Running all tests..."
        swift test --parallel
        log_success "Tests completed"
        ;;
    "build")
        log_info "Building project..."
        swift build
        log_success "Build completed"
        ;;
    "run")
        log_info "Running demo..."
        swift run TwitterAlgorithmDemo
        ;;
    "clean")
        log_info "Cleaning build artifacts..."
        swift package clean
        rm -rf .build
        log_success "Clean completed"
        ;;
    "deps")
        log_info "Resolving dependencies..."
        swift package resolve
        log_success "Dependencies resolved"
        ;;
    "backend")
        log_info "Starting backend services..."
        swift run TwitterAlgorithmDemo --service all --port 8080 &
        log_success "Backend started on port 8080"
        ;;
    "frontend")
        log_info "Starting frontend UI..."
        swift run TwitterAlgorithmDemo --ui swiftui --port 3000 &
        log_success "Frontend started on port 3000"
        ;;
    "full")
        log_info "Running full pipeline..."
        swift package clean
        swift package resolve
        swift test --parallel
        swift build
        swift run TwitterAlgorithmDemo --service all --port 8080 &
        sleep 2
        swift run TwitterAlgorithmDemo --ui swiftui --port 3000 &
        log_success "Full pipeline completed"
        ;;
    "help"|"-h"|"--help")
        echo "Twitter Algorithm Swift 6.1+ - Quick Start"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  test      Run all tests"
        echo "  build     Build project"
        echo "  run       Run demo"
        echo "  clean     Clean build artifacts"
        echo "  deps      Resolve dependencies"
        echo "  backend   Start backend services"
        echo "  frontend  Start frontend UI"
        echo "  full      Run full pipeline (test + build + run)"
        echo "  help      Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 test      # Run tests"
        echo "  $0 build     # Build project"
        echo "  $0 run       # Run demo"
        echo "  $0 full      # Full pipeline"
        ;;
    "")
        log_warning "No command specified"
        $0 help
        ;;
    *)
        log_warning "Unknown command: $1"
        $0 help
        ;;
esac
