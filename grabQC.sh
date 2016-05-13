#/bin/bash

###
# grabQC.sh
# retrieve section of FastQC results file for multiple samples and concatenate into a single file
# this example collects all 'Per sequence GC' sections
# usage:
# cd <some directory containing contents of FastQC result files with .zip extensions> 
# ./grabQC.sh


for THIS_ZDIR in $(ls *fastqc.zip); do

    echo ${THIS_ZDIR}
    unzip -q ${THIS_ZDIR}
    THIS_DIR=${THIS_ZDIR%.zip}
    THIS_SAMPLE=${THIS_ZDIR%_fastqc.zip}
    echo ${THIS_SAMPLE} > ${THIS_SAMPLE}.GCtmp
    #grep -A 102 ">>Per sequence GC" ${THIS_DIR}/fastqc_data.txt | tail -n +3 | cut -f 2 >> ${THIS_SAMPLE}.GCtmp
    grep -A 102 ">>Per sequence GC" ${THIS_DIR}/fastqc_data.txt | cut -f 2 >> ${THIS_SAMPLE}.GCtmp
    rm -r ${THIS_DIR}

done

echo -e "Sample\nPASS/FAIL\nGC_content" > 000_ROWHEADER.GCtmp
seq 0 100 >> 000_ROWHEADER.GCtmp

paste *.GCtmp > ALL.GC
rm *.GCtmp
