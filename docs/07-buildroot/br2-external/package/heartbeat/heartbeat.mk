################################################################################
#
# heartbeat
#
################################################################################

HEARTBEAT_VERSION = 1.0
# the sources live in lesson 6 of this repository
HEARTBEAT_SITE = $(BR2_EXTERNAL_COURSE_PATH)/../../06-init/app
HEARTBEAT_SITE_METHOD = local

# TARGET_CONFIGURE_OPTS passes Buildroot's cross compiler, CFLAGS and LDFLAGS.
# clean first: the copied folder may hold a binary from lesson 6
define HEARTBEAT_BUILD_CMDS
	$(MAKE) -C $(@D) clean
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define HEARTBEAT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/heartbeat $(TARGET_DIR)/usr/bin/heartbeat
endef

# used with BusyBox init and System V init: rcS runs /etc/init.d/S??* at boot
define HEARTBEAT_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/heartbeat.init $(TARGET_DIR)/etc/init.d/S40heartbeat
endef

# used with systemd
define HEARTBEAT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 $(@D)/heartbeat.service $(TARGET_DIR)/usr/lib/systemd/system/heartbeat.service
endef

$(eval $(generic-package))
