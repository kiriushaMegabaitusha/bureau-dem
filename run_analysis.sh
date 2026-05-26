#!/bin/bash
# Master Analysis Runner
# From Weber to the World: Tracing Bureaucratic Homogenization Over Time
# 
# This script executes the complete analysis pipeline:
# 1. Create master dataset
# 2. Test hypotheses H1-H4
# 3. Run robustness checks
# 4. Generate all figures

set -e  # Exit on error

echo "======================================================================"
echo "REPLICATION PACKAGE: DEMOCRACY-BUREAUCRACY ANALYSIS"
echo "======================================================================"
echo ""
echo "Starting analysis pipeline at $(date)"
echo ""

# Check R installation
if ! command -v Rscript &> /dev/null; then
    echo "ERROR: Rscript not found. Please install R version 4.5.0 or higher."
    exit 1
fi

echo "R version check:"
Rscript --version
echo ""

# Check/install required packages
echo "Checking required R packages..."
Rscript -e "
packages <- c('tidyverse', 'plm', 'lmtest', 'sandwich', 'countrycode', 'stargazer')
missing <- packages[!sapply(packages, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  cat('Installing missing packages:', paste(missing, collapse = ', '), '\n')
  install.packages(missing, repos = 'https://cloud.r-project.org')
}
cat('All required packages available.\n')
"
echo ""

# Create output directories
echo "Creating output directories..."
mkdir -p output/tables
mkdir -p output/figures
echo ""

# Step 1: Create master dataset
echo "======================================================================"
echo "STEP 1: Creating Master Dataset"
echo "======================================================================"
Rscript code/01_create_master_dataset.R 2>&1 | tee logs/01_master_dataset.log
echo ""

# Step 2: Test hypotheses
echo "======================================================================"
echo "STEP 2: Testing Hypotheses H1-H4"
echo "======================================================================"
Rscript code/02_test_hypotheses_h1-h4.R 2>&1 | tee logs/02_hypothesis_tests.log
echo ""

# Step 3: Robustness checks
echo "======================================================================"
echo "STEP 3: Running Robustness Checks"
echo "======================================================================"
Rscript code/03_robustness_checks.R 2>&1 | tee logs/03_robustness.log
echo ""

# Step 4: Create figures
echo "======================================================================"
echo "STEP 4: Generating Figures"
echo "======================================================================"
Rscript code/04_create_all_figures.R 2>&1 | tee logs/04_figures.log
echo ""

echo "======================================================================"
echo "ANALYSIS COMPLETE"
echo "======================================================================"
echo ""
echo "Completed at $(date)"
echo ""
echo "Output files:"
echo "  Data:     data/master_panel.csv"
echo "  Tables:   output/tables/"
echo "  Figures:  output/figures/"
echo "  Logs:     logs/"
echo ""
echo "To verify results, check:"
echo "  - output/tables/regression_table_h1-h4.txt"
echo "  - output/tables/robustness_table_h1-h4.txt"
echo ""
