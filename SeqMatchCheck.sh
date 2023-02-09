## a bash script that uses bioawk to check if the first 'linecount/4' reads are perfect matches between R1 and R2 of two fastq files
	## which is an error that certain versions of fastp sometimes makes?

## script attempts to then leave prematurely if this is noticed, hopefully interrupting any bash loops you have going
	## it will also a save a list of the seqIDs it found matching for you to spot check

## note, because bioawk is great, this code:
	## 1. works on compressed and uncompressed .fastq files
	## 2. also should work on .fasta files

## example run:
	## source SeqMatchCheck.sh rone=filt_1.fastq.gz rtwo=filt_2.fastq.gz linecount=40

## note, you need to enter the number of lines, not reads, you want to be checked (read from the top)

## written by INZ - 02/09/23
## Stanford Unversity
## provided with no acceptance of liability or promise of functionality
## version 0.1.0

## ===============================================================================================================================================

#!/bin/sh

## check if bioawk exists (from https://stackoverflow.com/a/677212)

if ! command -v bioawk &> /dev/null
then
	echo "bioawk could not be found"
	echo "consider installing with - conda install -c bioconda bioawk"
	echo "exiting"
	return 1 2>/dev/null
fi

## dynamic argument assignment (from https://unix.stackexchange.com/a/353639):

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

## report arguments
echo "-----=====-----"
echo "R1 = $rone"
echo "R2 = $rtwo"
echo "linecount = $linecount"
readcount=$(echo 'scale=0;'"$linecount"'/4' | bc)
echo "readcount = $readcount"

## look for seq-seq matches between R1 and R2
echo "running seq-seq comparison"
echo "writing temp match seqID file"

bioawk -c fastx 'NR == FNR {seqdict[FNR]=$seq; next} seqdict[FNR] == $seq {print "sequence match at @"$name}' <(head -"$linecount" "$rone") <(head -"$linecount" "$rtwo") > temp_matched.seqIDs

## checking if matches found
if [ -s temp_matched.seqIDs ]; then
	## The file is not-empty
	echo "seq-seq matches found - fastp might be bugging"
	echo "writing output match seqID file to matched.seqIDs"
	mv temp_matched.seqIDs matched.seqIDs
	echo "will now unceremoniously terminate this bash script - hold on tight"
	echo "consider updating fastp with - conda update fastp"
	return 1 2>/dev/null
else
	# The file is empty
	echo "no seq-seq matches found"
	echo "removing (empty) temp match seqID file"
	rm temp_matched.seqIDs
fi
