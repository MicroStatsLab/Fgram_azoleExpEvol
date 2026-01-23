library(readxl)
library(here)
library(tidyverse)
library(gridExtra)
library(ggpubr)


#read in data
Transfer_data <- read_excel(here("data_in", "01-Evolution_experiment", "Transfer_data.xlsx"))

##DMSO graph

DMS_data <- Transfer_data %>%
  filter(grouping == "a" & Sample %in% c("DMS1", "DMS2", "DMS3", "DMS4"))

DMS_data_subset <- DMS_data[DMS_data$transfer <= 40, ]

drug_increase_DMS <- data.frame(
  transfer = c(2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5), # Transfers where drug increased
  drug_concentration = c(0, 0, 0, 0, 0, 0, 0, 0) # Corresponding drug levels/increases
)


##PTZ data

PTZ_data <- Transfer_data %>%
  filter(grouping == "b" & Sample %in% c("PTZ1", "PTZ2", "PTZ3", "PTZ4"))

PTZ_data_subset <- PTZ_data[PTZ_data$transfer <= 40, ]

PTZ_rows_1 <- data.frame(
  Sample = rep("PTZ1", 10),
  transfer = c(31, 32, 33, 34, 35, 36, 37, 38, 39, 40),
  growth_area = rep(0, 10),       # Use rep() for repeated values
  drug_concentration = rep(0, 10),
  grouping = rep("d", 10)# Use rep() for repeated values
)

PTZ_rows_2 <- data.frame(
  Sample = rep("PTZ2", 10),  # Use rep() for repeated values
  transfer = c(31, 32, 33, 34, 35, 36, 37, 38, 39, 40),
  growth_area = rep(0, 10),       # Use rep() for repeated values
  drug_concentration = rep(0, 10),
  grouping = rep("d", 10)# Use rep() for repeated values
)

PTZ_rows_3 <- data.frame(
  Sample = rep("PTZ3", 10),  # Use rep() for repeated values
  transfer = c(31, 32, 33, 34, 35, 36, 37, 38, 39, 40),
  growth_area = rep(0, 10),       # Use rep() for repeated values
  drug_concentration = rep(0, 10),
  grouping = rep("d", 10)# Use rep() for repeated values
)

PTZ_rows_4 <- data.frame(
  Sample = rep("PTZ4", 10),
  transfer = c(31, 32, 33, 34, 35, 36, 37, 38, 39, 40),
  growth_area = rep(0, 10),       # Use rep() for repeated values
  drug_concentration = rep(0, 10),
  grouping = rep("d", 10)# Use rep() for repeated values
)

PTZ_data_subset_1 <- rbind(PTZ_data_subset, PTZ_rows_1, PTZ_rows_2, PTZ_rows_3, PTZ_rows_4)


drug_increase_data <- data.frame(
  transfer = c(2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5), # Transfers where drug increased
  drug_concentration = c(0.4, 0.8, 1.6, 3.2, 6.4, 12.8, 25.2, 50.4) # Corresponding drug levels/increases
)

##CMB data
CMB_data <- Transfer_data %>%
  filter(grouping == "d" & Sample %in% c("CMB1", "CMB2", "CMB3", "CMB4"))

CMB_data_subset_1 <- CMB_data[CMB_data$transfer <= 40, ]


##TBF data

TBF_data <- Transfer_data %>%
  filter(grouping == "c" & Sample %in% c("TBF1", "TBF2", "TBF3", "TBF4"))

TBF_data_subset <- TBF_data[TBF_data$transfer <= 40, ]
new_TBF_data <- TBF_data_subset
new_TBF_data$growth_area[new_TBF_data$growth_area == 0.0] <- 6.0

TBF_data_subset$growth_area[141] <- 6.0


## PLOT ##
DMSplot <- ggplot(DMS_data_subset, aes(x = transfer, y = growth_area, group = Sample)) +
  # Add the background bar graph layer first
  geom_vline(xintercept = c(6, 11, 16, 21, 26, 31, 36), 
             color = grey(0.8), # Use the same color as the previous bars
             linetype = "solid", # Set the line type to solid
             size = 0.5) +  # IMPORTANT: Prevents inheriting aes from main ggplot()
  ylim(0, 60) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  # Your existing line plot layer
  geom_line(size = 0.5, color = "#EF8636") +
  labs(title = "DMSO", x = "Transfer", y = "Growth Area (cm^2)")

PTZplot <- ggplot(PTZ_data_subset_1, aes(x = transfer, y = growth_area, group = Sample)) +
  # Add the background bar graph layer first
  geom_vline(xintercept = c(6, 11, 16, 21, 26, 31, 36), 
             color = grey(0.8), # Use the same color as the previous bars
             linetype = "solid", # Set the line type to solid
             size = 0.5) +  # IMPORTANT: Prevents inheriting aes from main ggplot()
  ylim(0, 60) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  # Your existing line plot layer
  geom_line(size = 0.5, color = "#3B75AF") +
  labs(title = "PTZ", x = "Transfer", y = "Growth Area (cm^2)")


TBFplot <- ggplot(TBF_data_subset, aes(x = transfer, y = growth_area, group = Sample)) +
  # Add the background bar graph layer first
  geom_vline(xintercept = c(6, 11, 16, 21, 26, 31, 36), 
             color = grey(0.8), # Use the same color as the previous bars
             linetype = "solid", # Set the line type to solid
             size = 0.5) +  # IMPORTANT: Prevents inheriting aes from main ggplot()
  ylim(0, 60) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  # Your existing line plot layer
  geom_line(size = 0.5, color = "#C53A32") +
  labs(title = "TBF", x = "Transfer", y = "Growth Area (cm^2)")

CMBplot <- ggplot(CMB_data_subset_1, aes(x = transfer, y = growth_area, group = Sample)) +
  # Add the background bar graph layer first
  geom_vline(xintercept = c(6, 11, 16, 21, 26, 31, 36), 
             color = grey(0.8), # Use the same color as the previous bars
             linetype = "solid", # Set the line type to solid
             size = 0.75) +  # IMPORTANT: Prevents inheriting aes from main ggplot()
  ylim(0, 60) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  # Your existing line plot layer
  geom_line(size = 0.5, color = "#8D69B8") +
  labs(title = "CMB", x = "Transfer", y = "Growth Area (cm^2)")

figure <- ggarrange(DMSplot, PTZplot, TBFplot, CMBplot,
                    #labels = c("DMSO", "PTZ", "TBF", "CMB"),
                    ncol = 2, nrow = 2)

ggsave(here("figures", "251110EvolTransferGrowth.pdf"), width = 7, height= 5, units =  "in", device = "pdf")


