#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --cpus-per-task=32
#SBATCH --time=0-36:02:00
#SBATCH --mem=500G
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=trim_alignment_readgroups_fixmate_FG
#SBATCH --output=%x-%j.out


##Load modules
module load nixpkgs/16.09
module load StdEnv/2020 bwa picard trimmomatic/0.39 gatk r

##Create directories for each sample
cat sample_list.txt | parallel 'mkdir /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}'
cat sample_list.txt | parallel 'mkdir /home/aruni/scratch/Kelsey_FG/data_out/alignment/{}'
cat sample_list.txt | parallel 'mkdir /home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}'

##Run Trimmomatic
cat sample_list.txt | parallel 'java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads $SLURM_CPUS_PER_TASK -trimlog /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}.log /home/aruni/scratch/Kelsey_FG/data_in/seq_NCBI/{}_1.fastq /home/aruni/scratch/Kelsey_FG/data_in/seq_NCBI/{}_2.fastq /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_1.trimmed_PE.fastq /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_1.trimmed_SE.fastq /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_2.trimmed_PE.fastq /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_2.trimmed_SE.fastq LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 TOPHRED33'

##Run Alignment (make sure reference only has the prifix, not the extension)
cat sample_list.txt | parallel 'time bwa mem -t $SLURM_CPUS_PER_TASK /home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_1.trimmed_PE.fastq /home/aruni/scratch/Kelsey_FG/data_out/trimmed_reads/{}/{}_2.trimmed_PE.fastq -o /home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sam'

##Sort the Alignment
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar SortSam I=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sam O=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sorted.sam SORT_ORDER=coordinate'

## Collect alignment statistics
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar CollectAlignmentSummaryMetrics R=/home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta I=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sorted.sam O=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.alignment_summary.txt'

##Convert SAM to BAM files
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar SamFormatConverter I=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sorted.sam O=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sorted.bam R=/home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta'

##Add read groups
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar AddOrReplaceReadGroups I=/home/aruni/scratch/Kelsey_FG/data_out/alignment/{}/{}.sorted.bam R=/home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta O=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG.bam RGID={} RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM={}'

#Mark potential reads duplicates
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar MarkDuplicates I=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG.bam O=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup.bam R=/home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta M=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup.txt CREATE_INDEX=true READ_NAME_REGEX=null'
#echo " Mark duplicates done!"

#Correct possible info differences in the aligned paired end reads. Readmore on this step
cat sample_list.txt | parallel 'time java -jar $EBROOTPICARD/picard.jar FixMateInformation I=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup.bam R=/home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta O=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup_Fixmate.bam ADD_MATE_CIGAR=true CREATE_INDEX=true'
#echo " Fixmate information done!"