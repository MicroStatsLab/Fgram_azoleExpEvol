library(readxl)
library(ggplot2)
library(dplyr)
library(here)

# --- Step 1: Read the data ---
# Ensure your 'Phenotypes.xlsx' file is in the correct working directory
Spore <- read_excel(here("data_in", "04-spore_production", "Phenotypes.xlsx"), sheet = "Spore")

# --- Step 2: Summarize the data to calculate mean and standard deviation ---
# This is the key change: we now calculate the standard deviation (sd)
summary_spore_data <- Spore %>%
  group_by(sample) %>%
  summarize(
    average_spore_count = mean(spore_count, na.rm = TRUE),
    sd_spore_count = sd(spore_count, na.rm = TRUE), 
    n = n(),
    se_spore_count = sd_spore_count / sqrt(n),
    # Calculate standard deviation
    .groups = "drop" # Ungroup after summarization
  )

# --- Step 3: Define the desired order for the 'sample' factor on the x-axis ---
desired_sample_order <- c("ANC", "DMS1", "DMS2", "DMS3", "DMS4", 
                          "PTZ1", "PTZ2", "PTZ3", "PTZ4",
                          "TBF1", "TBF2", "TBF3", "TBF4",
                          "CMB1", "CMB2", "CMB3", "CMB4")

# Filter and reorder the summary data
summary_spore_data <- summary_spore_data[summary_spore_data$sample %in% desired_sample_order, ]
summary_spore_data$sample <- factor(summary_spore_data$sample,
                                    levels = desired_sample_order)

# --- Step 4: Define colors based on sample groups (PTZ, TBF, CMB, etc.) ---
summary_spore_data <- summary_spore_data %>%
  mutate(group = case_when(
    grepl("^ANC", sample) ~ "ANC_group",
    grepl("^DMS", sample) ~ "DMS_group",
    grepl("^PTZ", sample) ~ "PTZ_group",
    grepl("^TBF", sample) ~ "TBF_group",
    grepl("^CMB", sample) ~ "CMB_group",
    TRUE ~ "Other_group"
  ))

# Define the color mapping for these groups
group_colors <- c("ANC_group" = "#7F7F7F",
                  "DMS_group" = "#EF8636",
                  "PTZ_group" = "#3B75AF", 
                  "TBF_group" = "#C53A32",
                  "CMB_group" = "#8D69B8")

# --- Step 5: Create the bar plot with standard deviation error bars ---
# This is the other key change: the ymin and ymax for the error bars are now
# calculated using the average and the standard deviation.
ggplot(summary_spore_data, aes(x = sample, y = average_spore_count, fill = group)) +
  geom_bar(stat = "identity", color = "black") + 
  geom_errorbar(aes(ymin = average_spore_count - sd_spore_count,
                    ymax = average_spore_count + sd_spore_count),
                width = 0.2, 
                color = "black") + 
  scale_fill_manual(values = group_colors) +
  labs(
    title = "Average Spore Count by Sample with Standard Deviation",
    x = "Sample",
    y = "Spore Count"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"), 
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 10), 
    axis.title = element_text(size = 12, face = "bold"), 
    legend.position = "none", 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.background = element_rect(fill = "white", colour = "white") 
  )

# --- Step 6: Create the log-scale bar plot with standard deviation error bars ---
# The same changes for the error bars are applied here as well.
summary_spore_data$average_spore_count_log10 <- log10(summary_spore_data$average_spore_count)
summary_spore_data$se_spore_count_log10 <- log10(summary_spore_data$se_spore_count)

ggplot(summary_spore_data, aes(x = sample, y = average_spore_count, fill = group)) +
  geom_bar(stat = "identity", color = "black") + 
  geom_errorbar(aes(ymin = average_spore_count - se_spore_count,
                    ymax = average_spore_count + se_spore_count),
                width = 0.2, 
                color = "black") + 
  scale_fill_manual(values = group_colors) +
  labs(
    title = "",
    x = "Lineage",
    y = "Macroconidia count (/mL)"
  ) +
  theme_minimal() +
#  scale_y_continuous(trans = "log10", labels = c("10", "1 000", "100 000"), breaks = c(10, 1000, 100000)) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"), 
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 10), 
    axis.title = element_text(size = 12, face = "bold"), 
    legend.position = "none", 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.background = element_rect(fill = "white", colour = "white") 
  )

ggsave(here("figures", "251113Macroconidia.pdf"), width = 6, height= 3.5, units =  "in", device = "pdf")


print("--- ANOVA Results ---")
anova_result <- aov(spore_count ~ sample, data = Spore)
summary(anova_result)

# Df    Sum Sq   Mean Sq F value  Pr(>F)   
# sample      16 1.084e+11 6.777e+09   2.746 0.00655 **
#   Residuals   34 8.392e+10 2.468e+09  

TukeyHSD(anova_result)
# diff        lwr        upr      p adj
# CMB1-ANC   -23000.0000 -174301.60 128301.597 0.99999989
# CMB2-ANC   -26666.6667 -177968.26 124634.931 0.99999910
# CMB3-ANC    -2666.6667 -153968.26 148634.931 1.00000000
# CMB4-ANC   -22333.3333 -173634.93 128968.264 0.99999993
# DMS1-ANC    60000.0000  -91301.60 211301.597 0.98277755
# DMS2-ANC   110000.0000  -41301.60 261301.597 0.38720383
# DMS3-ANC    26333.3333 -124968.26 177634.931 0.99999925
# DMS4-ANC    96666.6667  -54634.93 247968.264 0.59815534
# PTZ1-ANC   -19666.6667 -170968.26 131634.931 0.99999999
# PTZ2-ANC    18333.3333 -132968.26 169634.931 1.00000000
# PTZ3-ANC   -21666.6667 -172968.26 129634.931 0.99999996
# PTZ4-ANC   -19333.3333 -170634.93 131968.264 0.99999999
# TBF1-ANC   -82866.6667 -234168.26  68434.931 0.80835593
# TBF2-ANC     3666.6667 -147634.93 154968.264 1.00000000
# TBF3-ANC   -17666.6667 -168968.26 133634.931 1.00000000
# TBF4-ANC   -12666.6667 -163968.26 138634.931 1.00000000
# CMB2-CMB1   -3666.6667 -154968.26 147634.931 1.00000000
# CMB3-CMB1   20333.3333 -130968.26 171634.931 0.99999998
# CMB4-CMB1     666.6667 -150634.93 151968.264 1.00000000
# DMS1-CMB1   83000.0000  -68301.60 234301.597 0.80660133
# DMS2-CMB1  133000.0000  -18301.60 284301.597 0.13786104
# DMS3-CMB1   49333.3333 -101968.26 200634.931 0.99759496
# DMS4-CMB1  119666.6667  -31634.93 270968.264 0.26084588
# PTZ1-CMB1    3333.3333 -147968.26 154634.931 1.00000000
# PTZ2-CMB1   41333.3333 -109968.26 192634.931 0.99968912
# PTZ3-CMB1    1333.3333 -149968.26 152634.931 1.00000000
# PTZ4-CMB1    3666.6667 -147634.93 154968.264 1.00000000
# TBF1-CMB1  -59866.6667 -211168.26  91434.931 0.98312525
# TBF2-CMB1   26666.6667 -124634.93 177968.264 0.99999910
# TBF3-CMB1    5333.3333 -145968.26 156634.931 1.00000000
# TBF4-CMB1   10333.3333 -140968.26 161634.931 1.00000000
# CMB3-CMB2   24000.0000 -127301.60 175301.597 0.99999980
# CMB4-CMB2    4333.3333 -146968.26 155634.931 1.00000000
# DMS1-CMB2   86666.6667  -64634.93 237968.264 0.75560436
# DMS2-CMB2  136666.6667  -14634.93 287968.264 0.11381961
# DMS3-CMB2   53000.0000  -98301.60 204301.597 0.99485572
# DMS4-CMB2  123333.3333  -27968.26 274634.931 0.22108441
# PTZ1-CMB2    7000.0000 -144301.60 158301.597 1.00000000
# PTZ2-CMB2   45000.0000 -106301.60 196301.597 0.99914562
# PTZ3-CMB2    5000.0000 -146301.60 156301.597 1.00000000
# PTZ4-CMB2    7333.3333 -143968.26 158634.931 1.00000000
# TBF1-CMB2  -56200.0000 -207501.60  95101.597 0.99073164
# TBF2-CMB2   30333.3333 -120968.26 181634.931 0.99999450
# TBF3-CMB2    9000.0000 -142301.60 160301.597 1.00000000
# TBF4-CMB2   14000.0000 -137301.60 165301.597 1.00000000
# CMB4-CMB3  -19666.6667 -170968.26 131634.931 0.99999999
# DMS1-CMB3   62666.6667  -88634.93 213968.264 0.97459214
# DMS2-CMB3  112666.6667  -38634.93 263968.264 0.34940571
# DMS3-CMB3   29000.0000 -122301.60 180301.597 0.99999705
# DMS4-CMB3   99333.3333  -51968.26 250634.931 0.55438008
# PTZ1-CMB3  -17000.0000 -168301.60 134301.597 1.00000000
# PTZ2-CMB3   21000.0000 -130301.60 172301.597 0.99999997
# PTZ3-CMB3  -19000.0000 -170301.60 132301.597 0.99999999
# PTZ4-CMB3  -16666.6667 -167968.26 134634.931 1.00000000
# TBF1-CMB3  -80200.0000 -231501.60  71101.597 0.84180374
# TBF2-CMB3    6333.3333 -144968.26 157634.931 1.00000000
# TBF3-CMB3  -15000.0000 -166301.60 136301.597 1.00000000
# TBF4-CMB3  -10000.0000 -161301.60 141301.597 1.00000000
# DMS1-CMB4   82333.3333  -68968.26 233634.931 0.81529850
# DMS2-CMB4  132333.3333  -18968.26 283634.931 0.14264936
# DMS3-CMB4   48666.6667 -102634.93 199968.264 0.99792800
# DMS4-CMB4  119000.0000  -32301.60 270301.597 0.26857293
# PTZ1-CMB4    2666.6667 -148634.93 153968.264 1.00000000
# PTZ2-CMB4   40666.6667 -110634.93 191968.264 0.99974519
# PTZ3-CMB4     666.6667 -150634.93 151968.264 1.00000000
# PTZ4-CMB4    3000.0000 -148301.60 154301.597 1.00000000
# TBF1-CMB4  -60533.3333 -211834.93  90768.264 0.98133100
# TBF2-CMB4   26000.0000 -125301.60 177301.597 0.99999937
# TBF3-CMB4    4666.6667 -146634.93 155968.264 1.00000000
# TBF4-CMB4    9666.6667 -141634.93 160968.264 1.00000000
# DMS2-DMS1   50000.0000 -101301.60 201301.597 0.99721802
# DMS3-DMS1  -33666.6667 -184968.26 117634.931 0.99997740
# DMS4-DMS1   36666.6667 -114634.93 187968.264 0.99993081
# PTZ1-DMS1  -79666.6667 -230968.26  71634.931 0.84810041
# PTZ2-DMS1  -41666.6667 -192968.26 109634.931 0.99965724
# PTZ3-DMS1  -81666.6667 -232968.26  69634.931 0.82380248
# PTZ4-DMS1  -79333.3333 -230634.93  71968.264 0.85196662
# TBF1-DMS1 -142866.6667 -294168.26   8434.931 0.08118303
# TBF2-DMS1  -56333.3333 -207634.93  94968.264 0.99051464
# TBF3-DMS1  -77666.6667 -228968.26  73634.931 0.87048085
# TBF4-DMS1  -72666.6667 -223968.26  78634.931 0.91754024
# DMS3-DMS2  -83666.6667 -234968.26  67634.931 0.79771706
# DMS4-DMS2  -13333.3333 -164634.93 137968.264 1.00000000
# PTZ1-DMS2 -129666.6667 -280968.26  21634.931 0.16315837
# PTZ2-DMS2  -91666.6667 -242968.26  59634.931 0.67918060
# PTZ3-DMS2 -131666.6667 -282968.26  19634.931 0.14757130
# PTZ4-DMS2 -129333.3333 -280634.93  21968.264 0.16587841
# TBF1-DMS2 -192866.6667 -344168.26 -41565.069 0.00342471
# TBF2-DMS2 -106333.3333 -257634.93  44968.264 0.44227418
# TBF3-DMS2 -127666.6667 -278968.26  23634.931 0.18001517
# TBF4-DMS2 -122666.6667 -273968.26  28634.931 0.22796912
# DMS4-DMS3   70333.3333  -80968.26 221634.931 0.93509414
# PTZ1-DMS3  -46000.0000 -197301.60 105301.597 0.99889943
# PTZ2-DMS3   -8000.0000 -159301.60 143301.597 1.00000000
# PTZ3-DMS3  -48000.0000 -199301.60 103301.597 0.99822125
# PTZ4-DMS3  -45666.6667 -196968.26 105634.931 0.99898749
# TBF1-DMS3 -109200.0000 -260501.60  42101.597 0.39893247
# TBF2-DMS3  -22666.6667 -173968.26 128634.931 0.99999991
# TBF3-DMS3  -44000.0000 -195301.60 107301.597 0.99934287
# TBF4-DMS3  -39000.0000 -190301.60 112301.597 0.99984841
# PTZ1-DMS4 -116333.3333 -267634.93  34968.264 0.30099528
# PTZ2-DMS4  -78333.3333 -229634.93  72968.264 0.86324025
# PTZ3-DMS4 -118333.3333 -269634.93  32968.264 0.27645229
# PTZ4-DMS4 -116000.0000 -267301.60  35301.597 0.30521618
# TBF1-DMS4 -179533.3333 -330834.93 -28231.736 0.00842530
# TBF2-DMS4  -93000.0000 -244301.60  58301.597 0.65786542
# TBF3-DMS4 -114333.3333 -265634.93  36968.264 0.32686751
# TBF4-DMS4 -109333.3333 -260634.93  41968.264 0.39696589
# PTZ2-PTZ1   38000.0000 -113301.60 189301.597 0.99989076
# PTZ3-PTZ1   -2000.0000 -153301.60 149301.597 1.00000000
# PTZ4-PTZ1     333.3333 -150968.26 151634.931 1.00000000
# TBF1-PTZ1  -63200.0000 -214501.60  88101.597 0.97265223
# TBF2-PTZ1   23333.3333 -127968.26 174634.931 0.99999987
# TBF3-PTZ1    2000.0000 -149301.60 153301.597 1.00000000
# TBF4-PTZ1    7000.0000 -144301.60 158301.597 1.00000000
# PTZ3-PTZ2  -40000.0000 -191301.60 111301.597 0.99979218
# PTZ4-PTZ2  -37666.6667 -188968.26 113634.931 0.99990233
# TBF1-PTZ2 -101200.0000 -252501.60  50101.597 0.52389934
# TBF2-PTZ2  -14666.6667 -165968.26 136634.931 1.00000000
# TBF3-PTZ2  -36000.0000 -187301.60 115301.597 0.99994543
# TBF4-PTZ2  -31000.0000 -182301.60 120301.597 0.99999259
# PTZ4-PTZ3    2333.3333 -148968.26 153634.931 1.00000000
# TBF1-PTZ3  -61200.0000 -212501.60  90101.597 0.97939328
# TBF2-PTZ3   25333.3333 -125968.26 176634.931 0.99999957
# TBF3-PTZ3    4000.0000 -147301.60 155301.597 1.00000000
# TBF4-PTZ3    9000.0000 -142301.60 160301.597 1.00000000
# TBF1-PTZ4  -63533.3333 -214834.93  87768.264 0.97138479
# TBF2-PTZ4   23000.0000 -128301.60 174301.597 0.99999989
# TBF3-PTZ4    1666.6667 -149634.93 152968.264 1.00000000
# TBF4-PTZ4    6666.6667 -144634.93 157968.264 1.00000000
# TBF2-TBF1   86533.3333  -64768.26 237834.931 0.75754462
# TBF3-TBF1   65200.0000  -86101.60 216501.597 0.96438338
# TBF4-TBF1   70200.0000  -81101.60 221501.597 0.93601409
# TBF3-TBF2  -21333.3333 -172634.93 129968.264 0.99999996
# TBF4-TBF2  -16333.3333 -167634.93 134968.264 1.00000000
# TBF4-TBF3    5000.0000 -146301.60 156301.597 1.00000000



