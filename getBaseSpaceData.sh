#!/bin/sh

# getBaseSpaceData.sh
#
# purpose: retrieve fastq.gz data from BaseSpace using BaseMount
# a log file and manifest capture the full paths of the downloaded files and their md5sum/basenames respectively
# 
# author: Ian Donaldson - i.donaldson@qmul.ac.uk
#
# usage:
# set up a mount point using BaseMount - see https://basemount.basespace.illumina.com/
# this mount point is called BASEMOUNT_DIR in the SAMPLES_DIR path below
# SAMPLES_DIR points to a directory containing sub-directories (one per sample) that each contain multiple fastq.gz files
# the fastq.gz files may be directly in these sample directories or several levels down (see notes below)
# DEST_DIR describes a path to where you want to place the data and will be used by scp
# review the input parameters below
# use the testing section below to test these parameters in a test transfer before you run the whole scrip, then
# ./getBaseSpaceData.sh
# when the transfer has finished, check the log file and md5sums against the md5sums in the manifest file 
#
# set these parameters
BASEMOUNT_DIR=/home/ian/basespace_blgc
SAMPLES_DIR=${BASEMOUNT_DIR}/Projects/<project-name>/Samples
DEST_DIR="wgw000@login.hpc.qmul.ac.uk:~/projects/<project-name>/data"

#test parameters and connection using these commands like these example lines
#EXAMPLE_FILE="/basespace_blgc/Projects/project_name/Samples/Sample_name (2)/Files/Sample_name_S01_L001_R1_001.fastq.gz"
#scp -p "$EXAMPLE_FILE" "$DEST_DIR"/.
#exit;

# clear any previous manifest and log
if [ -e manifest ]; then
    rm manifest
fi
if [ -e log ]; then
    rm log
fi

echo -e "Fastq files are being retrieved from ${SAMPLES_DIR}" >> log
echo -e "Fastq files will be copied to ${DEST_DIR}" >> log

for THIS_FILE in `find -L ${SAMPLES_DIR} -name "*fastq*" | grep ".id."`; do
    # retrieve this file
    echo "${THIS_FILE}" >> log;
    scp -p ${THIS_FILE} ${DEST_DIR}/. ;
    #make a note of the md5sum
    echo "$(md5sum < ${THIS_FILE} | cut -d ' ' -f 1)  $(basename ${THIS_FILE})" >> manifest;
done

scp manifest $DEST_DIR/.
scp log $DEST_DIR/.


exit;

####
# notes
####


# directory names in illumina's basespace may include spaces
# since the files we want may be in such directories we could retrieve and use file paths
# using the find command as in the above solution
# the find command is used to retrieve paths to fastq files anywhere under the Samples directory
# -L allows the find command to follow symbolic links
# grep ".id." filters for paths that are symbolic links to Sample directories
# the Samples directory has two listings for every sample; the first one is a simple directory like
# Samples/BD\ 472
# note the space in the above directory name
# the second listing will be a symbolic link like 
# lrwxrwxrwx. 1 ian ian          6 Feb  9 10:17 .id.32243293 -> BD 472
# so the fastq files for this sample can be reached by two alternative paths:
# /BASEMOUNT_DIR/Projects/SOME_PROJECT_DIR/Samples/.id.32243293/Files/Data/Intensities/BaseCalls/BD-472_S707_L001_R1_001.fastq.gz
# or
# /BASEMOUNT_DIR/Projects/SOME_PROJECT_DIR/Samples/BD 472/Files/Data/Intensities/BaseCalls/BD-472_S707_L001_R2_001.fastq.gz
# yes, i know ^&&^%#$!!
# the above solution takes advantage of this double listing and avoids use of the path with the space in it
#
#
# alternatively, we could process directory names containing spaces using a for loop - as in the solution below
# this alternative solution was specifically tailored to a case where all of the  sought-after fastq files were in
# directories with names ending in (2)
#
# the default bash IFS (internal field separator) is a space
# the IFS is changed to a \n and then returned to the default after the script finishes

IFS_SAVED=$IFS
IFS=$'\n'

for THIS_DIR in `ls -1 $SAMPLES_DIR`; do
    TEST=1
    # if you only want to retrieve the directories with a name that ends in the string "(2)" 
    # then comment the above line and uncomment the next line
    #... see 'man expr' and http://tldp.org/LDP/abs/html/moreadv.html#EX45 for regex matching in bash
    #TEST=`expr "$THIS_DIR" : .*\(2\)`
    if [ "$TEST" -gt 0 ]; then
        for THIS_FILE in `ls -1 $SAMPLES_DIR/$THIS_DIR/Files`; do
            # retrieve this file - this solution is dependent on the fastq file being directly in $THIS_DIR - c.f. above
            echo "Retrieving file $SAMPLES_DIR/$THIS_DIR/Files/$THIS_FILE" >> log;
            scp -p $SAMPLES_DIR/$THIS_DIR/Files/$THIS_FILE $DEST_DIR/. ;
            #make a note of the md5sum
            echo "$(md5sum < ${THIS_FILE} | cut -d ' ' -f 1)  $(basename ${THIS_FILE})" >> manifest;
        done
    fi
done


# restore IFS
IFS=$IFS_SAVED
