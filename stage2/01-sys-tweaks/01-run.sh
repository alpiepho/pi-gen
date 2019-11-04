#!/bin/bash -e

install -m 755 files/resize2fs_once	"${ROOTFS_DIR}/etc/init.d/"

# EXTENDED - install pi_gen_extended_once scripts
install -m 755 files/pi_gen_extended_once_system	"${ROOTFS_DIR}/etc/init.d/"
install -m 755 files/pi_gen_extended_once_config	"${ROOTFS_DIR}/etc/init.d/"

install -d				"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf	"${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi		"${ROOTFS_DIR}/etc/apt/apt.conf.d/"

install -m 644 files/console-setup   	"${ROOTFS_DIR}/etc/default/"

install -m 755 files/rc.local		"${ROOTFS_DIR}/etc/"

on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
if [ "${ENABLE_SSH}" == "1" ]; then
	systemctl enable ssh
else
	systemctl disable ssh
fi
systemctl enable regenerate_ssh_host_keys
EOF

if [ "${USE_QEMU}" = "1" ]; then
	echo "enter QEMU mode"
	install -m 644 files/90-qemu.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
	on_chroot << EOF
systemctl disable resize2fs_once
EOF
	echo "leaving QEMU mode"
else
	on_chroot << EOF
systemctl enable resize2fs_once
EOF
fi

# EXTENDED - enable pi_gen_extended_once scripts
on_chroot << EOF
systemctl enable pi_gen_extended_once_system
systemctl enable pi_gen_extended_once_config
EOF


on_chroot <<EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r "\$GRP"
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

on_chroot << EOF
usermod --pass='*' root
EOF

# EXTENDED - run rpi_setup0.sh and rpi_setup2.sh
on_chroot << EOF
cd /home/pi
# basic setup
sudo -u pi ./rpi_setup0.sh
# node setup
sudo -u pi ./rpi_setup2.sh
EOF

# EXTENDED - example of installing custom-node-app
#on_chroot << EOF
#cd /home/pi
## unpack and install custom-node-app
#sudo -u pi tar xzvf custom-node-app.tgz
#cd custom-node-app
#sudo -u pi npm install
#EOF

rm -f "${ROOTFS_DIR}/etc/ssh/"ssh_host_*_key*
