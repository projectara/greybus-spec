This is the Greybus Specification.

Requirements:

- Sphinx: http://sphinx-doc.org/contents.html
- rst2pdf: https://code.google.com/p/rst2pdf/

On Ubuntu:

# apt-get install python-sphinx rst2pdf

Then:

$ make latexpdf

Output goes in build/latex. Build backends other than PDF are not
currently tested.
