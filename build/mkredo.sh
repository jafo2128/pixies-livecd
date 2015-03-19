#!/bin/bash

seq="setup_target_path unpack config_profile_link setup_confdir chroot_setup preclean livecd_update fsscript rcupdate unmerge remove empty integritycheck target_setup setup_overlay" # create_iso"

for i in $seq; do
	touch "/local/catalyst/tmp/default/.autoresume-livecd-stage2-amd64-hardened-2015.02/${i}"
done

