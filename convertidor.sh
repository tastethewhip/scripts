#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for f in *
do
  echo "$f"
  if [ -d $f -a $(echo $f | grep -v '^CD0' | grep -v '^CD10') ];then
  	pushd $f
	rename 's/ /_/g' *
  	/usr/local/bin/ape2mp3.sh *ape
  	popd
  fi
done
IFS=$SAVEIFS
