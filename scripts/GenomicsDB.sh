#!/usr/bin/bash
#$ -q all.q
#$ -cwd

module load java R/3.6.1 gatk bwa  picard/2.23.2 cromwell/37  samtools/1.6

# Variables and Paths
REF=/common/genomics-core/reference/WGS/Homo_sapiens_primary/Homo_sapiens_assembly38.primary.fasta
BWA=/hpc/apps/bwa/0.7.17/bin/bwa
GATK=/hpc/apps/gatk/4.1.8.0/bin/gatk
SAMTOOLS=/hpc/apps/samtools/1.6/bin/samtools
PICARD=/hpc/apps/picard/2.23.2/bin/picard.jar
GATK_bundle=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/
INTERVAL=$GATK_bundle/interval_list/input.txt
INTERVAL_PATH=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/interval_list/
i=$1
N=$2
SAMPLIST=$3

mkdir -p ./Joint/
mkdir -p ./Joint/tmp/

# Get all the samples from file listed in third command arg
Samps=$(sed -E 's/(.*)/-V .\/\1\/gatk\/\1.merged.raw.g.vcf.gz/' $SAMPLIST |tr "\n" " ")

time gatk  GenomicsDBImport \
   $Samps \
   --genomicsdb-workspace-path ./tmp/GDB_$i \
   -L $INTERVAL_PATH/$i

 time gatk GenotypeGVCFs \
    -R $REF \
    -V gendb://./tmp/GDB_$i \
    -O ./Joint/tmp/Joint_${N}.g.vcf \
    -L $INTERVAL_PATH/$i

