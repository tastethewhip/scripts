#!/bin/bash
# set paths / dirs
_paths="/home/fabio/musica"

# binary file name
_unison=/usr/bin/unison

# server names
# sync server1.cyberciti.com with rest of the server in cluster
_rserver="fa-work"

# sync it
for r in ${_rserver};do
	for p in ${_paths};do
		${_unison} -batch "${p}"  "ssh://${r}/${p}"
	done
done
