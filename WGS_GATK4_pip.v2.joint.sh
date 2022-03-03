#!/usr/bin/bash
#$ -q all.q
#$ -cwd

# run this script with a list of all samples as a command argument

module load java R/3.6.1 gatk bwa  picard/2.23.2 cromwell/37  samtools/1.6

# Variables and Paths
CMD_PATH=/common/genomics-core/apps/WGS_GATK4_pipeline/
REF=/common/genomics-core/reference/WGS/Homo_sapiens_primary/Homo_sapiens_assembly38.primary.fasta
BWA=/hpc/apps/bwa/0.7.17/bin/bwa
GATK=/hpc/apps/gatk/4.1.8.0/bin/gatk
SAMTOOLS=/hpc/apps/samtools/1.6/bin/samtools
PICARD=/hpc/apps/picard/2.23.2/bin/picard.jar
GATK_bundle=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/
INTERVAL=$GATK_bundle/interval_list/input.txt
INTERVAL_PATH=/common/genomics-core/apps/WGS_GATK4_pipeline/GATK_bundle/interval_list/
SAMPLIST=$1
SAMPLE=Joint

# Break the genome into intervals and operate on those separately
N=1
for i in `cat $INTERVAL`
do
    echo "$i $N"
    qsub -q all.q -N JointGenotype -pe smp 10 -cwd $CMD_PATH/GenomicsDB.sh $i $N $SAMPLIST
    let N+=1
done

# Merge the joint gVCFs across intervals
qsub -q highmem.q -N Joint.gVCF_merge -hold_jid JointGenotype -pe smp 10 -cwd $CMD_PATH/gVCF_Merge2.sh

# VQSR, annotation, and evaluation
qsub -q all.q -N ${SAMPLE}.VQSR -hold_jid $P{Sample}.gVCF_merge -pe smp 10 -cwd $CMD_PATH/VQSR_Joint.sh $SAMPLE ./Joint/gatk/
qsub -q all.q -N ${SAMPLE}.Annot -hold_jid ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/Anno_Joint.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Eval -hold_jid ${SAMPLE}.Annot -pe smp 10 -cwd $CMD_PATH/Eval.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Org -hold_jid ${SAMPLE}.Eval -cwd $CMD_PATH/Org.sh $SAMPLE $OUTDIR

