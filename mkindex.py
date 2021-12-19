#!/usr/bin/env python3

# Copyright (C) 2011-2021 Entware

import os
import hashlib
import tarfile
import gzip
import sys
import io
import time
from collections import OrderedDict

start = time.time()

wrong_fields = ['Maintainer', 'LicenseFiles', 'Source', 'SourceName', 'Require', 'SourceDateEpoch']

path = sys.argv[-1] + "/"

if not os.path.isdir(path):
	print(path + " folder is not exists!")
	sys.exit()

def size(path):
	return os.path.getsize(path)

def patch(package):
	out = OrderedDict()
	for line in package.split("\n"):
		field, data = line.split(': ', maxsplit = 1)
		if field not in wrong_fields:
			out[field] = data
	return out

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
	desc = "Description"
	a = b.find(desc)
	if a == -1:
		data = 'Description:  '
	else:
		data = b[a:]
		b = b[:a-1]
	a_.write(b)
	f = patch(b)
	f["Filename"] = i
	f["Size"] = str(size(path+i))
	f["SHA256sum"] = str(get_hash(path + i))
	for i in ['Filename', 'Size', 'SHA256sum']:
		a_.write('\n'+f'{i}: {f[i]}')
	a_.write('\n' + data + '\n')
	a2_.write('\n'.join([f'{x}: {y}' for x, y in f.items()]))
	a2_.write('\n' + data +'\n')

a_.close()
a2_.close()

with gzip.open(path + 'Packages.gz', 'wb') as f, open(path + 'Packages', 'rb') as p:
	f.write(p.read())

finish = time.time()
print(f'Indexing finished, spent {round(finish-start, 2)} sec.')