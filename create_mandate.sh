#!/bin/bash

# create_mandate.sh
#
# given a directory containing fastq.gz files
# 	that have names of the form
# 	Chip3-CS92-GC_S76_L001_R1_001.fastq.gz
# 	where elements of the name are separated by underscores
# 	Chip3-CS92-GC - is the sample name
# 	S76 - is the sample ID
# 	L001 - refers to lane 1
# 	R1   - refers to read 1
# this script will create a mandate list of the form
# 	job_name	read1_file	read2_file
# for example
#	Chip3-CS92-GC_S76	Chip3-CS92-GC_S76_L001_R1_001.fastq.gz	Chip3-CS92-GC_S76_L001_R1_002.fastq.gz
# for use by tophat
# the following files are made
# mandate - the full mandate
# mandate-01 - a subset of mandate contining no more than 100 lines
# fastqfiles - list of all fastq files
# read1      - list of read1 fastq files
# read2      - list of read2 fastq files
# job_names1 - list of all sample_names with lane ids
# sample_names - list of all sample names
# author: Ian Donaldson - i.donaldson@qmul.ac.uk

# usage: review the input parameters below then
# ./create_mandate.sh

# set these parameters
# provide a full path to the data directory containing the fastq.gz files and where the results should be placed
SAMPLES_DIR="/path-to-data-directory-with-fastq.gz-files/data"
OUTPUT_DIR="/path-to-mandate-directory/mandate"
# these need only be changed if the file names differ from the prescribed format above
R1_STRING="_R1_001.fastq.gz"
R2_STRING="_R2_001.fastq.gz"
LANE_STRING="_L00[1234]"

# no changes required past this point
if [ ! -e ${OUTPUT_DIR} ]; then mkdir ${OUTPUT_DIR}; fi
cd ${OUTPUT_DIR}

#separate read1 and read2 fastq files
ls -1 $SAMPLES_DIR | grep "fastq.gz" | sort > fastqfiles
grep "_R1_" fastqfiles > read1
grep "_R2_" fastqfiles > read2

#make job names by removing read info from fastq files
#they should be identical regardless of whether you use
#read1 or read2 fastq files
#this could form the basis of a check
sed "s/$R1_STRING//" read1 > job_names1
sed "s/"$R2_STRING"//" read2 > job_names2
#could check here and exit if job_names1 != job_names2

#create a mandate for tophat 
paste job_names1 read1 read2 > mandate

#split the mandate file into subfiles of 100 or less lines each
split -d -l 100 mandate mandate-

#make sample names -by stripping lane info from job_names1
#these will be used as directory names by merge
sed "s/$LANE_STRING//" job_names1 | sort | uniq > sample_names

##


#cleanup

exit
