###########################################################
#
# bash-completion
#
###########################################################
#
# BASH_COMPLETION_VERSION, BASH_COMPLETION_SITE and BASH_COMPLETION_SOURCE define
# the upstream location of the source code for the package.
# BASH_COMPLETION_DIR is the directory which is created when the source
# archive is unpacked.
# BASH_COMPLETION_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
BASH_COMPLETION_SITE=http://bash-completion.alioth.debian.org/files
BASH_COMPLETION_VERSION=1.2
BASH_COMPLETION_SOURCE=bash-completion-$(BASH_COMPLETION_VERSION).tar.bz2
BASH_COMPLETION_DIR=bash-completion-$(BASH_COMPLETION_VERSION)
BASH_COMPLETION_UNZIP=bzcat
BASH_COMPLETION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BASH_COMPLETION_DESCRIPTION=Programmable completion for the bash shell
BASH_COMPLETION_SECTION=utils
BASH_COMPLETION_PRIORITY=optional
BASH_COMPLETION_DEPENDS=
BASH_COMPLETION_SUGGESTS=bash
BASH_COMPLETION_CONFLICTS=

#
# BASH_COMPLETION_IPK_VERSION should be incremented when the ipk changes.
#
BASH_COMPLETION_IPK_VERSION=1

#
# BASH_COMPLETION_CONFFILES should be a list of user-editable files
#BASH_COMPLETION_CONFFILES=$(TARGET_PREFIX)/etc/bash-completion.conf $(TARGET_PREFIX)/etc/init.d/SXXbash-completion

#
# BASH_COMPLETION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BASH_COMPLETION_PATCHES=$(BASH_COMPLETION_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BASH_COMPLETION_CPPFLAGS=
BASH_COMPLETION_LDFLAGS=

#
# BASH_COMPLETION_BUILD_DIR is the directory in which the build is done.
# BASH_COMPLETION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BASH_COMPLETION_IPK_DIR is the directory in which the ipk is built.
# BASH_COMPLETION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BASH_COMPLETION_BUILD_DIR=$(BUILD_DIR)/bash-completion
BASH_COMPLETION_SOURCE_DIR=$(SOURCE_DIR)/bash-completion
BASH_COMPLETION_IPK_DIR=$(BUILD_DIR)/bash-completion-$(BASH_COMPLETION_VERSION)-ipk
BASH_COMPLETION_IPK=$(BUILD_DIR)/bash-completion_$(BASH_COMPLETION_VERSION)-$(BASH_COMPLETION_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bash-completion-source bash-completion-unpack bash-completion bash-completion-stage bash-completion-ipk bash-completion-clean bash-completion-dirclean bash-completion-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BASH_COMPLETION_SOURCE):
	$(WGET) -P $(@D) $(BASH_COMPLETION_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bash-completion-source: $(DL_DIR)/$(BASH_COMPLETION_SOURCE) $(BASH_COMPLETION_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(BASH_COMPLETION_BUILD_DIR)/.configured: $(DL_DIR)/$(BASH_COMPLETION_SOURCE) $(BASH_COMPLETION_PATCHES) make/bash-completion.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BASH_COMPLETION_DIR) $(@D)
	$(BASH_COMPLETION_UNZIP) $(DL_DIR)/$(BASH_COMPLETION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BASH_COMPLETION_PATCHES)" ; \
		then cat $(BASH_COMPLETION_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(BASH_COMPLETION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BASH_COMPLETION_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BASH_COMPLETION_DIR) $(@D) ; \
	fi
	sed -i -e 's|/etc/bash_completion|$(TARGET_PREFIX)&|' $(@D)/bash_completion*
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BASH_COMPLETION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BASH_COMPLETION_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bash-completion-unpack: $(BASH_COMPLETION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BASH_COMPLETION_BUILD_DIR)/.built: $(BASH_COMPLETION_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bash-completion: $(BASH_COMPLETION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BASH_COMPLETION_BUILD_DIR)/.staged: $(BASH_COMPLETION_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bash-completion-stage: $(BASH_COMPLETION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bash-completion
#
$(BASH_COMPLETION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: bash-completion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BASH_COMPLETION_PRIORITY)" >>$@
	@echo "Section: $(BASH_COMPLETION_SECTION)" >>$@
	@echo "Version: $(BASH_COMPLETION_VERSION)-$(BASH_COMPLETION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BASH_COMPLETION_MAINTAINER)" >>$@
	@echo "Source: $(BASH_COMPLETION_SITE)/$(BASH_COMPLETION_SOURCE)" >>$@
	@echo "Description: $(BASH_COMPLETION_DESCRIPTION)" >>$@
	@echo "Depends: $(BASH_COMPLETION_DEPENDS)" >>$@
	@echo "Suggests: $(BASH_COMPLETION_SUGGESTS)" >>$@
	@echo "Conflicts: $(BASH_COMPLETION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/etc/bash-completion/...
# Documentation files should be installed in $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/doc/bash-completion/...
# Daemon startup scripts should be installed in $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??bash-completion
#
# You may need to patch your application to make it use these locations.
#
$(BASH_COMPLETION_IPK): $(BASH_COMPLETION_BUILD_DIR)/.built
	rm -rf $(BASH_COMPLETION_IPK_DIR) $(BUILD_DIR)/bash-completion_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<D) DESTDIR=$(BASH_COMPLETION_IPK_DIR) install-strip
	$(INSTALL) -d $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/share/doc/bash-completion/contrib
	mv $(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/etc/bash_completion.d/* \
		$(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/share/doc/bash-completion/contrib/
	$(INSTALL) -m644 $(<D)/[CRT]* $(<D)/bash_completion \
		$(BASH_COMPLETION_IPK_DIR)$(TARGET_PREFIX)/share/doc/bash-completion/
	$(MAKE) $(BASH_COMPLETION_IPK_DIR)/CONTROL/control
	echo $(BASH_COMPLETION_CONFFILES) | sed -e 's/ /\n/g' > $(BASH_COMPLETION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BASH_COMPLETION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bash-completion-ipk: $(BASH_COMPLETION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bash-completion-clean:
	rm -f $(BASH_COMPLETION_BUILD_DIR)/.built
	-$(MAKE) -C $(BASH_COMPLETION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bash-completion-dirclean:
	rm -rf $(BUILD_DIR)/$(BASH_COMPLETION_DIR) $(BASH_COMPLETION_BUILD_DIR) $(BASH_COMPLETION_IPK_DIR) $(BASH_COMPLETION_IPK)
#
#
# Some sanity check for the package.
#
bash-completion-check: $(BASH_COMPLETION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
