# WGS/WES_analysis_human
This is the analysis pipeline for **human** WGS/WES data.

# Workflow
![flow chart of WGS/WES pipeline](https://github.com/cedars-sinai-genomics-core/WGS_WES_analysis_human/blob/main/image/WGS_WES_human_workflow.png)
 For more details, please check out the three .pptx files

# USAGE 

This script is run from the HPC (not Titan), otherwise the paths for reference files will not be correct.

## Joint 

GATK best practices suggest joint variant calling and genotyping when dealing with a cohort of many samples. If you are running this pipeline jointly, currently it will need to be run in two phases. The first phase is the variant calling for each individual sample in the cohort. For every sample, you will need to run `WGS_GATK4_pip.v2.sh`. Once this is complete, the second phase is joint genotyping of the entire cohort. For joint genotyping, `WGS_GATK4_pip.v2.joint.sh` will be run once on all samples simultaneously.

### Example

For each sample you must run:

```
nohup ~/genomics/apps/WGS_GATK4_pipeline/WGS_GATK4_pip.v2.sh \
  /FASTQ/Read1.fastq.gz \
  /FASTQ/Read2.fastq.gz \
  Read_Group_ID \
  Library_ID \
  Platform_Unit \
  Sample_Name \
  Path/To/Output/ \
  Joint
 ```
This can be streamlined by either creating a submission script with this command for every sample or by placing this information in a separate file and reading it in with a loop. We are working on implementing the latter option into the standard pipeline currently.

Processing of a single sample takes about a day. Multiple samples often run simultaneously, but this will depend on the load for the HPC queue. Once this stage has finished **for all samples**, you will need to run the joint genotyping on the entire cohort:

```
nohup ~/genomics/apps/WGS_GATK4_pipeline/WGS_GATK4_pip.v2.joint.sh ListOfSampleNames.txt
```

The list of sample names is a simple text file with one sample per line and in the same format as the sample names were passed into the individual script above. The majority of the time in this stage is building a GenomicDB from the entire cohort's variants. Once this is complete, the joint genotyping will take place using this data store.

## Individual

In some circumstances, joint variant calling may not be advisable/necessary. The pipeline is also equiped to perform the variant calling with leveraging the information of the entire cohort of samples. In this case, the pipeline will only need to be run once for every sample. It is similar to phase one in the joint variant calling except with the final `Joint` argument omitted.

### Example
```
nohup ~/genomics/apps/WGS_GATK4_pipeline/WGS_GATK4_pip.v2.sh \
  /FASTQ/Read1.fastq.gz \
  /FASTQ/Read2.fastq.gz \
  Read_Group_ID \
  Library_ID \
  Platform_Unit \
  Sample_Name \
  Path/To/Output/ 
```

Any trailing argument after the output path will trigger joint variant calling, so do not leave any text after the path. The difference will be apparent in the output files; joint calling produces `*.g.vcf` instead of `*.vcf`.
