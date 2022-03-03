#!/bin/bash

SAMPLE=$1
OUTDIR=$2

mv ${SAMPLE}.*.e* $OUTDIR/log
mv ${SAMPLE}.*.o* $OUTDIR/log

echo "Subject: WGS data processing is done for ${SAMPLE}" | sendmail -v yizhou.wang@cshs.org


