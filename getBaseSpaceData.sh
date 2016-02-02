#!/bin/sh

# getBaseSpaceData.sh
#
# retrieve fastq.gz data from BaseSpace using BaseMount
# 
# the default IFS (internal field separator) is a space
# in the case below, illumina basespace uses spaces in directory names
# since the files we want are in such directories and we need to process such directory names in a for loop, 
# the IFS is changed to a \n and then returned to the default after the script finishes
# author: Ian Donaldson - i.donaldson@qmul.ac.uk

# usage:
# set up a mount point using BaseMount - see https://basemount.basespace.illumina.com/
# this mount point is called 'basespace_blgc' in the SAMPLES_DIR path below
# SAMPLES_DIR points to a directory containing sub-directories (one per sample) that each contain multiple fastq.gz files
# DEST_DIR describes a path to where you want to place the data and will be used by scp
# review the input parameters below
# use the testing section below to test these parameters in a test transfer before you run the whole scrip, then
# ./getBaseSpaceData.sh
# when the transfer has finished, check the log file and md5sums against the md5sums in the manifest file 

# set these parameters
SAMPLES_DIR="/basespace_blgc/Projects/project_name/Samples"
DEST_DIR="user_name@login.hpc.qmul.ac.uk:~/scratch/data"


#test parameters and connection using these commands like these example lines
#EXAMPLE_FILE="/basespace_blgc/Projects/project_name/Samples/Sample_name (2)/Files/Sample_name_S01_L001_R1_001.fastq.gz"
#scp -p "$EXAMPLE_FILE" "$DEST_DIR"/.
#exit


echo $SAMPLES_DIR
echo $DEST_DIR
# clear any previous manifest and log
if [ -e manifest ]; then
    rm manifest
fi
if [ -e log ]; then
    rm log
fi


IFS_SAVED=$IFS
IFS=$'\n'


for THIS_DIR in `ls -1 $SAMPLES_DIR`; do
    TEST=1
    # if you only want to retrieve the directories witj a name that ends in the string "(2)" 
    # then comment the above line and uncomment the next line
    #... see 'man expr' and http://tldp.org/LDP/abs/html/moreadv.html#EX45 for regex matching in bash
    #TEST=`expr "$THIS_DIR" : .*\(2\)`
    if [ "$TEST" -gt 0 ]; then
        for THIS_FILE in `ls -1 $SAMPLES_DIR/$THIS_DIR/Files`; do
            # retrieve this file
            echo "Retrieving file $SAMPLES_DIR/$THIS_DIR/Files/$THIS_FILE" >> log;
            scp -p $SAMPLES_DIR/$THIS_DIR/Files/$THIS_FILE $DEST_DIR/. ;
            #make a note of the md5sum
            MD5=`md5sum $SAMPLES_DIR/$THIS_DIR/Files/$THIS_FILE | cut -d ' ' -f1` ;#only want the digest
            echo -e $MD5 "\t$THIS_FILE" >> manifest ;#add the corresponding digest and file name to the manifest
        done
    fi
done


# restore IFS
IFS=$IFS_SAVED

scp manifest $DEST_DIR/.
scp log $DEST_DIR/.


