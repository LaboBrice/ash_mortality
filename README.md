# Urban Forest Temporal Analysis - Reproducible Workflow

> Analysis of tree community dynamics in urban woodlands following ash mortality (2011-2023)

**Associated Manuscript**: Growth of co-occurring trees compensates for ash mortality in urban woodlands

**Authors**: Melanie Primeau, Stéphanie Pellerin, Marie-Hélène Brice

---

## Overview

This repository contains the complete reproducible workflow for analyzing temporal changes in urban forest composition and structure following emerald ash borer invasion. The analysis includes:

- Ash tree (*Fraxinus* spp.) health status and mortality patterns
- Temporal changes in tree basal area and sapling abundance (2011-2023)
- Temporal changes in tree and sapling richness

---

## Quick Start


```r
# Navigate to workflow directory
setwd("path/to/workflow")

# Run the analysis (using provided processed data)
source("00_setup.R")              # Install packages and load functions
source("01_create_site_map.R")    # Create study site map
source("02_fraxinus_analysis.R")  # Analyze ash tree health
source("03_temporal_analysis.R")  # Temporal changes in trees and saplings
```

---

## Repository Structure

```
workflow/
├── 00_setup.R                   # Package installation and setup
├── 01_create_site_map.R         # Study site map (optional)
├── 02_fraxinus_analysis.R       # Ash tree health analysis
├── 03_temporal_analysis.R       # Temporal community analysis
│
├── functions/                   # Custom R functions
│   ├── statistical_functions.R  # Statistical testing
│   └── plotting_functions.R     # Visualization functions
│
├── data/                        # Processed data
│   ├── fraxinus_health_DBH.csv
│   ├── sapling_2011.csv
│   ├── sapling_2023.csv
│   ├── BA_2011.csv
│   ├── BA_2023.csv
│   └── species_labels.csv
│
├── output/                      # All results
│   ├── figures/
│   └── tables/
│
└── README.md                    # This file
```

---

## Detailed Workflow

### Step 0: Setup (00_setup.R)

**Purpose**: Install and load all required R packages and custom functions.

**Packages installed**:
- `vegan` - Community ecology analyses
- `ggplot2`, `cowplot`, `patchwork` - Plotting
- `dplyr`, `tidyr` - Data manipulation
- `car`, `BSDA` - Statistical tests
- `ggpubr`, `ggrepel` - Enhanced plotting
- `readxl` - Excel file import
- `sf`, `ggspatial`, `rnaturalearth` - Mapping

**Run once per session**:
```r
source("00_setup.R")
```

---

### Step 1: Provided Data Files

**Note**: Raw data and data preparation scripts (`00b_load_data.R`) are not included in this repository. Cleaned and processed data files are provided in the `data/` directory.

**Provided data files** (in `data/`):
- `fraxinus_health_DBH.csv` - Ash health status by DBH category
- `BA_2011.csv`, `BA_2023.csv` - Basal area by species (2011 and 2023)
- `sapling_2011.csv`, `sapling_2023.csv` - Sapling abundance by species
- `species_labels.csv` - Species code to Latin name mapping
- `tree_species.csv` - List of all tree species codes
- Additional Fraxinus-specific files

**Data format**: CSV files with sites in rows and species in columns (wide format), except `fraxinus_health_DBH.csv` which is in long format.

---

### Step 2: Fraxinus Health Analysis (02_fraxinus_analysis.R)

**Purpose**: Analyze ash tree health status across size classes.

**Analyses performed**:
1. Summarize health states by DBH category
2. Chi-square test: health state distribution vs. DBH
3. Standardized residuals analysis
4. Visualization: stacked bar chart and residual heatmap

**Outputs**:
- **Tables**:
  - `fraxinus_health_summary.csv` - Counts by DBH and health
  - `chi_square_health_dbh.csv` - Chi-square test results
- **Figures**:
  - `fraxinus_health_by_dbh.png` - Health proportions by size class
  - `fraxinus_residuals_heatmap.png` - Chi-square residuals

```r
source("02_fraxinus_analysis.R")
```

---

### Step 3: Temporal Community Analysis (03_temporal_analysis.R)

**Purpose**: Analyze changes in tree and sapling communities between 2011 and 2023.

**Analyses performed**:

**A. Species-level changes**:
1. Calculate total counts for each species (2011 vs 2023)
2. Test significance of changes for species present in ≥5% of sites
3. Auto-select t-test or sign test based on normality
4. Create scatter plots highlighting significant species

**B. Tree species richness**:
1. Calculate richness per plot (2011 and 2023)
2. Paired t-test for temporal change
3. Summary statistics and confidence intervals

**C. Sapling species richness**:
1. Same approach as trees
2. Separate analysis for understory stratum

**Outputs**:
- **Tables**:
  - `sapling_totals_2011_2023.csv` - Sapling counts by species
  - `tree_totals_2011_2023.csv` - Tree counts by species
  - `sapling_significance_tests.csv` - Statistical test results
  - `tree_significance_tests.csv` - Statistical test results
  - `tree_richness_ttest.csv`, `tree_richness_per_plot.csv`
  - `sapling_richness_ttest.csv`, `sapling_richness_per_plot.csv`
- **Figures**:
  - `temporal_comparison_2panel.svg` - Saplings and basal area scatter plots
- **Data**:
  - `sapling_temporal.RData`, `tree_temporal.RData`

```r
source("03_temporal_analysis.R")
```

---

### Step 4: Site Map (01_create_site_map.R)

**Purpose**: Create a map showing study site locations (optional).

**Note**: Requires spatial coordinates for sites.

```r
source("01_create_site_map.R")  # Optional
```

---

## Custom Functions

### data_functions.R

| Function | Description |
|----------|-------------|
| `add_missing_species()` | Add missing species columns (filled with zeros) |
| `calculate_species_totals()` | Sum species counts across all sites by year |

### statistical_functions.R

| Function | Description |
|----------|-------------|
| `test_temporal_change()` | Auto-select parametric/non-parametric test based on normality |
| `test_top_species()` | Test significance for species present in ≥X% of sites |

### plotting_functions.R

| Function | Description |
|----------|-------------|
| `plot_fraxinus_health()` | Stacked bar chart of health states by DBH |
| `plot_temporal_scatter()` | Scatter plot with 1:1 line and highlighting |

---

## Data Format

### Input Data Requirements

**Fraxinus data** (`Fraxi_over23.xlsx`, `Fraxi_under23_filtered.xlsx`):
- Columns: `sitesCode`, `species`, `DHP` or `DHP_Category`, `Etat` (health state)
- Health states: 1=Healthy, 2=Light decline, 3=Moderate, 4=Severe, 5=Dead, 6=Dead with sprouts

**Basal area data** (`ST2011.xlsx`, `ST2023.xlsx`):
- Rows: Sites (column `sitesCode`)
- Columns: Species codes (basal area values)

**Sapling data**:
- Rows: Sites (column `sitesCode`)
- Columns: Species codes (abundance counts)

---

## Key Results

### Health State Categories
- **0-9.9 cm DBH**: Sapling/small trees
- **10-40+ cm DBH**: Mature trees (overstory)
- **Health states**: Healthy → Declining → Dead → Dead with sprouts

### Statistical Tests
- **Sign test**: Non-parametric test for species with non-normal distributions
- **t-test**: Parametric test for normally distributed changes
- **Paired t-test**: For within-site richness comparisons
- **Chi-square test**: Association between health and DBH category

### Species Selection
- Only species present in ≥5% of sites are tested
- Reduces false positives from rare species
- Ensures adequate sample size for statistical power

---

## Running the Complete Analysis

### Option 1: Run All at Once

```r
source("RUN_ALL.R")
```

### Option 2: Run Step by Step

```r
# Setup
source("00_setup.R")

# Run analyses (data files already provided in data/)
source("02_fraxinus_analysis.R")
source("03_temporal_analysis.R")
```

### Option 3: Interactive Analysis

```r
# Load functions
source("00_setup.R")

# Load specific data files
sapling_2011 <- read.csv("data/sapling_2011.csv")
sapling_2023 <- read.csv("data/sapling_2023.csv")

# Use functions directly
totals <- calculate_species_totals(sapling_2011, sapling_2023)
results <- test_top_species(totals, sapling_2011, sapling_2023)
```

---

## System Requirements

### Software
- **R** ≥ 4.0.0
- **RStudio** (recommended)

### R Packages
All packages installed automatically by `00_setup.R`:
- Core: `vegan`, `ggplot2`, `dplyr`, `tidyr`
- Statistics: `car`, `BSDA`, `ggpubr`
- Visualization: `ggrepel`, `patchwork`, `cowplot`
- Data I/O: `readxl`
- Mapping: `sf`, `ggspatial`, `rnaturalearth`, `rnaturalearthdata`

### Disk Space
- ~10 MB for scripts and functions
- ~5 MB for processed data files (provided)
- ~20 MB for outputs

---

## Reproducibility

### Session Information

Save your R session info for full reproducibility:

```r
writeLines(capture.output(sessionInfo()), "output/session_info.txt")
```

### Version Control

This workflow uses:
- R scripts (`.R`) for all analyses
- Plain text outputs (`.csv`) for tables
- Vector graphics (`.svg`) where possible
- Git-friendly formats throughout

### Best Practices

1. **Never modify raw data files** - All cleaning done in scripts
2. **Document changes** - Add comments when modifying code
3. **Test incrementally** - Run scripts one at a time first
4. **Check outputs** - Verify tables and figures after each step
5. **Use version control** - Track changes with git

---

## Troubleshooting

### Common Issues

**"Cannot find raw_data/ directory"**
- Place your raw data files in `raw_data/` subdirectories
- Or modify paths in `00b_load_data.R`

**"Package installation failed"**
- Check internet connection
- Install packages manually: `install.packages("package_name")`
- Update R if using very old version

**"Column not found"**
- Check that your data uses the same column names
- Modify scripts if your data format differs

**"Object not found"**
- Ensure you ran previous scripts first
- Check that `00_setup.R` ran successfully
- Verify data files were created in `data/` directory

**Statistical test warnings**
- Normal - functions auto-select appropriate tests
- Non-normality warnings indicate sign test was used (expected)

---

## Citation

If you use this workflow or adapt it for your research, please cite:

**Manuscript**:
```
Primeau, M., Brice, M.-H., & Pellerin, S. (2025). Growth of co-occurring
trees compensates for ash mortality in urban woodlands. [Journal TBD]
```

**Code/Workflow**:
```
Primeau, M., Brice, M.-H., & Pellerin, S. (2025). Urban Forest Temporal
Analysis - Reproducible Workflow. GitHub repository: [URL]
```

---

## License

[Add license information here - e.g., MIT, GPL-3, CC-BY]

---

## Contact

For questions about this workflow:
- **Melanie Primeau**: [email]
- **Marie-Hélène Brice**: [email]

---

## Acknowledgments

This research was conducted on [study area] and supported by [funding sources].

---

**Last updated**: March 2026
