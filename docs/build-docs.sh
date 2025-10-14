#!/bin/bash

# Twitter Algorithm Documentation Build Script
# Builds LaTeX presentations and papers with SVG diagrams

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Check if LaTeX is installed
check_latex() {
    print_status "Checking LaTeX installation..."
    
    if ! command -v pdflatex &> /dev/null; then
        print_error "pdflatex is not installed"
        print_status "Please install LaTeX (TeX Live or MiKTeX)"
        print_status "macOS: brew install --cask mactex"
        print_status "Ubuntu: sudo apt-get install texlive-full"
        exit 1
    fi
    
    if ! command -v bibtex &> /dev/null; then
        print_error "bibtex is not installed"
        exit 1
    fi
    
    print_success "LaTeX installation found"
}

# Create output directory
create_output_dir() {
    print_status "Creating output directory..."
    mkdir -p output
    print_success "Output directory created"
}

# Build presentation
build_presentation() {
    print_header "📊 Building Beamer Presentation"
    
    print_status "Building presentation.tex..."
    pdflatex -interaction=nonstopmode -output-directory=output presentation.tex >/dev/null 2>&1 || true
    pdflatex -interaction=nonstopmode -output-directory=output presentation.tex >/dev/null 2>&1 || true  # Run twice for references
    
    if [ -f "output/presentation.pdf" ]; then
        print_success "Presentation built successfully"
        print_status "Output: output/presentation.pdf"
    else
        print_error "Presentation build failed - LaTeX errors detected"
        print_status "Check output/presentation.log for details"
        print_status "Continuing with other builds..."
        return 1
    fi
}

# Build paper
build_paper() {
    print_header "📄 Building Academic Paper"
    
    print_status "Building paper.tex..."
    pdflatex -interaction=nonstopmode -output-directory=output paper.tex >/dev/null 2>&1 || true
    bibtex output/paper >/dev/null 2>&1 || true
    pdflatex -interaction=nonstopmode -output-directory=output paper.tex >/dev/null 2>&1 || true
    pdflatex -interaction=nonstopmode -output-directory=output paper.tex >/dev/null 2>&1 || true  # Run twice for references
    
    if [ -f "output/paper.pdf" ]; then
        print_success "Paper built successfully"
        print_status "Output: output/paper.pdf"
    else
        print_error "Paper build failed - LaTeX errors detected"
        print_status "Check output/paper.log for details"
        print_status "Continuing with other builds..."
        return 1
    fi
}

# Create bibliography
create_bibliography() {
    print_status "Creating bibliography file..."
    
    cat > references.bib << 'EOF'
@article{resnick1994grouplens,
  title={GroupLens: an open architecture for collaborative filtering of netnews},
  author={Resnick, Paul and Iacovou, Neophytos and Suchak, Mitesh and Bergstrom, Peter and Riedl, John},
  journal={Proceedings of the 1994 ACM conference on Computer supported cooperative work},
  pages={175--186},
  year={1994}
}

@inproceedings{cheng2016wide,
  title={Wide \& deep learning for recommender systems},
  author={Cheng, Heng-Tze and Koc, Levent and Harmsen, Jeremiah and Shaked, Tal and Chandra, Tushar and Aradhye, Hrishi and Anderson, Glen and Corrado, Greg and Chai, Wei and Ispir, Mustafa and others},
  booktitle={Proceedings of the 1st workshop on deep learning for recommender systems},
  pages={7--10},
  year={2016}
}

@article{vaswani2017attention,
  title={Attention is all you need},
  author={Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and Uszkoreit, Jakob and Jones, Llion and Gomez, Aidan N and Kaiser, {\L}ukasz and Polosukhin, Illia},
  journal={Advances in neural information processing systems},
  volume={30},
  year={2017}
}

@article{devlin2018bert,
  title={Bert: Pre-training of deep bidirectional transformers for language understanding},
  author={Devlin, Jacob and Chang, Ming-Wei and Lee, Kenton and Toutanova, Kristina},
  journal={arXiv preprint arXiv:1810.04805},
  year={2018}
}
EOF
    
    print_success "Bibliography created"
}

# Convert SVG to PDF (if needed)
convert_svg_to_pdf() {
    print_status "Converting SVG diagrams to PDF..."
    
    # Check if Inkscape is available
    if command -v inkscape &> /dev/null; then
        for svg_file in images/*.svg; do
            if [ -f "$svg_file" ]; then
                pdf_file="${svg_file%.svg}.pdf"
                inkscape --export-pdf="$pdf_file" "$svg_file" >/dev/null 2>&1 || true
                print_status "Converted $svg_file to $pdf_file"
            fi
        done
        print_success "SVG to PDF conversion completed"
    else
        print_status "Inkscape not found, using SVG files directly"
        print_status "Note: Some LaTeX distributions may not support SVG directly"
    fi
}

# Clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    rm -f *.aux *.log *.out *.toc *.nav *.snm *.vrb *.bbl *.blg *.fdb_latexmk *.fls *.synctex.gz
    rm -rf output/*.aux output/*.log output/*.out output/*.toc output/*.nav output/*.snm output/*.vrb output/*.bbl output/*.blg
    print_success "Build artifacts cleaned"
}

# Show help
show_help() {
    echo -e "${BLUE}Twitter Algorithm Documentation Build Script${NC}"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  presentation  - Build Beamer presentation only"
    echo "  paper        - Build academic paper only"
    echo "  all          - Build both presentation and paper (default)"
    echo "  clean        - Clean build artifacts"
    echo "  help         - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build both documents"
    echo "  $0 presentation       # Build presentation only"
    echo "  $0 paper              # Build paper only"
    echo "  $0 clean              # Clean build artifacts"
    echo ""
}

# Main function
main() {
    case "${1:-all}" in
        presentation)
            print_header "🎯 Building Presentation Only"
            check_latex
            create_output_dir
            convert_svg_to_pdf
            build_presentation
            print_success "Presentation build completed!"
            ;;
        paper)
            print_header "🎯 Building Paper Only"
            check_latex
            create_output_dir
            convert_svg_to_pdf
            create_bibliography
            build_paper
            print_success "Paper build completed!"
            ;;
        all)
            print_header "🎯 Building All Documents"
            check_latex
            create_output_dir
            convert_svg_to_pdf
            create_bibliography
            
            # Build presentation (continue even if it fails)
            build_presentation || print_status "Presentation build had issues, continuing..."
            
            # Build paper (continue even if it fails)
            build_paper || print_status "Paper build had issues, continuing..."
            
            print_success "Build process completed!"
            print_status "Check output/ directory for generated files"
            ;;
        clean)
            print_header "🧹 Cleaning Build Artifacts"
            clean_build
            print_success "Build artifacts cleaned!"
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
