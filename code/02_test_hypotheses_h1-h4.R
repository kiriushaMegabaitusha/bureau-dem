#!/usr/bin/env Rscript
# Test Hypotheses H1-H4: Democracy-Bureaucracy Relationship
# Fixed effects panel regression analysis
# 
# H1: Democratic transition accelerates bureaucratization (+)
# H2: Democracy duration associates with higher bureaucratization (+)
# H3: Democracy level associates with higher bureaucratization (+)
# H4: Democratic consolidation stabilizes bureaucratization

# Load required packages ----
library(tidyverse)
library(plm)        # Panel data models
library(lmtest)     # Coefficient tests
library(sandwich)   # Robust standard errors

# Configuration ----
# REPLICATION PACKAGE: paths relative to code/ directory
DATA_DIR <- "../data/processed"
OUTPUT_TABLES <- "../output/tables"
OUTPUT_FIGURES <- "../output/figures"

dir.create(OUTPUT_TABLES, showWarnings = FALSE, recursive = TRUE)
dir.create(OUTPUT_FIGURES, showWarnings = FALSE, recursive = TRUE)

cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("HYPOTHESES TESTING / H1-H4 DEMOCRACY-BUREAUCRACY ANALYSIS\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

# Step 1: Load master dataset ----
cat("Step 1: Loading master dataset...\n")

data_path <- file.path(DATA_DIR, "master_panel.RData")
load(data_path)

cat(sprintf("  Loaded: %d observations, %d countries (%d-%d)\n",
            nrow(df_master),
            n_distinct(df_master$country_code),
            min(df_master$year),
            max(df_master$year)))

# Step 2: Convert to panel format ----
cat("\nStep 2: Converting to panel format...\n")

# Create panel data frame
df_panel <- df_master %>%
  select(
    country_code,
    year,
    bureaucratization_index,
    democratic_transition,
    democracy_duration_log,
    v2x_polyarchy,
    democracy_stability_interaction,
    colonial_legacy,
    region_latin_america,
    region_eastern_europe,
    region_africa,
    region_asia
  ) %>%
  drop_na(bureaucratization_index)

# Convert to pdata.frame for plm
panel_data <- pdata.frame(df_panel, index = c("country_code", "year"))

cat(sprintf("  Panel data: %d observations, %d countries\n",
            nrow(panel_data),
            n_distinct(panel_data$country_code)))

# Step 3: Descriptive statistics ----
cat("\nStep 3: Computing descriptive statistics...\n")

descriptive_stats <- df_panel %>%
  summarise(
    N = n(),
    Mean = mean(bureaucratization_index, na.rm = TRUE),
    SD = sd(bureaucratization_index, na.rm = TRUE),
    Min = min(bureaucratization_index, na.rm = TRUE),
    Max = max(bureaucratization_index, na.rm = TRUE),
    Median = median(bureaucratization_index, na.rm = TRUE)
  )

cat(sprintf("  Bureaucratization Index: Mean=%.3f, SD=%.3f, Range=[%.3f, %.3f]\n",
            descriptive_stats$Mean,
            descriptive_stats$SD,
            descriptive_stats$Min,
            descriptive_stats$Max))

# Step 4: Test H1 - Democratic Transition Effect ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("H1: DEMOCRATIC TRANSITION EFFECT\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Model: bureaucratization ~ democratic_transition + controls + FE\n")

# H1 Model 1: Bivariate
h1_m1 <- plm(
  bureaucratization_index ~ democratic_transition,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# H1 Model 2: With controls
h1_m2 <- plm(
  bureaucratization_index ~ democratic_transition + colonial_legacy +
    region_latin_america + region_eastern_europe + region_africa + region_asia,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# Cluster-robust standard errors
h1_m2_robust <- coeftest(h1_m2, vcov = vcovHC(h1_m2, type = "HC1", cluster = "group"))

cat("\nH1 Results:\n")
cat(sprintf("  Model 1 (Bivariate): β=%.3f, SE=%.3f, p<%.3f\n",
            coef(h1_m1)["democratic_transition"],
            sqrt(vcovHC(h1_m1)["democratic_transition", "democratic_transition"]),
            summary(h1_m1)$coefficients["democratic_transition", "Pr(>|t|)"]))

cat(sprintf("  Model 2 (Controls): β=%.3f, SE=%.3f, p<%.3f\n",
            h1_m2_robust["democratic_transition", "Estimate"],
            h1_m2_robust["democratic_transition", "Std. Error"],
            h1_m2_robust["democratic_transition", "Pr(>|t|)"]))

# Interpretation
h1_supported <- h1_m2_robust["democratic_transition", "Estimate"] > 0 &&
                h1_m2_robust["democratic_transition", "Pr(>|t|)"] < 0.05

cat(sprintf("\n  Hypothesis H1: %s\n",
            ifelse(h1_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗")))

# Step 5: Test H2 - Democracy Duration Effect ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("H2: DEMOCRACY DURATION EFFECT (DIMINISHING RETURNS)\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Model: bureaucratization ~ democracy_duration_log + controls + FE\n")

# H2 Model 1: Bivariate
h2_m1 <- plm(
  bureaucratization_index ~ democracy_duration_log,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# H2 Model 2: With controls
h2_m2 <- plm(
  bureaucratization_index ~ democracy_duration_log + colonial_legacy +
    region_latin_america + region_eastern_europe + region_africa + region_asia,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# Cluster-robust standard errors
h2_m2_robust <- coeftest(h2_m2, vcov = vcovHC(h2_m2, type = "HC1", cluster = "group"))

cat("\nH2 Results:\n")
cat(sprintf("  Model 1 (Bivariate): β=%.3f, SE=%.3f, p<%.3f\n",
            coef(h2_m1)["democracy_duration_log"],
            sqrt(vcovHC(h2_m1)["democracy_duration_log", "democracy_duration_log"]),
            summary(h2_m1)$coefficients["democracy_duration_log", "Pr(>|t|)"]))

cat(sprintf("  Model 2 (Controls): β=%.3f, SE=%.3f, p<%.3f\n",
            h2_m2_robust["democracy_duration_log", "Estimate"],
            h2_m2_robust["democracy_duration_log", "Std. Error"],
            h2_m2_robust["democracy_duration_log", "Pr(>|t|)"]))

# Interpretation
h2_supported <- h2_m2_robust["democracy_duration_log", "Estimate"] > 0 &&
                h2_m2_robust["democracy_duration_log", "Pr(>|t|)"] < 0.05

cat(sprintf("\n  Hypothesis H2: %s\n",
            ifelse(h2_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗")))

# Step 6: Test H3 - Democracy Level Effect ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("H3: DEMOCRACY LEVEL EFFECT (CONTINUOUS)\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Model: bureaucratization ~ v2x_polyarchy + controls + FE\n")

# H3 Model 1: Bivariate
h3_m1 <- plm(
  bureaucratization_index ~ v2x_polyarchy,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# H3 Model 2: With controls
h3_m2 <- plm(
  bureaucratization_index ~ v2x_polyarchy + colonial_legacy +
    region_latin_america + region_eastern_europe + region_africa + region_asia,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# Cluster-robust standard errors
h3_m2_robust <- coeftest(h3_m2, vcov = vcovHC(h3_m2, type = "HC1", cluster = "group"))

cat("\nH3 Results:\n")
cat(sprintf("  Model 1 (Bivariate): β=%.3f, SE=%.3f, p<%.3f\n",
            coef(h3_m1)["v2x_polyarchy"],
            sqrt(vcovHC(h3_m1)["v2x_polyarchy", "v2x_polyarchy"]),
            summary(h3_m1)$coefficients["v2x_polyarchy", "Pr(>|t|)"]))

cat(sprintf("  Model 2 (Controls): β=%.3f, SE=%.3f, p<%.3f\n",
            h3_m2_robust["v2x_polyarchy", "Estimate"],
            h3_m2_robust["v2x_polyarchy", "Std. Error"],
            h3_m2_robust["v2x_polyarchy", "Pr(>|t|)"]))

# Interpretation
h3_supported <- h3_m2_robust["v2x_polyarchy", "Estimate"] > 0 &&
                h3_m2_robust["v2x_polyarchy", "Pr(>|t|)"] < 0.05

cat(sprintf("\n  Hypothesis H3: %s\n",
            ifelse(h3_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗")))

# Step 7: Test H4 - Democratic Consolidation Effect ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("H4: DEMOCRATIC CONSOLIDATION (STABILITY) EFFECT\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Model: bureaucratization ~ democracy_stability_interaction + controls + FE\n")

# H4 Model 1: Bivariate
h4_m1 <- plm(
  bureaucratization_index ~ democracy_stability_interaction,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# H4 Model 2: With controls
h4_m2 <- plm(
  bureaucratization_index ~ democracy_stability_interaction + colonial_legacy +
    region_latin_america + region_eastern_europe + region_africa + region_asia,
  data = panel_data,
  model = "within",
  effect = "twoways",
  index = c("country_code", "year")
)

# Cluster-robust standard errors
h4_m2_robust <- coeftest(h4_m2, vcov = vcovHC(h4_m2, type = "HC1", cluster = "group"))

cat("\nH4 Results:\n")
cat(sprintf("  Model 1 (Bivariate): β=%.3f, SE=%.3f, p<%.3f\n",
            coef(h4_m1)["democracy_stability_interaction"],
            sqrt(vcovHC(h4_m1)["democracy_stability_interaction", "democracy_stability_interaction"]),
            summary(h4_m1)$coefficients["democracy_stability_interaction", "Pr(>|t|)"]))

cat(sprintf("  Model 2 (Controls): β=%.3f, SE=%.3f, p<%.3f\n",
            h4_m2_robust["democracy_stability_interaction", "Estimate"],
            h4_m2_robust["democracy_stability_interaction", "Std. Error"],
            h4_m2_robust["democracy_stability_interaction", "Pr(>|t|)"]))

# Interpretation
h4_supported <- h4_m2_robust["democracy_stability_interaction", "Estimate"] > 0 &&
                h4_m2_robust["democracy_stability_interaction", "Pr(>|t|)"] < 0.05

cat(sprintf("\n  Hypothesis H4: %s\n",
            ifelse(h4_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗")))

# Step 8: Export regression tables ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("EXPORTING REGRESSION TABLES\n")
cat(rep("=", 70), "\n\n", sep = "")

# Create comprehensive regression table
library(stargazer)

# Prepare models for export
models_list <- list(h1_m2, h2_m2, h3_m2, h4_m2)
model_names <- c("H1: Transition", "H2: Duration", "H3: Level", "H4: Consolidation")

# Export to text file
table_path <- file.path(OUTPUT_TABLES, "regression_table_h1-h4.txt")
stargazer(
  models_list,
  type = "text",
  title = "Democracy-Bureaucracy Relationship: Testing H1-H4",
  dep.var.labels = "Bureaucratization Index",
  covariate.labels = c(
    "Democratic transition",
    "Democracy duration (log)",
    "Democracy level (polyarchy)",
    "Democracy × Stability",
    "Colonial legacy",
    "Latin America",
    "Eastern Europe",
    "Africa",
    "Asia"
  ),
  out = table_path,
  keep.stat = c("n", "adj.rsq"),
  notes.append = TRUE,
  notes = c("Fixed effects: Country + Year",
            "Standard errors clustered by country in parentheses",
            "*p<0.1; **p<0.05; ***p<0.01")
)

cat(sprintf("  ✓ Saved: %s\n", table_path))

# Export to CSV (for easier integration)
csv_path <- file.path(OUTPUT_TABLES, "regression_results.csv")

# Extract coefficients and standard errors
results_df <- tibble(
  hypothesis = c("H1", "H2", "H3", "H4"),
  variable = c("democratic_transition", "democracy_duration_log", 
               "v2x_polyarchy", "democracy_stability_interaction"),
  coefficient = c(
    h1_m2_robust["democratic_transition", "Estimate"],
    h2_m2_robust["democracy_duration_log", "Estimate"],
    h3_m2_robust["v2x_polyarchy", "Estimate"],
    h4_m2_robust["democracy_stability_interaction", "Estimate"]
  ),
  std_error = c(
    h1_m2_robust["democratic_transition", "Std. Error"],
    h2_m2_robust["democracy_duration_log", "Std. Error"],
    h3_m2_robust["v2x_polyarchy", "Std. Error"],
    h4_m2_robust["democracy_stability_interaction", "Std. Error"]
  ),
  p_value = c(
    h1_m2_robust["democratic_transition", "Pr(>|t|)"],
    h2_m2_robust["democracy_duration_log", "Pr(>|t|)"],
    h3_m2_robust["v2x_polyarchy", "Pr(>|t|)"],
    h4_m2_robust["democracy_stability_interaction", "Pr(>|t|)"]
  ),
  supported = c(h1_supported, h2_supported, h3_supported, h4_supported)
)

write_csv(results_df, csv_path)
cat(sprintf("  ✓ Saved: %s\n", csv_path))

# Step 9: Summary ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("ANALYSIS SUMMARY\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Hypothesis Support:\n")
cat(sprintf("  H1 (Democratic transition): %s (β=%.3f, p=%.3f)\n",
            ifelse(h1_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗"),
            h1_m2_robust["democratic_transition", "Estimate"],
            h1_m2_robust["democratic_transition", "Pr(>|t|)"]))

cat(sprintf("  H2 (Democracy duration): %s (β=%.3f, p=%.3f)\n",
            ifelse(h2_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗"),
            h2_m2_robust["democracy_duration_log", "Estimate"],
            h2_m2_robust["democracy_duration_log", "Pr(>|t|)"]))

cat(sprintf("  H3 (Democracy level): %s (β=%.3f, p=%.3f)\n",
            ifelse(h3_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗"),
            h3_m2_robust["v2x_polyarchy", "Estimate"],
            h3_m2_robust["v2x_polyarchy", "Pr(>|t|)"]))

cat(sprintf("  H4 (Democratic consolidation): %s (β=%.3f, p=%.3f)\n",
            ifelse(h4_supported, "SUPPORTED ✓", "NOT SUPPORTED ✗"),
            h4_m2_robust["democracy_stability_interaction", "Estimate"],
            h4_m2_robust["democracy_stability_interaction", "Pr(>|t|)"]))

cat("\nModel Fit:\n")
cat(sprintf("  H1 Model: R²=%.3f, N=%d\n",
            summary(h1_m2)$r.squared["within"],
            nobs(h1_m2)))
cat(sprintf("  H2 Model: R²=%.3f, N=%d\n",
            summary(h2_m2)$r.squared["within"],
            nobs(h2_m2)))
cat(sprintf("  H3 Model: R²=%.3f, N=%d\n",
            summary(h3_m2)$r.squared["within"],
            nobs(h3_m2)))
cat(sprintf("  H4 Model: R²=%.3f, N=%d\n",
            summary(h4_m2)$r.squared["within"],
            nobs(h4_m2)))

cat("\n", rep("=", 70), "\n", sep = "")
cat("ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n\n", sep = "")
