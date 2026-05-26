# Replication Package Metadata

## Package Information

| Field | Value |
|-------|-------|
| **Title** | From Weber to the World: Tracing Bureaucratic Homogenization Over Time |
| **Author** | Kiiokhiko-Kyrylo Yasuda |
| **Institution** | Kyiv School of Economics |
| **Program** | Master of Public Policy (MPPG26) |
| **Advisor** | Dr. Anastasiia Vlasenko |
| **Year** | 2026 |
| **Version** | 1.0 |
| **Release Date** | 2026-03-29 |
| **DOI** | [PENDING] |
| **License** | MIT (code), V-Dem License (data) |

---

## Subject Classification

| System | Code | Description |
|--------|------|-------------|
| **JEL** | D73, H83, P16 | Bureaucracy, Public Administration, Democracy |
| **Keywords** | bureaucracy, democracy, Weber, fixed effects, V-Dem, panel data |

---

## Data Coverage

| Dimension | Value |
|-----------|-------|
| **Temporal Scope** | 1940-2024 (85 years) |
| **Geographic Scope** | 183 countries |
| **Observations** | 13,971 country-years |
| **Data Type** | Unbalanced panel |

---

## Variables

### Dependent Variable
- `bureaucratization_index` (0-1 scale) - Mean of 5 V-Dem components

### Independent Variables (H1-H4)
- `democratic_transition` (binary) - H1: Transition effect
- `democracy_duration_log` (continuous) - H2: Duration effect
- `v2x_polyarchy` (0-1) - H3: Level effect
- `democracy_stability_interaction` (continuous) - H4: Consolidation effect

### Control Variables
- `gdppc_log` - Log GDP per capita (absorbed by fixed effects)
- `colonial_legacy` (binary) - Non-OECD proxy
- `region_*` (binary) - Regional dummies

---

## Methods

| Component | Specification |
|-----------|---------------|
| **Primary Model** | Fixed Effects (country + year) |
| **Standard Errors** | Clustered by country (HC1) |
| **Estimation** | Within transformation (plm) |
| **Software** | R 4.5.3 |

---

## File Inventory

### Code (4 scripts, ~1,500 lines)
| File | Lines | Purpose |
|------|-------|---------|
| `01_create_master_dataset.R` | 346 | Data preparation |
| `02_test_hypotheses_h1-h4.R` | 395 | Main analysis |
| `03_robustness_checks.R` | 512 | Robustness tests |
| `04_create_all_figures.R` | 392 | Visualization |

### Data (3 files, ~8 MB)
| File | Size | Format |
|------|------|--------|
| `master_panel.csv` | 5 MB | CSV |
| `master_panel.RData` | 3 MB | R binary |
| `master_panel_codebook.txt` | 2 KB | Text |

### Output Tables (4 files)
| File | Content |
|------|---------|
| `regression_table_h1-h4.txt` | Stargazer tables |
| `regression_results.csv` | Machine-readable |
| `robustness_table_h1-h4.txt` | Subsample tables |
| `robustness_results.csv` | Machine-readable |

### Output Figures (6 files, ~3 MB)
| File | Dimensions | Description |
|------|------------|-------------|
| `fig1_bureaucratization_trends.png` | 3000x1800 | Time series |
| `fig2_coefficient_plot.png` | 3000x1800 | Dot-and-whisker |
| `fig3_regional_comparison.png` | 3000x1800 | Bar chart |
| `fig4_democracy_bureaucracy_scatter.png` | 3000x2100 | Density heatmap |
| `fig5_consolidation_interaction.png` | 3000x1800 | Interaction plot |
| `fig6_subsample_comparison.png` | 3000x1800 | Grouped bars |

### Documentation (5 files, ~50 KB)
| File | Purpose |
|------|---------|
| `README.md` | Quick start guide |
| `CITATION.md` | Citation formats |
| `LICENSE.md` | License terms |
| `docs/replication_guide.md` | Detailed instructions |
| `METADATA.md` | This file |

---

## Computational Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **RAM** | 4 GB | 8 GB |
| **CPU** | Dual-core | Quad-core |
| **Disk** | 500 MB | 1 GB |
| **Runtime** | ~4 minutes | ~2 minutes (SSD) |

---

## Software Environment

### R Version
```
R version 4.5.3 (2026-03-01)
Platform: x86_64-pc-linux-gnu
```

### Package Versions
```
tidyverse: 2.0.0
plm: 2.6-4
lmtest: 0.9-40
sandwich: 3.1-0
countrycode: 1.6.0
stargazer: 5.2.3
```

---

## Reproducibility Checklist

- [x] All code uses relative paths
- [x] All dependencies documented
- [x] Random seeds set (N/A - deterministic analysis)
- [x] Data availability confirmed
- [x] Output files included
- [x] Documentation complete
- [x] License specified
- [x] Citation information provided

---

## Contact Information

### Author
**Kiiokhiko-Kyrylo Yasuda**  
Kyiv School of Economics  
Email: [your-email@kse.ua]  
ORCID: [ORCID-PENDING]

### Advisor
**Dr. Anastasiia Vlasenko**  
Kyiv School of Economics  
Email: [advisor-email@kse.ua]

### Institution
**Kyiv School of Economics**  
Mykolytivska St, 7, Kyiv, Ukraine, 04070  
Website: https://kse.ua/

---

## Funding and Conflicts of Interest

**Funding:** None declared  
**Conflicts of Interest:** None declared

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-03-29 | Initial release |

---

## Archival Information

**Archive Location:** Harvard Dataverse / Zenodo  
**Archive DOI:** [PENDING]  
**Archive Date:** [PENDING]

**Retention Policy:** Permanent archival recommended

---

**Last Updated:** 2026-03-29  
**Package Status:** ✅ Complete and Ready for Distribution
