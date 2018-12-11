#/bin/bash
# $Id$
# bash script converts all png files to gifs. Uses imagemagick's convert utility
IMAGES_TO_GRAYSCALE="yes.png no.png"
# first generate some grayscale pngs
echo "Converting images '${IMAGES_TO_GRAYSCALE}' to gray-scale"
for i in `echo "${IMAGES_TO_GRAYSCALE}"` ;
do
	GRAYSCALE_NAME="`basename $i .png`_gray.gif"
	echo "    $i to ${GRAYSCALE_NAME}"
	convert -colorspace Gray $i `basename $i .png`_gray.gif
done

echo "Converting pngs to gifs"
for i in $(ls *.png);
do
	echo "    $i"
	convert $i `basename $i .png`.gif
done
