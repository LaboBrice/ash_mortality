# =============================================================================
# Setup Script - Install and Load Required Packages
# =============================================================================
# Run this script first to install all required packages
# Author: Melanie Primeau, M-H Brice
# =============================================================================

cat("Installing and loading required packages...\n\n")

# List of required packages
required_packages <- c(
  "vegan",      # Community ecology analyses
  "ggplot2",    # Plotting
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "car",        # Statistical tests
  "ggpubr",     # QQ plots
  "BSDA",       # Sign test
  "ggrepel",    # Text labels for plots
  "patchwork", "cowplot",  # Combine plots
  "readxl",     # Read Excel files
  "sf",         # Spatial features
  "ggspatial",  # Spatial plotting
  "rnaturalearth",  # Natural Earth map data
  "rnaturalearthdata"  # Natural Earth data
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) {
  cat("Installing packages:", paste(new_packages, collapse = ", "), "\n")
  install.packages(new_packages, dependencies = TRUE)
}

# Load all packages
cat("\nLoading packages...\n")
suppressPackageStartupMessages({
  library(vegan)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(car)
  library(ggpubr)
  library(BSDA)
  library(ggrepel)
  library(patchwork)
  library(cowplot)
  library(readxl)
  library(sf)
  library(ggspatial)
  library(rnaturalearth)
  library(rnaturalearthdata)
})

# Source all custom functions
cat("Loading custom functions...\n")
source("functions/statistical_functions.R")
source("functions/plotting_functions.R")

cat("\n✓ Setup complete! All packages and functions loaded.\n")
