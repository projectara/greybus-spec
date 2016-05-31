# Makefile for Sphinx documentation
#

# try to determine the local copy of sphinx, different distros name it
# different things.  Yeah for Python breaking version compatility!  :(
SPHINX := $(shell { command -v sphinx-build || command -v sphinx-build2; } 2>/dev/null)

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   ?= $(SPHINX)
PAPER         =
BUILDDIR      = build

# User-friendly check for sphinx-build
ifeq ($(shell which $(SPHINXBUILD) >/dev/null 2>&1; echo $$?), 1)
$(error The 'sphinx-build' command was not found. Make sure you have Sphinx installed, then set the SPHINXBUILD environment variable to point to the full path of the '$(SPHINXBUILD)' executable. Alternatively you can add the directory with the executable to your PATH. If you don't have Sphinx installed, grab it from http://sphinx-doc.org/)
endif

# ' (this line works around an Emacs makefile-mode bug)

# Internal variables.
PAPEROPT_a4      = -D latex_paper_size=a4
PAPEROPT_letter  = -D latex_paper_size=letter
ALLSPHINXOPTS    = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source
# Directed graphs converted from .dot to .png
DOT_GRAPH_DIR    = source/img/dot
DOT_GRAPHS       = $(wildcard $(DOT_GRAPH_DIR)/*.dot)
GEN_PNG_GRAPHS   = $(DOT_GRAPHS:.dot=.png)
# Message sequence charts converted from .msc to .png
MSC_DIR          = source/img/msc
MSC_DIAGRAMS     = $(wildcard $(MSC_DIR)/*.msc)
GEN_MSC_DIAGRAMS = $(MSC_DIAGRAMS:.msc=.png)
# .svg images converted to .png
SVG_DIR          = source/img/svg
SVG_IMGS         = $(wildcard $(SVG_DIR)/*.svg)
GEN_PNG_IMGS     = $(SVG_IMGS:.svg=.png)

.PHONY: help clean all html latexpdf generated-images

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  singlehtml to make standalone single HTML file"
	@echo "  html       to make standalone HTML files"
	@echo "  latexpdf   to make LaTeX files and run them through pdflatex"

clean:
	rm -rf $(BUILDDIR)/*
	rm -f source/extensions/*.pyc
	rm -f $(DOT_GRAPH_DIR)/*.png
	rm -f $(MSC_DIR)/*.png
	rm -f $(SVG_DIR)/*.png

$(DOT_GRAPH_DIR)/%.png: $(DOT_GRAPH_DIR)/%.dot
	@dot -Tpng $< -o $@
	@echo DOT: $<

$(MSC_DIR)/%.png: $(MSC_DIR)/%.msc
	@mscgen -T png $<
	@echo MSCGEN: $<

$(SVG_DIR)/%.png: $(SVG_DIR)/%.svg
	@convert $< $@
	@echo CONVERT: $<

generated-images: $(GEN_PNG_GRAPHS) $(GEN_MSC_DIAGRAMS) $(GEN_PNG_IMGS)

all:	html latexpdf singlehtml

singlehtml: generated-images
	$(SPHINXBUILD) -b singlehtml $(ALLSPHINXOPTS) $(BUILDDIR)/singlehtml
	@echo
	@echo "Build finished. The single HTML page is in $(BUILDDIR)/singlehtml."

html: generated-images
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

latexpdf: generated-images
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."
