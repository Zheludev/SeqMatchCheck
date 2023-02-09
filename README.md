# SeqMatchCheck
a simple bash script based on bioawk that checks if two .fastx files have exactly matching sequences in the same positions - used to check if fastp made a duplication error

-----------------------------------------------------------------------------------

a bash script that uses bioawk to check if the first 'linecount/4' reads are perfect matches between R1 and R2 of two fastq files
which is a duplication error that certain versions of fastp sometimes makes?

script attempts to then leave prematurely if this is noticed, hopefully interrupting any bash loops you have going
it will also a save a list of the seqIDs it found matching for you to spot check

note, because bioawk is great, this code:
1. works on compressed and uncompressed .fastq files
2. also should work on .fasta files

example run:
```source SeqMatchCheck.sh rone=filt_1.fastq.gz rtwo=filt_2.fastq.gz linecount=40```

note, you need to enter the number of lines, not reads, you want to be checked (read from the top)

written by INZ - 02/09/23
Stanford Unversity
provided with no acceptance of liability or promise of functionality
version 0.1.0
