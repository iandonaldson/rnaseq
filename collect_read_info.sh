#!/bin/bash

# collect_read_info.sh
#
# purpose: for every tophat results directory , use
# samtools to retrieve number of mapped reads and number of unmapped
# reads and store these in a row of a file along with the directory
# name and the corresponding sample name
#
# author: Ian Donaldson - i.donaldson@qmul.ac.uk
#
# usage:
# review the parameters below, then
# ./collect_read_info.sh
#
# set these parameters
PROJECT_DIR=/data/home/wgw057/projects/Bailey
INPUT_DIR=${PROJECT_DIR}/results_tophat
OUTPUT_DIR=${PROJECT_DIR}/results_final

###
# no changes required beyond this point
###


#setup
if [ ! -e ${OUTPUT_DIR} ]; then mkdir -p ${OUTPUT_DIR}; fi

module load samtools/0.1.18

cd ${INPUT_DIR}

for THIS_DIR in $(ls -1); do
     if [ ! -d ${THIS_DIR} ]; then continue; fi
     SAMPLE_NAME=${THIS_DIR%%_*};
     MAPPED_READS=$(samtools view -c -F 256 ${THIS_DIR}/accepted_hits.bam);
     UNMAPPED_READS=$(samtools view -c -F 256 ${THIS_DIR}/unmapped.bam);
	echo -e "${THIS_DIR}\t${SAMPLE_NAME}\t${MAPPED_READS}\t${UNMAPPED_READS}";
done > ${OUTPUT_DIR}/read_info

exit;

notes:

the number of mapped reads is retrieved using the command
samtools view -c -F 256 accepted_hits.bam

-c count
-F filter any results with corresponding bit set in flag

sam format is explained here
http://samtools.github.io/hts-specs/SAMv1.pdf

to find the meaning of a flag use
https://broadinstitute.github.io/picard/explain-flags.html
FLAG of 256 means 'secondary alignment'

samtools command line params are here
http://www.htslib.org/doc/samtools.html

to inspect a sam/bam file visually, do
samtools view filename.bam | less -S

this script uses bash substring removal, see :
http://tldp.org/LDP/abs/html/string-manipulation.html
