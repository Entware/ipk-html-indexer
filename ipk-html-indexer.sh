#!/usr/bin/env bash
#
# Copyright (C) 2011-2014 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML>
<!-- Designed and coded by Entware team -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
<title>Packages list</title>
</head>
<body>'

# Table header
echo '<table border="1">
<tr>
<th>Name</th>
<th>Version</th>
<th>Section</th>
<th>Description</th>
</tr>'

# Table strings
while read line; do
    case $line in
    Package:*)
        name=${line#Package: }
        pkg_info_started=1
        ;;
    Version:*)
        version=${line#Version: }
        ;;
    Section:*)
        section=${line#Section: }
        ;;
    Filename:*)
        filename=${line#Filename: }
        ;;
    Description:*)
        description=${line#Description: }
        ;;
    *)
        description="$description $line"
        ;;
    esac

    if [ -z "$line" ] && [ "$pkg_info_started" -eq "1" ]
    then
	echo "<tr><td><a href=\"$filename\">$name</a></td>
<td>$version</td>
<td>$section</td>
<td>$description</td></tr>"
	pkg_info_started=0
    fi
done < Packages

# Closing HTML table and body
echo '</table>'
echo '</body>
</html>'
