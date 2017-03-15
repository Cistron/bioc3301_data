#!/bin/bash -l
# Batch script to run a serial job on Legion with the upgraded
# software stack under SGE.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request wallclock time (format hours:minutes:seconds).
#$ -l h_rt=2:30:0

# 3. Request RAM (G = gigabyte)
#$ -l mem=24G

# 4. Request x gigabyte of TMPDIR space (default is 10 GB)
#$ -l tmpfs=40G

# 5. Set the name of the job.
#$ -N _2017_cr_nojoin_no_golay

# 6. Select threads (12 = max).
#$ -pe smp 6

# Joining stdout and stderr stream
#$ -j y

# 6. Set the working directory to somewhere in your scratch space.
#$ -wd /home/sejj036/Scratch/output

# 8. Automate transfer of output to Scratch from $TMPDIR. At the end of the job, files are transferred from $TMPDIR to a directory in scratch with the structure <job id>/<job id>.<task id>.<queue>/
#Local2Scratch

# 8. Run the application.

cd $TMPDIR

# copying sequence files to local
echo "copying sequence and map files"
cp $HOME/2017/Read1.fastq.gz $TMPDIR
cp $HOME/2017/Index.fastq.gz $TMPDIR
cp $HOME/2017/map.tsv $TMPDIR

chmod 777 *.fastq.gz

# loading virtualenv
echo "loading module and virtualenv"
module load gsl/1.16/gnu-4.9.2
module load ea-utils
source activate qiime1

# splitting libraries
echo "splitting libraries"
time split_libraries_fastq.py --barcode_type 12 -i $TMPDIR/Read1.fastq.gz -b $TMPDIR/Index.fastq.gz -o $TMPDIR/slout -m $TMPDIR/map.tsv

# removing source files
echo "removing source files"
rm $TMPDIR/*.fastq.gz

# counting sequences
echo "Counting sequences"
time count_seqs.py -i slout/seqs.fna

# picking OTUs
echo "Picking OTUs with open reference"
time pick_closed_reference_otus.py -i $TMPDIR/slout/seqs.fna -o $TMPDIR/otus -a -O 6 
