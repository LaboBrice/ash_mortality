# =============================================================================
# Setup Script - Install and Load Required Packages
# =============================================================================
# Run this script first to install all required packages
# Author: Melanie Primeau, M-H Brice
# =============================================================================

# Load all packages
cat("\nLoading packages...\n")
suppressPackageStartupMessages({
  library(vegan)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(lubridate)
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
source("R/fun_statistical.R")
source("R/fun_plotting.R")

cat("\n✓ Setup complete! All packages and functions loaded.\n")
