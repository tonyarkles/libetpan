# libEtPan! -- a mail stuff library
#
# Copyright (C) 2007 g10 Code GmbH
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the libEtPan! project nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.



# Description of the build system
# ===============================

# The build system uses automake and autoconf mostly in the usual way.
# A typical work flow for working with the SVN version would be:

# $ autoreconf
# $ ./configure --enable-maintainer-mode
# $ make

# All Makefile.am files must contain:

# include $(top_srcdir)/rules.mk

# If BUILT_SOURCES are desired, they need to be defined *after* the
# above include by a += directive, for example:

# BUILT_SOURCES += foo.h

# This is because rules.mk defines BUILT_SOURCES for its own purposes.


# Header Link Farm
# ================

# The public header files of libetpan are scattered throughout the
# source tree and defined by libetpaninclude_HEADERS automake variables.
# (The corresponding libetpanincludedir is defined in rules.mk).  Before
# building anything else in the project, we prepare a header link farm
# in include/libetpan (this directory will be created).  The header link
# farm is generated automatically when any Makefile (or other
# configure-generated file) is modified, for example by editing
# Makefile.am in maintainer mode.  This ensures that all modifications
# to libetpaninclude_HEADERS variables are picked up properly.

# The header link farm is built using the BUILT_SOURCES mechanism of
# automake, which means that it will only be built by "make all", "make
# check" and "make install".  This means that eithr of these commands
# needs to be used before targeting individual project files works.  If
# the header link farm should be generated or updated manually, the
# following command can be used in the *top-level build directory*:

# $ rm stamp-prepare; make stamp-prepare



# Public header files are defined by libetpaninclude_HEADERS variables.
etpanincludedir = $(includedir)/libetpan

# We add a recursive target "prepare" which creates the desired links
# in include/libetpan from libetpan include files scattered throughout
# the source.  See also README.rules.

# We hook into the BUILT_SOURCES mechanism of automake, see Section
# "Built sources" in the automake manual for details.
BUILT_SOURCES = $(top_builddir)/stamp-prepare

# The stamp file depends on all files generated by configure.  This
# naturally includes all Makefiles which define
# libetpaninclude_HEADERS variables for public header files, which are
# the files we want.  There are some more files in this list, but we
# don't mind regenerating the header link farm a bit more often than
# necessary.  Usually you won't notice a difference as
# configure-generated files are updated very rarely.
$(top_builddir)/stamp-prepare: $(cfg_files)
	cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) stamp-prepare-target
	touch $(top_builddir)/stamp-prepare

# This target should only be invoked in the top level directory (ie
# indirectly through $(top_builddir)/stamp-prepare).  It is
# responsible for updating the header link farm.  First, the header
# link farm is deleted by invoking the clean target in the include
# directory.  Then the header link farm is (re-)generated by
# exploiting the recursive targets mechanism provided by automake.
# Note that this is exploiting automake internals (automake currently
# provides no official hooks for recursive targets).
stamp-prepare-target: $(cfg_files)
	cd include && $(MAKE) $(AM_MAKEFLAGS) clean
	$(MAKE) $(AM_MAKEFLAGS) RECURSIVE_TARGETS=prepare-recursive prepare
	touch stamp-prepare

# Leaf directories (without SUBDIRS) do not have a target
# $(RECURSIVE_TARGETS), so we need to terminate prepare-recursive for
# them here.
prepare-recursive:

# The standard prepare target first recurses, and then calls the
# individual rules.
prepare: prepare-recursive prepare-am

# The local prepare rules are first rules internal to this file
# rules.mk, and second rules local to a single Makefile.am file.  The
# internal rules here create symbolic links for each installed public
# header file of libetpan under $(top_builddir)/include/libetpan/.
prepare-am: prepare-local
	@if test "$(etpaninclude_HEADERS)" != ""; then \
	  echo "top_srcdir: $(top_srcdir) abs_top_srcdir: $(abs_top_srcdir)"; \
          echo "$(mkinstalldirs) $(top_builddir)/include/libetpan/"; \
          $(mkinstalldirs) $(top_builddir)/include/libetpan/;\
	  for hdr in $(etpaninclude_HEADERS) list_end; do \
           if test $${hdr} != list_end; then \
                 filepath="$(abs_top_srcdir)/$(subdir)"; \
		 echo "Looking for $${filepath}/$${hdr}"; \
	         if test -e $${filepath}/$${hdr}; then \
	           echo "$(LN_S) -f $${filepath}/$${hdr} $(top_builddir)/include/libetpan"; \
	           $(LN_S) -f $${filepath}/$${hdr} $(top_builddir)/include/libetpan; \
             else \
	           echo "Failed the existence check"; \
	           echo "$(LN_S) -f $(top_builddir)/$(subdir)/$${hdr} $(top_builddir)/include/libetpan"; \
	           $(LN_S) -f $(abs_top_builddir)/$(subdir)/$${hdr} $(top_builddir)/include/libetpan; \
             fi; \
           fi; \
	     done; \
	fi

# Use this target to extend the prepare rules in a single Makefile.am.
prepare-local:


#  Copyright 2007 g10 Code GmbH

#  This file is free software; as a special exception the author gives
#  unlimited permission to copy and/or distribute it, with or without
#  modifications, as long as this notice is preserved.

#  This file is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
#  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
