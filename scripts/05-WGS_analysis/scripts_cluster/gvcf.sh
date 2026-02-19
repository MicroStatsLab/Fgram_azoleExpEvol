#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=58:00:00
#SBATCH --mem=600G
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=gvcf
#SBATCH --output=%x-%j.out

##Load modules
module load nixpkgs/16.09
module load StdEnv/2020 bwa picard trimmomatic/0.39 gatk r

##Create directories for each sample
cat sample_list.txt | parallel 'mkdir -p /home/aruni/scratch/Kelsey_FG/data_out/gvcf/{}'


#Run Haplotypecaller in g.vcf mode
cat sample_list.txt | parallel 'gatk --java-options "-Xmx32g" HaplotypeCaller --native-pair-hmm-threads $SLURM_CPUS_PER_TASK -R /home/aruni/scratch/Kelsey_FG/reference_Fgram/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta -ploidy 1 -I /home/aruni/scratch/Kelsey_FG/data_out/clean_alignment/{}/{}.sorted_RG_dedup_Fixmate.bam -O /home/aruni/scratch/Kelsey_FG/data_out/gvcf/{}/{}.raw.snps.indels.g.vcf.gz -ERC GVCF'

echo " HaplotypeCaller done!"