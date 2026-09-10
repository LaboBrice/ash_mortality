# Urban Forest Temporal Analysis - Reproducible Workflow

> Analysis of tree community dynamics in urban woodlands following ash mortality (2011-2023)

**Associated Manuscript**: Growth of co-occurring trees compensates for ash decline in urban woodlands

**Authors**: Mélanie Primeau, Marie-Hélène Brice, Stéphanie Pellerin

---

## Overview

This repository contains the complete reproducible workflow for analyzing temporal changes in urban forest composition and structure following emerald ash borer invasion in Montreal, Canada. The analysis includes:

- Study site mapping with spatial context
- Ash tree (*Fraxinus* spp.) health status across size classes
- Temporal changes in tree density, basal area, and species richness (2011-2023)
- Temporal changes in sapling abundance and species richness

---

## Quick Start

### Installation and Execution

```r
# Navigate to project directory
setwd("path/to/ash_mortality")

# Run the complete analysis workflow
source("R/00_setup.R")              # Install packages and load functions
source("R/01_create_site_map.R")    # Create study site map
source("R/02_fraxinus_analysis.R")  # Analyze ash tree health
source("R/03_temporal_analysis.R")  # Analyze temporal changes in forest structure

# Outputs will be saved to:
# - output/figures/  (maps, plots, visualizations)
# - output/tables/   (statistical results, summary tables)
```

---

## Repository Structure

```
ash_mortality/
├── R/                                # R analysis scripts (numbered workflow)
│   ├── 00_setup.R                    # Package installation and custom functions
│   ├── 01_create_site_map.R          # Study site map generation
│   ├── 02_fraxinus_analysis.R        # Ash tree health analysis
│   ├── 03_temporal_analysis.R        # Temporal community analysis
│   └── functions/                    # Custom R functions
│       ├── statistical_functions.R   # Statistical testing functions
│       └── plotting_functions.R      # Visualization functions
│
├── data/                             # Processed data files (ready for analysis)
│   ├── fraxinus_health_DBH.csv       # Ash health status by DBH category
│   ├── sapling_2011.csv              # Sapling density per plot (stems/ha), 2011
│   ├── sapling_2023.csv              # Sapling density per plot (stems/ha), 2023
│   ├── density_2011.csv              # Tree density per plot (stems/ha), 2011
│   ├── density_2023.csv              # Tree density per plot (stems/ha), 2023
│   ├── BA_2011.csv                   # Tree basal area per plot (m²/ha), 2011
│   ├── BA_2023.csv                   # Tree basal area per plot (m²/ha), 2023
│   ├── species_labels.csv            # Species code to Latin name mapping
│   └── sites_shp/                    # Study site spatial data
│       └── sites_coordinates.shp     # Shapefile with plot locations (NAD83/MTM zone 8)
│
├── output/                           # Analysis outputs (auto-generated)
│   ├── figures/                      # Generated plots and maps
│   └── tables/                       # Statistical results and summary tables
│
└── README.md                         # This file
```

---

## Analysis Workflow

### Script 00: Setup
Installs packages, loads custom functions, prepares environment.

### Script 01: Site Map
Creates study site map with Montreal/Quebec context.
**Key output**: `fig1_location_map.png`

### Script 02: Fraxinus Analysis
Tests relationship between ash health status and tree size (chi-square test).
**Key outputs**: `fig2_fraxinus_health_by_dbh.png`, `chi_square_health_dbh.csv`

### Script 03: Temporal Analysis
Compares 2011-2023 changes in tree/sapling communities using paired tests. Analyzes species abundance, richness, density, and basal area.
**Key outputs**: `fig3_temporal_community_change.svg`, significance test results, richness/density/basal area statistics

---

## Requirements

### R Packages
The following packages are automatically installed by `R/00_setup.R`:
- **Statistics**: `vegan`, `car`, `BSDA`
- **Data manipulation**: `dplyr`, `tidyr`, `lubridate`, `readxl`
- **Visualization**: `ggplot2`, `ggpubr`, `ggrepel`, `patchwork`, `cowplot`
- **Spatial analysis**: `sf`, `ggspatial`, `rnaturalearth`, `rnaturalearthdata`

---

## Citation

If you use this code or data, please cite:

> Primeau, M., Pellerin, S., & Brice, M.-H. (2026). Growth of co-occurring trees compensates for ash mortality in urban woodlands. *submitted to Canadian Journal of forest research*.


---

**Last updated**: July 2026
