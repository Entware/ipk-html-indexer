#!/usr/bin/env python3

# Copyright (C) 2011-2021 Entware

import os
import hashlib
import tarfile
import gzip
import sys
import io
import time

start = time.time()

path = sys.argv[-1] + "/"

if not os.path.isdir(path):
    print(path + " folder is not exists!")
    sys.exit()

def size(path):
	return os.path.getsize(path)

def patch(package):
	_package = package.split("\n")
	out = []
	_fields = []
	fields = ['Package: ', 'Version: ', 'Depends: ', 'Conflicts: ', 'Provides: ', 'Section: ', 'Essential: ', 'Architecture: ', 'Installed-Size: ', 'Filename: ', 'Size: ', 'SHA256sum: ']
	for j in fields:
		for i in _package:
			if i.startswith(j):
				out.append(i.split(j)[1])
				_fields.append(j)
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

def get_hash(file):
	sha256 = hashlib.sha256()
	with open(file, "rb") as f:
	    sha256.update(f.read())
	return sha256.hexdigest()

a_ = open(path + "Packages.manifest", "w")
a2_ = open(path + "Packages", "w")
files = [i for i in next(os.walk(path))[-1] if i.endswith(".ipk")]
files.sort(key = lambda x: x.split("_")[0])

for i in files:
    with tarfile.open(path + i, "r:gz") as tar:
        control_file = tar.extractfile("./control.tar.gz").read()
        with tarfile.open(fileobj = io.BytesIO(control_file), mode = "r:gz") as tar2:
            b = tar2.extractfile("./control").read().decode()
    c = b.find("Description: ")
    d = b[:c] + "Filename: " + i + "\nSize: " + str(size(path+i)) + "\nSHA256sum: " + str(get_hash(path + i)) + "\n" + b[c:].replace("Description:  ", "Description: ")
    a_.write(d + "\n")
    a2_.write(patch(d))

a_.close()
a2_.close()

with gzip.open(path + 'Packages.gz', 'wb') as f, open(path + 'Packages', 'rb') as p:
    f.write(p.read())

finish = time.time()
print(f'Indexing finished, spent {round(finish-start, 2)} sec.')