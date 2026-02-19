#!/bin/bash
#SBATCH --account=def-acgerste
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=58:00:00
#SBATCH --mem=600G
#SBATCH --mail-user=sumanara@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=vcf
#SBATCH --output=%x-%j.out


module load StdEnv/2020  gcc/9.3.0  openmpi/4.0.3
module load picard gatk

output="/home/aruni/scratch/Kelsey_FG/data_out/vcf"
ref="/home/aruni/scratch/Kelsey_FG/reference_Fgram"


#Combine all gvcf files

gatk CombineGVCFs -R $ref/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta --variant g.vcf.list  -O $output/FG_combined.g.vcf.gz

#Run genotype vcf to generate final vcf
gatk --java-options "-Xmx32g" GenotypeGVCFs --all-sites -R $ref/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta -V $output/FG_combined.g.vcf.gz -O $output/FG_joint_combined.vcf.gz

gatk SelectVariants \
    -V $output/FG_joint_combined.vcf.gz \
    --exclude-non-variants true \
    -select-type SNP \
    -O $output/FG_snps.vcf.gz \
    -R $ref/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta

gatk SelectVariants \
    -V $output/FG_joint_combined.vcf.gz \
    --exclude-non-variants true \
    -xl-select-type SNP \
    -O $output/FG_indel_mnp.vcf.gz \
    -R $ref/Fusgra4_AssemblyScaffolds_Repeatmasked.fasta


gatk VariantFiltration \
    -V $output/FG_snps.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O $output/FG_snps_filtered.vcf.gz


gatk VariantFiltration \
    -V $output/FG_indel_mnp.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $output/FG_indel_mnp_filtered.vcf.gz


java -jar $EBROOTPICARD/picard.jar MergeVcfs \
          I=$output/FG_snps_filtered.vcf.gz \
          I=$output/FG_indel_mnp_filtered.vcf.gz \
          O=$output/FG_merged_filtered_variants.vcf.gz
