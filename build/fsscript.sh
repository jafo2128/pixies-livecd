#!/bin/sh

## set the root password
#'D;(%n`gN^yFjsc2cyLYo
echo 'root:$1$W1i4J1fe$bybJlnRIdnIbkKZ0m6vxR.' | chpasswd -e

echo 'EDITOR=/usr/bin/vim' > /etc/env.d/99livecd

#rc-update del pwgen default
#rc-update del clock boot
#rc-update add sshd default

cat << EOF > /root/.bashrc
. /etc/bash/bashrc

unset MAIL
shopt -s checkwinsize

grsec_control()
{
        local grsec_keys="destroy_unused_shm chroot_findtask dmesg audit_mount tpe_restrict_all tpe chroot_deny_sysctl chroot_caps chroot_restrict_nice chroot_deny_mknod chroot_deny_chmod chroot_enforce_chdir chroot_deny_pivot chroot_deny_chroot chroot_deny_fchdir chroot_deny_mount chroot_deny_unix chroot_deny_shmat resource_logging forkfail_logging signal_logging fifo_restrictions linking_restrictions"

        for key in \${grsec_keys}; do
                sysctl -w kernel.grsecurity.\${key}=\$1
        done
}

alias minicom="/usr/bin/minicom --color=on --noinit --wrap"
alias grsec_disable="grsec_control 0"
alias grsec_enable="grsec_control 1"

. /usr/libexec/mc/mc.sh

EOF

cat << EOF > /usr/bin/vimpager
#!/bin/bash

cat $1 | col -b | vim -c 'se ft=man ro nomod nowrap ls=1 notitle ic' -c 'nmap <Space> <C-F>' -c 'nmap b <C-B>' -c 'nmap q :q!<CR>' -c 'norm L' -
EOF

chmod 755 /usr/bin/vimpager

#sed -i 's|^RC_DEVICES=".*|RC_DEVICES="static"|' /etc/conf.d/rc

cat << EOF >> /etc/fstab

none      /proc          proc    noauto,nodev,noexec,nosuid    0 0
none      /sys           sysfs   noauto,nodev,noexec,nosuid    0 0
tmpfs     /dev/shm       tmpfs   noauto,nodev,noexec,nosuid    0 0
none      /dev/pts       devpts  noauto,gid=5,mode=620         0 0

#none      /proc/bus/usb  usbfs   defaults               0 0

EOF

cp /usr/lib/gcc/*-pc-linux-gnu/*/*.so* /usr/lib/
ldconfig

/bin/dd if=/dev/urandom of=/var/run/random-seed count=1 &> /dev/null

mkdir -p /boot
mkdir -p /mnt/server

#groupadd sshusers
#useradd -m -G users,sshusers,wheel -g users -s /bin/bash admin
#chown -R admin:users /home/admin

echo " * binary integrity check"
for i in /bin/* /sbin/* /usr/bin/* /usr/sbin/*; do
        ldd $i | grep -v 'use-ld=gold' | grep -qi "not found" && \
                echo $i && \
                ldd $i
done

echo " * broken links"

for i in /bin/ /sbin/ /usr/bin/ /usr/sbin/ /lib/; do
	find "${i}" -type l -xtype l | while read loc; do
		echo " ${loc}  symlink broken"
		rm -f "${loc}"
	done
done

exit 0

