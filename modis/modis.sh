#!/bin/bash
# http://rapidfire.sci.gsfc.nasa.gov/subsets/?subset=Spain.2010130.terra.250m.jpg&vectors=fires+coast+borders
HOST="http://rapidfire.sci.gsfc.nasa.gov/subsets/?subset="
CAPA="Spain"
FECHA=$(date +%Y%j)
#FECHA=$(date -d 'yesterday' +%Y%j)
SAT="aqua"
RES="250m"
VECTORS="&vectors=fires+coast+borders"
URL="${HOST}${CAPA}.${FECHA}.${SAT}.${RES}.jpg${VECTORS}"
LOCAL="/tmp/modis.$SAT.$FECHA.jpg"
DEST="/tmp/modis-listo.jpg"
echo "Haciendo curl -s $URL > $LOCAL"
curl -s "$URL" > $LOCAL
TAM=$(du $LOCAL| cut -f1)
if [ $TAM -lt 3000 ];then
	SAT="terra"
	URL="${HOST}${CAPA}.${FECHA}.${SAT}.${RES}.jpg${VECTORS}"
	LOCAL="/tmp/modis.$SAT.$FECHA.jpg"
	echo "Haciendo curl -s $URL > $LOCAL"
	curl -s "$URL" > $LOCAL
	TAM=$(du $LOCAL| cut -f1)
	if [ $TAM -lt 3000 ];then
		SAT="aqua"
		FECHA=$(date -d 'yesterday' +%Y%j)
		URL="${HOST}${CAPA}.${FECHA}.${SAT}.${RES}.jpg${VECTORS}"
		LOCAL="/tmp/modis.$SAT.$FECHA.jpg"
		echo "Haciendo curl -s $URL > $LOCAL"
		curl -s "$URL" > $LOCAL
	fi

fi

# Resize
convert $LOCAL -resize '1366' -crop '1366x768+0+50' -sharpen 1 $DEST

# Set the Gnome background:
gconftool-2 -t str --set /desktop/gnome/background/picture_filename $DEST

# Clean images older than 1 day. Yeah, it's ugly.
#find /tmp/ -name 'modis.*.jpg' -mtime +1 | xargs rm -f

