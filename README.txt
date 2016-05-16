This is the Greybus Specification.

Requirements:

- Sphinx: http://sphinx-doc.org/contents.html
- LaTeX (and pdflatex, and various LaTeX packages)
- Graphviz (in particular, "dot"): http://www.graphviz.org/
- Mscgen: http://www.mcternan.me.uk/mscgen/
- Imagemagick: https://imagemagick.org

On Ubuntu:

# apt-get install python-sphinx texlive texlive-latex-extra texlive-humanities graphviz mscgen imagemagick

Then:

$ make latexpdf # For generating pdf
$ make html # For generating a hierarchy of html pages
$ make singlehtml # For generating a single html page

Output goes in build/latex. Build backends other than PDF are not
currently tested.
