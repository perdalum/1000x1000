
# Makefile for matrix determinant project

# Compiler settings
FC = gfortran
FFLAGS = -o
LIBS = -llapack -lblas

# Files
FORTRAN_SOURCES = det-matrix-big.f
FORTRAN_TARGET = det-matrix-big
README_DOCX = README.docx
README_MD = README.md

# Default target
.PHONY: all
all: $(FORTRAN_TARGET) $(README_MD)

# Compile FORTRAN program
$(FORTRAN_TARGET): $(FORTRAN_SOURCES)
	$(FC) $(FFLAGS) $@ $< $(LIBS)

# Convert README.docx to Markdown
$(README_MD): $(README_DOCX)
	pandoc -f docx -t markdown+fenced_code_blocks --wrap=none $(README_DOCX) -o $(README_MD)

# Clean build artifacts
.PHONY: clean
clean:
	rm -f $(FORTRAN_TARGET) $(README_MD)

# Clean everything including object files
.PHONY: distclean
distclean: clean

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Compile FORTRAN program and convert README.docx to Markdown"
	@echo "  clean     - Remove compiled binary and generated Markdown"
	@echo "  distclean - Clean everything"
	@echo "  help      - Show this help message"