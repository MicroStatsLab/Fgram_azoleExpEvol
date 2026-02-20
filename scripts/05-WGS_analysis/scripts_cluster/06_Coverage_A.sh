module load samtools/1.20

BAMROOT=/home/aruni/scratch/Kelsey_FG/data_out/clean_alignment
OUTDIR=/home/aruni/scratch/Kelsey_FG/data_out/full_depth
mkdir -p "$OUTDIR"

# Make a sample list from the SRR folders
ls -d "$BAMROOT"/SRR* | xargs -n 1 basename > samples.txt

# Depth (no header)
cat samples.txt | parallel '
  samtools depth -a '"$BAMROOT"'/{0}/{0}.sorted_RG_dedup_Fixmate.bam \
    > '"$OUTDIR"'/{0}.depth
'

# Add header (final file)
cat samples.txt | parallel '
  echo -e "Chr\tlocus\t{0}" | cat - '"$OUTDIR"'/{0}.depth \
    > '"$OUTDIR"'/{0}.Hbam.txt


    