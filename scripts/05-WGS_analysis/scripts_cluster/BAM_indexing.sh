#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --cpus-per-task=1
#SBATCH --time=0-00:30:00
#SBATCH --mem=4G
#SBATCH --job-name=BAM_Indexing
#SBATCH --output=%x-%j.out
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL

module load samtools

# Index all final BAM files in clean_alignment directory
cat sample_list.txt | parallel 'samtools index /home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup_Fixmate.bam'