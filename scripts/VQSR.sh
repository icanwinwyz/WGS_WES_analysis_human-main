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

SAMPLE=$1
OUTDIR=$2

###VQSR
time $GATK VariantRecalibrator \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.merged.raw.vcf.gz \
     --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $GATK_bundle/hg38_v0_hapmap_3.3.hg38.vcf \
     --resource:omini,known=false,training=true,truth=false,prior=12.0 $GATK_bundle/hg38_v0_1000G_omni2.5.hg38.vcf \
     --resource:1000G,known=false,training=true,truth=false,prior=10.0 $GATK_bundle/hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf \
     --resource:dbsnp,known=true,training=false,truth=false,prior=6.0 $GATK_bundle/Homo_sapiens_assembly38.dbsnp138.vcf \
     -an DP -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum \
     -mode SNP \
     -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 \
     --rscript-file $OUTDIR/gatk/${SAMPLE}.HC.snps.plots.R \
     --tranches-file $OUTDIR/gatk/${SAMPLE}.HC.snps.tranches \
     -O $OUTDIR/gatk/${SAMPLE}.HC.snps.recal && \
time $GATK ApplyVQSR \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.merged.raw.vcf.gz \
     --truth-sensitivity-filter-level 99.0 \
     --tranches-file $OUTDIR/gatk/${SAMPLE}.HC.snps.tranches \
     --recal-file $OUTDIR/gatk/${SAMPLE}.HC.snps.recal \
     --mode SNP \
     -O $OUTDIR/gatk/${SAMPLE}.HC.snps.VQSR.vcf.gz && echo "** SNPs VQSR done **"

time $GATK VariantRecalibrator \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.HC.snps.VQSR.vcf.gz \
     --resource:mills,known=true,training=true,truth=true,prior=12.0 $GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf \
     -an DP -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum \
     -mode INDEL \
     --max-gaussians 6 \
     --rscript-file $OUTDIR/gatk/${SAMPLE}.HC.snps.indels.plots.R \
     --tranches-file $OUTDIR/gatk/${SAMPLE}.HC.snps.indels.tranches \
     --output $OUTDIR/gatk/${SAMPLE}.HC.snps.indels.recal && \
time $GATK ApplyVQSR \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.HC.snps.VQSR.vcf.gz \
     --truth-sensitivity-filter-level 99.0 \
     --tranches-file $OUTDIR/gatk/${SAMPLE}.HC.snps.indels.tranches \
     --recal-file $OUTDIR/gatk/${SAMPLE}.HC.snps.indels.recal \
     --mode INDEL \
     -O $OUTDIR/gatk/${SAMPLE}.HC.VQSR.vcf.gz && echo "** SNPs and Indels VQSR (${SAMPLE}) finish done**"

####Extract SNPs
time $GATK SelectVariants \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.HC.VQSR.vcf.gz \
     -select-type SNP \
     -O $OUTDIR/gatk/${SAMPLE}.HC.VQSR.snp.vcf.gz

####Extract INDELs
time $GATK SelectVariants \
     -R $REF \
     -V $OUTDIR/gatk/${SAMPLE}.HC.VQSR.vcf.gz \
     -select-type INDEL \
     -O $OUTDIR/gatk/${SAMPLE}.HC.VQSR.indel.vcf.gz
