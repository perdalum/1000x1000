# Makefile for matrix determinant project

# ---------- Compilers ----------
FC = gfortran
CC = clang

# ---------- Flags ----------
FFLAGS = -o
CFLAGS = -std=c89 -O2
LIBS = -llapack -lblas
# For Accelerate instead, use:
# LIBS = -framework Accelerate

# ---------- Files ----------
FORTRAN_SOURCES = det-matrix-big.f
FORTRAN_TARGET  = det-matrix-big-f

C_SOURCES = det-matrix-big.c
C_TARGET  = det-matrix-big-c

README_DOCX = README.docx
README_MD   = README.md
SCRIPTS_DIR = src

# ---------- Default target ----------
.PHONY: all
all: $(FORTRAN_TARGET) $(C_TARGET) $(README_MD)

# ---------- Compile FORTRAN program ----------
$(FORTRAN_TARGET): $(FORTRAN_SOURCES)
	$(FC) $(FFLAGS) $@ $< $(LIBS)

# ---------- Compile C program ----------
$(C_TARGET): $(C_SOURCES)
	$(CC) $(CFLAGS) -o $@ $< $(LIBS) -lm

# ---------- Convert README.docx to Markdown ----------
$(README_MD): $(README_DOCX)
	pandoc -f docx -t gfm --extract-media=. --wrap=none $(README_DOCX) -o $(README_MD)
	@if [ -d "$(SCRIPTS_DIR)" ] && [ -f "$(SCRIPTS_DIR)/pandoc-tiff-to-png.sh" ]; then \
		$(SCRIPTS_DIR)/pandoc-tiff-to-png.sh $(README_MD) ./media; \
	else \
		echo "Warning: Image conversion script not found"; \
	fi

# ---------- Clean ----------
.PHONY: clean
clean:
	rm -f $(FORTRAN_TARGET) $(C_TARGET) $(README_MD)
	rm -rf media

# ---------- Distclean ----------
.PHONY: distclean
distclean: clean

# ---------- Help ----------
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Build FORTRAN and C versions, generate README.md"
	@echo "  clean     - Remove binaries and generated files"
	@echo "  distclean - Same as clean"
	@echo "  help      - Show this help message"
