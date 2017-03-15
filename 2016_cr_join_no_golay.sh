#!/bin/bash -l
# Batch script to run a serial job on Legion with the upgraded
# software stack under SGE.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request wallclock time (format hours:minutes:seconds).
#$ -l h_rt=6:00:0

# 3. Request RAM (G = gigabyte)
#$ -l mem=48G

# 4. Request x gigabyte of TMPDIR space (default is 10 GB)
#$ -l tmpfs=60G

# 5. Set the name of the job.
#$ -N _2016_closed_ref

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
cp $HOME/2016/bioc3101_2016_read1.fastq.gz $TMPDIR
cp $HOME/2016/bioc3101_2016_read2.fastq.gz $TMPDIR
cp $HOME/2016/bioc3101_2016_barcodes.fastq.gz $TMPDIR
cp $HOME/2016/map.tsv $TMPDIR

# un-gzipping
echo "g-unzipping and fixing file headers"
gunzip bioc3101_2016_read1.fastq.gz
# adjusting header for read2
gunzip bioc3101_2016_read2.fastq.gz
sed 's/ 3:N:0:0/2:N:0:0/g' bioc3101_2016_read2.fastq > bioc3101_2016_read2.fixed.fastq
rm bioc3101_2016_read2.fastq
# adjusting header for barcodes
gunzip bioc3101_2016_barcodes.fastq.gz
sed 's/2:N:0:0/1:N:0:0/g' bioc3101_2016_barcodes.fastq > bioc3101_2016_barcodes.fixed.fastq
rm bioc3101_2016_barcodes.fastq
chmod 777 bioc3101*

# loading virtualenv
echo "loading module and virtualenv"
module load gsl/1.16/gnu-4.9.2
module load ea-utils
source activate qiime1

echo "joining paired end reads"
time join_paired_ends.py -f $TMPDIR/bioc3101_2016_read1.fastq -r $TMPDIR/bioc3101_2016_read2.fixed.fastq -b $TMPDIR/bioc3101_2016_barcodes.fixed.fastq -o $TMPDIR/fastq-join_joined

# removing source files
echo "removing source files"
rm $TMPDIR/bioc3101_2016_read1.fastq
rm $TMPDIR/bioc3101_2016_read2.fixed.fastq
rm $TMPDIR/bioc3101_2016_barcodes.fixed.fastq

# validating mapping file
echo "validating mapping file"
time validate_mapping_file.py -m $TMPDIR/map.tsv -o $TMPDIR/map

# splitting libraries
echo "splitting libraries"
time split_libraries_fastq.py -i $TMPDIR/fastq-join_joined/fastqjoin.join.fastq -b $TMPDIR/fastq-join_joined/fastqjoin.join_barcodes.fastq -o $TMPDIR/slout -m $TMPDIR/map.tsv --barcode_type 12

# counting sequences
echo "Counting sequences"
time count_seqs.py -i slout/seqs.fna

# picking OTUs
echo "Picking OTUs with open reference"
time pick_closed_reference_otus.py -i $TMPDIR/slout/seqs.fna -o $TMPDIR/otus -a -O 6
