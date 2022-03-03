#!/bin/bash

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
CMD_PATH=/common/genomics-core/apps/WGS_GATK4_pipeline/
FASTQC=/common/genomics-core/anaconda3/bin/fastqc

FQ1=$1
FQ2=$2
SAMPLE=$3
OUTDIR=$4

####Collect Alignment & Insert Size Metrics
time $FASTQC -o $OUTDIR/qc/ -t 10 $FQ1 $FQ2

time java -jar $PICARD CollectAlignmentSummaryMetrics R=$REF I=$OUTDIR/bwa/${SAMPLE}.sorted.bam O=$OUTDIR/qc/${SAMPLE}_alignment_metrics.txt

time java -jar $PICARD CollectInsertSizeMetrics INPUT=$OUTDIR/bwa/${SAMPLE}.sorted.bam OUTPUT=$OUTDIR/qc/${SAMPLE}_insert_metrics.txt HISTOGRAM_FILE=$OUTDIR/qc/${SAMPLE}_insert_size_histogram.pdf
