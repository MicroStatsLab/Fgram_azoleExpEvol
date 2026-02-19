#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=0-00:42:00
#SBATCH --mem=350G
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=CreateSequenceDictionary
#SBATCH --output=%x-%j.out

module load picard gatk

java -jar $EBROOTPICARD/picard.jar CreateSequenceDictionary R=Fusgra4_AssemblyScaffolds_Repeatmasked.fasta O=Fusgra4_AssemblyScaffolds_Repeatmasked.dict