# Determinants of Blank and Null Votes in the Brazilian Presidential Elections

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Statistical modeling of blank and null votes in the 2018 Brazilian presidential election using GAMLSS unit regression models.

This repository contains the codes, data, and figures associated with the research project **"Determinants of Blank and Null Votes in the Brazilian Presidential Elections"**, published in Stats (ISSN 2571-905X) and submitted in 2025. The study analyzes the socioeconomic and regional factors influencing the proportion of blank and null votes across Brazilian municipalities in the 2018 presidential election, using unit regression models within the GAMLSS framework.

## 📂 Project Structure

```
sec-project/
├── codes/
│   ├── modeling-project.R
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
- **Main Result:** The beta regression model with varying dispersion (non-constant sigma) showed the best overall performance according to AIC, BIC, R², and forecast error metrics.

## 🛠️ How to Reproduce

1. Clone this repository:
   ```bash
   git clone https://github.com/ryanxnovaes/sec-project.git
   ```

2. Open the `sec-proj.Rproj` file in **RStudio**.

3. Run the scripts in the following order:
   - `modeling-project.R` (Fixed-effects modeling)

4. Make sure to load the custom distributions by sourcing:
   - `KUMA_reg.R`
   - `RUBXII_reg.R`
   - `UW_reg.R`

## 📄 Data Description

The primary dataset `brazil_election2018.xlsx` was assembled from publicly available sources:
- **Atlas of Human Development in Brazil** (MHDI indicators)
- **Brazilian Institute of Geography and Statistics (IBGE)** (demographic data)
- **IPEADATA** (election-related statistics)

> The file `votesBrazil_2018.xlsx` was not used in the final analysis.

### Main Variables

| Variable                  | Source   | Description                                    |
| ------------------------- | -------- | ---------------------------------------------- |
| Acronym                   | -        | State abbreviation                             |
| Code                      | IBGE     | Municipality code                              |
| Municipality              | IBGE     | Municipality name                              |
| WVF, WVS                  | IPEADATA | Blank votes (1st/2nd rounds)                   |
| NVF, NVS                  | IPEADATA | Null votes (1st/2nd rounds)                    |
| VVF, VVS                  | IPEADATA | Valid votes (1st/2nd rounds)                   |
| MHDI\_I, MHDI\_H, MHDI\_E | ATLAS    | MHDI by Income, Health, and Education          |
| Capital                   | -        | Indicator of state capital                     |
| Region                    | -        | Region (North, Northeast, etc.)                |
| DD                        | IBGE     | Population density                             |
| PBNVF                     | -        | Prop. of blank/null votes (1st round)          |
| PBNVS                     | -        | Prop. of blank/null votes (2nd round - target) |

## 📈 Figures and Diagnostics

Visualizations and model diagnostics are available in the `figures/` folder:
- **grafico_pbnvs.pdf:** Histogram and boxplot of PBNVS
- **boxplots-sbs.pdf:** Boxplots of PBNVS by region and capital
- **residuals.pdf:** Histogram and QQ-plot of residuals for the final model
- **wormplots_1.pdf** and **wormplots_2.pdf:** Partial effects of covariates on dispersion parameter

## 🔧 Custom Distributions

This project uses extended unit distributions from:

* **[UnitDistsForGAMLSS](https://github.com/renata-rojasg/UnitDistForGAMLSS)**

Please cite this repository if you reuse the code:

```bibtex
@misc{Guerra2025,
  author = {Guerra, Renata Rojas},
  title = {UnitDistForGAMLSS},
  year = {2025},
  note = {Available online: \url{https://github.com/renata-rojasg/UnitDistForGAMLSS}, DOI: \href{https://doi.org/10.6084/m9.figshare.25328575.v2}{10.6084/m9.figshare.25328575.v2}}
}
```
## 📚 Citation

If you use this material, please cite:

```bibtex
@article{guerra2025determinants,
  title={Determinants of Blank and Null Votes in the Brazilian Presidential Elections},
  author={Guerra, Renata Rojas and Moraes, Kerolene S. and Moreira Junior, Fernando J. and Pe\~na-Ram\'irez, Fernando A. and Pereira, Ryan N.},
  journal={Stats},
  year={2025}
}
```
## 🙏 Acknowledgments

This work was supported by **FAPESP** (Grant No. **2024/18409-7**) through the program:

> *ABC - Brazilian Academy of Sciences / [EVC](https://fapesp.br/vocacoes2024) - Scientific Vocations Stimulus Scholarship0 (2024/2025)*

We thank **Prof. Renata Rojas Guerra** and **Prof. Fernando A. Peña-Ramírez** for their valuable support.

## 📬 Contact

For questions, suggestions, or collaboration proposals, please contact:

**Ryan Novaes Pereira**  
📧 Email: [ryan.novaes@unesp.br](mailto:ryan.novaes@unesp.br)

---