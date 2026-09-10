# =============================================================================
# Step 3: Tree and Sapling Temporal Analysis (2011-2023)
# =============================================================================
# This script analyzes changes in tree and sapling communities over time
# =============================================================================

# Load setup and data
source("R/00_setup.R")

sapling_2023 <- read.csv("data/sapling_2023.csv")
sapling_2011 <- read.csv("data/sapling_2011.csv")
BA_2011 <- read.csv("data/BA_2011.csv")
BA_2023 <- read.csv("data/BA_2023.csv") 
density_2011 <- read.csv("data/density_2011.csv")
density_2023 <- read.csv("data/density_2023.csv")
species_labels <- read.csv("data/species_labels.csv")

cat("\n=== TEMPORAL ANALYSIS (TREES AND SAPLINGS) ===\n\n")

# -----------------------------------------------------------------------------
# 2. CALCULATE SPECIES TOTALS
# -----------------------------------------------------------------------------
cat("Calculating species totals for each year...\n")

# Calculate totals across all sites
saplings_totals <- calculate_species_totals(
  data_2011 = sapling_2011[,-1],
  data_2023 = sapling_2023[,-1]
)

BA_totals <- calculate_species_totals(
  data_2011 = BA_2011[,-1],
  data_2023 = BA_2023[,-1]
)

density_totals <- calculate_species_totals(
  data_2011 = density_2011[,-1],
  data_2023 = density_2023[,-1]
)


# Create output directories if they don't exist
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Save totals
write.csv(saplings_totals, "output/tables/sapling_totals_2011_2023.csv",
          row.names = FALSE)
write.csv(BA_totals, "output/tables/BA_totals_2011_2023.csv",
          row.names = FALSE)
write.csv(density_totals, "output/tables/density_totals_2011_2023.csv",
          row.names = FALSE)

# -----------------------------------------------------------------------------
# 3. STATISTICAL TESTING FOR TOP SPECIES
# -----------------------------------------------------------------------------
cat("Testing significance of species changes...\n")

# Test top species with at least 5% of occurrence
saplings_results <- test_top_species(
  species_totals = saplings_totals,
  data_2011 = sapling_2011,
  data_2023 = sapling_2023
)

BA_results <- test_top_species(
  species_totals = BA_totals,
  data_2011 = BA_2011,
  data_2023 = BA_2023
)

density_results <- test_top_species(
  species_totals = density_totals,
  data_2011 = density_2011,
  data_2023 = density_2023
)

print(saplings_results %>% arrange(p_value))
print(BA_results %>% arrange(p_value))
print(density_results %>% arrange(p_value))

# Save results
write.csv(saplings_results, "output/tables/sapling_significance_tests.csv",
          row.names = FALSE)
write.csv(BA_results, "output/tables/BA_significance_tests.csv",
          row.names = FALSE)
write.csv(density_results, "output/tables/density_significance_tests.csv",
          row.names = FALSE)


# -----------------------------------------------------------------------------
# 4. CREATE SCATTER PLOT
# -----------------------------------------------------------------------------
cat("Creating temporal comparison plots...\n")

# Identify significant species
significant_saplings <- saplings_results %>%
  filter(significant == TRUE) %>%
  pull(species)

significant_BA <- BA_results %>%
  filter(significant == TRUE) %>%
  pull(species)

significant_density <- density_results %>%
  filter(significant == TRUE) %>%
  pull(species)

cat("Significant saplings:", paste(significant_saplings, collapse = ", "), "\n")
cat("Significant BA:", paste(significant_BA, collapse = ", "), "\n\n")

# Prepare sapling data with Latin names
saplings_plot_data <- saplings_totals %>%
  rename(Saplings_2011 = Count_2011, Saplings_2023 = Count_2023) %>%
  left_join(species_labels, by = c("SpCodes" = "code"))

# Create sapling scatter plot
p_saplings <- plot_temporal_scatter(
  data = saplings_plot_data,
  x_col = "Saplings_2011",
  y_col = "Saplings_2023",
  label_col = "latin_name",
  highlight_species = species_labels$latin_name[species_labels$code %in% significant_saplings],
  x_label = "Mean Sapling Density 2011 (stems/ha)", #"Saplings count (2011)",
  y_label = "Mean Sapling Density 2023 (stems/ha)", #"Saplings count (2023)"
  x_limit = 95000,
  y_limit = 95000
)

# Calculate mean basal area per species
mean_BA_2011 <- BA_2011 %>%
  summarise(across(
    all_of(BA_results$species),
    ~ mean(.x, na.rm = TRUE),
    .names = "{.col}"
  )) %>%
  pivot_longer(everything(), names_to = "SpCode", values_to = "Mean_BA_2011")

mean_BA_2023 <- BA_2023 %>%
  summarise(across(
    all_of(BA_results$species),
    ~ mean(.x, na.rm = TRUE),
    .names = "{.col}"
  )) %>%
  pivot_longer(everything(), names_to = "SpCode", values_to = "Mean_BA_2023")

# Combine and add Latin names
basal_area_df <- mean_BA_2011 %>%
  left_join(mean_BA_2023, by = "SpCode") %>%
  left_join(species_labels, by = c("SpCode" = "code"))

# Create basal area scatter plot
p_basal <- plot_temporal_scatter(
  data = basal_area_df,
  x_col = "Mean_BA_2011",
  y_col = "Mean_BA_2023",
  label_col = "latin_name",
  highlight_species = species_labels$latin_name[species_labels$code %in% significant_BA],
  x_label = bquote("Mean Basal Area 2011 (m"^2*"/ha)"),
  y_label = bquote("Mean Basal Area 2023 (m"^2*"/ha)"),
  x_limit = 8,
  y_limit = 8
)


# Calculate mean density per species
mean_density_2011 <- density_2011 %>%
  summarise(across(
    all_of(density_results$species),
    ~ mean(.x, na.rm = TRUE),
    .names = "{.col}"
  )) %>%
  pivot_longer(everything(), names_to = "SpCode", values_to = "Mean_Density_2011")

mean_density_2023 <- density_2023 %>%
  summarise(across(
    all_of(density_results$species),
    ~ mean(.x, na.rm = TRUE),
    .names = "{.col}"
  )) %>%
  pivot_longer(everything(), names_to = "SpCode", values_to = "Mean_Density_2023")

# Combine and add Latin names
density_df <- mean_density_2011 %>%
  left_join(mean_density_2023, by = "SpCode") %>%
  left_join(species_labels, by = c("SpCode" = "code"))

# Create density scatter plot
p_density <- plot_temporal_scatter(
  data = density_df,
  x_col = "Mean_Density_2011",
  y_col = "Mean_Density_2023",
  label_col = "latin_name",
  highlight_species = species_labels$latin_name[species_labels$code %in% significant_density],
  x_label = "Mean Tree Density 2011 (stems/ha)",
  y_label = "Mean Tree Density 2023 (stems/ha)",
  x_limit = 130,
  y_limit = 130
)

# Create 3-panel figure
p_combined <- plot_grid(p_density, p_basal, p_saplings, ncol = 3, labels = c("A", "B", "C"))

# Save combined plot
ggsave("output/figures/fig3_temporal_community_change.svg",
       p_combined, width = 15, height = 4)

print(p_combined)


# -----------------------------------------------------------------------------
# 5. TREE SPECIES RICHNESS ANALYSIS
# -----------------------------------------------------------------------------
cat("Analyzing tree species richness per plot...\n")

# Calculate species richness per plot (number of species present)
tree_richness_2011 <- BA_2011 %>%
  rowwise() %>%
  mutate(richness_2011 = sum(c_across(-sitesCode) > 0, na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, richness_2011)

tree_richness_2023 <- BA_2023 %>%
  rowwise() %>%
  mutate(richness_2023 = sum(c_across(-sitesCode) > 0, na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, richness_2023)

# Combine richness data
tree_richness_comparison <- tree_richness_2011 %>%
  inner_join(tree_richness_2023, by = "sitesCode")

# Display summary statistics
cat("\nSpecies richness summary:\n")
cat("2011 - Mean:", round(mean(tree_richness_comparison$richness_2011, na.rm = TRUE), 2),
    "± SD:", round(sd(tree_richness_comparison$richness_2011, na.rm = TRUE), 2), "\n")
cat("2023 - Mean:", round(mean(tree_richness_comparison$richness_2023, na.rm = TRUE), 2),
    "± SD:", round(sd(tree_richness_comparison$richness_2023, na.rm = TRUE), 2), "\n\n")

# Perform paired t-test
cat("Performing paired t-test for species richness...\n")
tree_richness_ttest <- t.test(tree_richness_comparison$richness_2023,
                         tree_richness_comparison$richness_2011,
                         paired = TRUE)

print(tree_richness_ttest)

# Calculate mean difference
tree_mean_diff <- mean(tree_richness_comparison$richness_2023 - tree_richness_comparison$richness_2011)

cat("\nMean change in richness per plot:", round(tree_mean_diff, 2), "species\n")

# Save results
tree_richness_results <- data.frame(
  test = "Paired t-test",
  mean_2011 = mean(tree_richness_comparison$richness_2011, na.rm = TRUE),
  sd_2011 = sd(tree_richness_comparison$richness_2011, na.rm = TRUE),
  mean_2023 = mean(tree_richness_comparison$richness_2023, na.rm = TRUE),
  sd_2023 = sd(tree_richness_comparison$richness_2023, na.rm = TRUE),
  mean_difference = tree_mean_diff,
  t_statistic = tree_richness_ttest$statistic,
  df = tree_richness_ttest$parameter,
  p_value = tree_richness_ttest$p.value,
  CI_lower = tree_richness_ttest$conf.int[1],
  CI_upper = tree_richness_ttest$conf.int[2],
  significant = tree_richness_ttest$p.value < 0.05
)

write.csv(tree_richness_results, "output/tables/tree_richness_ttest.csv", row.names = FALSE)
write.csv(tree_richness_comparison, "output/tables/tree_richness_per_plot.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 6. SAPLING SPECIES RICHNESS ANALYSIS
# -----------------------------------------------------------------------------
cat("Analyzing sapling species richness per plot...\n")

# Calculate sapling species richness per plot (number of species present)
sapling_richness_2011 <- sapling_2011 %>%
  rowwise() %>%
  mutate(richness_2011 = sum(c_across(-sitesCode) > 0, na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, richness_2011)

sapling_richness_2023 <- sapling_2023 %>%
  rowwise() %>%
  mutate(richness_2023 = sum(c_across(-sitesCode) > 0, na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, richness_2023)

# Combine richness data
sapling_richness_comparison <- sapling_richness_2011 %>%
  inner_join(sapling_richness_2023, by = "sitesCode")

# Display summary statistics
cat("\nSapling species richness summary:\n")
cat("2011 - Mean:", round(mean(sapling_richness_comparison$richness_2011, na.rm = TRUE), 2),
    "± SD:", round(sd(sapling_richness_comparison$richness_2011, na.rm = TRUE), 2), "\n")
cat("2023 - Mean:", round(mean(sapling_richness_comparison$richness_2023, na.rm = TRUE), 2),
    "± SD:", round(sd(sapling_richness_comparison$richness_2023, na.rm = TRUE), 2), "\n\n")

# Perform paired t-test
cat("Performing paired t-test for sapling species richness...\n")
sapling_richness_ttest <- t.test(sapling_richness_comparison$richness_2023,
                                  sapling_richness_comparison$richness_2011,
                                  paired = TRUE)

print(sapling_richness_ttest)

# Calculate mean difference
sapling_mean_diff <- mean(sapling_richness_comparison$richness_2023 - sapling_richness_comparison$richness_2011)

cat("\nMean change in sapling richness per plot:", round(sapling_mean_diff, 2), "species\n")

# Save results
sapling_richness_results <- data.frame(
  test = "Paired t-test",
  mean_2011 = mean(sapling_richness_comparison$richness_2011, na.rm = TRUE),
  sd_2011 = sd(sapling_richness_comparison$richness_2011, na.rm = TRUE),
  mean_2023 = mean(sapling_richness_comparison$richness_2023, na.rm = TRUE),
  sd_2023 = sd(sapling_richness_comparison$richness_2023, na.rm = TRUE),
  mean_difference = sapling_mean_diff,
  t_statistic = sapling_richness_ttest$statistic,
  df = sapling_richness_ttest$parameter,
  p_value = sapling_richness_ttest$p.value,
  CI_lower = sapling_richness_ttest$conf.int[1],
  CI_upper = sapling_richness_ttest$conf.int[2],
  significant = sapling_richness_ttest$p.value < 0.05
)

write.csv(sapling_richness_results, "output/tables/sapling_richness_ttest.csv", row.names = FALSE)
write.csv(sapling_richness_comparison, "output/tables/sapling_richness_per_plot.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 7. TOTAL TREE DENSITY CHANGES
# -----------------------------------------------------------------------------
cat("\nAnalyzing total tree density changes...\n")

# Calculate total density per plot (sum across all species)
total_density_2011 <- density_2011 %>%
  rowwise() %>%
  mutate(total_density_2011 = sum(c_across(-sitesCode), na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, total_density_2011)

total_density_2023 <- density_2023 %>%
  rowwise() %>%
  mutate(total_density_2023 = sum(c_across(-sitesCode), na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, total_density_2023)

# Combine density data
total_density_comparison <- total_density_2011 %>%
  inner_join(total_density_2023, by = "sitesCode")

# Display summary statistics
cat("\nTotal tree density summary:\n")
cat("2011 - Mean:", round(mean(total_density_comparison$total_density_2011, na.rm = TRUE), 2),
    "± SD:", round(sd(total_density_comparison$total_density_2011, na.rm = TRUE), 2), "stems/ha\n")
cat("2023 - Mean:", round(mean(total_density_comparison$total_density_2023, na.rm = TRUE), 2),
    "± SD:", round(sd(total_density_comparison$total_density_2023, na.rm = TRUE), 2), "stems/ha\n\n")

# Perform paired t-test
cat("Performing paired t-test for total tree density...\n")
total_density_ttest <- t.test(total_density_comparison$total_density_2023,
                               total_density_comparison$total_density_2011,
                               paired = TRUE)

print(total_density_ttest)

# Calculate mean difference
density_mean_diff <- mean(total_density_comparison$total_density_2023 -
                          total_density_comparison$total_density_2011)

cat("\nMean change in density per plot:", round(density_mean_diff, 2), "stems/ha\n")

# Save results
total_density_results <- data.frame(
  test = "Paired t-test",
  mean_2011 = mean(total_density_comparison$total_density_2011, na.rm = TRUE),
  sd_2011 = sd(total_density_comparison$total_density_2011, na.rm = TRUE),
  mean_2023 = mean(total_density_comparison$total_density_2023, na.rm = TRUE),
  sd_2023 = sd(total_density_comparison$total_density_2023, na.rm = TRUE),
  mean_difference = density_mean_diff,
  t_statistic = total_density_ttest$statistic,
  df = total_density_ttest$parameter,
  p_value = total_density_ttest$p.value,
  CI_lower = total_density_ttest$conf.int[1],
  CI_upper = total_density_ttest$conf.int[2],
  significant = total_density_ttest$p.value < 0.05
)

write.csv(total_density_results, "output/tables/total_density_ttest.csv", row.names = FALSE)
write.csv(total_density_comparison, "output/tables/total_density_per_plot.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 8. TOTAL BASAL AREA CHANGES
# -----------------------------------------------------------------------------
cat("\nAnalyzing total basal area changes...\n")

# Calculate total basal area per plot (sum across all species)
total_BA_2011 <- BA_2011 %>%
  rowwise() %>%
  mutate(total_BA_2011 = sum(c_across(-sitesCode), na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, total_BA_2011)

total_BA_2023 <- BA_2023 %>%
  rowwise() %>%
  mutate(total_BA_2023 = sum(c_across(-sitesCode), na.rm = TRUE)) %>%
  ungroup() %>%
  select(sitesCode, total_BA_2023)

# Combine basal area data
total_BA_comparison <- total_BA_2011 %>%
  inner_join(total_BA_2023, by = "sitesCode")

# Display summary statistics
cat("\nTotal basal area summary:\n")
cat("2011 - Mean:", round(mean(total_BA_comparison$total_BA_2011, na.rm = TRUE), 2),
    "± SD:", round(sd(total_BA_comparison$total_BA_2011, na.rm = TRUE), 2), "m²/ha\n")
cat("2023 - Mean:", round(mean(total_BA_comparison$total_BA_2023, na.rm = TRUE), 2),
    "± SD:", round(sd(total_BA_comparison$total_BA_2023, na.rm = TRUE), 2), "m²/ha\n\n")

# Perform paired t-test
cat("Performing paired t-test for total basal area...\n")
total_BA_ttest <- t.test(total_BA_comparison$total_BA_2023,
                         total_BA_comparison$total_BA_2011,
                         paired = TRUE)

print(total_BA_ttest)

# Calculate mean difference
BA_mean_diff <- mean(total_BA_comparison$total_BA_2023 -
                     total_BA_comparison$total_BA_2011)

cat("\nMean change in basal area per plot:", round(BA_mean_diff, 2), "m²/ha\n")

# Save results
total_BA_results <- data.frame(
  test = "Paired t-test",
  mean_2011 = mean(total_BA_comparison$total_BA_2011, na.rm = TRUE),
  sd_2011 = sd(total_BA_comparison$total_BA_2011, na.rm = TRUE),
  mean_2023 = mean(total_BA_comparison$total_BA_2023, na.rm = TRUE),
  sd_2023 = sd(total_BA_comparison$total_BA_2023, na.rm = TRUE),
  mean_difference = BA_mean_diff,
  t_statistic = total_BA_ttest$statistic,
  df = total_BA_ttest$parameter,
  p_value = total_BA_ttest$p.value,
  CI_lower = total_BA_ttest$conf.int[1],
  CI_upper = total_BA_ttest$conf.int[2],
  significant = total_BA_ttest$p.value < 0.05
)

write.csv(total_BA_results, "output/tables/total_basal_area_ttest.csv", row.names = FALSE)
write.csv(total_BA_comparison, "output/tables/total_basal_area_per_plot.csv", row.names = FALSE)


cat("\n=== TEMPORAL ANALYSIS COMPLETE ===\n")

