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
ANNO_PATH=/common/genomics-core/apps/annovar_20191024/annovar/
SCRIPT_PATH=/common/genomics-core/apps/WGS_advance_anno/


SAMPLE=$1
OUTDIR=$2


####Annotate SNPs
time $ANNO_PATH/table_annovar.pl \
     $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp.vcf.gz \
     $ANNO_PATH/humandb \
     -buildver hg38 \
     --outfile $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp \
     -remove \
     -protocol refGene,1000g2015aug_all,avsnp150,gnomad30_genome,cosmic91_noncoding,cosmic91_coding,clinvar_20200316 \
     -operation g,f,f,f,f,f,f \
     --vcfinput \
     --thread 10 \
     -nastring .
     -polish

Rscript $SCRIPT_PATH/WGS_advance_anno.human.format.R $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp.vcf.gz ${SAMPLE}.HC.VQSR.snp $OUTDIR/gatk


####Annotate INDELs
time $ANNO_PATH/table_annovar.pl \
     $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel.vcf.gz \
     $ANNO_PATH/humandb \
     -buildver hg38 \
     --outfile $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel \
     -remove \
     -protocol refGene,1000g2015aug_all,avsnp150,gnomad30_genome,cosmic91_noncoding,cosmic91_coding,clinvar_20200316 \
     -operation g,f,f,f,f,f,f \
     --vcfinput \
     --thread 10 \
     -nastring .
     -polish

Rscript $SCRIPT_PATH/WGS_advance_anno.human.format.R $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel.vcf.gz ${SAMPLE}.HC.VQSR.indel $OUTDIR/gatk

time $GATK IndexFeatureFile -I $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp.hg38_multianno.vcf

time $GATK IndexFeatureFile -I $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel.hg38_multianno.vcf

