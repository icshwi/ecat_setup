#!/bin/bash
#OUT_FILE=.$1.out
PATCH_OPTS="-d ../../ethercat-hg/ -p1 --backup-if-mismatch"

if [ "$2" == "dry" ]; then
	PATCH_OPTS="${PATCH_OPTS} --dry-run"
fi

#echo "Using patch options: $PATCH_OPTS" > $OUT_FILE
#echo "" >> $OUT_FILE
#patch ${PATCH_OPTS} < $1 &>> $OUT_FILE

patch ${PATCH_OPTS} < $1


