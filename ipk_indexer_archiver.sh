#!/usr/bin/env bash
#
# Copyright (C) 2011-2015 Entware
#

# Some measurements on this VPS:
# indexing 9000 packages takes ~1,1 minutes,
# archiving ~0,5 minutes.

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
	rm -f Packages Packages.gz
	exit 1
fi

# Index feed only if there is no index or it's older than any of packages
if [ ! -f Packages.gz ] || [ -n "$(find -maxdepth 1 -type f -name "*.ipk" -newer Packages.gz)" ] ; then
    # Delete old temp index file older then 30 minutes. Something went wrong.
    [ -n "$(find -name "Packages.tmp" -mtime +30)" ] && rm -f Packages.tmp

    # Previously started indexer is still working, skipping this feed
    if [ -f Packages.tmp ] ; then
	echo 'Previous instance is still running, try to run this script a bit later'
	exit 0
    fi

    echo "Indexing $1 ..."
    /usr/local/bin/ipkg-make-index.sh . > Packages.tmp
    # This is a trick for instant replacing feed index
    # Otherwise, index will be absent for several minutes
    mv -f Packages.tmp Packages

    gzip -9c Packages > Packages.gz

    if [ ! -z "$2" ] ; then
	/usr/local/bin/index_html.sh > Packages.html
	echo "Archiving $1 feed..."
	[ -d archive ] || mkdir archive
	cp -u *.ipk archive
    fi
fi
