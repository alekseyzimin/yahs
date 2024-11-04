#!/bin/bash
function usage {
echo 'This script converts bam file to pa5 file, removing PCR duplicates
IMPORTANT! The script assumes that alignment with bwa was run in paired mode with -SP, i.e.:
   bwa mem <idxbase> -SP file_R1.fastq file_R2.fastq
bam file does not need to be sorted.

Usage: bamToPa5.sh [options]

Options:
  -b string       BAM file
  -h              help/usage message'
}

BAMFILE="file.bam"
#parsing arguments
while [[ $# > 0 ]]
  do
  key="$1"

  case $key in
  -b|--bam)
    BAMFILE="$2"
    shift
    ;;
  -h|--help|-u|--usage)
    usage
    exit 255
    ;;
  *)
    echo "Unknown option $1"
    usage
    exit 1        # unknown option
    ;;
  esac
  shift
done

if [ -s $BAMFILE ];then
  BAM=`basename $BAMFILE`
  samtools view $BAMFILE|\
  grep -v 'SA:Z' | \
  awk '{if($3!="*"){if($1 == pread){print pread"\t"pctg"\t"pstart"\t"$3"\t"$4}else{pread=$1;pstart=$4;pctg=$3}}}' | \
  perl -ane '{unless(defined($h{join(" ",@F[1..$#F])})){print;$h{join(" ",@F[1..$#F])}=1}}' > $BAM.pa5 &&\
  echo "Success!  The PA5 file is $BAM.pa5"
else
  echo "BAM file $BAMFILE not found!"
fi
