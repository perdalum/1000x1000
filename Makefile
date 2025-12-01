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
SCRIPTS_DIR = src

# Default target
.PHONY: all
all: $(FORTRAN_TARGET) $(README_MD)

# Compile FORTRAN program
$(FORTRAN_TARGET): $(FORTRAN_SOURCES)
	$(FC) $(FFLAGS) $@ $< $(LIBS)

# Convert README.docx to Markdown
$(README_MD): $(README_DOCX)
	pandoc -f docx -t gfm --extract-media=. --wrap=none $(README_DOCX) -o $(README_MD)
	@if [ -d "$(SCRIPTS_DIR)" ] && [ -f "$(SCRIPTS_DIR)/pandoc-tiff-to-png.sh" ]; then \
		$(SCRIPTS_DIR)/pandoc-tiff-to-png.sh $(README_MD) ./media; \
	else \
		echo "Warning: Image conversion script not found"; \
	fi

# Clean build artifacts
.PHONY: clean
clean:
	rm -f $(FORTRAN_TARGET) $(README_MD) .media/*
	rmdir media

# Clean everything including object files
.PHONY: distclean
distclean: clean

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Compile FORTRAN program and convert README.docx to Markdown"
	@echo "  clean     - Remove compiled binary, generated Markdown, and extracted images"
	@echo "  distclean - Clean everything"
	@echo "  help      - Show this help message"