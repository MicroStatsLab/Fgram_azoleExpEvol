library(here)
library(tidyverse)
library(Hmisc)

mut <- read_csv(here("data_in", "05_mutation_analysis", "TableS1-filteredVariants.csv"))

table(mut$Strain)
# CMB1 CMB2 CMB3 CMB4 DMS1 DMS2 DMS3 DMS4 PTZ1 PTZ2 PTZ3 PTZ4 TBF1 TBF2 TBF3 TBF4 
#   5    1    2    2    5    1    5   10   10    8    7    9    8    8    9   10 

mut$effect[mut$AnnotSimple %in% c("indel", "nonsynonymous", "UTR")] <- "effect_yes"
mut$effect[mut$AnnotSimple %nin% c("indel", "nonsynonymous", "UTR")] <- "effect_no"

table(mut$Strain, mut$effect)

subset(mut, effect == "effect_yes")

desired_strain_order <- c(
  "DMS1", "DMS2", "DMS3", "DMS4",
  "PTZ1", "PTZ2", "PTZ3", "PTZ4",
  "TBF1", "TBF2", "TBF3", "TBF4",
  "CMB1", "CMB2", "CMB3", "CMB4"
)


ggplot(Supplimentary, aes(x = "Strain", fill = Result)) + # x = "" makes a single bar per facet
  geom_bar(position = "stack") + # Stacks the annotations within each bar
  facet_wrap(~ Strain, ncol = 4) + # Arrange into 4 columns (will result in 4 rows)
  labs(
    title = "Annotation Distribution per Strain",
    x = "", # No x-axis label needed as each facet is one strain
    y = "Count of Annotations",
    fill = "Annotation Type" # Legend title
  ) +
  theme_light() + # Start with a light theme
  theme(
    axis.text.x = element_blank(), # Remove x-axis text (as it's just "")
    axis.ticks.x = element_blank(), # Remove x-axis ticks
    panel.spacing = unit(0.5, "cm"), # Adjust spacing between panels
    strip.text = element_text(size = 8, face = "bold"), # Adjust facet label text
    plot.title = element_text(hjust = 0.5, face = "bold"), # Center plot title
    legend.position = "bottom", # Place legend at the bottom
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    panel.background = element_rect(fill = "white", colour = NA), # Ensure plain white background
    axis.line = element_blank() # Remove axis lines
  )


ggplot(Supplimentary, aes(x = "", fill = Result)) + # x = "" makes a single bar per facet
  geom_bar(position = "stack") + # Stacks the annotations within each bar
  facet_wrap(~ Strain, ncol = 4) + # Arrange into 4 columns (will result in 4 rows)
  labs(
    title = "Annotation Distribution per Strain",
    x = "", # No x-axis label needed as each facet is one strain
    y = "Count of Annotations",
    fill = "Annotation Type" # Legend title
  ) +
  theme_light() + # Start with a light theme
  theme(
    axis.text.x = element_blank(), # Remove x-axis text (as it's just "")
    axis.ticks.x = element_blank(), # Remove x-axis ticks
    panel.spacing = unit(0.5, "cm"), # Adjust spacing between panels
    strip.text = element_text(size = 10, face = "bold"), # Adjust facet label text (make it slightly larger for visibility)
    strip.background = element_blank(), # Remove the background box from facet labels
    strip.placement = "outside", # Place facet labels outside the panel (below the graph)
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)), # Center plot title, add bottom margin
    legend.position = "bottom", # Place legend at the bottom
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    panel.background = element_rect(fill = "white", colour = NA), # Ensure plain white background
    axis.line = element_blank(), # Remove axis lines
    panel.border = element_blank() # <--- Crucial: Removes the box around each graph
  )


ggplot(Supplimentary, aes(x = "", fill = Result)) +
  geom_bar(position = "stack") +
  facet_wrap(~ Strain, ncol = 4, strip.position = "bottom") + # <--- CRUCIAL CHANGE HERE
  labs(
    title = "Annotation Distribution per Strain",
    x = "",
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.7, "cm"), # Increased spacing slightly
    strip.text = element_text(size = 10, face = "bold"),
    strip.background = element_blank(),
    # strip.placement = "outside", # <--- REMOVE THIS LINE
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line = element_blank(),
    panel.border = element_blank()
  )

Coding <- Supplimentary %>%
  filter(Result == "C")



Supplimentary$Strain <- factor(Supplimentary$Strain, levels = desired_strain_order)

ggplot(Supplimentary, aes(x = "", fill = Result)) +
  geom_bar(position = "stack", width = 0.5) + # <--- Made bars skinnier (e.g., 0.5)
  facet_wrap(~ Strain, nrow = 1, strip.position = "bottom") + # <--- Changed to single row
  labs(
    title = "Annotation Distribution per Strain",
    x = "",
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_blank(), # Remove x-axis text (as it's just "")
    axis.ticks.x = element_blank(), # Remove x-axis ticks
    panel.spacing.x = unit(0.2, "cm"), # <--- Adjusted horizontal spacing between panels (make it smaller for denser single row)
    panel.spacing.y = unit(0.5, "cm"), # Keep vertical spacing consistent for rows (even if only 1 row)
    strip.text = element_text(size = 10, face = "bold"),
    strip.background = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line = element_blank(),
    panel.border = element_blank() # Remove the box around each graph
  )


ggplot(Supplimentary, aes(x = Strain, fill = Result)) + # <--- X-axis is now 'Strain'
  geom_bar(position = "stack", width = 0.9) + # <--- Increased width for less whitespace (default is 0.9)
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain", # <--- X-axis label added back
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"), # <--- Make x-axis text visible and rotate for readability
    axis.ticks.x = element_line(), # <--- Add x-axis ticks back
    # panel.spacing.x = unit(0.2, "cm"), # No longer relevant as we don't have facets for individual bars
    # panel.spacing.y = unit(0.5, "cm"), # No longer relevant
    strip.text = element_blank(), # <--- Remove facet labels (they are now on x-axis)
    strip.background = element_blank(), # <--- Remove facet background
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major.x = element_blank(), # <--- Remove vertical grid lines if desired
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(), # <--- Add x-axis line
    axis.line.y = element_line(), # Keep y-axis line
    panel.border = element_blank() # No overall panel border
  )


ggplot(Supplimentary, aes(x = Strain, fill = Result)) +
  geom_bar(position = "stack", width = 0.95) + # Adjusted width slightly for very close bars
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain",
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
    axis.ticks.x = element_line(),
    strip.text = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(),
    axis.line.y = element_line(),
    panel.border = element_blank()
  ) +
  scale_fill_grey(start = 0.2, end = 0.8)

ggplot(Supplimentary, aes(x = Strain, fill = Result)) + # <--- X-axis is now 'Strain'
  geom_bar(position = "stack", width = 0.9) + # <--- Increased width for less whitespace (default is 0.9)
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain", # <--- X-axis label added back
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"), # <--- Make x-axis text visible and rotate for readability
    axis.ticks.x = element_line(), # <--- Add x-axis ticks back
    # panel.spacing.x = unit(0.2, "cm"), # No longer relevant as we don't have facets for individual bars
    # panel.spacing.y = unit(0.5, "cm"), # No longer relevant
    strip.text = element_blank(), # <--- Remove facet labels (they are now on x-axis)
    strip.background = element_blank(), # <--- Remove facet background
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major.x = element_blank(), # <--- Remove vertical grid lines if desired
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(), # <--- Add x-axis line
    axis.line.y = element_line(), # Keep y-axis line
    panel.border = element_blank() # No overall panel border
  )




group_colors <- c(
  "ANC_group" = "#66C2A5",
  "DMS_group" = "#377EB8",
  "PTZ_group" = "#E7298A",
  "TBF_group" = "#7570B3",
  "CMB_group" = "#D95F02"
)




ggplot(Coding, aes(x = Strain, fill = Annotation)) + # <--- X-axis is now 'Strain'
  geom_bar(position = "stack", width = 0.9) + # <--- Increased width for less whitespace (default is 0.9)
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain", # <--- X-axis label added back
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"), # <--- Make x-axis text visible and rotate for readability
    axis.ticks.x = element_line(), # <--- Add x-axis ticks back
    # panel.spacing.x = unit(0.2, "cm"), # No longer relevant as we don't have facets for individual bars
    # panel.spacing.y = unit(0.5, "cm"), # No longer relevant
    strip.text = element_blank(), # <--- Remove facet labels (they are now on x-axis)
    strip.background = element_blank(), # <--- Remove facet background
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major.x = element_blank(), # <--- Remove vertical grid lines if desired
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(), # <--- Add x-axis line
    axis.line.y = element_line(), # Keep y-axis line
    panel.border = element_blank() # No overall panel border
  )


desired_strain_order <- c(
  "DMS1", "DMS2", "DMS3", "DMS4",
  "PTZ1", "PTZ2", "PTZ3", "PTZ4",
  "TBF1", "TBF2", "TBF3", "TBF4",
  "CMB1", "CMB2", "CMB3", "CMB4"
)

# --- CRITICAL STEP: Convert 'Strain' to a factor with specified levels ---
Coding$Strain <- factor(Coding$Strain, levels = desired_strain_order)

# --- Your Plotting Code ---
ggplot(Coding, aes(x = Strain, fill = Annotation)) +
  geom_bar(position = "stack", width = 0.95) + # Adjusted width slightly for very close bars
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain",
    y = "Count of Annotations",
    fill = "Annotation Type"
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
    axis.ticks.x = element_line(),
    strip.text = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(),
    axis.line.y = element_line(),
    panel.border = element_blank()
  )


annotation_patterns <- c(
  "disruptive_inframe_deletion" = "stripe",
  "frameshift_variant"          = "crosshatch",
  "synonymous_variant"          = "pch",
  "missense_variant"            = "circle",
  "stop_gained"                 = "wave",
  "STR"                         = "stripe",
  "conservative_inframe_deletion" = "none", # This will be a solid white/black block
  "disruptive_inframe_insertion"  = "gradient"
  # Add more mappings for any other unique annotations in your data
)



ggplot(Coding, aes(x = Strain, fill = Annotation, pattern = Annotation)) + # <--- Add 'pattern = Annotation'
  geom_bar_pattern( # <--- Change from geom_bar to geom_bar_pattern
    position = "stack",
    width = 0.95,
    # Define the colors for the patterns themselves (black and white)
    pattern_fill = "white",   # Background color of the pattern
    pattern_colour = "black", # Color of the pattern lines/dots
    # Optional: Adjust density and spacing for better visual clarity
    pattern_density = 0.1,    # How dense the pattern lines/dots are (0 to 1)
    pattern_spacing = 0.01    # Spacing between pattern elements (0 to 1)
  ) +
  labs(
    title = "Annotation Distribution per Strain",
    x = "Strain",
    y = "Count of Annotations",
    fill = "Annotation Type" # Legend title for the annotation types
  ) +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
    axis.ticks.x = element_line(),
    strip.text = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 10)),
    legend.position = "bottom",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line.x = element_line(),
    axis.line.y = element_line(),
    panel.border = element_blank()
  ) +
  # --- Control the patterns ---
  scale_pattern_manual(values = annotation_patterns) + # Assign specific pattern types
  # --- Control the base fill color (underneath the pattern) ---
  # Since patterns are doing the differentiation, you often want a single, solid
  # color for the background of all patterns, or a very subtle grayscale.
  scale_fill_manual(values = rep("white", length(unique(Coding$Annotation))))
# You can also try a very light grey:
# scale_fill_manual(values = rep("grey90", length(unique(Coding$Annotation))))

install.packages('ggpattern')
library(dplyr)

library(ggpattern)# Load the ggpattern library

install.packages("magick")


