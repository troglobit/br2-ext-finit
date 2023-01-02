################################################################################
#
# skeleton-init-finit
#
################################################################################

SKELETON_INIT_FINIT_VERSION = 0.2
SKELETON_INIT_FINIT_SITE = $(call github,troglobit,finit-skel,v$(SKELETON_INIT_FINIT_VERSION))
SKELETON_INIT_FINIT_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_INIT_FINIT_ADD_SKELETON_DEPENDENCY = NO
SKELETON_INIT_FINIT_TMPFILE := $(shell mktemp)
SKELETON_INIT_FINIT_DEPENDENCIES = skeleton-init-common

# Enable when BR2_INIT_FINT
#SKELETON_INIT_FINIT_PROVIDES = skeleton

# Prefer Finit built-in getty unless options are set, squash zero baudrate
define SKELETON_INIT_FINIT_GETTY
	if [ -z "$(SYSTEM_GETTY_OPTIONS)" ]; then \
		if [ $(SYSTEM_GETTY_BAUDRATE) -eq 0 ]; then \
			SYSTEM_GETTY_BAUDRATE=""; \
		fi; \
		echo "tty [12345789] $(SYSTEM_GETTY_PORT) $(SYSTEM_GETTY_BAUDRATE) $(SYSTEM_GETTY_TERM) noclear"; \
	else \
		echo "tty [12345789] /sbin/getty -L $(SYSTEM_GETTY_OPTIONS) $(SYSTEM_GETTY_BAUDRATE) $(SYSTEM_GETTY_PORT) $(SYSTEM_GETTY_TERM)"; \
	fi
endef

#
# Helpers
#
define finit_enable
	ln -sf ../available/$(1).conf $(FINIT_D)/enabled/$(1).conf
endef

define finit_disable
	rm -f $(FINIT_D)/enabled/$(1).conf
endef

#
# Finit services to enable by default if selected in Buildroot Menuconfig
#
define SKELETON_INIT_FINIT_SET_GENERIC_GETTY
	$(SKELETON_INIT_FINIT_GETTY) > $(SKELETON_INIT_FINIT_TMPFILE)
	grep -qxF "`cat $(SKELETON_INIT_FINIT_TMPFILE)`" $(FINIT_D)/available/getty.conf \
		|| cat $(SKELETON_INIT_FINIT_TMPFILE) >> $(FINIT_D)/available/getty.conf
	rm $(SKELETON_INIT_FINIT_TMPFILE)
	$(finit_enable getty)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_GENERIC_GETTY

# Dropbear SSH
ifeq ($(BR2_PACKAGE_DROPBEAR),y)
define SKELETON_INIT_FINIT_SET_DROPBEAR
	$(finit_enable dropbear)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_DROPBEAR
endif

# OpenSSH
ifeq ($(BR2_PACKAGE_OPENSSH),y)
define SKELETON_INIT_FINIT_SET_OPENSSH
	$(finit_enable sshd)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_OPENSSH
endif

ifeq ($(BR2_PACKAGE_LLDPD),y)
define SKELETON_INIT_FINIT_SET_LLDPD
	$(finit_enable lldpd)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_LLDPD
endif

ifeq ($(BR2_PACKAGE_MINI_SNMPD),y)
define SKELETON_INIT_FINIT_SET_MINI_SNMPD
	$(finit_enable mini-snmpd)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_MINI_SNMPD
endif

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
define SKELETON_INIT_FINIT_SET_RNGD
	$(finit_enable rngd)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_RNGD
endif

# Enable Busybox syslogd unless sysklogd is enabled
ifeq ($(BR2_PACKAGE_SYSKLOGD),y)
define SKELETON_INIT_FINIT_SET_SYSLOGD
	$(finit_enable sysklogd)
	$(finit_disable syslogd)
endef
else
define SKELETON_INIT_FINIT_SET_SYSLOGD
	$(finit_enable syslogd)
	$(finit_disable sysklogd)
endef
endif
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_SYSLOGD

# SSDP Responder
ifeq ($(BR2_PACKAGE_SSDP_RESPONDER),y)
define SKELETON_INIT_FINIT_SET_SSDP_RESPONDER
	$(finit_enable ssdp-responder)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_SSDP_RESPONDER
endif

ifeq ($(BR2_PACKAGE_SMCROUTE),y)
define SKELETON_INIT_FINIT_SET_SMCROUTE
	$(finit_enable smcroute)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_SMCROUTE
endif

# Watchdogd
ifeq ($(BR2_PACKAGE_WATCHDOGD),y)
define SKELETON_INIT_FINIT_SET_WATCHDOGD
	$(finit_enable watchdogd)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_WATCHDOGD
endif

# Enable gdbserver when running in Qemu mode
ifeq ($(QEMU_GDB),y)
define SKELETON_INIT_FINIT_SET_GDBSERVER
	$(finit_enable gdbserver)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_SET_GDBSERVER
endif

# Workaround, should be in ifupdown-scripts package
ifeq ($(BR2_PACKAGE_IFUPDOWN_SCRIPTS),y)
define SKELETON_INIT_FINIT_IFUPDOWN_WORKAROUND
	$(IFUPDOWN_SCRIPTS_PREAMBLE)
	$(IFUPDOWN_SCRIPTS_LOCALHOST)
        $(IFUPDOWN_SCRIPTS_DHCP)
endef
SKELETON_INIT_FINIT_TARGET_FINALIZE_HOOKS += SKELETON_INIT_FINIT_IFUPDOWN_WORKAROUND
endif


ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
# Uncomment /dev/root entry in fstab to allow Finit to remount it rw
define SKELETON_INIT_FINIT_ROOT_RO_OR_RW
	$(SED) '\:^#[[:blank:]]*/dev/root[[:blank:]]:s/^# //' $(TARGET_DIR)/etc/fstab
endef
else
# Comment out /dev/root entry to prevent Finit from remounting it rw
define SKELETON_INIT_FINIT_ROOT_RO_OR_RW
	$(SED) '\:^/dev/root[[:blank:]]:s/^/# /' $(TARGET_DIR)/etc/fstab
endef
endif

define SKELETON_INIT_FINIT_INSTALL_TARGET_CMDS
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D) install
	$(SKELETON_INIT_FINIT_ROOT_RO_OR_RW)
endef

$(eval $(generic-package))
