#!/bin/bash

module load java R/3.6.1 gatk bwa  picard/2.23.2 cromwell/37  samtools/1.6

REF=/common/genomics-core/reference/WGS/Homo_sapiens_primary/Homo_sapiens_assembly38.primary.fasta
BWA=/hpc/apps/bwa/0.7.17/bin/bwa
GATK=/hpc/apps/gatk/4.1.8.0/bin/gatk
SAMTOOLS=/hpc/apps/samtools/1.6/bin/samtools
PICARD=/hpc/apps/picard/2.23.2/bin/picard.jar
GATK_bundle=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/
INTERVAL=$GATK_bundle/interval_list/input.txt
SAMPLE=$1
OUTDIR=$2


MERGE_VCFS=""
for i in {1..50}; do
    MERGE_VCFS=${MERGE_VCFS}" -I $OUTDIR/temp/${SAMPLE}.${i}.temp.g.vcf.gz"
done && $GATK MergeVcfs ${MERGE_VCFS} -O $OUTDIR/gatk/${SAMPLE}.merged.raw.g.vcf.gz


    
