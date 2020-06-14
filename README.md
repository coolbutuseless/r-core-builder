# `r-devel` replica with CI tools

This repo provides a _cross-sectional_ snapshot (as opposed to a commit-level mirror) of the
`r-devel` SVN repository hosted at https://svn.r-project.org/R/trunk/. For a full-fidelity mirror,
check https://github.com/wch/r-source.

The main purpose of this mirror is to offer potential R contributors continuous
integration tools (for now, GitHub Actions) against which to test their edits
to the R code base -- each edit can be built from source and tested automatically.
On success, a `patch` is produced as an artefact that can be submitted as a
patch to R via [Bugzilla](https://bugs.r-project.org/).
