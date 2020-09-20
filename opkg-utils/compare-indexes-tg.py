#!/usr/bin/env python3

from __future__ import absolute_import
from __future__ import print_function

import sys, os
from glob import glob
import subprocess
import opkg

pkg_dir1 = sys.argv[1]
pkg_dir2 = sys.argv[2]

if ( not pkg_dir1 or not pkg_dir2 ):
	sys.stderr.write("Usage: opkg-update-index <Packages1> <Packages2>\n")
	sys.exit(1)

pkgs1 = opkg.Packages()
pkgs1.read_packages_file(pkg_dir1)

pkgs2 = opkg.Packages()
pkgs2.read_packages_file(pkg_dir2)

names1 = list(pkgs1.packages.keys())
names2 = list(pkgs2.packages.keys())

## union of the two names lists
pkgs = {}
for name in names1:
    pkgs[name] = pkgs1.packages[name]
for name in names2:
    pkgs[name] = pkgs2.packages[name]

names = list(pkgs.keys())
names.sort() 
for name in names:
    pkg1 = None
    pkg2 = None
    if name in pkgs1.packages:
        pkg1 = pkgs1.packages[name]
    if name in pkgs2.packages:
        pkg2 = pkgs2.packages[name]
    if pkg1 and pkg2 and pkg1.version != pkg2.version:
        print("- %s %s updated,\\n"% (pkg1.package, pkg2.version))
    if not pkg1:
        print("- %s %s added,\\n"% (pkg2.package, pkg2.version))
    if not pkg2:
        print("- %s %s deleted,\\n"% (pkg1.package, pkg1.version))
