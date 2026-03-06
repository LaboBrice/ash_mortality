# =============================================================================
# Plotting Functions
# =============================================================================

#' Plot Fraxinus Health State by DBH
#'
#' Creates a stacked bar chart showing health state proportions across DBH categories
plot_fraxinus_health <- function(fraxinus_health, label_data = NULL, residual_data = NULL, n_data = NULL) {

  p <- ggplot(fraxinus_health, aes(x = DBH, fill = factor(Health))) +
    geom_bar(position = "fill") +
    scale_fill_manual(
      values = c("darkgreen", "springgreen", "yellow2", "sienna1", "red2", "red4"),
      labels = c("Healthy", "Light Decline", "Moderate Decline",
                 "Severe Decline", "Dead", "Dead with basal sprouts")
    ) +
    labs(
      title = NULL,
      x = "DBH (cm)",
      y = "Proportion",
      fill = "Health State"
    ) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.text = element_text(color = "black"),
      axis.text.x = element_text(margin = margin(t = -10))
    )

  # Add count labels at y = 0.25
  if (!is.null(n_data)) {
    n_data$y_position <- 0.25
    p <- p + geom_text(data = n_data,
                       aes(x = DBH, y = y_position, label = n),
                       inherit.aes = FALSE, size = 3, color = "white")
  }

  return(p)
}


#' Create Scatter Plot with 1:1 Line
#'
#' Creates a scatter plot comparing 2011 vs 2023 values with optional highlighting
plot_temporal_scatter <- function(data, x_col, y_col, label_col = NULL,
                                  highlight_species = NULL,
                                  x_label = "2011", y_label = "2023",
                                  title = NULL, x_limit = NULL, y_limit = NULL) {

  # Create shape column if highlighting
  if (!is.null(highlight_species) && !is.null(label_col)) {
    data$Shape <- ifelse(data[[label_col]] %in% highlight_species,
                         "Highlighted", "Normal")
  } else {
    data$Shape <- "Normal"
  }

  # Create color column based on significance
  if (!is.null(highlight_species) && !is.null(label_col)) {
    data$Color <- ifelse(data[[label_col]] %in% highlight_species, "black", "grey60")
  } else {
    data$Color <- "black"
  }

  p <- ggplot(data, aes(x = .data[[x_col]], y = .data[[y_col]])) +
    geom_point(aes(shape = Shape, color = Color), size = 2) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
    scale_shape_manual(values = c("Highlighted" = 17, "Normal" = 16)) +
    scale_color_identity() +
    labs(title = title, x = x_label, y = y_label) +
    theme_minimal() +
    theme(
      text = element_text(size = 10),
      legend.position = "none",
      panel.grid = element_blank(),
      axis.ticks = element_line(color = "black"),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 1)
    )

  # Add labels if provided (only for significant species)
  if (!is.null(label_col)) {
    if (!is.null(highlight_species)) {
      # Only label significant species
      label_data <- data %>% filter(.data[[label_col]] %in% highlight_species)
      p <- p + geom_text_repel(data = label_data, aes(label = .data[[label_col]]),
                               size = 3, max.overlaps = Inf,
                               box.padding = 0.5, point.padding = 0.2,
                               min.segment.length = 0.5, seed = 42)
    } else {
      # Label all if no highlight_species specified
      p <- p + geom_text_repel(aes(label = .data[[label_col]]),
                               size = 3, max.overlaps = Inf,
                               box.padding = 0.5, point.padding = 0.3,
                               min.segment.length = 0, seed = 42)
    }
  }

  # Set limits if provided
  if (!is.null(x_limit)) p <- p + xlim(0, x_limit)
  if (!is.null(y_limit)) p <- p + ylim(0, y_limit)

  return(p)
}
