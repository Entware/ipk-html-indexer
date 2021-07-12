#!/usr/bin/env python3

# Copyright (C) 2011-2020 Entware

import os, sys
import hashlib
import tarfile
import time
import gzip
import sys
import random

path = sys.argv[-1] + "/"
if not os.path.isdir(path):
    print(path + " folder is not exists!")
    sys.exit()

rand_num = str(random.getrandbits(64))
tmp = f"/tmp/s{rand_num}/"
os.mkdir(tmp)

def size(path):
	return os.path.getsize(path)

def patch(package):
	_package = package.split("\n")
	out = []
	_fields = []
	fields = ['Package: ', 'Version: ', 'Depends: ', 'Conflicts: ', 'Provides: ', 'Section: ', 'Essential: ', 'Architecture: ', 'Installed-Size: ', 'Filename: ', 'Size: ', 'SHA256sum: ']
	for j in fields:
		ok = False
		for i in _package:
			if i.startswith(j):
				out.append(i.split(j)[1])
				_fields.append(j)
				ok = True
	_fields.append("Description: ")
	a = package.find("Description: ")
	if a >= 0:
		out.append(package[a+len("Description: "):])
	_out = ""
	s = 0
	for i in out:
		_out += _fields[s] + i + "\n"
		s += 1
	return _out

out = ""
out2 = ""
_files = next(os.walk(path))[-1]
files = []
for i in _files:
	if i.endswith(".ipk"):
		files.append(i)
def get_hash(file):
	sha256 = hashlib.sha256()
	with open(file, "rb") as f:
	    sha256.update(f.read())
	return sha256.hexdigest()
files.sort(key = lambda x: x.split("_")[0])
for i in files:
    tar = tarfile.open(path + i, "r:gz")
    cur = tar.next()
    while cur.name != "./control.tar.gz":
    	cur = tar.next()
    tar.extract(cur, path = tmp)
    tar.close()
    tar = tarfile.open(tmp + "control.tar.gz", "r:gz")
    cur = tar.next()
    while cur.name != "./control":
    	cur = tar.next()
    tar.extract(cur, path = tmp)
    tar.close()
    a = open(tmp + "control")
    b = a.read()
    a.close()
    os.remove(tmp + "control")
    os.remove(tmp + "control.tar.gz")
    c = b.find("Description: ")
    d = b[:c] + "Filename: " + i + "\nSize: " + str(size(path+i)) + "\nSHA256sum: " + str(get_hash(path + i)) + "\n" + b[c:].replace("Description:  ", "Description: ")
    out += d + "\n"
    out2 += patch(d)

os.rmdir(tmp)

a = open(path + "Packages.manifest", "w")
a.write(out)
a.close()

a = open(path + "Packages", "w")
a.write(out2)
a.close()

with gzip.open(path + 'Packages.gz', 'wb') as f:
    f.write(out2.encode())
