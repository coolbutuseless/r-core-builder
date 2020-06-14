##
## ${R_HOME}/src/appl/Makefile


srcdir = .
top_srcdir = ../..

top_builddir = ../..
subdir = src/appl

include $(top_builddir)/Makeconf

SOURCES_C = \
	integrate.c interv.c maxcol.c optim.c pretty.c uncmin.c
SOURCES_F = \
	dchdc.f dpbfa.f dpbsl.f dpoco.f dpodi.f dpofa.f dposl.f dqrdc.f \
	dqrdc2.f dqrls.f dqrsl.f dqrutl.f dsvdc.f dtrco.f dtrsl.f
DEPENDS = $(SOURCES_C:.c=.d)
OBJECTS_BLAS =  blas.o  cmplxblas.o
OBJECTS_LIN = $(SOURCES_F:.f=.o)
OBJECTS = $(SOURCES_C:.c=.o) $(OBJECTS_LIN) # $(OBJECTS_BLAS)
HEADERS = lbfgsb.c

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)
DISTFILES = \
	Makefile.in Makefile.win \
	$(HEADERS) \
	$(SOURCES_C) \
	$(SOURCES_F)

#ALL_CFLAGS = $(ALL_CFLAGS_LO)
#ALL_FFLAGS = $(ALL_FFLAGS_LO)

Rblas_la = libRblas$(R_DYLIB_EXT)
Rblas_la_LIBADD =  -flat_namespace -undefined suppress

all: R

Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status $(SOURCES_C)
	@cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@

Makedeps: Makefile $(DEPENDS)
	@cat $(DEPENDS) >> Makefile
	@touch $@

R: Makedeps
	@$(MAKE) libappl.a
	#@$(MAKE) install-Linpack

libappl.a: $(OBJECTS)
	@rm -f $@
	$(AR) -cr $@ $(OBJECTS)
	$(RANLIB) $@

libLinpack.a: $(OBJECTS_LIN)
	@rm -f $@
	$(AR) -cr $@ $(OBJECTS_LIN)
	$(RANLIB) $@

## only for checking, so only installed locally
install-Linpack: libLinpack.a
	@$(MKINSTALLDIRS) ../../lib
	@$(SHELL) $(top_srcdir)/tools/copy-if-change libLinpack.a ../../lib/libLinpack.a

## Used with --disable-BLAS-shlib
blas.o: $(top_srcdir)/src/extra/blas/blas.f
	$(FC) $(ALL_FFLAGS) -c $< -o $@
cmplxblas.o: $(top_srcdir)/src/extra/blas/cmplxblas.f
	$(FC) $(ALL_FFLAGS) -c $< -o $@

mostlyclean: clean
clean:
	@-rm -Rf .libs _libs
	@-rm -f Makedeps *.d *.o *.a *.lo *.la stamp-lo $(Rblas_la)

distclean: clean
	@-rm -f Makefile
maintainer-clean: distclean

install install-strip uninstall TAGS info dvi check:

distdir: $(DISTFILES)
	@for f in $(DISTFILES); do \
	  test -f $(distdir)/$${f} \
	    || ln $(srcdir)/$${f} $(distdir)/$${f} 2>/dev/null \
	    || cp -p $(srcdir)/$${f} $(distdir)/$${f}; \
	done

## Automagically generated dependencies:

