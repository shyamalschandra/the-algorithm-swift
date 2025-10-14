#!/bin/bash

# Twitter Algorithm - Swift 6.1+ Build and Run Script
# Comprehensive script for building, testing, and running the project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project information
PROJECT_NAME="Twitter Algorithm Swift 6.1+"
VERSION="1.0.0"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check if Swift is installed
check_swift() {
    print_status "Checking Swift installation..."
    
    if ! command -v swift &> /dev/null; then
        print_error "Swift is not installed or not in PATH"
        print_status "Please install Swift from https://swift.org/download/"
        exit 1
    fi
    
    SWIFT_VERSION=$(swift --version | head -n1)
    print_success "Swift found: $SWIFT_VERSION"
}

# Function to check if Xcode is installed (for macOS)
check_xcode() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Checking Xcode installation..."
        
        if ! command -v xcodebuild &> /dev/null; then
            print_warning "Xcode command line tools not found"
            print_status "Installing Xcode command line tools..."
            xcode-select --install 2>/dev/null || true
        else
            print_success "Xcode command line tools found"
        fi
    fi
}

# Function to clean previous builds
clean_project() {
    print_header "🧹 Cleaning Project"
    
    print_status "Removing build artifacts..."
    swift package clean
    
    print_status "Removing derived data..."
    rm -rf .build/
    rm -rf DerivedData/
    
    print_success "Project cleaned successfully"
}

# Function to resolve dependencies
resolve_dependencies() {
    print_header "📦 Resolving Dependencies"
    
    print_status "Resolving Swift package dependencies..."
    swift package resolve
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies resolved successfully"
    else
        print_error "Failed to resolve dependencies"
        exit 1
    fi
}

# Function to build the project
build_project() {
    print_header "🔨 Building Project"
    
    print_status "Building Swift package..."
    swift build
    
    if [ $? -eq 0 ]; then
        print_success "Project built successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    print_header "🧪 Running Tests"
    
    print_status "Running unit tests..."
    swift test
    
    if [ $? -eq 0 ]; then
        print_success "All tests passed"
    else
        print_error "Tests failed"
        exit 1
    fi
}

# Function to run performance tests
run_performance_tests() {
    print_header "⚡ Running Performance Tests"
    
    print_status "Running performance benchmarks..."
    swift run TwitterAlgorithmDemo --benchmark --iterations 100
    
    if [ $? -eq 0 ]; then
        print_success "Performance tests completed"
    else
        print_warning "Performance tests failed (this is expected in demo mode)"
    fi
}

# Function to run the demo
run_demo() {
    print_header "🚀 Running Demo"
    
    print_status "Starting Twitter Algorithm Demo..."
    echo ""
    echo -e "${CYAN}🐦 Twitter Algorithm - Swift 6.1+ Implementation${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
    
    swift run TwitterAlgorithmDemo
    
    if [ $? -eq 0 ]; then
        print_success "Demo completed successfully"
    else
        print_error "Demo failed"
        exit 1
    fi
}

# Function to run interactive demo
run_interactive_demo() {
    print_header "🎮 Running Interactive Demo"
    
    print_status "Starting interactive Twitter Algorithm Demo..."
    echo ""
    echo -e "${CYAN}🎮 Interactive Twitter Algorithm Demo${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    swift run TwitterAlgorithmDemo --interactive
    
    if [ $? -eq 0 ]; then
        print_success "Interactive demo completed successfully"
    else
        print_error "Interactive demo failed"
        exit 1
    fi
}

# Function to generate documentation
generate_docs() {
    print_header "📚 Generating Documentation"
    
    print_status "Generating Swift documentation..."
    swift package generate-documentation
    
    if [ $? -eq 0 ]; then
        print_success "Documentation generated successfully"
        print_status "Documentation available at: .build/documentation/"
    else
        print_warning "Documentation generation failed (requires Xcode)"
    fi
}

# Function to show project info
show_project_info() {
    print_header "📋 Project Information"
    
    echo -e "${CYAN}Project:${NC} $PROJECT_NAME"
    echo -e "${CYAN}Version:${NC} $VERSION"
    echo -e "${CYAN}Swift Version:${NC} $(swift --version | head -n1)"
    echo -e "${CYAN}Platform:${NC} $(uname -s) $(uname -m)"
    echo -e "${CYAN}Directory:${NC} $(pwd)"
    echo ""
    
    print_status "Available targets:"
    swift package describe --type json | jq -r '.targets[].name' 2>/dev/null || echo "  - TwitterAlgorithmCore"
    echo "  - TwitterAlgorithmML"
    echo "  - TwitterAlgorithmUI"
    echo "  - TwitterAlgorithmDemo"
    echo ""
    
    print_status "Available commands:"
    echo "  - swift build          # Build the project"
    echo "  - swift test           # Run tests"
    echo "  - swift run TwitterAlgorithmDemo  # Run demo"
    echo "  - swift run TwitterAlgorithmDemo --interactive  # Interactive demo"
    echo "  - swift run TwitterAlgorithmDemo --benchmark    # Performance test"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Twitter Algorithm - Swift 6.1+ Build Script${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -i, --info              Show project information"
    echo "  -c, --clean             Clean project and build artifacts"
    echo "  -b, --build             Build the project"
    echo "  -t, --test              Run tests"
    echo "  -p, --performance      Run performance tests"
    echo "  -d, --demo              Run demo"
    echo "  -a, --interactive       Run interactive demo"
    echo "  -g, --docs              Generate documentation"
    echo "  -f, --full              Full build, test, and run (default)"
    echo "  -q, --quick             Quick build and run (skip tests)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Full build, test, and run"
    echo "  $0 --quick              # Quick build and run"
    echo "  $0 --demo               # Just run the demo"
    echo "  $0 --interactive        # Run interactive demo"
    echo "  $0 --clean --build      # Clean and build"
    echo ""
}

# Main execution function
main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--info)
            show_project_info
            exit 0
            ;;
        -c|--clean)
            check_swift
            check_xcode
            clean_project
            exit 0
            ;;
        -b|--build)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            exit 0
            ;;
        -t|--test)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            run_tests
            exit 0
            ;;
        -p|--performance)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            run_performance_tests
            exit 0
            ;;
        -d|--demo)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            run_demo
            exit 0
            ;;
        -a|--interactive)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            run_interactive_demo
            exit 0
            ;;
        -g|--docs)
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            generate_docs
            exit 0
            ;;
        -q|--quick)
            print_header "🚀 Quick Build and Run"
            check_swift
            check_xcode
            resolve_dependencies
            build_project
            run_demo
            exit 0
            ;;
        -f|--full|"")
            print_header "🎯 Full Build, Test, and Run"
            check_swift
            check_xcode
            clean_project
            resolve_dependencies
            build_project
            run_tests
            run_performance_tests
            run_demo
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
