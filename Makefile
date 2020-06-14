#
# ${R_HOME}/Makefile


srcdir = .
top_srcdir = .

top_builddir = .

include $(top_builddir)/Makeconf

GIT = `if [ -d "$(top_builddir)/.git" ]; then echo "git"; fi`

distdir = $(PACKAGE)-$(VERSION)
INSTFILES = COPYING
NON_SVN_INSTFILES = SVN-REVISION
DISTFILES = $(INSTFILES) \
	ChangeLog INSTALL README VERSION VERSION-NICK \
	Makeconf.in Makefile.in Makefile.fw \
	config.site configure configure.ac
SUBDIRS = m4 tools doc etc share src tests
SUBDIRS_WITH_NO_BUILD = po

all: Makefile Makeconf R docs recommended vignettes javaconf
recommended:  stamp-recommended

Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
	@cd $(top_builddir) && $(SHELL) ./config.status $@
Makeconf: $(srcdir)/Makeconf.in $(top_builddir)/config.status
	@cd $(top_builddir) && $(SHELL) ./config.status $@

ACLOCAL_M4 = aclocal.m4
## NB: this is duplicated in m4/Makefile.in
ACINCLUDE_DEPENDENCIES = \
	m4/R.m4 \
	m4/bigendian.m4 \
	m4/cairo.m4 \
	m4/clibs.m4 \
	m4/codeset.m4 \
	m4/cxx_11.m4 \
	m4/gettext.m4 m4/gettext-lib.m4 \
	m4/libtool.m4 m4/ltoptions.m4 m4/ltversion.m4 m4/ltsugar.m4 m4/lt~obsolete.m4 \
	m4/openmp.m4 \
	m4/stat-time.m4
CONFIGURE_DEPENDENCIES = $(srcdir)/VERSION
config.status: $(srcdir)/configure
	@$(SHELL) ./config.status --recheck
$(srcdir)/configure: # $(srcdir)/configure.ac $(ACLOCAL_M4) $(CONFIGURE_DEPENDENCIES)
	@BD=`pwd`; cd $(srcdir) && $(AUTOCONF) -B $${BD}
$(ACLOCAL_M4): $(srcdir)/configure.ac acinclude.m4
	@BD=`pwd`; cd $(srcdir) && $(ACLOCAL) --output=$${BD}/$@ -I $${BD}
acinclude.m4: $(srcdir)/configure.ac $(ACINCLUDE_DEPENDENCIES)
	@(cd $(srcdir) && cat $(ACINCLUDE_DEPENDENCIES)) > $@

LIBTOOL_DEPS = tools/ltmain.sh
libtool: $(LIBTOOL_DEPS)
	$(SHELL) ./config.status --recheck

R: Makefile svnonly
	@if test "$(BUILDDIR_IS_SRCDIR)" = no ; then \
	  for f in $(INSTFILES); do \
	    $(INSTALL_DATA) $(srcdir)/$${f} $(top_builddir); \
	  done; \
	fi
	@for d in $(SUBDIRS); do \
	  (cd $${d} && $(MAKE) R) || exit 1; \
	done
	@test -f src/library/stamp-docs || \
	  $(ECHO) "you should 'make docs' now ..."

docs: R FORCE
	-@(cd doc && $(MAKE) $@)
	-@(cd src/library && $(MAKE) $@)
FORCE:

stamp-recommended: R docs
	@(cd src/library/Recommended && $(MAKE))

## One of the grid vignettes requires lattice
vignettes: stamp-recommended
	@(cd src/library && $(MAKE) $@)

## This needs packages built, hence 'R' dependence on 'javaconf'
## javareconf gets remade often.
## If configure is re-run, etc/Makeconf gets reset to initial Java state
stamp-java : etc/Makeconf etc/javaconf $(srcdir)/src/scripts/javareconf.in
	@$(ECHO) "configuring Java ..."
	@-bin/R CMD javareconf
	@touch stamp-java

javaconf: R
	@$(MAKE) stamp-java


install install-strip: installdirs svnonly
	@for d in $(SUBDIRS); do \
	  (cd $${d} && $(MAKE) $@) || exit 1; \
	done
	@for f in $(INSTFILES); do \
	  $(INSTALL_DATA) $(srcdir)/$${f} "$(DESTDIR)$(rhome)"; \
	done
	@for f in $(NON_SVN_INSTFILES); do \
	  $(INSTALL_DATA) $${f} "$(DESTDIR)$(rhome)"; \
	done
#		$(MAKE) -f $(srcdir)/Makefile.fw top_srcdir=$(top_srcdir) $@

svnonly:
	@if test ! -f "$(srcdir)/doc/FAQ" || test -f non-tarball ; then \
	  (cd doc/manual && $(MAKE) front-matter html-non-svn) ; \
	  touch non-tarball ; \
	  (cd $(srcdir); LC_ALL=C TZ=GMT $(GIT) svn info || $(ECHO) "Revision: -99") 2> /dev/null \
	    | sed -n -e '/^Revision/p' -e '/^Last Changed Date/'p \
	    | cut -d' ' -f1,2,3,4 > SVN-REVISION-tmp ; \
	  if test "`cat SVN-REVISION-tmp`" = "Revision: -99"; then \
	    $(ECHO) "ERROR: not an svn checkout"; \
	    exit 1; \
	  fi; \
	  $(SHELL) $(top_srcdir)/tools/move-if-change SVN-REVISION-tmp SVN-REVISION ; \
	  rm -f SVN-REVISION-tmp ; \
	else \
	  if test "$(BUILDDIR_IS_SRCDIR)" = no ; then \
	    for f in $(NON_SVN_INSTFILES); do \
	      $(INSTALL_DATA) $(srcdir)/$${f} $(top_builddir); \
	    done \
	  fi \
	fi

libR_la = libR$(R_DYLIB_EXT)
#libR_la = libR.a
install-libR:
	@if test -f lib$(R_ARCH)/$(libR_la); then $(MAKE) install-libR-exists; fi
install-libR-exists:
	@$(MKINSTALLDIRS) "$(DESTDIR)${libdir}"
	@$(INSTALL_DATA) -m755 lib$(R_ARCH)/$(libR_la) "$(DESTDIR)${libdir}"
uninstall-libR:
	@rm -f "$(DESTDIR)${libdir}/$(libR_la)"

installdirs:
	@$(MKINSTALLDIRS) "$(DESTDIR)$(rhome)"
uninstall:
	@(for d in $(SUBDIRS); do rsd="$${d} $${rsd}"; done; \
	  for d in $${rsd}; do (cd $${d} && $(MAKE) $@); done)
	@for f in $(INSTFILES) $(NON_SVN_INSTFILES); do \
	  rm -f "$(DESTDIR)$(rhome)/$${f}"; \
	done
	@rm -Rf "$(DESTDIR)$(Rexecbindir)" "$(DESTDIR)$(rhome)/lib"
	@rmdir "$(DESTDIR)$(rhome)" 2>/dev/null \
          || $(ECHO) "  dir $(DESTDIR)$(rhome) not removed"
	@rm -f "$(DESTDIR)${libdir}/libR$(R_DYLIB_EXT)"

mostlyclean: clean
clean:
	@(for d in $(SUBDIRS); do rsd="$${d} $${rsd}"; done; \
	  for d in $${rsd}; do (cd $${d} && $(MAKE) $@); done)
	@if test "$(BUILDDIR_IS_SRCDIR)" = no ; then \
	  rm -f $(INSTFILES); \
	fi
distclean: clean
	@(for d in $(SUBDIRS); do rsd="$${d} $${rsd}"; done; \
	  for d in $${rsd}; do (cd $${d} && $(MAKE) $@); done)
	@rm -f po/Makefile
	-@rm -Rf bin include lib library modules gnome
	@if test -f non-tarball ; then \
	  rm -f $(NON_SVN_INSTFILES) non-tarball doc/FAQ doc/RESOURCES doc/html/resources.html doc/html/NEWS.html; \
	fi
	@if test "$(BUILDDIR_IS_SRCDIR)" = no ; then \
	  rm -f $(NON_SVN_INSTFILES); \
	  rm -Rf $(SUBDIRS) $(SUBDIRS_WITH_NO_BUILD); \
	fi
	-@rm -Rf libconftest.dSYM
	-@rm -f Makeconf Makefile Makefile.bak Makefrag.* \
	  config.cache config.log config.status libtool stamp-java \
	  $(ACLOCAL_M4) acinclude.m4 $(distdir).tar.gz
maintainer-clean: distclean
	@$(ECHO) "This command is intended for maintainers to use; it"
	@$(ECHO) "deletes files that may need special rules to rebuild"
	@(for d in $(SUBDIRS); do rsd="$${d} $${rsd}"; done; \
	  for d in $${rsd}; do (cd $${d} && $(MAKE) $@); done)
	-@(cd $(srcdir) && rm -Rf autom4te.cache)

dist: dist-unix
## GNU gzip 1.8 warns that env var GZIP is obsolescent for gzip, so use as arg
dist-unix: distdir
	-chmod -R a+r $(distdir)
	-chmod -R go-w $(distdir)
	distname=`$(srcdir)/tools/GETDISTNAME`; \
	  dirname=`$(ECHO) $${distname} | sed -e s/_.*//`; \
          if test $(distdir) != $${dirname} ; then \
            mv $(distdir) $${dirname}; \
          fi ; \
	  $(TAR) cf $${distname}.tar $${dirname} && $(R_GZIPCMD) $(GZIP) $${distname}.tar; \
	  rm -Rf $${dirname}
dist-win:
distdir: $(DISTFILES) vignettes
	@rm -Rf $(distdir)
	@mkdir $(distdir)
	@-chmod 755 $(distdir)
	@for f in $(DISTFILES); do \
	  test -f $(distdir)/$${f} \
	    || ln $(srcdir)/$${f} $(distdir)/$${f} 2>/dev/null \
	    || cp -p $(srcdir)/$${f} $(distdir)/$${f}; \
	done
	@for f in $(NON_SVN_INSTFILES) ; do \
	  cp -p $${f} $(distdir)/$${f}; \
	done
	@for d in $(SUBDIRS); do \
	  test -d $(distdir)/$${d} \
	    || mkdir $(distdir)/$${d} \
	    || exit 1; \
	  chmod 755 $(distdir)/$${d}; \
	  (cd $${d} && $(MAKE) distdir) \
	    || exit 1; \
	done
	@for d in $(SUBDIRS_WITH_NO_BUILD); do \
	  ((cd $(srcdir); $(TAR) -c -f - $(DISTDIR_TAR_EXCLUDE) $${d}) \
	      | (cd $(distdir); $(TAR) -x -f -)) \
	    || exit 1; \
	done
	@for d in grid parallel utils; do \
	  mkdir -p $(distdir)/src/library/$${d}/inst/doc; \
	  cp library/$${d}/doc/*.pdf $(distdir)/src/library/$${d}/inst/doc; \
	done
	@(cd $(distdir); tools/link-recommended)

info pdf:
	-@(cd doc && $(MAKE) $@)
install-info install-pdf:
	-@(cd doc/manual && $(MAKE) $@)
uninstall-info uninstall-pdf:
	-@(cd doc/manual && $(MAKE) $@)

install-tests:
	-@(cd tests && $(MAKE) $@)
	-@(cd src/library && $(MAKE) $@)

uninstall-tests:
	-@(cd src/library && $(MAKE) $@)
	-@(cd tests && $(MAKE) $@)

check check-devel check-all check-recommended:
	@(cd tests && $(MAKE) $@)

reset-recommended:
	@(cd src/library/Recommended && $(MAKE) clean)

TAGS:
