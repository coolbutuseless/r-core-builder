#
# ${R_HOME}/src/main/Makefile


srcdir = .
top_srcdir = ../..

top_builddir = ../..
subdir = src/main
# next is needed for shared BLAS
R_HOME=$(top_builddir)

include $(top_builddir)/Makeconf

SOURCES_C = \
	CommandLineArgs.c \
	Rdynload.c Renviron.c RNG.c \
	agrep.c altclasses.c altrep.c apply.c arithmetic.c array.c attrib.c \
	bind.c builtin.c \
	character.c coerce.c colors.c complex.c connections.c context.c cum.c \
	dcf.c datetime.c debug.c deparse.c devices.c \
	dotcode.c dounzip.c dstruct.c duplicate.c \
	edit.c engine.c envir.c errors.c eval.c \
	format.c \
	gevents.c gram.c gram-ex.c graphics.c grep.c \
	identical.c inlined.c inspect.c internet.c iosupport.c \
	lapack.c list.c localecharset.c logic.c \
	main.c mapply.c match.c memory.c \
	names.c \
	objects.c options.c \
	paste.c platform.c plot.c plot3d.c plotmath.c \
	print.c printarray.c printvector.c printutils.c qsort.c \
	radixsort.c random.c raw.c registration.c relop.c rlocale.c \
	saveload.c scan.c seq.c serialize.c sort.c source.c split.c \
	sprintf.c startup.c subassign.c subscript.c subset.c summary.c sysutils.c \
	times.c \
	unique.c util.c \
	version.c \
	g_alab_her.c g_cntrlify.c g_fontdb.c g_her_glyph.c

SOURCES_F =  xxxpr.f

## If the substitutes are needed, the corresponding objects are put by
## configure in  
EXTRA_SOURCES_C = \
	Rmain.c alloca.c mkdtemp.c strdup.c strncasecmp.c

DEPENDS = $(SOURCES_C:.c=.d) $(EXTRA_SOURCES_C:.c=.d)
SOURCES = $(SOURCES_C) $(SOURCES_F)
OBJECTS = $(SOURCES_C:.c=.o) $(SOURCES_F:.f=.o)  
HEADERS = \
	RBufferUtils.h Rcomplex.h Rstrptime.h \
	arithmetic.h \
	basedecl.h \
	contour-common.h \
	datetime.h \
	duplicate.h \
	gzio.h \
	qsort-body.c \
	rlocale_data.h \
	split-incl.c \
	unzip.h \
	valid_utf8.h \
	xspline.c \
	g_cntrlify.h g_control.h g_extern.h g_her_metr.h g_jis.h


distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)
DISTFILES = Makefile.in Makefile.win \
	$(HEADERS) \
	$(SOURCES_C) \
	$(EXTRA_SOURCES_C) \
	$(SOURCES_F) \
	gram.y

TRE_CPPFLAGS =  -I$(top_srcdir)/src/extra
XDR_CPPFLAGS = # -I$(top_srcdir)/src/extra/xdr
XDR_CPPFLAGS = 

## platform.c needs $(CURL_CPPFLAGS).
ALL_CPPFLAGS = $(TRE_CPPFLAGS) $(XDR_CPPFLAGS) $(R_XTRA_CPPFLAGS) \
  $(CURL_CPPFLAGS) $(CPPFLAGS) -I$(top_srcdir)/src/nmath $(DEFS)
#ALL_CFLAGS = $(ALL_CFLAGS_LO)
#ALL_FFLAGS = $(ALL_FFLAGS_LO)


## use an explicit library: there might be an unsatisfactory -lintl around
R_TRE =  ../extra/tre/libtre.a
R_XDR = # ../extra/xdr/libxdr.a
R_LIBINTL = # ../extra/intl/libintl.a
R_TZONE =  ../extra/tzone/libtz.a

MAIN_LIBS = ../unix/libunix.a ../appl/libappl.a ../nmath/libnmath.a
MAIN_OBJS = `ls ../unix/*.o ../appl/*.o ../nmath/*.o`
EXTRA_STATIC_LIBS = $(R_TRE) $(R_XDR) $(R_LIBINTL) $(R_TZONE)
STATIC_LIBS = $(MAIN_LIBS) $(EXTRA_STATIC_LIBS)

EXTRA_LIBS = $(BLAS_LIBS) $(FLIBS)  -lintl -Wl,-framework -Wl,CoreFoundation $(READLINE_LIBS) $(LIBS)

R_binary = R.bin
R_bin_OBJECTS = Rmain.o $(OBJECTS)
R_bin_LDADD = $(MAIN_OBJS) $(EXTRA_STATIC_LIBS) $(EXTRA_LIBS)
## Linked against -lRblas becasue -lR is and otherwise ld complains.
#R_bin_LDADD = -lR -lRblas
R_bin_DEPENDENCIES = libR.a # $(top_builddir)/etc/R.exp

libR_la = libR$(R_DYLIB_EXT)
libR_la_OBJECTS = $(OBJECTS)
libR_la_LIBADD =  $(MAIN_OBJS) $(EXTRA_STATIC_LIBS) $(EXTRA_LIBS) # # -Wl,-bE:$(top_builddir)/etc/R.exp
libR_la_DEPENDENCIES = $(STATIC_LIBS) $(R_TZONE) # # $(top_builddir)/etc/R.exp

## The next is needed for macOS only at present
LIBR_LDFLAGS = -install_name libR.dylib -compatibility_version 4.0.0  -current_version 4.0.0  -headerpad_max_install_names


all: R

Makefile: $(srcdir)/Makefile.in \
  $(top_builddir)/config.status \
  ../include/config.h \
  ../include/Rversion.h \
  $(SOURCES_C) $(EXTRA_SOURCES_C)
	@cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@

Makedeps: Makefile $(DEPENDS)
	@cat $(DEPENDS) >> Makefile
	@touch $@

## This target has been changed to ensure that R.bin and libR get
## installed in the build tree if necessary, even if the corresponding
## objects are not re-made.
## Note that dependencies in the test Makefiles used to depend on these objects,
## so copy-if-change is used.
R: Makedeps
#	@$(MAKE) install-lib-local
#	@$(MAKE) install-static-local
	@$(MAKE) install-bin-local


## is this portable?  Documented as GNU extension.
../include/config.h ../include/Rversion.h:
	(cd $(@D); $(MAKE) $(@F))

$(R_binary): $(R_bin_OBJECTS) $(R_bin_DEPENDENCIES)
	$(MAIN_LINK) -o $@ $(R_bin_OBJECTS) $(R_bin_LDADD)

libR.a: $(OBJECTS) $(STATIC_LIBS)
	-@mkdir libs
	@(cd libs; for l in $(STATIC_LIBS); do $(AR) -x ../$$l; done)
	@rm -Rf $@
	$(AR) -cr $@ $(OBJECTS) libs/*o
	$(RANLIB) $@
	@rm -Rf libs

install-bin-local: $(R_binary)
	@$(MAKE) rhome="$(abs_top_builddir)" install-bin

install-static-local: libR.a
	@$(MAKE) rhome="$(abs_top_builddir)" install-static

$(top_builddir)/etc/R.exp: $(OBJECTS) $(MAIN_LIBS)
	@$(SHELL) $(top_srcdir)/tools/ldAIX4 -o $@ $(OBJECTS) $(MAIN_LIBS)

## is this portable?  Documented as GNU extension.
$(MAIN_LIBS):
	(cd $(@D); $(MAKE) $(@F))

../extra/bzip2/libbz2.a ../extra/pcre/libpcre.a ../extra/pcre/libtre.a\
  ../extra/xdr/libxdr.a ../extra/zlib/libz.a ../extra/xz/liblzma.a \
  ../extra/intl/libintl.a:
	(cd $(@D); $(MAKE))


libR: $(libR_la)

$(libR_la): $(libR_la_OBJECTS) $(libR_la_DEPENDENCIES)
	$(DYLIB_LINK) $(LIBR_LDFLAGS) -o $@ $(libR_la_OBJECTS) $(libR_la_LIBADD)

install-lib-local: $(libR_la)
	@$(MAKE) rhome="$(abs_top_builddir)" install-lib


# suppress #line directives
YFLAGS=-l

$(srcdir)/gram.c: # $(srcdir)/gram.y
	@$(ECHO) "re-making gram.c"
	$(YACC) $(YFLAGS) $(srcdir)/gram.y
	$(SHELL) $(top_srcdir)/tools/move-if-change y.tab.c $(srcdir)/gram.c

install: installdirs
	@$(MAKE) install-bin
	@if test -f $(libR_la); then $(MAKE) install-lib; fi
#	@$(MAKE) install-static
## may not need $(rhome)/lib if not static/shared libR, external blas and lapack.
installdirs:
	@$(MKINSTALLDIRS) "$(DESTDIR)$(Rexecbindir2)"
install-bin: installdirs
	@$(SHELL) $(top_srcdir)/tools/copy-if-change $(R_binary) "$(DESTDIR)$(Rexecbindir2)/R"
install-lib: installdirs
	@$(MKINSTALLDIRS) "$(DESTDIR)$(Rexeclibdir)"
	@$(SHELL) $(top_srcdir)/tools/copy-if-change $(libR_la) "$(DESTDIR)$(Rexeclibdir)/$(libR_la)"
install-static: installdirs
	@$(MKINSTALLDIRS) "$(DESTDIR)$(Rexeclibdir)"
	@$(SHELL) $(top_srcdir)/tools/copy-if-change libR.a "$(DESTDIR)$(Rexeclibdir)/libR.a"
install-strip: installdirs
	@${INSTALL_PROGRAM} -s $(R_binary) "$(DESTDIR)$(Rexecbindir2)/R"
	@if test -f $(libR_la); then $(MAKE) install-lib; fi
	@if test -n "$(STRIP_SHARED_LIB)"; then \
	  if test -f $(libR_la); then $(STRIP_SHARED_LIB) "$(DESTDIR)$(Rexeclibdir)/$(libR_la)"; fi; \
	fi
#	@$(MAKE) install-strip-static
install-strip-static: installdirs
	@$(MAKE) install-static
	@if test -n "$(STRIP_STATIC_LIB)"; then \
	  if test -f libR.a; then $(STRIP_STATIC_LIB) "$(DESTDIR)$(Rexeclibdir)/libR.a"; fi; \
	fi
uninstall:
	@rm -f "$(DESTDIR)$(Rexecbindir)/exec/$(R_ARCH)/R" "$(DESTDIR)$(Rexecbindir)/R.bin"
	@rm -f "$(DESTDIR)$(Rexeclibdir)/libR$(R_DYLIB_EXT)"
	@rm -f "$(DESTDIR)$(Rexeclibdir)/libR.a"

mostlyclean: clean
clean:
	@-rm -f $(top_builddir)/etc/R.exp
	@-rm -Rf .libs _libs
	@-rm -f *core Makedeps *.d *.o *.lo *.la *$(R_DYLIB_EXT) \
	  $(R_binary) libR.a
distclean: clean
	@-rm -f Makefile
maintainer-clean: distclean
	@$(ECHO) "This command is intended for maintainers to use; it"
	@$(ECHO) "deletes files that may need special rules to rebuild"
	@-rm -f $(srcdir)/gram.c $(srcdir)/gramLatex.c $(srcdir)/gramRd.c

tags: TAGS
TAGS: $(SOURCES) $(EXTRA_SOURCES_C) $(HEADERS)
	etags $(SOURCES) $(EXTRA_SOURCES_C) $(HEADERS)

## Unused targets
info dvi check:

distdir: $(DISTFILES)
	@for f in $(DISTFILES); do \
	  test -f $(distdir)/$${f} \
	    || ln $(srcdir)/$${f} $(distdir)/$${f} 2>/dev/null \
	    || cp -p $(srcdir)/$${f} $(distdir)/$${f}; \
	done

## Automagically generated dependencies:

