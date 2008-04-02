# Makefile for SatStress
SHELL = /bin/sh
SSDIR = SatStress

# Python modules for which we are making documentation:
EPYDOC_MODS = $(SSDIR)/SatStress.py\
           $(SSDIR)/GridCalc.py\
           $(SSDIR)/__init__.py

# Source files that are included in the current release:
PUB_SRC = $(EPYDOC_MODS)\
           $(SSDIR)/physcon.py\
           $(SSDIR)/Love/JohnWahr/love.f\
           test/test_nsr_diurnal.py\
           test/test_nsr_diurnal.pkl\
           input/Europa.satellite\
           input/NSR_Diurnal_exhaustive.grid

EPYDOC_OPTS = --verbose\
              --css=doc/css/SatStress.css\
              --name=SatStress\
              --url=http://code.google.com/p/satstress\
              --inheritance=grouped\
              --no-private

# love is built down in this directory, which has its own Makefile:
love : SatStress/Love/JohnWahr/love.f
	(cd SatStress/Love/JohnWahr; make love)

# Generate all of the HTML documentation based on the Python __doc__ strings:
htmldoc : $(EPYDOC_MODS) doc/css/SatStress.css
	epydoc --html --output=doc/html $(EPYDOC_OPTS) $(EPYDOC_MODS)

# Make PDF documentation based on the Python __doc__ strings:
pdfdoc : $(EPYDOC_MODS)
	epydoc --pdf --output=doc/pdf $(EPYDOC_OPTS) $(EPYDOC_MODS)

# Check the documentation for completeness:
doccheck : $(EPYDOC_MODS)
	epydoc --check $(EPYDOC_OPTS) $(EPYDOC_MODS)

# Get rid of all the documentation:
docclean : 
	rm -f doc/html/* doc/pdf/*

# Make all forms of documentation, and check it:
doc : htmldoc pdfdoc doccheck

# See if SatStress is working:
check : love $(PUB_SRC)
	python test/test_nsr_diurnal.py

# An alias for check:
test : check

# Get rid of random junk:
clean :
	rm -rf *~ *.pyc lovetmp-*
	(cd $(SSDIR); rm -rf *~ *.pyc lovetmp-*)
	rm -rf dist
	rm -rf build
	rm -f MANIFEST

# Get rid of all non-source files
realclean : clean docclean
	rm -rf $(SSDIR)/Love/*/calcLove*

# Restore the package to pristene condition:
distclean : realclean htmldoc

dist : distclean $(PUB_SRC)
	python setup.py sdist

install : love $(PUB_SRC)
	python setup.py install