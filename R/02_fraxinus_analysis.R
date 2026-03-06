# =============================================================================
# Step 1: Fraxinus Health Analysis
# =============================================================================
# This script analyzes ash tree health states and mortality patterns
# =============================================================================

# Load setup and data
source("00_setup.R")

fraxinus_health <- read.csv("data/fraxinus_health_DBH.csv") %>%
  filter(!is.na(DBH)) %>%
  mutate(DBH = factor(DBH,
                      levels = c("0-0.9", "1-2.4", "2.5-4.9", "5-9.9",
                                 "10-20", "21-30", "31-40", "41+"),
                      ordered = TRUE))

cat("\n=== FRAXINUS HEALTH ANALYSIS ===\n\n")

# -----------------------------------------------------------------------------
# 1. SUMMARIZE HEALTH STATES
# -----------------------------------------------------------------------------

# Count by DBH and health state
health_summary <- fraxinus_health %>%
  group_by(DBH, Health) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(DBH) %>%
  mutate(proportion = count / sum(count))

print(health_summary)

# Save summary
write.csv(health_summary, "output/tables/fraxinus_health_summary.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 2. CHI-SQUARE TEST
# -----------------------------------------------------------------------------
cat("\nCHI-SQUARE TEST: Testing association between health state and DBH category...\n")

# Test if health state distribution differs across DBH categories

# Create contingency table
contingency_table <- table(fraxinus_health$DBH, fraxinus_health$Health)
print("Contingency Table:")
print(contingency_table)
cat("\n")


# Perform chi-square test
chi_test <- chisq.test(contingency_table, simulate.p.value = TRUE, B = 9999)
print(chi_test)

# Save results
chi_results <- data.frame(
  test = "Chi-square",
  statistic = chi_test$statistic,
  df = chi_test$parameter,
  p_value = chi_test$p.value,
  significant = chi_test$p.value < 0.05
)

write.csv(chi_results, "output/tables/chi_square_health_dbh.csv", row.names = FALSE)


# Extract standardized residuals for plotting
std_res <- chi_test$stdres
df_res <- as.data.frame(as.table(std_res))
colnames(df_res) <- c("DBH", "Health", "StdResid")
df_obs <- as.data.frame(as.table(contingency_table))
colnames(df_obs) <- c("DBH", "Health", "Observed")

df_res <- left_join(df_res, df_obs, by = c("DBH", "Health"))

if (chi_test$p.value < 0.05) {
  cat("\n✓ SIGNIFICANT: Health state distribution differs across DBH categories (p < 0.05)\n")

  # Post-hoc: Calculate standardized residuals to identify which cells contribute most
  cat("\nStandardized Residuals (cells with |residual| > 2 are noteworthy):\n")
  std_residuals <- chi_test$stdres
  print(round(std_residuals, 2))
  cat("\n")

} else {
  cat("\n✗ NOT SIGNIFICANT: Health state distribution does not differ across DBH categories\n\n")
  residual_plot_data <- NULL
}

# -----------------------------------------------------------------------------
# 3. CREATE PLOTS
# -----------------------------------------------------------------------------
cat("\nCreating plots...\n")

# Calculate total counts per DBH category for labels
n_per_category <- fraxinus_health %>%
  group_by(DBH) %>%
  summarise(n = n(), .groups = "drop")

# Main health state plot with statistical letters (if available) and residual symbols
p_health <- plot_fraxinus_health(fraxinus_health, n_data = n_per_category)

# Save plot
ggsave("output/figures/fraxinus_health_by_dbh.png",
       p_health, width = 6, height = 3, dpi = 300)

cat("✓ Plot saved to output/figures/fraxinus_health_by_dbh.png\n")

# Display plot
print(p_health)

# Create heatmap of standardized residuals
residual_plot_data <- df_res %>%
  rename(std_residual = StdResid) %>%
  mutate(DBH = factor(DBH,
                      levels = c("0-0.9", "1-2.4", "2.5-4.9", "5-9.9",
                                 "10-20", "21-30", "31-40", "41+"),
                      ordered = TRUE))

p_heatmap <- ggplot(residual_plot_data, aes(x = DBH, y = Health, fill = std_residual)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.2f", std_residual)),
            color = "black", size = 3) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                       midpoint = 0,
                       limits = c(-max(abs(residual_plot_data$std_residual)),
                                  max(abs(residual_plot_data$std_residual))),
                       name = "Standardized\nResidual") +
  labs(title = "Standardized Residuals Heatmap",
       subtitle = "Chi-square test of Health State vs DBH Category",
       x = "DBH Category",
       y = "Health State") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Save heatmap
ggsave("output/figures/fraxinus_residuals_heatmap.png",
       p_heatmap, width = 10, height = 6, dpi = 300)

cat("✓ Heatmap saved to output/figures/fraxinus_residuals_heatmap.png\n")

# Display heatmap
print(p_heatmap)

cat("\n=== FRAXINUS HEALTH ANALYSIS COMPLETE ===\n")

