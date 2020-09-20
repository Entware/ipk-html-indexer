#!/usr/bin/env bash
#
# Copyright (C) 2011-2018 Entware
#

if [ -z "$1" ] ; then
    cat << EOF
	Usage:
	ipk_index_archiver.sh /path/to/repo arch_html
	/path/to/repo	- folder with *.ipk files
	arch_html 	- (optional) build HTML index and make an archive of packages
EOF
    exit 0
fi

cd "$1"

# Skip feed if no packages here
if [ -z "$(ls *.ipk)" ] ; then
	echo 'No *.ipk files found'
	rm -f Packages*
	exit 1
fi

# Index feed only if there is no index or it's older than any of packages
if [ ! -f Packages.gz ] || [ -n "$(find -maxdepth 1 -type f -name "*.ipk" -newer Packages.gz)" ] ; then
    # Delete old temp index file older then 30 minutes. Something went wrong.
    [ -n "$(find -name "Packages.prev" -mtime +30)" ] && rm -f Packages.prev

    # Previously started indexer is still working, skipping this feed
    if [ -f Packages.prev ] ; then
	echo 'Previous instance is still running, try to run this script a bit later'
	exit 0
    fi

    echo "Indexing $1 ..."
    [ -f Packages ] && cp Packages Packages.prev
    chmod 666 *.ipk
    /usr/local/bin/ipkg-make-index.sh . 2>&1 > Packages.manifest
    grep -vE '^(Maintainer|LicenseFiles|Source|Require)' Packages.manifest > Packages
    gzip -9nc Packages > Packages.gz

    feed_name="$(basename $1)"
    if [ -f Packages.prev ] && [ ! -z "$(echo $feed_name | grep -E 'aarch64-k3.10|armv5sf-k3.2|armv7sf-k2.6|armv7sf-k3.2|mipselsf-k3.4|mipssf-k3.4|x64-k3.2')" ] && [ "$feed_name" != "keenetic" ]; then
       msg="$feed_name feed changes:\n"
       msg+=" $(/home/ryzhovau/index-compare/compare-indexes-tg.py Packages.prev Packages)"
       msg+="See <a href=\"https://bin.entware.net/$feed_name/Packages.html\">package list</a> for details."
       tg_say_entware.sh "$(echo -e $msg)"
    fi

    if [ ! -z "$2" ] ; then
	/usr/local/bin/index_html.sh > Packages.html
	echo "Archiving $1 feed..."
	[ -d archive ] || mkdir archive
	cp -u *.ipk archive
    fi

    rm -f Packages.prev
fi
