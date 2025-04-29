# Determinants of Blank and Null Votes in the Brazilian Presidential Elections

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Statistical modeling of blank and null votes in the 2018 Brazilian presidential election using GAMLSS unit regression models.

This repository contains the codes, data, and figures associated with the research project **"Determinants of Blank and Null Votes in the Brazilian Presidential Elections"**, submitted for publication in 2025. The study analyzes the socioeconomic and regional factors influencing the proportion of blank and null votes across Brazilian municipalities in the 2018 presidential election, using unit regression models within the GAMLSS framework.

## 📂 Project Structure

```
sec-project/
├── codes/
│   ├── KUMA_reg.R
│   ├── RUBXII_reg.R
│   ├── UW_reg.R
│   ├── modeling-project.R
│   ├── random-effects-modeling.R
│   └── sec-proj.Rproj
│
├── data/
│   └── brazil_election2018.xlsx
│
├── figures/
│   ├── boxplots-sbs.pdf
│   ├── grafico_pbnvs.pdf
│   ├── residuals.pdf
│   ├── wormplots_1.pdf
│   ├── wormplots_2.pdf
│
├── .gitignore
└── README.md
```

## 📊 Project Overview

- **Objective:** Identify the determinants of the proportion of blank and null votes (PBNVS) in the second round of the 2018 Brazilian presidential election.
- **Methodology:** Fit GAMLSS models using five different unit distributions:
  - Beta
  - Simplex
  - Kumaraswamy (Kuma)
  - Unit Weibull (UW)
  - Reflected Unit Burr XII (RUBXII)
- **Data:** Proportions of blank and null votes, disaggregated Municipal Human Development Index (MHDI) dimensions (income, health, education), demographic density, capital indicator, and region.
- **Main Result:** The beta regression model with varying dispersion (non-constant sigma) showed the best overall performance according to AIC, BIC, R², and forecast error metrics.

## 🛠️ How to Reproduce

1. Clone this repository:
   ```bash
   git clone https://github.com/ryanxnovaes/sec-project.git
   ```

2. Open the `sec-proj.Rproj` file in **RStudio**.

3. Run the scripts in the following order:
   - `modeling-project.R` (Fixed-effects modeling)
   - `random-effects-modeling.R` (Random-effects modeling)

4. Make sure to load the custom distributions by sourcing:
   - `KUMA_reg.R`
   - `RUBXII_reg.R`
   - `UW_reg.R`

> **Note:** Although random effects were explored, some distributions (e.g., Unit Weibull, Kumaraswamy, and RUBXII) lack established bibliography for mixed-effects modeling, thus random effects were not fully included for all distributions.

## 📄 Data Description

The primary dataset `brazil_election2018.xlsx` was assembled from publicly available sources:
- **Atlas of Human Development in Brazil** (MHDI indicators)
- **Brazilian Institute of Geography and Statistics (IBGE)** (demographic data)
- **IPEADATA** (election-related statistics)

> The file `votesBrazil_2018.xlsx` was not used in the final analysis.

### Main Variables

| Variable | Source | Description |
|:---|:---|:---|
| Acronym | - | State abbreviation |
| Code | IBGE_SIDRA | Municipality code |
| Municipality | IBGE_SIDRA | Municipality name |
| WVF | IPEADATA | Blank votes, first round |
| WVS | IPEADATA | Blank votes, second round |
| NVF | IPEADATA | Null votes, first round |
| NVS | IPEADATA | Null votes, second round |
| VVF | IPEADATA | Valid votes, first round |
| VVS | IPEADATA | Valid votes, second round |
| MHDI_I | ATLAS | Municipal Human Development Index (Income) |
| MHDI_H | ATLAS | Municipal Human Development Index (Health) |
| MHDI_E | ATLAS | Municipal Human Development Index (Education) |
| Capital | - | Indicator whether the municipality is a state capital |
| Region | - | Brazilian region (North, Northeast, Central-West, Southeast, South) |
| DD | IBGE_SIDRA | Population density |
| PBNVF | - | Proportion of blank and null votes (first round) |
| PBNVS | - | Proportion of blank and null votes (second round - dependent variable) |

## 📈 Figures and Diagnostics

Visualizations and model diagnostics are available in the `figures/` folder:
- **grafico_pbnvs.pdf:** Histogram and boxplot of PBNVS
- **boxplots-sbs.pdf:** Boxplots of PBNVS by region and capital
- **residuals.pdf:** Histogram and QQ-plot of residuals for the final model
- **wormplots_1.pdf** and **wormplots_2.pdf:** Partial effects of covariates on dispersion parameter

## 📚 Citation

Guerra, R. R.; Moraes, K. S.; Junior, F. J. M.; Peña-Ramírez, F. A.; Pereira, R. N. (2025).  
**Determinants of Blank and Null Votes in the Brazilian Presidential Elections.**  
Manuscript submitted for publication. Preprint available upon request.

If you use this material, please cite our work.

## 🙏 Acknowledgments

This project was supported by the São Paulo Research Foundation (FAPESP) through the program  
**"ABC - Brazilian Academy of Sciences / EVC - Scientific Vocations Stimulus Scholarship (2024/2025)"**,  
under the call for proposals [FAPESP Vocations 2024](https://fapesp.br/vocacoes2024).

Grant Number: **2024/18409-7**.

We gratefully acknowledge FAPESP for their financial support and encouragement of scientific research.

Special thanks to **Professor Renata Rojas Guerra** and **Professor Fernando Arturo Peña-Ramírez**  
for their valuable guidance, encouragement, and insightful discussions throughout the development of this project.

## 📬 Contact

For questions, suggestions, or collaboration proposals, please contact:

**Ryan Novaes Pereira**  
📧 Email: [ryan.novaes@unesp.br](mailto:ryan.novaes@unesp.br)

---