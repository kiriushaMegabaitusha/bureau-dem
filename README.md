# Replication Package

## From Weber to the World: Tracing Bureaucratic Homogenization Over Time

**Author:** Kyrylo Yasuda  
**Program:** Master of Public Policy (MPPG26), Kyiv School of Economics  
**Date:** 2026  

---

## Overview

This replication package contains all data, code, and documentation needed to reproduce the analysis and figures from the master's thesis examining the democracy-bureaucracy relationship across 183 countries from 1940 to 2024.

**Research Question:** Does democratic transition accelerate bureaucratization?

**Key Findings:** All four hypotheses are strongly supported (p < 0.001):
- **H1:** Democratic transitions produce immediate bureaucratization gains (β = 0.057)
- **H2:** Sustained democracy deepens bureaucratization with diminishing returns (β = 0.178)
- **H3:** Democracy level is the strongest predictor (β = 0.511, R² = 0.429)
- **H4:** Democratic consolidation stabilizes bureaucratic development (β = 0.033)

---

## Package Contents

```
replication/
├── README.md                 # This file
├── CITATION.md               # Citation information
├── LICENSE.md                # License terms
├── run_analysis.sh           # Master script (Unix/Mac)
├── run_analysis.bat          # Master script (Windows)
├── code/
│   ├── 01_create_master_dataset.R    # Data preparation
│   ├── 02_test_hypotheses_h1-h4.R    # Main analysis
│   ├── 03_robustness_checks.R        # Robustness tests
│   └── 04_create_all_figures.R       # Figure generation
├── data/
│   ├── master_panel.csv              # Clean analysis dataset
│   ├── master_panel.RData            # R data file
│   └── master_panel_codebook.txt     # Variable documentation
├── output/
│   ├── tables/                       # Regression tables
│   │   ├── regression_table_h1-h4.txt
│   │   └── regression_results.csv
│   └── figures/                      # All 6 figures (300 DPI PNG)
│       ├── fig1_bureaucratization_trends.png
│       ├── fig2_coefficient_plot.png
│       ├── fig3_regional_comparison.png
│       ├── fig4_democracy_bureaucracy_scatter.png
│       ├── fig5_consolidation_interaction.png
│       └── fig6_subsample_comparison.png
└── docs/
    └── replication_guide.md          # Detailed replication instructions
```

---

## System Requirements

### Software
- **R** version 4.5.0 or higher
- **R packages:** tidyverse, plm, lmtest, sandwich, countrycode, stargazer

### Hardware
- **RAM:** 4GB minimum (8GB recommended)
- **Disk space:** ~500MB for data and outputs
- **OS:** Windows, macOS, or Linux

---

## Quick Start

### Option 1: Automated (Recommended)

**Windows:**
```batch
run_analysis.bat
```

**macOS/Linux:**
```bash
chmod +x run_analysis.sh
./run_analysis.sh
```

This script will:
1. Install required R packages (if missing)
2. Create the master dataset
3. Run all hypothesis tests (H1-H4)
4. Conduct robustness checks
5. Generate all 6 figures
6. Export regression tables

### Option 2: Manual Execution

Run each script in order:

```bash
# Step 1: Create master dataset
Rscript code/01_create_master_dataset.R

# Step 2: Test hypotheses H1-H4
Rscript code/02_test_hypotheses_h1-h4.R

# Step 3: Run robustness checks
Rscript code/03_robustness_checks.R

# Step 4: Create all figures
Rscript code/04_create_all_figures.R
```

---

## Data Sources

### Primary Data
The analysis uses **V-Dem Core v15** (Varieties of Democracy) as the primary data source:

| Variable | V-Dem Code | Description | Range |
|----------|------------|-------------|-------|
| Bureaucratization Index | Constructed | Mean of 5 components | 0-1 |
| Polyarchy | v2x_polyarchy | Electoral democracy index | 0-1 |
| Regime Type | v2x_regime | Regime classification | 1-3 |

**Bureaucratization Index Components:**
1. `v2clrspct` - Rigorous and impartial administration
2. `v2cltrnslw` - Transparent laws
3. `v2clrlaw` - Rule of law
4. `v2clacjst` - Access to justice
5. `v2clcrpt` - Absence of corruption

### Data Access
V-Dem data is publicly available at: https://www.v-dem.net/data/

**Citation:**  
Coppedge, M., Gerring, J., Knutsen, C. H., et al. (2025). "V-Dem Dataset v15." Varieties of Democracy (V-Dem) Project.

---

## Reproduction Steps

### Step 1: Data Preparation

**Input:** V-Dem Core v15 (`.rds` format)  
**Output:** `data/master_panel.csv` (13,971 observations)

The script:
- Loads V-Dem Core v15 data
- Extracts bureaucratization components (5 variables)
- Constructs democracy variables (transition, duration, level)
- Creates control variables (colonial legacy, regional dummies)
- Merges into unbalanced panel (1940-2024, 183 countries)
- Handles missing values (2.5% imputed via linear interpolation)

**Expected output:**
```
  ✓ Saved: data/master_panel.csv
  ✓ Saved: data/master_panel.RData
  ✓ Saved: data/master_panel_codebook.txt
```

### Step 2: Hypothesis Testing

**Input:** `data/master_panel.RData`  
**Output:** Regression tables in `output/tables/`

Four fixed effects models estimated:

| Model | Hypothesis | Key Variable | Expected Sign |
|-------|------------|--------------|---------------|
| H1 | Transition | `democratic_transition` | + |
| H2 | Duration | `democracy_duration_log` | + |
| H3 | Level | `v2x_polyarchy` | + |
| H4 | Consolidation | `democracy × stability` | + |

**Method:** Fixed effects regression with country and year fixed effects, clustered standard errors (HC1)

**Expected output:**
```
H1: β = 0.057, SE = 0.008, p < 0.001
H2: β = 0.178, SE = 0.022, p < 0.001
H3: β = 0.511, SE = 0.028, p < 0.001
H4: β = 0.033, SE = 0.005, p < 0.001
```

### Step 3: Robustness Checks

**Input:** `data/master_panel.RData`  
**Output:** `output/tables/robustness_table_h1-h4.txt`

Five subsamples tested:
1. OECD countries (n ≈ 1,500)
2. Non-OECD countries (n ≈ 10,000)
3. Post-1990 observations (n ≈ 4,500)
4. European countries (n ≈ 2,000)
5. Full sample (baseline)

**Total models:** 20 (4 hypotheses × 5 subsamples)

### Step 4: Figure Generation

**Input:** `data/master_panel.RData` + regression results  
**Output:** 6 PNG files in `output/figures/` (300 DPI)

| Figure | Description | Chapter |
|--------|-------------|---------|
| 1 | Bureaucratization trends (1940-2024) | Results |
| 2 | Coefficient plot (H1-H4) | Results |
| 3 | Regional comparison | Results |
| 4 | Democracy-bureaucracy scatterplot | Results |
| 5 | Consolidation interaction | Discussion |
| 6 | Subsample comparison | Discussion |

---

## File Descriptions

### R Scripts

| Script | Lines | Purpose |
|--------|-------|---------|
| `01_create_master_dataset.R` | 322 | Data preparation and merging |
| `02_test_hypotheses_h1-h4.R` | 394 | Main regression analysis |
| `03_robustness_checks.R` | ~350 | Subsample analyses |
| `04_create_all_figures.R` | 391 | Visualization generation |

### Data Files

| File | Size | Format | Description |
|------|------|--------|-------------|
| `master_panel.csv` | ~5MB | CSV | Clean analysis dataset |
| `master_panel.RData` | ~3MB | R binary | R data file |
| `master_panel_codebook.txt` | ~2KB | Text | Variable documentation |

### Output Tables

| File | Content |
|------|---------|
| `regression_table_h1-h4.txt` | Stargazer-formatted regression tables |
| `regression_results.csv` | Machine-readable results |
| `robustness_table_h1-h4.txt` | Subsample comparison tables |
| `robustness_results.csv` | Machine-readable robustness results |

---

## Expected Results

### Main Findings (Table 4.2-4.5)

| Hypothesis | Coefficient | Std. Error | p-value | R² |
|------------|-------------|------------|---------|----|
| H1: Transition | 0.057 | 0.008 | <0.001 | -0.016 |
| H2: Duration | 0.178 | 0.022 | <0.001 | 0.167 |
| H3: Level | 0.511 | 0.028 | <0.001 | 0.429 |
| H4: Consolidation | 0.033 | 0.005 | <0.001 | 0.155 |

### Robustness Summary (Table 5.1)

All hypotheses remain significant (p < 0.001) across:
- ✓ OECD subsample
- ✓ Non-OECD subsample
- ✓ Post-1990 subsample
- ✓ European subsample

**Total:** 20/20 models show expected sign and significance

---

## Troubleshooting

### Common Issues

**1. Missing R packages**
```r
install.packages(c('tidyverse', 'plm', 'lmtest', 'sandwich', 
                   'countrycode', 'stargazer'))
```

**2. Data file not found**
Ensure V-Dem Core v15 data is in the correct location:
```
03-methodology/thesis_calculations/data/raw/V-Dem-CY-Core-v15_rds/
```

**3. Path errors on Windows**
Use forward slashes (/) or double backslashes (\\) in paths:
```r
# Correct
DATA_DIR <- "data/processed"
# Also correct
DATA_DIR <- "data\\processed"
```

**4. Memory issues**
If running on limited RAM (<4GB), try processing in chunks:
```r
# Load only required columns
df <- read_csv("data/master_panel.csv", 
               col_select = c("country_code", "year", 
                             "bureaucratization_index", 
                             "democratic_transition"))
```

---

## Computational Reproducibility

### Runtime Estimates

| Script | Time | Memory |
|--------|------|--------|
| 01_create_master_dataset.R | ~30 seconds | ~500MB |
| 02_test_hypotheses_h1-h4.R | ~45 seconds | ~600MB |
| 03_robustness_checks.R | ~60 seconds | ~700MB |
| 04_create_all_figures.R | ~90 seconds | ~800MB |
| **Total** | **~4 minutes** | **~800MB** |

### Random Seeds

All analyses are deterministic (no stochastic elements). No random seed required.

### Software Versions

```
R version 4.5.3 (2026-03-01)
Platform: x86_64-pc-linux-gnu

Package versions:
- tidyverse: 2.0.0
- plm: 2.6-4
- lmtest: 0.9-40
- sandwich: 3.1-0
- countrycode: 1.6.0
- stargazer: 5.2.3
```

---

## Contact

**Corresponding Author:**  
Kiiokhiko-Kyrylo Yasuda  
Kyiv School of Economics  
Email: `kiriloasuda@gmail.com`

---

## License

- **Code:** MIT License (see LICENSE.md)
- **Data:** V-Dem data governed by V-Dem license
- **Documentation:** CC BY 4.0

---

## Citation

If you use this replication package, please cite:

```bibtex
@mastersthesis{yasuda2026weber,
  title = {From Weber to the World: Tracing Bureaucratic Homogenization Over Time},
  author = {Yasuda, Kiiokhiko-Kyrylo},
  school = {Kyiv School of Economics},
  year = {2026},
  type = {Master's Thesis},
}
```

---
