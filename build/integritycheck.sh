#!/bin/bash

echo " * broken links"

for i in /bin/ /sbin/ /usr/bin/ /usr/sbin/ /lib/; do
    find "${i}" -type l -xtype l | while read loc; do
        echo " ${loc}  symlink broken"
        rm -f "${loc}"
    done
done


echo " * binary integrity check"
for i in /bin/* /sbin/* /usr/bin/* /usr/sbin/*; do
        ldd $i | grep -v 'use-ld=gold' | grep -qi "not found" && \
                echo $i && \
                ldd $i
done

exit 0

