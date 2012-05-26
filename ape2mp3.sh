#!/bin/bash
# Fabio 20110824 Esta instalado en /usr/local/bin

LAME_PARS="-h"

echo "Script ape2mp3"
echo
echo

MAC=`which mac`
if [ -z $MAC ]; then
echo "ERROR :-("
echo "Monkey's Audio Codec is not installed."
echo "See http://sourceforge.net/projects/mac-port for more details."
exit -1
fi

for i in $*; do
case $i in
*.[aA][pP][eE])
echo "Processing file $i...";;
*)
echo "Warning: File $i don't have .ape extension. Ommiting..."
continue
esac

FILENAME="$(basename $i)"
FILENAME="${FILENAME%.[aA][pP][eE]}"

$MAC $i $FILENAME.wav -d
lame $LAME_PARS $FILENAME.wav $FILENAME.mp3
rm $FILENAME.wav
if [ -e $FILENAME.cue ]; then
mp3splt -f -c $FILENAME.cue -o @n+-+@t $FILENAME.mp3
rm $FILENAME.mp3
fi
done
