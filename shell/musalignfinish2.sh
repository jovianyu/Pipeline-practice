#!/bin/bash
# 
# script to align short (50bp) single end whole genome reads
# custom project for mouse tumor sequencing project, no generalizable variables in current version
#
# Corrected last steps due to typo in prior edition of musalignfinish. Not intended for future use.
#
# set script to fail if any command, variable, or output fails
set -euo pipefail
#
# set IFS to split only on newline and tab
IFS=$'\n\t'
#
# load compilers
module load java-jdk/1.8.0_92
module load gcc/6.2.0
#
# load necessary modules
module load picard/2.8.1
module load samtools/1.6.0
#
# navigate to working directory
cd /scratch/mleukam/mouse
#
# filter out unmapped and multimapped reads
samtools view -F 4 -q 1 A20_temp.sam > A20_filteredtemp.sam
#
# samtools sort creates downstream errors with picard tools
# only recommend sorting using picard tools
java -Xmx16G -jar ${PICARD} SortSam \
      I=A20_filteredtemp.sam \
      O=A20.aligned.bam \
      SORT_ORDER=coordinate
#
# merge aligned bam with ubam to preserve read information
java -Xmx16G -jar ${PICARD} MergeBamAlignment \
ALIGNED_BAM=A20_aligned.bam \
UNMAPPED_BAM=A20_unaligned.bam \
OUTPUT=A20_merged.bam \
R=/scratch/mleukam/mouse/GRCm38p6_ref.fa \
CREATE_INDEX=true ADD_MATE_CIGAR=true \
CLIP_ADAPTERS=false CLIP_OVERLAPPING_READS=true \
INCLUDE_SECONDARY_ALIGNMENTS=true MAX_INSERTIONS_OR_DELETIONS=-1 \
PRIMARY_ALIGNMENT_STRATEGY=MostDistant ATTRIBUTES_TO_RETAIN=XS \
TMP_DIR=/scratch/mleukam/temp
#
# clean up and remove temporary files
rm A20_temp.fq
rm A20_temp.sai
rm A20_temp.sam
rm A20_aligned.bam
rm A20_filteredtemp