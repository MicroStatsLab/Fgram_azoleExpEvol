library(tidyverse)
library(readxl)
library(here)
library(agricolae)
library(lmerTest)
library(lme4)
library("Matrix")

wheat_data <- read_csv(here("data_in", "03B-wheat_data", "2511103_wheat_data_raw.csv"))

table(is.na(wheat_data$june_27)) #19 NAs

#remove plants where there was no data on the last day of the experiment
wheat_data_na_rm <- wheat_data[!is.na(wheat_data$june_27), ] 

table(is.na(wheat_data$june_27), wheat_data$Pot_number) # 19 plants from 12 pots were NA on June 27 from

#calculate audpc using function from agricolae package
dates <- c(0, 4, 7, 11)
wheat_data_na_rm$audpc <- audpc(wheat_data_na_rm[,c(4:7)], dates)$june_17

wheat_data_na_rm_noANC <- subset(wheat_data_na_rm, substr(wheat_data_na_rm$lineage, 1, 3) !="ANC")
wheat_data_na_rm_ANC <- subset(wheat_data_na_rm, substr(wheat_data_na_rm$lineage, 1, 3) =="ANC")


# keep water in for figure, take out for stats
summary_data_noANC <- wheat_data_na_rm_noANC %>%
  group_by(lineage) %>%
  summarise(
    mean_audpc = mean(audpc, na.rm = TRUE),
    sd_audpc = sd(audpc, na.rm = TRUE),
    n_audpc = n()
  ) %>%
  mutate(se_audpc = sd_audpc / sqrt(n_audpc))

summary_data_ANC <- wheat_data_na_rm_ANC %>%
  summarise(
    mean_audpc = mean(audpc, na.rm = TRUE),
    sd_audpc = sd(audpc, na.rm = TRUE),
    n_audpc = n()
  ) %>%
  mutate(se_audpc = sd_audpc / sqrt(n_audpc))

summary_data_ANC <- cbind(lineage = "ANC", summary_data_ANC)

summary_data_wANC <- rbind(summary_data_ANC, summary_data_noANC)

desired_order_wANC <- c("ANC",
                   "DMS1", "DMS2", "DMS3", "DMS4",
                   "PTZ1", "PTZ2", "PTZ3", "PTZ4",
                   "TBF1", "TBF2", "TBF3", "TBF4",
                   "CMB1", "CMB2", "CMB3", "CMB4", "water")

# reorder based on desired order - this may or may not be working
summary_data_wANC$lineage <- factor(summary_data_wANC$lineage, levels = desired_order_wANC)

ggplot(summary_data_wANC, aes(x = lineage, y = mean_audpc, fill = lineage)) +
  geom_bar(stat = "identity", color = "black") + # Add black outline to bars
  geom_errorbar(aes(ymin = mean_audpc - se_audpc, ymax = mean_audpc + se_audpc),
                width = 0.2, position = position_dodge(0.9)) +
  scale_fill_manual(values = c("water" = "black",
                               "ANC" = "#7F7F7F",
                               "DMS1" = "#EF8636",
                               "DMS2" = "#EF8636",
                               "DMS3" = "#EF8636",
                               "DMS4" = "#EF8636",
                               "PTZ1" = "#3B75AF",
                               "PTZ2" = "#3B75AF",
                               "PTZ3" = "#3B75AF",
                               "PTZ4" = "#3B75AF",
                               "TBF1" = "#C53A32",
                               "TBF2" = "#C53A32",
                               "TBF3" = "#C53A32",
                               "TBF4" = "#C53A32",
                               "CMB1" = "#8D69B8", 
                               "CMB2" = "#8D69B8",
                               "CMB3" = "#8D69B8",
                               "CMB4" = "#8D69B8"
  )) +
  labs(title = "",
       x = "Lineage",
       y = "AUDPC") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"), # Center and bold the plot title
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 10), # Rotate x-axis labels
        axis.title = element_text(size = 12, face = "bold"), # Bold axis titles
        legend.position = "none", # Hide the legend
        panel.grid.major = element_blank(), # Explicitly remove major grid lines
        panel.grid.minor = element_blank(), # Explicitly remove minor grid lines
        panel.background = element_rect(fill = "white", colour = "white") # Set solid white background
  ) 

ggsave(here("figures", "251110AUDPC.pdf"), width = 6, height= 3.5, units =  "in", device = "pdf")

######### STATS
#remove water pots
wheat_data_na_noH20 <- subset(wheat_data_na_rm, lineage != "water")

#make all ANC reps the same lineage
wheat_data_na_noH20$lineage[substr(wheat_data_na_noH20$lineage, 1, 3) =="ANC"] <- "ANC"

aov_model <- aov(audpc ~ lineage, data = wheat_data_na_noH20)
summary(aov_model)

#lmer_model <- lmer(audpc ~ lineage + (1 | Pot_number), data = wheat_data_na_noH20)
#model_with_pvals <- as(lmer_model, "lmerModLmerTest")
#summary(model_with_pvals)
