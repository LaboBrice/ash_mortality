# =============================================================================
# Step 3: Tree and Sapling Temporal Analysis (2011-2023)
# =============================================================================
# This script analyzes changes in tree and sapling communities over time
# =============================================================================

# Load setup and data
source("00_setup.R")

sapling_2023 <- read.csv("data/sapling_2023.csv")
sapling_2011 <- read.csv("data/sapling_2011.csv")
BA_2011 <- read.csv("data/BA_2011.csv")
BA_2023 <- read.csv("data/BA_2023.csv") 
species_labels <- read.csv("data/species_labels.csv")

cat("\n=== TEMPORAL ANALYSIS (TREES AND SAPLINGS) ===\n\n")

cat("Data loaded:\n")
cat("  2011 sapling sites:", nrow(sapling_2011), "\n")
cat("  2023 sapling sites:", nrow(sapling_2023), "\n")
cat("  2011 tree sites:", nrow(BA_2011), "\n")
cat("  2023 tree sites:", nrow(BA_2023), "\n\n")

# -----------------------------------------------------------------------------
# 2. CALCULATE SPECIES TOTALS
# -----------------------------------------------------------------------------
cat("Calculating species totals for each year...\n")

# Calculate totals across all sites
saplings_totals <- calculate_species_totals(
  data_2011 = sapling_2011,
  data_2023 = sapling_2023,
  exclude_cols = "sitesCode"
)

trees_totals <- calculate_species_totals(
  data_2011 = BA_2011,
  data_2023 = BA_2023,
  exclude_cols = "sitesCode"
)

cat("✓ Species totals calculated\n")

# Save totals
write.csv(saplings_totals, "output/tables/sapling_totals_2011_2023.csv",
          row.names = FALSE)
write.csv(trees_totals, "output/tables/tree_totals_2011_2023.csv",
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

trees_results <- test_top_species(
  species_totals = trees_totals,
  data_2011 = BA_2011,
  data_2023 = BA_2023
)
cat("\n✓ Statistical tests complete\n")

print(saplings_results %>% arrange(p_value))
print(trees_results %>% arrange(p_value))

# Save results
write.csv(saplings_results, "output/tables/sapling_significance_tests.csv",
          row.names = FALSE)
write.csv(trees_results, "output/tables/tree_significance_tests.csv",
          row.names = FALSE)


# -----------------------------------------------------------------------------
# 4. CREATE SCATTER PLOT
# -----------------------------------------------------------------------------
cat("Creating temporal comparison plots...\n")

# Identify significant species
significant_saplings <- saplings_results %>%
  filter(significant == TRUE) %>%
  pull(species)

significant_trees <- trees_results %>%
  filter(significant == TRUE) %>%
  pull(species)

cat("Significant saplings:", paste(significant_saplings, collapse = ", "), "\n")
cat("Significant trees:", paste(significant_trees, collapse = ", "), "\n\n")

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
  x_label = "Saplings Count (2011)",
  y_label = "Saplings Count (2023)",
  x_limit = 350,
  y_limit = 350
)

# Calculate mean basal area per species
mean_BA_2011 <- BA_2011 %>%
  summarise(across(
    all_of(trees_results$species),
    ~ mean(.x, na.rm = TRUE),
    .names = "{.col}"
  )) %>%
  pivot_longer(everything(), names_to = "SpCode", values_to = "Mean_BA_2011")

mean_BA_2023 <- BA_2023 %>%
  summarise(across(
    all_of(trees_results$species),
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
  highlight_species = species_labels$latin_name[species_labels$code %in% significant_trees],
  x_label = bquote("Mean Basal Area 2011 (m"^2*"/ha)"),
  y_label = bquote("Mean Basal Area 2023 (m"^2*"/ha)")
)

# Create 2-panel figure
p_combined <- plot_grid(p_saplings, p_basal, ncol = 2, labels = c("A", "B"))

# Save individual and combined plots
ggsave("output/figures/temporal_comparison_2panel.svg",
       p_combined, width = 10, height = 4)

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

cat("\nMean change in richness per plot:", round(mean_diff, 2), "species\n")

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


cat("=== TEMPORAL ANALYSIS COMPLETE ===\n")

