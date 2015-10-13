This is the Greybus Specification.

Requirements:

- Sphinx: http://sphinx-doc.org/contents.html
- LaTeX (and pdflatex, and various LaTeX packages)

On Ubuntu:

# apt-get install python-sphinx texlive texlive-latex-extra texlive-humanities

Then:

$ make latexpdf # For generating pdf
$ make html # For generating html

Output goes in build/latex. Build backends other than PDF are not
currently tested.
