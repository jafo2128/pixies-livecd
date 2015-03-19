
SNAPSHOT="hardened-2015.02"

PACKAGES_DIR="/local/catalyst/packages/${SNAPSHOT}"

stage='0'

start() {

	[[ "${stage}" == "0" ]] && exit 1
	CHROOT_DIR="/local/catalyst/tmp/default/livecd-stage${stage}-amd64-${SNAPSHOT}"

	mount | grep -q "${CHROOT_DIR}/usr/portage " || \
		mount -o bind /usr/portage ${CHROOT_DIR}/usr/portage
	mkdir -p ${CHROOT_DIR}/local/distfiles
	mount | grep -q "${CHROOT_DIR}/local/distfiles " || \
		mount -o bind /local/portage/distfiles ${CHROOT_DIR}/local/distfiles
	mount | grep -q "${CHROOT_DIR}/usr/portage/packages " || \
		mount -o bind ${PACKAGES_DIR} ${CHROOT_DIR}/usr/portage/packages
	mount | grep -q "${CHROOT_DIR}/usr/local/portage " || \
		mount -o bind /local/portage/overlay ${CHROOT_DIR}/usr/local/portage
	mount | grep -q "${CHROOT_DIR}/dev " || \
		mount -o bind /dev ${CHROOT_DIR}/dev
	mount | grep -q "${CHROOT_DIR}/sys " || \
		mount -o bind /sys ${CHROOT_DIR}/sys
	mount | grep -q "${CHROOT_DIR}/proc " || \
		mount -o bind /proc ${CHROOT_DIR}/proc

	chroot ${CHROOT_DIR} /bin/bash
}

partial() {
	[[ "${stage}" == "0" ]] && exit 1
	CHROOT_DIR="/local/catalyst/tmp/default/livecd-stage${stage}-amd64-${SNAPSHOT}"

	mkdir -p ${CHROOT_DIR}/local/distfiles
	mount | grep -q "${CHROOT_DIR}/local/distfiles " || \
		mount -o bind /local/portage/distfiles ${CHROOT_DIR}/local/distfiles
}


stop() {
	[[ "${stage}" == "0" ]] && exit 1
	CHROOT_DIR="/local/catalyst/tmp/default/livecd-stage${stage}-amd64-${SNAPSHOT}"

	mount | grep -q "${CHROOT_DIR}/local/distfiles " && \
		umount ${CHROOT_DIR}/local/distfiles
	mount | grep -q "${CHROOT_DIR}/usr/portage/packages " && \
		umount ${CHROOT_DIR}/usr/portage/packages
	mount | grep -q "${CHROOT_DIR}/usr/local/portage " && \
		umount ${CHROOT_DIR}/usr/local/portage
	mount | grep -q "${CHROOT_DIR}/usr/portage " && \
		umount ${CHROOT_DIR}/usr/portage
	mount | grep -q "${CHROOT_DIR}/dev " && \
		umount ${CHROOT_DIR}/dev
	mount | grep -q "${CHROOT_DIR}/sys " && \
		umount ${CHROOT_DIR}/sys
	mount | grep -q "${CHROOT_DIR}/proc " && \
		umount ${CHROOT_DIR}/proc

}

while (( "$#" )); do

        if [ "$1" = "--stage" ]; then
			shift;
			stage=$1
			shift;
        elif [ "$1" = "--start" ]; then
            shift;
            start
        elif [ "$1" = "--partial" ]; then
            shift;
            partial
        elif [ "$1" = "--stop" ]; then
        	shift;
			stop
		else
			shift;
		fi
done
