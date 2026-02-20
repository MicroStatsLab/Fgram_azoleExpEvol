#!/bin/bash
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=full_depth


cd /home/aruni/scratch/Kelsey_FG/data_out/full_depth/

paste *.Hbam.txt | \
cut -f 1,2,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69 \
> Full_coverage.txt