########## Kelsey's variant analysis
########## Aruni
########## Created: 2026.01.30
########## Modified: 2026.02.10

## Load the libraries ########
library(tidyverse)
library(stringr)
library(tidyr)
library(dplyr)

## Getting the data file (raw vcf file converted to txt file using gatk VariantsToTable)
ref_1_ <- read.table("data_in/FG_merged_filtered_pass_correctRef.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)


## Renaming the SRR36459893.GT column as Anc (ancestor)
ref_1_Anc <- ref_1_ %>%
  rename(Anc = SRR36459893.GT)


## Removing the common variants across all coumns
commonAnc_removed <- ref_1_Anc %>%
  rowwise() %>%
  filter(n_distinct(c_across(6:28)) > 1) %>%
  ungroup()


## Turm missing variants (.) to 0s
step1 <- commonAnc_removed %>%
  mutate(across(6:27, ~ ifelse(. == ".", "0", .)))


## Replace variants common to Anc with 0
step2 <- step1 %>%
  mutate(across(6:27, ~ ifelse(. == Anc, 0, .)))


## Filter out rows with 0s across all columns
step2_cleaned <- step2 %>%
  filter(if_any(6:27, ~ . != 0))

write.csv(step2_cleaned, "data_out/step2_cleaned.csv")
  

missing_removed_ <- ref_1_Anc %>%
  filter(Anc != ".")



## Convert everything else (not 0) into 1
Binary_to_count <- step2_cleaned %>%
  mutate(across(6:27, ~ ifelse(. != 0, 1, 0)))

write.csv(Binary_to_count, "data_out/Binary_to_count.csv")


missing_removed <- step2_cleaned %>%
  filter(Anc != ".")



##############################################################################
## Getting the BED files

infile <- "data_out/Binary_to_count.csv"

outdir <- "data_out/BED_files"  # folder for BED outputs

dir.create(outdir, recursive = TRUE, showWarnings = FALSE) # make sure folder exists

dat <- readr::read_csv(infile, guess_max = 1e6)
dat <- dat[, -1]

dat <- dat %>%
  rename_with(~ sub("\\.GT$", "", .x), 6:27)


# Rename first two columns explicitly for clarity
dat <- dat %>%
  rename(CHROM = 1, POS = 2) %>%
  mutate(CHROM = as.character(CHROM),POS   = as.integer(POS))


# In the table, "samples" are in columns 6–27 (22 samples total)
sample_cols <- names(dat)[6:27]
stopifnot(length(sample_cols) == 22)  # sanity check


# Make sure all sample columns are strictly 0 or 1 integers
# - replace_na: turn missing values into 0
# - as.numeric/as.integer: enforce numeric type
dat <- dat %>%
  mutate(across(all_of(sample_cols),
                ~ as.integer(replace_na(as.numeric(.x), 0L))))


######### Write BED files ##############
# For each sample:
# 1. Keep only rows where sample == 1 (variant present)
# 2. Create three columns:
#    - CHROM: from col 1
#    - START: POS - 1 (0-based coordinate)
#    - END:   POS   (end coordinate; BED is half-open [START, END))
# 3. Write to a .bed file (no header, tab-separated)

walk(sample_cols, function(samp) {
  bed <- dat %>%
    filter(.data[[samp]] == 1L) %>%
    transmute(
      CHROM,
      START = pmax(POS - 1L, 0L),  # ensure start is non-negative
      END   = POS
    ) %>%
    arrange(CHROM, START, END)
  
  # Output filename will be the sample column name with "_bed.bed" suffix
  readr::write_tsv(
    bed,
    file.path(outdir, paste0(samp, "_bed.bed")),
    col_names = FALSE)})

############################################################################





  
  