@echo off
REM Master Analysis Runner (Windows)
REM From Weber to the World: Tracing Bureaucratic Homogenization Over Time
REM
REM This script executes the complete analysis pipeline:
REM 1. Create master dataset
REM 2. Test hypotheses H1-H4
REM 3. Run robustness checks
REM 4. Generate all figures

echo ======================================================================
echo REPLICATION PACKAGE: DEMOCRACY-BUREAUCRACY ANALYSIS
echo ======================================================================
echo.
echo Starting analysis pipeline at %DATE% %TIME%
echo.

REM Check R installation
where Rscript >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Rscript not found. Please install R version 4.5.0 or higher.
    echo Download from: https://cran.r-project.org/
    exit /b 1
)

echo R version check:
Rscript --version
echo.

REM Check/install required packages
echo Checking required R packages...
Rscript -e "packages <- c('tidyverse', 'plm', 'lmtest', 'sandwich', 'countrycode', 'stargazer'); missing <- packages[!sapply(packages, requireNamespace, quietly = TRUE)]; if (length(missing) > 0) { cat('Installing missing packages:', paste(missing, collapse = ', '), '\n'); install.packages(missing, repos = 'https://cloud.r-project.org') }; cat('All required packages available.\n')"
echo.

REM Create output directories
echo Creating output directories...
if not exist "output\tables" mkdir "output\tables"
if not exist "output\figures" mkdir "output\figures"
if not exist "logs" mkdir "logs"
echo.

REM Step 1: Create master dataset
echo ======================================================================
echo STEP 1: Creating Master Dataset
echo ======================================================================
Rscript code\01_create_master_dataset.R > logs\01_master_dataset.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Step 1 failed. Check logs\01_master_dataset.log
    exit /b 1
)
echo.

REM Step 2: Test hypotheses
echo ======================================================================
echo STEP 2: Testing Hypotheses H1-H4
echo ======================================================================
Rscript code\02_test_hypotheses_h1-h4.R > logs\02_hypothesis_tests.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Step 2 failed. Check logs\02_hypothesis_tests.log
    exit /b 1
)
echo.

REM Step 3: Robustness checks
echo ======================================================================
echo STEP 3: Running Robustness Checks
echo ======================================================================
Rscript code\03_robustness_checks.R > logs\03_robustness.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Step 3 failed. Check logs\03_robustness.log
    exit /b 1
)
echo.

REM Step 4: Create figures
echo ======================================================================
echo STEP 4: Generating Figures
echo ======================================================================
Rscript code\04_create_all_figures.R > logs\04_figures.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Step 4 failed. Check logs\04_figures.log
    exit /b 1
)
echo.

echo ======================================================================
echo ANALYSIS COMPLETE
echo ======================================================================
echo.
echo Completed at %DATE% %TIME%
echo.
echo Output files:
echo   Data:     data\master_panel.csv
echo   Tables:   output\tables\
echo   Figures:  output\figures\
echo   Logs:     logs\
echo.
echo To verify results, check:
echo   - output\tables\regression_table_h1-h4.txt
echo   - output\tables\robustness_table_h1-h4.txt
echo.
pause
