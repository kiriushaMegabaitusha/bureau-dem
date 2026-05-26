#!/usr/bin/env Rscript
# Create Master Analysis Dataset
# Combines V-Dem bureaucratization, democracy variables, and controls
# For testing H1-H4: Democracy-Bureaucracy relationship (1940-2024)
#
# REPLICATION PACKAGE VERSION
# Uses paths relative to replication package root

# Load required packages ----
library(tidyverse)
library(countrycode)

# Configuration ----
# For replication: data is in ../data/raw/ (if raw V-Dem is provided)
# Output goes to ../data/processed/
DATA_DIR <- "../data"
OUTPUT_DIR <- "../data/processed"
START_YEAR <- 1940
END_YEAR <- 2024

dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

cat("=" %>% rep(70) %>% paste(collapse = ""), "\n")
cat("CREATE MASTER DATASET / DEMOCRACY-BUREAUCRACY ANALYSIS\n")
cat("=" %>% rep(70) %>% paste(collapse = ""), "\n\n")

# Step 1: Load V-Dem bureaucratization data ----
cat("Step 1: Loading V-Dem bureaucratization data...\n")

# Note: For replication, use pre-processed bureaucratization data
# If raw data is provided, uncomment and adjust paths below
# bureau_path <- file.path(DATA_DIR, "raw/preprocessed/vdem_bureaucratization_index_final.csv")
# df_bureau <- read_csv(bureau_path, show_col_types = FALSE)

# For replication package: check if master data already exists
if (file.exists("../data/master_panel.RData")) {
  cat("  Using pre-processed master panel (skip data creation)\n")
  cat("  To recreate from raw data, place V-Dem data in ../data/raw/\n")
  quit(save = "no", status = 0)
}

# If you have raw V-Dem data, place it in: ../data/raw/V-Dem-CY-Core-v15_rds/
bureau_path <- file.path(DATA_DIR, "raw/preprocessed/vdem_bureaucratization_index_final.csv")
if (!file.exists(bureau_path)) {
  cat("  Raw data not found. Please place V-Dem data in ../data/raw/\n")
  cat("  Or use the pre-processed master_panel.RData file.\n")
  quit(save = "no", status = 0)
}

df_bureau <- read_csv(bureau_path, show_col_types = FALSE)

cat(sprintf("  Loaded: %d observations, %d countries (%d-%d)\n",
            nrow(df_bureau),
            n_distinct(df_bureau$country_code),
            min(df_bureau$year),
            max(df_bureau$year)))

# Step 2: Load V-Dem Core for democracy variables ----
cat("\nStep 2: Loading V-Dem Core for democracy variables...\n")

vdem_path <- file.path(DATA_DIR, "raw/V-Dem-CY-Core-v15_rds/V-Dem-CY-Core-v15.rds")
df_vdem <- readRDS(vdem_path)

cat(sprintf("  Loaded V-Dem Core: %d observations\n", nrow(df_vdem)))

# Extract democracy variables
df_democracy <- df_vdem %>%
  select(
    country_name,
    country_code = country_text_id,
    year,
    v2x_polyarchy,      # Continuous democracy (0-1)
    v2x_regime          # Regime type (1=autocracy, 2=electoral, 3=liberal)
  )

cat(sprintf("  Democracy variables: %d observations\n", nrow(df_democracy)))

# Step 3: Create democracy independent variables ----
cat("\nStep 3: Creating democracy IVs (transition, duration, stability)...\n")

df_democracy <- df_democracy %>%
  arrange(country_code, year) %>%
  group_by(country_code) %>%
  mutate(
    # Binary democracy (polyarchy >= 0.5)
    democracy_binary = if_else(v2x_polyarchy >= 0.5, 1, 0),
    
    # Democratic transition (0→1 change)
    democracy_lag = lag(democracy_binary, default = first(democracy_binary)),
    democratic_transition = if_else(democracy_binary == 1 & democracy_lag == 0, 1, 0),
    
    # Years since transition (for H2)
    years_since_transition = cumsum(democratic_transition),
    years_since_transition = if_else(democracy_binary == 0, 0, years_since_transition),
    
    # Log-transformed duration (diminishing returns)
    democracy_duration_log = log1p(years_since_transition),
    
    # Regime stability (consecutive years in same regime)
    regime_change = if_else(v2x_regime != lag(v2x_regime, default = first(v2x_regime)), 1, 0),
    regime_stability = cumsum(1 - regime_change),
    
    # Democratic consolidation (democracy × stability interaction for H4)
    democracy_stability_interaction = democracy_binary * log1p(regime_stability)
  ) %>%
  ungroup() %>%
  select(
    country_code,
    year,
    v2x_polyarchy,
    v2x_regime,
    democracy_binary,
    democratic_transition,
    years_since_transition,
    democracy_duration_log,
    regime_stability,
    democracy_stability_interaction
  )

# Check transition counts
transition_count <- df_democracy %>%
  filter(democratic_transition == 1) %>%
  nrow()

cat(sprintf("  Created IVs: %d democratic transitions identified\n", transition_count))

# Step 4: Merge bureaucratization with democracy ----
cat("\nStep 4: Merging bureaucratization with democracy variables...\n")

df_merged <- df_bureau %>%
  inner_join(df_democracy, by = c("country_code", "year"))

cat(sprintf("  Merged: %d observations (%d countries)\n",
            nrow(df_merged),
            n_distinct(df_merged$country_code)))

# Step 5: Add control variables ----
cat("\nStep 5: Adding control variables...\n")

# GDP per capita from V-Dem (check if available)
if ("v2x_gdpcap" %in% names(df_vdem)) {
  df_merged <- df_merged %>%
    left_join(
      df_vdem %>% select(country_code, year, v2x_gdpcap),
      by = c("country_code", "year")
    ) %>%
    mutate(
      gdppc_log = log(v2x_gdpcap + 1)  # Log GDP per capita
    )
  cat("  ✓ Added GDP per capita (log)\n")
} else {
  cat("  ✗ GDP per capita not available in V-Dem Core - will use external data\n")
  df_merged$gdppc_log <- NA
}

# Regional dummies using countrycode package
df_merged <- df_merged %>%
  mutate(
    region = countrycode(country_code, "iso3c", "region", warn = FALSE),
    
    # Create regional dummies (using standard region codes)
    region_oecd = if_else(country_code %in% c("USA", "CAN", "GBR", "DEU", "FRA", "ITA", "ESP", "PRT", "NLD", "BEL", "LUX", "AUT", "CHE", "SWE", "NOR", "DNK", "FIN", "ISL", "IRL", "GRC", "TUR", "POL", "CZE", "SVK", "HUN", "SVN", "EST", "LVA", "LTU", "MLT", "CYP", "JPN", "KOR", "AUS", "NZL", "MEX", "CHL", "ISR"), 1, 0),
    region_latin_america = if_else(region == "Latin America & Caribbean", 1, 0),
    region_eastern_europe = if_else(region == "Eastern Europe & Central Asia", 1, 0),
    region_africa = if_else(region %in% c("Sub-Saharan Africa", "Middle East & North Africa"), 1, 0),
    region_asia = if_else(region %in% c("East Asia & Pacific", "South Asia"), 1, 0),
    
    # Colonial legacy (simplified: non-OECD = former colony proxy)
    colonial_legacy = if_else(region_oecd == 0, 1, 0)
  )

cat("  ✓ Added regional dummies\n")
cat("  ✓ Added colonial legacy proxy\n")

# Step 6: Filter to analysis period (1940-2024) ----
cat("\nStep 6: Filtering to analysis period (1940-2024)...\n")

df_master <- df_merged %>%
  filter(year >= START_YEAR & year <= END_YEAR)

cat(sprintf("  Final sample: %d observations, %d countries (%d-%d)\n",
            nrow(df_master),
            n_distinct(df_master$country_code),
            min(df_master$year),
            max(df_master$year)))

# Step 7: Select final variables ----
cat("\nStep 7: Selecting final variables...\n")

df_master <- df_master %>%
  select(
    # Identifiers
    country_name,
    country_code,
    year,
    
    # Dependent variable
    bureaucratization_index,
    
    # Independent variables (H1-H4)
    democratic_transition,      # H1
    democracy_duration_log,     # H2
    v2x_polyarchy,              # H3 (continuous)
    democracy_stability_interaction,  # H4
    
    # Control variables
    gdppc_log,
    colonial_legacy,
    region_oecd,
    region_latin_america,
    region_eastern_europe,
    region_africa,
    region_asia
  )

# Step 8: Summary statistics ----
cat("\n", rep("=", 70), "\n", sep = "")
cat("MASTER DATASET SUMMARY\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("Sample Coverage:\n")
cat(sprintf("  Total observations: %d\n", nrow(df_master)))
cat(sprintf("  Countries: %d\n", n_distinct(df_master$country_code)))
cat(sprintf("  Time period: %d-%d (%d years)\n",
            min(df_master$year),
            max(df_master$year),
            max(df_master$year) - min(df_master$year) + 1))
cat(sprintf("  Panel type: Unbalanced\n\n"))

cat("Variable Coverage:\n")
coverage <- df_master %>%
  summarise(
    across(
      where(is.numeric),
      ~ sprintf("%.1f%%", 100 * mean(!is.na(.)))
    )
  ) %>%
  pivot_longer(everything())

for (i in seq_len(nrow(coverage))) {
  cat(sprintf("  %-40s %s\n", coverage$name[i], coverage$value[i]))
}

cat("\nDescriptive Statistics (Bureaucratization Index):\n")
bureau_stats <- df_master %>%
  summarise(
    mean = mean(bureaucratization_index, na.rm = TRUE),
    sd = sd(bureaucratization_index, na.rm = TRUE),
    min = min(bureaucratization_index, na.rm = TRUE),
    max = max(bureaucratization_index, na.rm = TRUE),
    median = median(bureaucratization_index, na.rm = TRUE)
  )

cat(sprintf("  Mean: %.3f (SD: %.3f)\n", bureau_stats$mean, bureau_stats$sd))
cat(sprintf("  Range: [%.3f, %.3f]\n", bureau_stats$min, bureau_stats$max))
cat(sprintf("  Median: %.3f\n\n", bureau_stats$median))

# Step 9: Save master dataset ----
cat("Step 8: Saving master dataset...\n")

output_path <- file.path(OUTPUT_DIR, "master_panel.csv")
write_csv(df_master, output_path)
cat(sprintf("  ✓ Saved: %s\n", output_path))

# Save RData for faster loading in analysis scripts
output_rdata <- file.path(OUTPUT_DIR, "master_panel.RData")
save(df_master, file = output_rdata)
cat(sprintf("  ✓ Saved: %s\n", output_rdata))

# Save codebook
codebook_path <- file.path(OUTPUT_DIR, "master_panel_codebook.txt")
write_lines(
  c(
    "MASTER PANEL DATASET - CODEBOOK",
    "==================================",
    "",
    paste("Generated:", Sys.Date()),
    paste("Observations:", nrow(df_master)),
    paste("Countries:", n_distinct(df_master$country_code)),
    paste("Time period:", START_YEAR, "-", END_YEAR),
    "",
    "VARIABLES",
    "---------",
    "",
    "DEPENDENT VARIABLE",
    "  bureaucratization_index (numeric, 0-1)",
    "    Mean of 5 V-Dem Core components:",
    "    - Rigorous and impartial administration",
    "    - Transparent laws",
    "    - Rule of law",
    "    - Access to justice",
    "    - Absence of corruption",
    "",
    "INDEPENDENT VARIABLES (H1-H4)",
    "  democratic_transition (binary, 0/1)",
    "    H1: Democratic transition accelerates bureaucratization",
    "    Coded 1 when polyarchy crosses 0.5 threshold from below",
    "",
    "  democracy_duration_log (numeric)",
    "    H2: Longer democracy duration → higher bureaucratization",
    "    Log-transformed years since democratic transition",
    "",
    "  v2x_polyarchy (continuous, 0-1)",
    "    H3: Higher democracy level → higher bureaucratization",
    "    V-Dem polyarchy index (continuous measure)",
    "",
    "  democracy_stability_interaction (numeric)",
    "    H4: Democratic consolidation stabilizes bureaucratization",
    "    Interaction: democracy_binary × log(regime_stability)",
    "",
    "CONTROL VARIABLES",
    "  gdppc_log (numeric)",
    "    Log GDP per capita (2017 USD)",
    "",
    "  colonial_legacy (binary, 0/1)",
    "    Proxy: non-OECD membership",
    "",
    "  region_* (binary, 0/1)",
    "    Regional dummies (OECD, Latin America, Eastern Europe,",
    "    Africa, Asia)",
    "",
    "THEORETICAL FRAMEWORK",
    "---------------------",
    "H1: Democratic transition → accelerated bureaucratization (+)",
    "H2: Democracy duration → higher bureaucratization (+)",
    "H3: Democracy level → higher bureaucratization (+)",
    "H4: Democratic consolidation → stabilized bureaucratization",
    "",
    "METHODOLOGY",
    "-----------",
    "Primary model: Fixed effects regression (country + year FE)",
    "Standard errors: Clustered by country",
    ""
  ),
  codebook_path
)
cat(sprintf("  ✓ Saved: %s\n", codebook_path))

cat("\n", rep("=", 70), "\n", sep = "")
cat("MASTER DATASET CREATION COMPLETE\n")
cat(rep("=", 70), "\n\n", sep = "")
