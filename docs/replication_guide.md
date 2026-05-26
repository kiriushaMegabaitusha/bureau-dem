# Replication Guide

## Detailed Instructions for Reproducing "From Weber to the World"

This guide provides step-by-step instructions for independent researchers who wish to replicate or extend the analysis in this thesis.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Data Acquisition](#data-acquisition)
4. [Running the Analysis](#running-the-analysis)
5. [Verifying Results](#verifying-results)
6. [Extending the Analysis](#extending-the-analysis)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 4 GB | 8 GB |
| **Disk Space** | 500 MB | 1 GB |
| **R Version** | 4.5.0 | 4.5.3+ |
| **OS** | Windows 10 / macOS 11 / Linux | Any modern OS |

### Required Software

1. **R** (version 4.5.0 or higher)
   - Download: https://cran.r-project.org/
   - Installation guide: https://cran.r-project.org/doc/manuals/r-release/R-admin.html

2. **RStudio** (optional, but recommended)
   - Download: https://posit.co/download/rstudio-desktop/

### Required R Packages

All packages are free and available on CRAN:

```r
install.packages(c(
  'tidyverse',    # Data manipulation and visualization
  'plm',          # Panel data econometrics
  'lmtest',       # Regression diagnostics
  'sandwich',     # Robust standard errors
  'countrycode',  # Country code conversion
  'stargazer'     # Publication-quality tables
))
```

---

## Installation

### Step 1: Download the Replication Package

**Option A: Download from Dataverse/Zenodo** (recommended)
```bash
# Replace with actual DOI once archived
wget https://doi.org/10.7910/DVN/[PENDING]/replication-package.zip
unzip replication-package.zip
cd replication
```

**Option B: Clone from GitHub** (if available)
```bash
git clone https://github.com/[username]/weber-to-world-replication.git
cd weber-to-world-replication/replication
```

**Option C: Use existing files** (if you have the thesis files)
```bash
# The replication package is in the /replication directory
cd /path/to/thesis/replication
```

### Step 2: Verify Directory Structure

Your directory should look like this:

```
replication/
├── README.md
├── CITATION.md
├── LICENSE.md
├── run_analysis.sh (or run_analysis.bat for Windows)
├── code/
│   ├── 01_create_master_dataset.R
│   ├── 02_test_hypotheses_h1-h4.R
│   ├── 03_robustness_checks.R
│   └── 04_create_all_figures.R
├── data/
│   ├── master_panel.csv
│   ├── master_panel.RData
│   └── master_panel_codebook.txt
├── output/
│   ├── tables/
│   └── figures/
├── logs/
└── docs/
    └── replication_guide.md
```

---

## Data Acquisition

### V-Dem Data (Required for Full Replication)

If you want to recreate the master dataset from scratch:

1. **Register for V-Dem access**
   - Go to: https://www.v-dem.net/data/
   - Click "Download Data"
   - Create a free account
   - Accept the terms of use

2. **Download V-Dem Core v15**
   - Select "V-Dem Core v15" dataset
   - Download the `.rds` format (Country-Year)
   - File size: ~50 MB

3. **Place data in correct location**
   ```
   replication/
   └── data/
       └── raw/
           └── V-Dem-CY-Core-v15_rds/
               └── V-Dem-CY-Core-v15.rds
   ```

### Pre-Processed Data (Quick Start)

The replication package includes pre-processed data:
- `data/master_panel.csv` - Clean analysis dataset (13,971 observations)
- `data/master_panel.RData` - R binary format
- `data/master_panel_codebook.txt` - Variable documentation

**Note:** You can run all analyses using the pre-processed data without downloading V-Dem.

---

## Running the Analysis

### Option 1: Automated Script (Recommended)

**Linux/macOS:**
```bash
cd replication
chmod +x run_analysis.sh
./run_analysis.sh
```

**Windows:**
```batch
cd replication
run_analysis.bat
```

The script will:
1. Check R installation
2. Install missing packages
3. Run all 4 analysis scripts in order
4. Save logs to `logs/` directory
5. Display progress and completion status

**Expected runtime:** ~4 minutes

### Option 2: Manual Execution

Run each script individually:

```bash
# Step 1: Create master dataset (if you have raw V-Dem data)
Rscript code/01_create_master_dataset.R

# Step 2: Test main hypotheses H1-H4
Rscript code/02_test_hypotheses_h1-h4.R

# Step 3: Run robustness checks
Rscript code/03_robustness_checks.R

# Step 4: Generate all figures
Rscript code/04_create_all_figures.R
```

### Option 3: RStudio

1. Open RStudio
2. Set working directory: `Session > Set Working Directory > Choose...`
3. Open each `.R` script and click "Run" or press `Ctrl+Shift+S`

---

## Verifying Results

### Main Results (H1-H4)

After running `02_test_hypotheses_h1-h4.R`, check:

**File:** `output/tables/regression_table_h1-h4.txt`

Expected coefficients:

| Hypothesis | Variable | Coefficient | Std. Error | p-value |
|------------|----------|-------------|------------|---------|
| H1 | Democratic transition | 0.057 | 0.008 | <0.001 |
| H2 | Democracy duration (log) | 0.178 | 0.022 | <0.001 |
| H3 | Democracy level (polyarchy) | 0.511 | 0.028 | <0.001 |
| H4 | Democratic consolidation | 0.033 | 0.005 | <0.001 |

**Verification command:**
```bash
grep "democratic_transition" output/tables/regression_table_h1-h4.txt
# Should show: 0.057***
```

### Robustness Results

After running `03_robustness_checks.R`, check:

**File:** `output/tables/robustness_table_h1-h4.txt`

Expected: All 20 models (4 hypotheses × 5 subsamples) should show:
- Positive coefficients (matching H1-H4 predictions)
- Statistical significance (p < 0.05 or better)

### Figures

After running `04_create_all_figures.R`, verify:

**Directory:** `output/figures/`

| File | Size | Description |
|------|------|-------------|
| `fig1_bureaucratization_trends.png` | ~500 KB | Time series 1940-2024 |
| `fig2_coefficient_plot.png` | ~300 KB | Dot-and-whisker plot |
| `fig3_regional_comparison.png` | ~400 KB | Regional bar chart |
| `fig4_democracy_bureaucracy_scatter.png` | ~600 KB | 2D density heatmap |
| `fig5_consolidation_interaction.png` | ~350 KB | Interaction plot |
| `fig6_subsample_comparison.png` | ~400 KB | Grouped bar chart |

**Visual check:** All figures should have:
- Clear titles and axis labels
- 300 DPI resolution (publication quality)
- Consistent color scheme (blue, pink, gray)

---

## Extending the Analysis

### Adding New Variables

To add control variables (e.g., GDP from external sources):

1. **Prepare your data:**
   ```r
   # Create a CSV with country_code, year, and your variable
   new_data <- read_csv("path/to/your/data.csv")
   ```

2. **Modify `01_create_master_dataset.R`:**
   ```r
   # Add after loading master data
   df_master <- df_master %>%
     left_join(new_data, by = c("country_code", "year"))
   ```

3. **Update regression models in `02_test_hypotheses_h1-h4.R`:**
   ```r
   model_h1 <- plm(
     bureaucratization_index ~ democratic_transition + gdppc_log + 
       your_new_variable + region_dummies,
     data = panel_data,
     model = "within",
     effect = "twoways"
   )
   ```

### Alternative Specifications

**Random Effects instead of Fixed Effects:**
```r
# In 02_test_hypotheses_h1-h4.R, change:
model <- plm(..., model = "random")  # instead of "within"

# Then run Hausman test:
phtest(model_fe, model_re)
```

**Alternative Democracy Measures:**
```r
# Replace v2x_polyarchy with:
# - v2x_polyarchy (electoral democracy)
# - v2x_libdem (liberal democracy)
# - v2x_partip (participatory democracy)
# - v2x_delib (deliberative democracy)
# - v2x_egali (egalitarian democracy)
```

### Subsample Analysis

To analyze a specific region:

```r
# In 03_robustness_checks.R, add:
df_europe <- df_master %>%
  filter(region_europe == 1)

# Then run regressions on df_europe
```

---

## Troubleshooting

### Common Errors and Solutions

#### Error: "Package 'plm' not found"

**Solution:**
```r
install.packages('plm', repos = 'https://cloud.r-project.org')
```

#### Error: "File not found: data/master_panel.RData"

**Cause:** Data file is missing or path is incorrect.

**Solution:**
1. Check if file exists: `ls data/`
2. Verify working directory: `getwd()` in R
3. Use absolute paths if needed

#### Error: "Error in readRDS: cannot open file"

**Cause:** V-Dem data file is missing or corrupted.

**Solution:**
1. Re-download V-Dem data from https://www.v-dem.net/
2. Verify file path matches script expectation
3. Check file permissions

#### Error: "Non-stationary panel" warning

**Note:** This is expected for long panels (1940-2024). Fixed effects absorb time-invariant heterogeneity.

**Solution:** No action needed. Results are robust with FE.

#### Error: "Singular fit" or "Perfect multicollinearity"

**Cause:** Too many fixed effects or collinear variables.

**Solution:**
```r
# Check for collinearity
library(car)
vif(model)

# Remove collinear variables or use fewer fixed effects
```

### Performance Issues

**Slow execution (>10 minutes):**
- Close other applications
- Increase RAM allocation
- Use pre-processed data instead of raw V-Dem

**Memory errors:**
```r
# In R, increase memory limit (Windows only)
memory.limit(size = 8000)  # 8 GB

# Or process in chunks
library(data.table)
df <- fread("data/master_panel.csv", select = c("country_code", "year", "key_variables"))
```

---

## Contact and Support

### Getting Help

1. **Check this guide first** - Most issues are documented above
2. **Review logs** - `logs/` directory contains detailed output
3. **Contact author** - See CITATION.md for contact information

### Reporting Issues

When reporting problems, include:
- R version (`R --version`)
- OS and version
- Error message (full text)
- Which script failed
- Steps to reproduce

---

## Checklist for Successful Replication

- [ ] R version 4.5.0+ installed
- [ ] All required packages installed
- [ ] Replication package downloaded and extracted
- [ ] Working directory set to `replication/`
- [ ] Data files present in `data/` directory
- [ ] Run script executed without errors
- [ ] Output tables match expected coefficients
- [ ] All 6 figures generated successfully
- [ ] Logs saved for reference

---

**Last Updated:** 2026-03-29  
**Guide Version:** 1.0  
**Tested On:** R 4.5.3, Ubuntu 24.04
