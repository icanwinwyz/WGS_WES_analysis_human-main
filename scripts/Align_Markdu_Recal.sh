#!/usr/bin/bash

module load java R/3.6.1 gatk bwa  picard/2.23.2 cromwell/37  samtools/1.6

REF=/common/genomics-core/reference/WGS/Homo_sapiens_primary/Homo_sapiens_assembly38.primary.fasta
BWA=/hpc/apps/bwa/0.7.17/bin/bwa
GATK=/hpc/apps/gatk/4.1.8.0/bin/gatk
SAMTOOLS=/hpc/apps/samtools/1.6/bin/samtools
PICARD=/hpc/apps/picard/2.23.2/bin/picard.jar
GATK_bundle=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/
INTERVAL=$GATK_bundle/interval_list/input.txt

FQ1=$1
FQ2=$2
RGID=$3  ##Read Group, usually use Lane ID
LIB=$4 ##library ID
PU=$5
SAMPLE=$6 ## sample name
OUTDIR=$7 ## path to output

#OUTDIR=${OUTDIR}/${SAMPLE}

####BWA for alignment
time $BWA mem -t 12 -M -R "@RG\tID:$RGID\tPL:ILLUMINA\tPU:$PU\tLB:$LIB\tSM:$SAMPLE" $REF \
    $FQ1 $FQ2| $SAMTOOLS view -@ 10 -bS - > $OUTDIR/bwa/${SAMPLE}.bam && echo "**BWA MEM done **" && \


####Samtools sort BAM
time $SAMTOOLS sort -@ 12 -O BAM -o $OUTDIR/bwa/${SAMPLE}.sorted.bam $OUTDIR/bwa/${SAMPLE}.bam && echo "** sorted raw bamfile done **"



####Mark duplicates
time $GATK MarkDuplicates \
     -I $OUTDIR/bwa/${SAMPLE}.sorted.bam \
     -M $OUTDIR/qc/${SAMPLE}.markdup_metrics.txt \
     -O $OUTDIR/bwa/${SAMPLE}.sorted.markdup.bam && echo "** ${SAMPLE}.sorted.bam MarDuplicates Done **"

####Recalibration
time $GATK BaseRecalibrator \
     -R $REF \
     -I $OUTDIR/bwa/${SAMPLE}.sorted.markdup.bam \
     --known-sites $GATK_bundle/Homo_sapiens_assembly38.known_indels.vcf \
     --known-sites $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf \
     --known-sites $GATK_bundle/Homo_sapiens_assembly38.dbsnp138.vcf \
     -O $OUTDIR/bwa/${SAMPLE}.sorted.markdup.recal_data.table && echo "** ${SAMPLE}.sorted.markdup.recal_data.table done **"

time $GATK ApplyBQSR \
     --bqsr-recal-file $OUTDIR/bwa/${SAMPLE}.sorted.markdup.recal_data.table \
     -R $REF \
     -I $OUTDIR/bwa/${SAMPLE}.sorted.markdup.bam \
     -O $OUTDIR/bwa/${SAMPLE}.sorted.markdup.BQSR.bam && echo "** ApplyBQSR done **"

####Index BAM file
time $SAMTOOLS index $OUTDIR/bwa/${SAMPLE}.sorted.markdup.BQSR.bam


