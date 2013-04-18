#!/bin/sh
DIR="/www/wbm"
METAFILE="/www/wbm/META"

[ ! -d $DIR ] && make -p $DIR

rm -f $METAFILE 2>/dev/null

cd $DIR 

for f in *.bin; do
	echo "$(md5sum $f) $(cat /etc/wbm.version)" >> $METAFILE
done

cat $METAFILE
