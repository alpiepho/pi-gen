#!/bin/bash -e

install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"

# EXTENDED - enable ssh
# old method, now using ENABLE_SSH in build 'config' file
#install -m 644 files/ssh "${ROOTFS_DIR}/boot/"
