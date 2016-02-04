#!/bin/bash

# consolidate_htseq_results.sh
#
# htseq-count creates one file per sample.  this script collects all sample results into a single file 
# where each column contains results from one sample
# a column header (sample-names) is added to the file
# author: Ian Donaldson - i.donaldson@qmul.ac.uk
#
# usage
# review the parameters below, then
# ./consolidate_htseq_results.sh
#
# set these parameters
INPUT_DIR="/project-directory/results_htseq"
SAMPLE_NAMES="/project-directory/mandate/sample_names"
OUTPUT_DIR="/project-directory/results_htseq_consolidated"

if [ ! -e ${OUTPUT_DIR} ]; then mkdir ${OUTPUT_DIR}; fi

#cycle through the list of output files, 
#for each, retrieve column of just the raw counts and write to a separate file
#note that htseq output files have no header and
#they each have five lines at the end that each begin with __
#so these lines will sort to the bottom of the file

#also construct a list of column names for the final file 

#start list of column names
echo "ID" > ${OUTPUT_DIR}/column_names

echo "consolidating htseq data for exons"

while read THIS_SAMPLE; do
    if [ -e ${INPUT_DIR}/${THIS_SAMPLE}/gene_read_counts_table.tsv ]; then
        sort -k 1,1 ${INPUT_DIR}/${THIS_SAMPLE}/gene_read_counts_table.tsv > tmp; 
        #store ID and raw counts in separate files
        cut -f 1 tmp > ${OUTPUT_DIR}/${THIS_SAMPLE}_ID;
        cut -f 2 tmp > ${OUTPUT_DIR}/${THIS_SAMPLE}_raw_counts;
        #store an ID column from the first sample
        if [ ! -e ${OUTPUT_DIR}/ID_COLUMN ]; then
            cut -f 1 tmp > ${OUTPUT_DIR}/ID_COLUMN;
        fi
        #add to the column names
        echo ${THIS_SAMPLE} >> ${OUTPUT_DIR}/column_names
    fi
done < ${SAMPLE_NAMES}


#####
#paste together the ID column with the raw count columns from each sample
#this will only work if all files have identical IDs in column 1 in the same order
#this assumption can be checked - see below 
####
#add column headers line with a return at the end of it to temp file 1
cat ${OUTPUT_DIR}/column_names | tr '\n' '\t' | head -c -1 > ${OUTPUT_DIR}/tmp1
echo -e -n "\n" >> ${OUTPUT_DIR}/tmp1
#add the data columns to temp file 2
paste  ${OUTPUT_DIR}/ID_COLUMN $(ls ${OUTPUT_DIR}/*_raw_counts) > ${OUTPUT_DIR}/tmp2
#combine the column headers with the data and store in temp file 3
cat ${OUTPUT_DIR}/tmp1 ${OUTPUT_DIR}/tmp2 > ${OUTPUT_DIR}/tmp3
#remove the last 5 lines (irrelevant)
head -n -5 ${OUTPUT_DIR}/tmp3 > ${OUTPUT_DIR}/consolidated_raw_counts_final
 
### check to see if all samples have the same gene ids in column 1 in the same order
md5sum ${OUTPUT_DIR}/*_ID  > ${OUTPUT_DIR}/md5sum_check
 
#cleanup
exit
