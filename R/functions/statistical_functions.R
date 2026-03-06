# =============================================================================
# Statistical Testing Functions
# =============================================================================

#' Test Temporal Change (Auto-selects parametric or non-parametric)
#'
#' Internal function used by test_top_species
test_temporal_change <- function(x, test_type = "auto", mu = 0,
                                 alternative = "two.sided", conf.level = 0.95) {

  # Remove NAs
  x <- x[!is.na(x)]

  # Auto-detect test type based on normality
  if (test_type == "auto") {
    if (length(x) < 3) {
      warning("Sample size too small for testing")
      return(list(test = "none", p.value = NA, is_normal = NA))
    }

    # Shapiro-Wilk test for normality
    if (length(x) >= 3 && length(x) <= 5000) {
      shapiro_test <- shapiro.test(x)
      is_normal <- shapiro_test$p.value > 0.05
    } else {
      is_normal <- FALSE
    }

    test_type <- ifelse(is_normal, "t.test", "sign")
  } else {
    is_normal <- NA
  }

  # Perform test
  if (test_type == "t.test") {
    result <- t.test(x, mu = mu, alternative = alternative, conf.level = conf.level)
    output <- list(
      test = "t.test",
      statistic = result$statistic,
      p.value = result$p.value,
      conf.int = result$conf.int,
      is_normal = is_normal
    )
  } else if (test_type == "sign") {
    result <- BSDA::SIGN.test(x, md = mu, alternative = alternative, conf.level = conf.level)
    output <- list(
      test = "sign",
      statistic = result$statistic,
      p.value = result$p.value,
      conf.int = result$conf.int,
      is_normal = is_normal
    )
  } else {
    stop("test_type must be 'auto', 't.test', or 'sign'")
  }

  return(output)
}


#' Test Top Species Changes
#'
#' Tests for significant changes in species abundance between 2011 and 2023
#' Only tests species present in at least min_prevalence of sites
test_top_species <- function(species_totals, data_2011, data_2023,
                             min_prevalence = 0.05, test_type = "auto") {

  # Align datasets by common sites
  common_sites <- intersect(data_2011$sitesCode, data_2023$sitesCode)
  n_sites <- length(common_sites)

  # Filter species present in at least min_prevalence of sites
  species_list <- setdiff(names(data_2011), "sitesCode")

  top_species <- character()
  for (sp in species_list) {
    if (sp %in% names(data_2011) && sp %in% names(data_2023)) {
      # Count sites where species is present (> 0) in either year
      n_present <- sum(data_2011[[sp]][data_2011$sitesCode %in% common_sites] > 0 |
                       data_2023[[sp]][data_2023$sitesCode %in% common_sites] > 0)
      prevalence <- n_present / n_sites

      if (prevalence >= min_prevalence) {
        top_species <- c(top_species, sp)
      }
    }
  }

  cat("Selected", length(top_species), "species present in >=", min_prevalence * 100, "% of sites\n")

  # Ensure species columns exist in both datasets
  for (sp in top_species) {
    if (!sp %in% names(data_2011)) data_2011[[sp]] <- 0
    if (!sp %in% names(data_2023)) data_2023[[sp]] <- 0
  }

  # Align datasets by common sites
  common_sites <- intersect(data_2011$sitesCode, data_2023$sitesCode)
  data_2011 <- data_2011[data_2011$sitesCode %in% common_sites, ]
  data_2023 <- data_2023[data_2023$sitesCode %in% common_sites, ]

  # Sort by sitesCode to ensure alignment
  data_2011 <- data_2011[order(data_2011$sitesCode), ]
  data_2023 <- data_2023[order(data_2023$sitesCode), ]

  # Test each species
  results <- data.frame(
    species = character(),
    test_used = character(),
    p_value = numeric(),
    significant = logical(),
    stringsAsFactors = FALSE
  )

  for (sp in top_species) {
    delta <- data_2023[[sp]] - data_2011[[sp]]
    test_result <- test_temporal_change(delta, test_type = test_type)

    results <- rbind(results, data.frame(
      species = sp,
      test_used = test_result$test,
      p_value = test_result$p.value,
      significant = test_result$p.value < 0.05,
      stringsAsFactors = FALSE
    ))
  }

  return(results)
}

#' Calculate Species Totals
#'
#' Calculate total counts for each species across all sites in 2011 and 2023
calculate_species_totals <- function(data_2011, data_2023,
                                     exclude_cols = c("sitesCode", "Status", "patchID", "patchPosition", "Year")) {

  # Get species columns
  species_2011 <- setdiff(names(data_2011), exclude_cols)
  species_2023 <- setdiff(names(data_2023), exclude_cols)
  all_species <- union(species_2011, species_2023)

  # Calculate totals
  totals <- data.frame(
    SpCodes = all_species,
    Count_2011 = sapply(all_species, function(sp) {
      if (sp %in% species_2011) sum(data_2011[[sp]], na.rm = TRUE) else 0
    }),
    Count_2023 = sapply(all_species, function(sp) {
      if (sp %in% species_2023) sum(data_2023[[sp]], na.rm = TRUE) else 0
    })
  )

  # Calculate difference
  totals$Delta <- totals$Count_2023 - totals$Count_2011

  # Sort by species code
  totals <- totals %>% arrange(SpCodes)

  return(totals)
}
