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



####GATK eval for SNP & INDEL
time $GATK VariantEval \
     --eval $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp.hg38_multianno.vcf \
     -R $REF \
     -O $OUTDIR/qc/${SAMPLE}.snps.eval \
     --dbsnp $GATK_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

time $GATK VariantEval \
     --eval $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel.hg38_multianno.vcf \
     -R $REF \
     -O $OUTDIR/qc/${SAMPLE}.indel.eval \
     --dbsnp $GATK_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

time /common/genomics-core/anaconda3/bin/multiqc -n ${SAMPLE}.multiqc_report --outdir $OUTDIR/qc/ $OUTDIR/qc/
