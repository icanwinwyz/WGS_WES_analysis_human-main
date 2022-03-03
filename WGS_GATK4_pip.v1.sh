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

FQ1=$1
FQ2=$2
RGID=$3  ##Read Group, usually use Lane ID
LIB=$4 ##library ID
PU=$5
SAMPLE=$6 ## sample name
OUTDIR=$7 ## path to output

OUTDIR=${OUTDIR}/${SAMPLE}

if [ ! -d $OUTDIR/cleanfq ]
then mkdir -p $OUTDIR/cleanfq
fi

if [ ! -d $OUTDIR/bwa ]
then mkdir -p $OUTDIR/bwa
fi

if [ ! -d $OUTDIR/gatk ]
then mkdir -p $OUTDIR/gatk
fi

if [ ! -d $OUTDIR/qc ]
then mkdir -p $OUTDIR/qc
fi

if [ ! -d $OUTDIR/temp ]
then mkdir -p $OUTDIR/temp
fi


if [ ! -d $OUTDIR/log ]
then mkdir -p $OUTDIR/log
fi

key_align="$OUTDIR/bwa/${SAMPLE}.sorted.markdup.BQSR.bam"
key_qc="$OUTDIR/qc/${SAMPLE}_insert_metrics.txt"
key_call_var="$OUTDIR/gatk/${SAMPLE}.merged.raw.vcf.gz"
key_vqsr="$OUTDIR/gatk/${SAMPLE}.HC.VQSR.vcf.gz"

if [ ! -e $key_align ]; then

qsub -q all.q -N ${SAMPLE}.BWA_align -pe smp 10 -cwd $CMD_PATH/Align_Markdu_Recal.sh $FQ1 $FQ2 $RGID $LIB $PU $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.QC -pe smp 10 -hold_jid ${SAMPLE}.BWA_align -cwd $CMD_PATH/QC.sh $FQ1 $FQ2 $SAMPLE $OUTDIR
N=1
for i in `cat $INTERVAL` 
do
    echo "$i $N"
    TEMP_NAME=${SAMPLE}.$N.temp.vcf.gz
    qsub -q highmem.q -N ${SAMPLE}.call_variant -hold_jid ${SAMPLE}.BWA_align -pe smp 10 -cwd $CMD_PATH/Call_Variant.sh $SAMPLE $i $OUTDIR $TEMP_NAME
    let N+=1
done
qsub -q highmem.q -N ${SAMPLE}.VCF_merge -hold_jid ${SAMPLE}.call_variant -pe smp 10 -cwd $CMD_PATH/VCF_Merge.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.VQSR -hold_jid ${SAMPLE}.VCF_merge -pe smp 10 -cwd $CMD_PATH/VQSR.sh $SAMPLE $OUTDIR 
qsub -q all.q -N ${SAMPLE}.Annot -hold_jid ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/Anno.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Eval -hold_jid ${SAMPLE}.Annot -pe smp 10 -cwd $CMD_PATH/Eval.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Org -hold_jid ${SAMPLE}.Eval -cwd $CMD_PATH/Org.sh $SAMPLE $OUTDIR

elif [[ -e $key_align ]] && [[ ! -e $key_qc ]]; then

qsub -q all.q -N ${SAMPLE}.QC -pe smp 10 -cwd $CMD_PATH/QC.sh $FQ1 $FQ2 $SAMPLE $OUTDIR
N=1
for i in `cat $INTERVAL` 
do
    echo "$i $N"
    TEMP_NAME=${SAMPLE}.$N.temp.vcf.gz
    qsub -q highmem.q -N ${SAMPLE}.call_variant -pe smp 10 -cwd $CMD_PATH/Call_Variant.sh $SAMPLE $i $OUTDIR $TEMP_NAME
    let N+=1
done
qsub -q highmem.q -N ${SAMPLE}.VCF_merge -hold_jid ${SAMPLE}.call_variant -pe smp 10 -cwd $CMD_PATH/VCF_Merge.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.VQSR -hold_jid ${SAMPLE}.VCF_merge -pe smp 10 -cwd $CMD_PATH/VQSR.sh $SAMPLE $OUTDIR 
qsub -q all.q -N ${SAMPLE}.Annot -hold_jid ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/Anno.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Eval -hold_jid ${SAMPLE}.Annot -pe smp 10 -cwd $CMD_PATH/Eval.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Org -hold_jid ${SAMPLE}.Eval -cwd $CMD_PATH/Org.sh $SAMPLE $OUTDIR

elif [[ -e $key_align ]] && [[ -e $key_qc ]] && [[ ! -e $key_call_var ]]; then

N=1
for i in `cat $INTERVAL` 
do
    echo "$i $N"
    TEMP_NAME=${SAMPLE}.$N.temp.vcf.gz
    qsub -q highmem.q -N ${SAMPLE}.call_variant -pe smp 10 -cwd $CMD_PATH/Call_Variant.sh $SAMPLE $i $OUTDIR $TEMP_NAME
    let N+=1
done
qsub -q highmem.q -N ${SAMPLE}.VCF_merge -hold_jid ${SAMPLE}.call_variant -pe smp 10 -cwd $CMD_PATH/VCF_Merge.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.VQSR -hold_jid ${SAMPLE}.VCF_merge -pe smp 10 -cwd $CMD_PATH/VQSR.sh $SAMPLE $OUTDIR 
qsub -q all.q -N ${SAMPLE}.Annot -hold_jid ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/Anno.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Eval -hold_jid ${SAMPLE}.Annot -pe smp 10 -cwd $CMD_PATH/Eval.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Org -hold_jid ${SAMPLE}.Eval -cwd $CMD_PATH/Org.sh $SAMPLE $OUTDIR

elif [[ -e $key_align ]] && [[ -e $key_qc ]] && [[ -e $key_call_var ]] && [[ ! -e $key_vqsr ]]; then

qsub -q all.q -N ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/VQSR.sh $SAMPLE $OUTDIR 
qsub -q all.q -N ${SAMPLE}.Annot -hold_jid ${SAMPLE}.VQSR -pe smp 10 -cwd $CMD_PATH/Anno.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Eval -hold_jid ${SAMPLE}.Annot -pe smp 10 -cwd $CMD_PATH/Eval.sh $SAMPLE $OUTDIR
qsub -q all.q -N ${SAMPLE}.Org -hold_jid ${SAMPLE}.Eval -cwd $CMD_PATH/Org.sh $SAMPLE $OUTDIR
fi
