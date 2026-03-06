# Urban Forest Temporal Analysis - Reproducible Workflow

> Analysis of tree community dynamics in urban woodlands following ash mortality (2011-2023)

**Associated Manuscript**: Growth of co-occurring trees compensates for ash mortality in urban woodlands

**Authors**: Mélanie Primeau, Stéphanie Pellerin, Marie-Hélène Brice

---

## Overview

This repository contains the complete reproducible workflow for analyzing temporal changes in urban forest composition and structure following emerald ash borer invasion. The analysis includes:

- Ash tree (*Fraxinus* spp.) health status and mortality patterns
- Temporal changes in tree basal area and sapling abundance (2011-2023)
- Temporal changes in tree and sapling richness

---

## Quick Start


```r
# Navigate to project directory
setwd("path/to/ash_mortality")

# Run the analysis (using provided processed data)
source("R/00_setup.R")              # Install packages and load functions
source("R/01_create_site_map.R")    # Create study site map
source("R/02_fraxinus_analysis.R")  # Analyze ash tree health
source("R/03_temporal_analysis.R")  # Temporal changes in trees and saplings
```

---

## Repository Structure

```
ash_mortality/
├── R/                           # R analysis scripts
│   ├── 00_setup.R               # Package installation and setup
│   ├── 01_create_site_map.R     # Study site map (optional)
│   ├── 02_fraxinus_analysis.R   # Ash tree health analysis
│   └── 03_temporal_analysis.R   # Temporal community analysis
│
├── data/                        # Processed data files
│   ├── fraxinus_health_DBH.csv       # Ash health by DBH category
│   ├── sapling_2011.csv              # Sapling counts 2011
│   ├── sapling_2023.csv              # Sapling counts 2023
│   ├── BA_2011.csv                   # Basal area 2011
│   ├── BA_2023.csv                   # Basal area 2023
│   ├── BA_Fraxi_2011.csv             # Fraxinus basal area 2011
│   ├── BA_Fraxi_2023.csv             # Fraxinus basal area 2023
│   ├── Fraxi_sapling_2023.csv        # Fraxinus sapling data
│   ├── Fraxi_tree_2023.csv           # Fraxinus tree data
│   ├── tree_species.csv              # Species code list
│   ├── species_labels.csv            # Species code to name mapping
│   └── sites_shp/                    #  Shapefile of site locations
│       ├── sites_coordinates.shp
│       ├── sites_coordinates.dbf
│       ├── sites_coordinates.prj
│       └── [other shapefile components]
│
├── output/                      # Analysis outputs
│   ├── figures/                 # Generated plots
│   └── tables/                  # Statistical results
│
└── README.md                    # This file
```


---

**Last updated**: March 2026
