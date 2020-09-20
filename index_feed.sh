#!/usr/bin/env bash

# # Copyright (C) 2011-2020 Entware


# abort on error
set -e

# debug
#set -x

function usage
{
  cat << EOF
    This script creates feed index (Packages.*) for given folder
    usage: index_feed.sh -a -h -t -f /path/to/feed

      -a | --archive		: Create feed archive (default: no)
      -h | --html		: Create Package.html (default: no)
      -t | --telegram		: Send message about changes (default: no)
      -f | --force		: Re-create feed index (default: no)

EOF
}

function parse_args
{
  # positional args
  args=()

  # named args
  while [ "$1" != "" ]; do
    case "$1" in
      -a | --archive )	create_archive='yes';	shift;;
      -h | --html )	create_html='yes';	shift;;
      -t | --telegram )	send_msg='yes';		shift;;
      -f | --force )	force='yes';		shift;;
      * ) args+=("$1");				shift;;
    esac
  done

  # restore positional args
  set -- "${args[@]}"

  # set positionals to vars
  feed_path="${args[0]}"

  # validate required args
  if [[ -z "${feed_path}" || ! -d "${feed_path}" || ! -z "${args[1]}" ]]; then
    echo "Invalid arguments!"
    usage
    exit;
  fi
}

function check_ipk_exists
{
  if [ `ls -1 ${feed_path}/*.ipk  2>/dev/null | wc -l` = 0 ]; then
    echo 'No *.ipk files found, exiting.'
#    rm -f ${feed_path}/Packages*
    exit 1
  fi
}

function create_archive
{
  if [ "$create_archive" = "yes" ]; then
    [ -d ${feed_path}/archive ] || mkdir ${feed_path}/archive
    cp -u ${feed_path}/*.ipk ${feed_path}/archive
  fi
}

function send_msg
{
  feed_name="$(basename ${feed_path})"
  if [ "$send_msg" = "yes" ] && [ -f ${feed_path}/Packages.prev ] && [ "$feed_name" != "keenetic" ]; then
    msg="$(/usr/local/bin/opkg-utils/compare-indexes-tg.py ${feed_path}/Packages.prev ${feed_path}/Packages)"
    if [ `expr length "$msg"` -le 1000 ] && [ ! -z "$msg" ]; then
      msg="$feed_name feed changes:\n $msg"
#      msg+="See <a href=\"https://bin.entware.net/$feed_name/Packages.html\">package list</a> for details."
#      tg_say_entware.sh "$(echo -e $msg)"
    fi
  fi
}

function run
{
  parse_args "$@"
  check_ipk_exists
  if [ "$force" = "yes" ] || [ ! -f ${feed_path}/Packages.gz ] || \
	[ -n "$(find ${feed_path} -maxdepth 1 -type f -name "*.ipk" -newer ${feed_path}/Packages.gz)" ]; then
    # Delete old temp index file older then 5 minutes. Something went wrong.
    [ -n "$(find ${feed_path} -maxdepth 1 -type f -name Packages.prev -mtime +5)" ] && rm -f ${feed_path}/Packages.prev

    # Previously started indexer is still working, skipping this feed
    if [ -f ${feed_path}/Packages.prev ]; then
        echo 'Previous instance is still running, try to run this script a bit later, exiting.'
        exit 1
    fi

    # Create Packages.manifest, Packages, Packages.gz
    [ -f ${feed_path}/Packages ] && cp ${feed_path}/Packages ${feed_path}/Packages.prev
    /usr/local/bin/mkindex.py $feed_path
#    /usr/local/bin/mkindex.sh $feed_path

    # Fix file permissions if possible
    [ "$USER" = "root" ] && chmod 666 ${feed_path}/*.ipk ${feed_path}/Packages*

    # Create archive if needed
    create_archive

    # Create Packages.html if needed
    [ "$create_html" = "yes" ] && /usr/local/bin/mkhtml.py $feed_path

    # Send telegram message if needed
    send_msg

    rm -f ${feed_path}/Packages.prev
  fi
}

run "$@";
