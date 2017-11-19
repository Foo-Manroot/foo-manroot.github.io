#!/bin/sh

if ! command -v ffmpeg > /dev/null
then
	printf "Error: ffmpeg not found\n"
	return
fi



if ! [ -f "$1" ]
then
	printf "Error: no such file: '%s'" "$1"
	return
fi

# From https://encrypted.pcode.nl/blog/2010/10/17/encoding-webm-using-ffmpeg/
ffmpeg -i "$1" -s 1280x720 -vpre libvpx-720p -b:v 3900k -pass 1 \
	-an -f webm -y output.webm

ffmpeg -i "$1" -s 1280x720 -vpre libvpx-720p -b:v 3900k -pass 2 \
	-acodec libvorbis -ab 100k -f webm -y output.webm
