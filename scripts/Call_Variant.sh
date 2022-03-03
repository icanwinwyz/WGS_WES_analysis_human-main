#!/usr/bin/bash

module load java R/3.6.1 gatk bwa  picard/2.23.2 cromwell/37  samtools/1.6


###trimmomatic = path to trimmomatic.jar
###REF=/home/wangyiz/genomics/reference/BWA/chr19_test/chr19.fasta
REF=/common/genomics-core/reference/WGS/Homo_sapiens_primary/Homo_sapiens_assembly38.primary.fasta
BWA=/hpc/apps/bwa/0.7.17/bin/bwa
GATK=/hpc/apps/gatk/4.1.8.0/bin/gatk
SAMTOOLS=/hpc/apps/samtools/1.6/bin/samtools
PICARD=/hpc/apps/picard/2.23.2/bin/picard.jar
GATK_bundle=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/
INTERVAL=$GATK_bundle/interval_list/input.txt
INTERVAL_PATH=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/interval_list/
SAMPLE=$1
INTERVAL_LIST=$2
OUTDIR=$3
OUTPUT_FILE=$4


###Call Variants
time $GATK HaplotypeCaller \
     -R $REF \
     -I $OUTDIR/bwa/${SAMPLE}.sorted.markdup.BQSR.bam \
     -O $OUTDIR/temp/$OUTPUT_FILE \
     -L $INTERVAL_PATH/$INTERVAL_LIST \
     --native-pair-hmm-threads 10 \


