#!/usr/bin/env python3

# Copyright (C) 2011-2020 Entware

import sys
import os.path

out = """<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML>
<!-- Designed and coded by Entware team -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
<title>Packages list</title>
<link rel="stylesheet" type="text/css" href="/css/packages.css">
</head>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/list.js/1.5.0/list.min.js"></script>
<body>
<div id="packages">
You may sort table by clicking any column headers and\or use <input class="search" placeholder="Search" /> field.
\n"""

out += """<table>
<thead>
<tr>
<th class="sort" data-sort="name">Name</th>
<th class="sort" data-sort="version">Version</th>
<th class="sort" data-sort="section">Section</th>
<th class="sort">Description</th>
</tr>
</thead>
<tbody class="list">
"""

def parse(package):
    _package = package.split("\n")
    out = []
    for j in ["Filename: ", "Package: ", "Version: ", "Section: "]:
        ok = False
        for i in _package:
            if i.startswith(j):
                out.append(i.split(j)[1])
                ok = True
        if not ok:
            out.append("* Null *")
    a = package.find("Description: ")
    if a >= 0:
        out.append(package[a+len("Description: "):].replace("\n", ""))
    else:
        out.append("* Null *")
    return out

path = sys.argv[-1] + "/Packages"
if not os.path.exists(path):
    print(path + " file is not exists!")
    sys.exit()

text_file = open(path)
b = text_file.read().split("\n\n")
text_file.close()

del b[-1]
packages = map(parse, b)

for filename, name, version, section, description in packages:
    out += f"""\n<tr><td class=\"name\"><a href=\"{filename}\">{name}</a></td>
<td class=\"version\">{version}</td>
<td class=\"section\">{section}</td>
<td class=\"description\">{description} </td></tr>"""

out +="""
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
</html>"""
a = open(path + ".html", "w")
a.write(out)
a.close()
