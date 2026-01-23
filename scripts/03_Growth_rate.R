library(ggplot2)
library(dplyr)
library(readxl)
library(here)

Growth_rate <- read_excel(here("data_in", "03A-growth_rate", "Growth_rate.xlsx"))

growth_rate_long <- Growth_rate %>%
  tidyr::pivot_longer(cols = starts_with("R"), names_to = "Replicate", values_to = "Value")

# Calculate mean and standard deviation for error bars
growth_summary <- growth_rate_long %>%
  group_by(Sample) %>%
  summarise(
    Mean = mean(Value),
    SD = sd(Value), 
    n = n(),
    SE = SD/sqrt(n)
  )


desired_order <- c("ANC", "DMS1", "DMS2", "DMS3", "DMS4", "PTZ1", "PTZ2", "PTZ3", "PTZ4", "TBF1", "TBF2", "TBF3", "TBF4", "CMB1", "CMB2", "CMB3", "CMB4")

# Reorder the samples in the summary data frame
growth_summary$Sample <- factor(growth_summary$Sample, levels = desired_order)

group_colors <- c("ANC_group" = "#7F7F7F",
                  "DMS_group" = "#EF8636",
                  "PTZ_group" = "#3B75AF", 
                  "TBF_group" = "#C53A32",
                  "CMB_group" = "#8D69B8")

sample_colors <- c(
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
)

# Create the bar plot with error bars
ggplot(growth_summary, aes(x = Sample, y = Mean, fill = Sample)) +
  geom_bar(stat = "identity", color = "black") +
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0.2, color = "black") +
  labs(title = "", x = "Evolved strain", y = "Growth area") +
  scale_fill_manual(values = sample_colors) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"), # Center and bold the plot title
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 10), # Rotate x-axis labels
        axis.title = element_text(size = 12, face = "bold"), # Bold axis titles
        legend.position = "none", # Hide the legend
        panel.grid.major = element_blank(), # Explicitly remove major grid lines
        panel.grid.minor = element_blank(), # Explicitly remove minor grid lines
        panel.background = element_rect(fill = "white", colour = "white") # Set solid white background
  )


ggsave(here("figures", "251114GrowthArea.pdf"), width = 6, height= 3.5, units =  "in", device = "pdf")

anova_result.2 <- aov(Value ~ Sample, data = growth_rate_long)
print(anova_result.2)
TukeyHSD(anova_result.2)