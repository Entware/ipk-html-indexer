#!/usr/bin/env bash
#
# Copyright (C) 2011-2016 Entware
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
<link rel="stylesheet" type="text/css" href="/css/packages.css">
</head>
<script type="text/javascript" src="/js/list.js"></script>
<body>
<div id="packages">
You may sort table by clicking any column headers and\or use <input class="search" placeholder="Search" /> field.
'

# Table header
echo '<table>
<thead>
<tr>
<th class="sort" data-sort="name">Name</th>
<th class="sort" data-sort="version">Version</th>
<th class="sort" data-sort="section">Section</th>
<th class="sort">Description</th>
</tr>
</thead>
<tbody class="list">
'

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
        echo "<tr><td class=\"name\"><a href=\"$filename\">$name</a></td>
<td class=\"version\">$version</td>
<td class=\"section\">$section</td>
<td class=\"description\">$description</td></tr>"
        pkg_info_started=0
    fi
done < Packages

# Closing HTML table and body
cat << EOF
</tbody>
</table>
</div>
<script type="text/javascript">
    var options = {
        valueNames: [ 'name', 'version', 'section', 'description' ]
    };

    var userList = new List('packages', options);
</script>
</body>
</html>
EOF
