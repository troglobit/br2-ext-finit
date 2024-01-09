################################################################################
#
# skeleton-init-finit
#
################################################################################

SKELETON_INIT_FINIT_VERSION = 1.2
SKELETON_INIT_FINIT_SITE = $(call github,troglobit,finit-skel,v$(SKELETON_INIT_FINIT_VERSION))
SKELETON_INIT_FINIT_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_INIT_FINIT_ADD_SKELETON_DEPENDENCY = NO
SKELETON_INIT_FINIT_TMPFILE := $(shell mktemp)
SKELETON_INIT_FINIT_DEPENDENCIES = skeleton-init-common

# Enable when BR2_INIT_FINIT
#SKELETON_INIT_FINIT_PROVIDES = skeleton

#
# Helpers
#
ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_ENABLE),y)
define finit_enable
	ln -sf ../available/$(1).conf $(FINIT_D)/enabled/$(1).conf
endef
endif

define finit_disable
	rm -f $(FINIT_D)/enabled/$(1).conf
endef

#
# Workarounds
#

# Should be in ifupdown-scripts package
ifeq ($(BR2_PACKAGE_IFUPDOWN_SCRIPTS),y)
define SKELETON_INIT_FINIT_IFUPDOWN_WORKAROUND
	$(IFUPDOWN_SCRIPTS_PREAMBLE)
	$(IFUPDOWN_SCRIPTS_LOCALHOST)
        $(IFUPDOWN_SCRIPTS_DHCP)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_IFUPDOWN_WORKAROUND
endif

#
# Finit services to enable by default if selected in Buildroot Menuconfig
# Note, since some services need a .conf file in /etc they are disabled.
#

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

define SKELETON_INIT_FINIT_SET_GENERIC_GETTY
	$(SKELETON_INIT_FINIT_GETTY) > $(SKELETON_INIT_FINIT_TMPFILE)
	grep -qxF "`cat $(SKELETON_INIT_FINIT_TMPFILE)`" $(FINIT_D)/available/getty.conf \
		|| cat $(SKELETON_INIT_FINIT_TMPFILE) >> $(FINIT_D)/available/getty.conf
	rm $(SKELETON_INIT_FINIT_TMPFILE)
	$(call finit_enable,getty)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_GENERIC_GETTY

ifeq ($(BR2_PACKAGE_AVAHI_DAEMON),y)
define SKELETON_INIT_FINIT_SET_AVAHI
	$(call finit_enable,avahi)
	$(call finit_enable,avahi-dnsconfd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_AVAHI
endif

ifeq ($(BR2_PACKAGE_AVAHI_AUTOIPD),y)
define SKELETON_INIT_FINIT_SET_AVAHI_AUTOIPD
	echo "service [2345789] name:zeroconf :%i avahi-autoipd --force-bind --syslog %i -- ZeroConf for %i" \
		> $(FINIT_D)/available/zeroconf@.conf
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_AVAHI_AUTOIPD
endif

ifeq ($(BR2_PACKAGE_CHRONY),y)
define SKELETON_INIT_FINIT_SET_CHRONY
	$(call finit_enable,chrony)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_CHRONY
endif

ifeq ($(BR2_PACKAGE_CONNTRACKD),y)
define SKELETON_INIT_FINIT_SET_CONNTRACKD
	$(call finit_enable,conntrackd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_CONNTRACKD
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_CROND),y)
define SKELETON_INIT_FINIT_SET_CROND
	$(call finit_enable,crond)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_CROND
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_DNSD),y)
define SKELETON_INIT_FINIT_SET_DNSD
	$(call finit_enable,dnsd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_DNSD
endif

ifeq ($(BR2_PACKAGE_DNSMASQ),y)
define SKELETON_INIT_FINIT_SET_DNSMASQ
	$(call finit_enable,dnsmasq)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_DNSMASQ
endif

ifeq ($(BR2_PACKAGE_DROPBEAR),y)
define SKELETON_INIT_FINIT_SET_DROPBEAR
	$(call finit_enable,dropbear)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_DROPBEAR
endif

ifeq ($(BR2_PACKAGE_FRR),y)
define SKELETON_INIT_FINIT_SET_FRR
	cp $(FINIT_D)/available/frr/*  $(FINIT_D)/available/
	$(call finit_enable,zebra)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_FRR
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_FTPD),y)
define SKELETON_INIT_FINIT_SET_FTPD
	$(call finit_enable,ftpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_FTPD
endif

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GDB_SERVER_COPY),y)
define SKELETON_INIT_FINIT_SET_GDBSERVER
	$(call finit_enable,gdbserver)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_GDBSERVER
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_HTTPD),y)
define SKELETON_INIT_FINIT_SET_HTTPD
	$(call finit_enable,httpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_HTTPD
endif

ifeq ($(BR2_PACKAGE_INADYN),y)
define SKELETON_INIT_FINIT_SET_INADYN
	$(call finit_enable,inadyn)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_INADYN
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_INETD),y)
define SKELETON_INIT_FINIT_SET_INETD
	$(call finit_enable,inetd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_INETD
endif

ifeq ($(BR2_PACKAGE_LLDPD),y)
define SKELETON_INIT_FINIT_SET_LLDPD
	$(call finit_enable,lldpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_LLDPD
endif

ifeq ($(BR2_PACKAGE_MDNSD),y)
define SKELETON_INIT_FINIT_SET_MDNSD
	$(call finit_enable,mdnsd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_MDNSD
endif

ifeq ($(BR2_PACKAGE_MINI_SNMPD),y)
define SKELETON_INIT_FINIT_SET_MINI_SNMPD
	$(call finit_enable,mini-snmpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_MINI_SNMPD
endif

ifeq ($(BR2_PACKAGE_MSTPD),y)
define SKELETON_INIT_FINIT_SET_MSTPD
	$(call finit_enable,mstpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_MSTPD
endif

ifeq ($(BR2_PACKAGE_NETSNMP),y)
define SKELETON_INIT_FINIT_SET_NETSNMP
	$(call finit_enable,snmpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_NETSNMP
endif

ifeq ($(BR2_PACKAGE_NGINX),y)
define SKELETON_INIT_FINIT_SET_NGINX
	$(call finit_enable,nginx)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_NGINX
endif

ifeq ($(BR2_PACKAGE_NTPD),y)
define SKELETON_INIT_FINIT_SET_NTPD
	$(call finit_enable,ntpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_NTPD
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_NTPD),y)
define SKELETON_INIT_FINIT_SET_NTPD
	$(call finit_enable,ntpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_NTPD
endif

ifeq ($(BR2_PACKAGE_OPENSSH),y)
define SKELETON_INIT_FINIT_SET_OPENSSH
	$(call finit_enable,sshd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_OPENSSH
endif

ifeq ($(BR2_PACKAGE_QUAGGA),y)
define SKELETON_INIT_FINIT_SET_QUAGGA
	cp $(FINIT_D)/available/quagga/zebra.conf $(FINIT_D)/available/
	$(call finit_enable,zebra)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA

ifeq ($(BR2_PACKAGE_QUAGGA_ISISD),y)
define SKELETON_INIT_FINIT_SET_QUAGGA_ISISD
	cp $(FINIT_D)/available/quagga/isisd.conf $(FINIT_D)/available/
	$(call finit_enable,isisd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA_ISISD
endif

ifeq ($(BR2_PACKAGE_QUAGGA_OSPFD),y)
define SKELETON_INIT_FINIT_SET_QUAGGA_OSPFD
	cp $(FINIT_D)/available/quagga/ospfd.conf $(FINIT_D)/available/
	$(call finit_enable,ospfd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA_OSPFD
endif

ifeq ($(BR2_PACKAGE_QUAGGA_OSP6D),y)
define SKELETON_INIT_FINIT_SET_QUAGGA_OSP6D
	cp $(FINIT_D)/available/quagga/ospf6d.conf $(FINIT_D)/available/
	$(call finit_enable,ospf6d)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA_OSP6D
endif

ifeq ($(BR2_PACKAGE_QUAGGA_RIPD),y)
define SKELETON_INIT_FINIT_SET_QUAGGA_RIPD
	cp $(FINIT_D)/available/quagga/ripd.conf $(FINIT_D)/available/
	$(call finit_enable,ripd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA_RIPD
endif

ifeq ($(BR2_PACKAGE_QUAGGA_RIPNGD),y)
define SKELETON_INIT_FINIT_SET_QUAGGA_RIPNG
	cp $(FINIT_D)/available/quagga/ripng.conf $(FINIT_D)/available/
	$(call finit_enable,ripng)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_QUAGGA_RIPNG
endif

endif # BR2_PACKAGE_QUAGGA

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
define SKELETON_INIT_FINIT_SET_RNGD
	$(call finit_enable,rngd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_RNGD
endif

ifeq ($(BR2_PACKAGE_SMCROUTE),y)
define SKELETON_INIT_FINIT_SET_SMCROUTE
	$(call finit_enable,smcroute)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_SMCROUTE
endif

ifeq ($(BR2_PACKAGE_SSDP_RESPONDER),y)
define SKELETON_INIT_FINIT_SET_SSDP_RESPONDER
	$(call finit_enable,ssdp-responder)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_SSDP_RESPONDER
endif

# Enable Busybox syslogd unless sysklogd is enabled
ifeq ($(BR2_PACKAGE_SYSKLOGD),y)
define SKELETON_INIT_FINIT_SET_SYSLOGD
	$(call finit_enable,sysklogd)
	$(call finit_disable,syslogd)
endef
else
define SKELETON_INIT_FINIT_SET_SYSLOGD
	$(call finit_enable,syslogd)
	$(call finit_disable,sysklogd)
endef
endif
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_SYSLOGD

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_TELNETD),y)
define SKELETON_INIT_FINIT_SET_TELNETD
	$(call finit_enable,telnetd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_TELNETD
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_UDHCPD),y)
define SKELETON_INIT_FINIT_SET_UDHCPD
	$(call finit_enable,udhcpd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_UDHCPD
endif

ifeq ($(BR2_PACKAGE_ULOGD),y)
define SKELETON_INIT_FINIT_SET_ULOGD
	$(call finit_enable,ulogd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_ULOGD
endif

ifeq ($(BR2_PACKAGE_WATCHDOGD),y)
define SKELETON_INIT_FINIT_SET_WATCHDOGD
	$(call finit_enable,watchdogd)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_WATCHDOGD
endif

ifeq ($(BR2_PACKAGE_WPA_SUPPLICANT),y)
define SKELETON_INIT_FINIT_SET_WPA_SUPPLICANT
	$(call finit_enable,wpa_supplicant)
endef
SKELETON_INIT_FINIT_POST_INSTALL_TARGET_HOOKS += SKELETON_INIT_FINIT_SET_WPA_SUPPLICANT
endif

#
# Install skeleton, with all available/ .conf files
#

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

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_INETD_FAKEIDENTD),y)
define SKELETON_INIT_FINIT_INETD_FAKEIDENTD
	$(SED) '\:^#[[:blank:]]*ident[[:blank:]]:s/^# //' $(TARGET_DIR)/etc/inetd.conf
endef
else
define SKELETON_INIT_FINIT_INETD_FAKEIDENTD
	$(SED) '\:^ident[[:blank:]]:s/^/# /' $(TARGET_DIR)/etc/inetd.conf
endef
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_INETD_FTPD),y)
define SKELETON_INIT_FINIT_INETD_FTPD
	$(SED) '\:^#[[:blank:]]*ftp[[:blank:]]:s/^# //' $(TARGET_DIR)/etc/inetd.conf
endef
else
define SKELETON_INIT_FINIT_INETD_FTPD
	$(SED) '\:^ftp[[:blank:]]:s/^/# /' $(TARGET_DIR)/etc/inetd.conf
endef
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_INETD_TELNETD),y)
define SKELETON_INIT_FINIT_INETD_TELNETD
	$(SED) '\:^#[[:blank:]]*telnet[[:blank:]]:s/^# //' $(TARGET_DIR)/etc/inetd.conf
endef
else
define SKELETON_INIT_FINIT_INETD_TELNETD
	$(SED) '\:^telnet[[:blank:]]:s/^/# /' $(TARGET_DIR)/etc/inetd.conf
endef
endif

ifeq ($(BR2_PACKAGE_SKELETON_INIT_FINIT_INETD_TFTPD),y)
define SKELETON_INIT_FINIT_INETD_TFTPD
	$(SED) '\:^#[[:blank:]]*tftp[[:blank:]]:s/^# //' $(TARGET_DIR)/etc/inetd.conf
endef
else
define SKELETON_INIT_FINIT_INETD_TFTPD
	$(SED) '\:^tftp[[:blank:]]:s/^/# /' $(TARGET_DIR)/etc/inetd.conf
endef
endif

define SKELETON_INIT_FINIT_INSTALL_TARGET_CMDS
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D) install
	$(SKELETON_INIT_FINIT_ROOT_RO_OR_RW)
	$(SKELETON_INIT_FINIT_INETD_TELNETD)
	$(SKELETON_INIT_FINIT_INETD_TFTPD)
endef

$(eval $(generic-package))
