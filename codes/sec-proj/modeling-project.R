# ------------------------------------------------------------------------------
# Created by: Kerolene De Souza Moraes
# Edited, improved, and revised by: Ryan Novaes Pereira
# Date: March 2025
# ------------------------------------------------------------------------------

# ==============================================================================
# Load Required Libraries
# ==============================================================================

library(readxl)
library(dplyr)
library(gamlss)
library(mlr)
library(forecast)
library(psych)
library(stats)

# ==============================================================================
# Load and Prepare the Dataset
# ==============================================================================

data <- readxl::read_xlsx("../../data/brazil_election2018.xlsx")

# Create proportions of blank and null votes
data <- data |>
  mutate(
    PBNVF = (WVF + NVF) / (WVF + NVF + VVF),
    PBNVS = (WVS + NVS) / (WVS + NVS + VVS)
  )

# ==============================================================================
# Descriptive Statistics
# ==============================================================================

desc <- describe(data[,-c(1:9, 13:14)])
desc$CV = (desc$sd / desc$mean) * 100
desc[, c(3, 5, 11, 12, 8, 9, 14)]

# Region frequency table
f <- as.matrix(table(data$Region))
total <- sum(f[,1])
f1 <- rbind(f, total)
fr <- c(round((f[,1]/sum(f[,1]))*100,2), sum(round((f[,1]/sum(f[,1]))*100,2)))
tabela <- cbind(f1, fr)
colnames(tabela) <- c("Absolute Frequency", "Relative Frequency (%)")
print(tabela)

# Capital frequency table
fre <- as.matrix(table(data$Capital))
total <- sum(fre[,1])
fre1 <- rbind(fre, total)
fr1 <- c(round((fre[,1]/sum(f[,1]))*100,2), sum(round((fre[,1]/sum(f[,1]))*100,2)))
tabela <- cbind(fre1, fr1)
colnames(tabela) <- c("Absolute Frequency", "Relative Frequency (%)")
print(tabela)

# ==============================================================================
# Descriptive Statistics by Region for PBNVS
# ==============================================================================

# Calculate the median of PBNVS by Region
data %>%
  group_by(Region) %>%
  summarize(mediana_PBNVS = median(PBNVS, na.rm = TRUE))

# Calculate detailed descriptive statistics of PBNVS by Region
data %>%
  group_by(Region) %>%
  summarize(
    count = n(),                                # Number of observations
    mean_PBNVS = mean(PBNVS, na.rm = TRUE),      # Mean
    median_PBNVS = median(PBNVS, na.rm = TRUE),  # Median
    sd_PBNVS = sd(PBNVS, na.rm = TRUE),          # Standard deviation
    min_PBNVS = min(PBNVS, na.rm = TRUE),        # Minimum value
    max_PBNVS = max(PBNVS, na.rm = TRUE),        # Maximum value
    quantile_25 = quantile(PBNVS, 0.25, na.rm = TRUE),  # 1st quartile (25%)
    quantile_75 = quantile(PBNVS, 0.75, na.rm = TRUE)   # 3rd quartile (75%)
  )

# ==============================================================================
# Spearman Correlation Analysis for Continuous Variables
# ==============================================================================

# Define continuous variables to be analyzed
variaveis_continuas <- c("PBNVS", "PBNVF", "MHDI_I", "MHDI_H", "MHDI_E", "DD")

# Initialize empty matrices to store Spearman correlation coefficients and p-values
correlacoes_spearman <- matrix(NA, nrow = length(variaveis_continuas), ncol = length(variaveis_continuas),
                               dimnames = list(variaveis_continuas, variaveis_continuas))
pvalores_spearman <- matrix(NA, nrow = length(variaveis_continuas), ncol = length(variaveis_continuas),
                            dimnames = list(variaveis_continuas, variaveis_continuas))

# Loop to calculate pairwise Spearman correlations and corresponding p-values
for (i in 1:length(variaveis_continuas)) {
  for (j in i:length(variaveis_continuas)) {
    cor_resultado <- cor.test(datafix[[variaveis_continuas[i]]], datafix[[variaveis_continuas[j]]], 
                              method = "spearman", exact = FALSE)
    
    correlacoes_spearman[i, j] <- cor_resultado$estimate  # Save correlation coefficient
    correlacoes_spearman[j, i] <- cor_resultado$estimate  # Fill symmetric position
    
    pvalores_spearman[i, j] <- cor_resultado$p.value      # Save p-value
    pvalores_spearman[j, i] <- cor_resultado$p.value      # Fill symmetric position
  }
}

# Print rounded Spearman correlation matrix
print(round(correlacoes_spearman, 4))

# Print rounded p-values matrix
print(round(pvalores_spearman, 4))

# ==============================================================================
# Visualizations - Histogram and Boxplots
# ==============================================================================

# Histogram and Boxplot of PBNVS

layout(matrix(c(1,2), 2, 1, byrow=TRUE), heights = c(3, 1))

par(mar = c(2, 4, 2, 1))
hist(data$PBNVS, 
     freq = FALSE,
     main = "",
     xlab = "",
     ylab = "Frequency",
     ylim = c(0, 14),
     cex.axis = 1.2,
     las = 1)

lines(density(data$PBNVS), col = "darkred", lwd = 2)

par(mar = c(2, 4, 0.5, 1))
boxplot(data$PBNVS,
        notch = TRUE,
        horizontal = TRUE,
        frame = FALSE,
        cex.axis = 1.2,
        axes = TRUE)

# Boxplots by Region and Capital

layout(matrix(c(1, 2), 1, 2, byrow = TRUE))

par(mar = c(5, 4, 2, 1))
boxplot(PBNVS ~ Region, data = data,
        xlab = "Region", ylab = "Proportion of Blank and Null Votes",
        cex.axis = 1.2, cex.lab = 1.3, boxwex = 0.4,
        names = c("CW", "N", "NE", "S", "SE"),
        notch = TRUE)

par(mar = c(5, 4, 2, 1))
boxplot(PBNVS ~ as.factor(Capital), data = data,
        xlab = "Capital", ylab = "",
        cex.axis = 1.2, cex.lab = 1.3, boxwex = 0.4,
        names = c("No", "Yes"),
        notch = TRUE)

# ==============================================================================
# Data Preparation for Modeling
# ==============================================================================

# Remove unnecessary columns
datareg <- data |>
  select(-c(1:9, 14))

# Create dummy variables for Region
Dummy_reg <- createDummyFeatures(data$Region, cols = NULL)

# Combine dummy variables with cleaned data
datafix <- cbind(datareg, Dummy_reg[, -1])

# ==============================================================================
# Load Distribution Families (Unit Weibull, Reflected Unit Burr XII, Kumaraswamy)
# ==============================================================================

source("UW_reg.R")
source("RUBXII_reg.R")
source("Kuma_reg.R")

# ==============================================================================
# GAMLSS Modeling (Fixed Effects)
# ==============================================================================

# --- Beta Distribution ---
beta_fixed <- gamlss(formula = PBNVS ~., sigma.formula = ~., family = BE(), data = datafix)

# --- Simplex Distribution ---
simplex_fixed <- gamlss(PBNVS ~., sigma.formula = ~., family = SIMPLEX(), data = datafix)

# --- Kumaraswamy Distribution ---
kuma_fixed <- gamlss(
  PBNVS ~., sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + North + Northeast + South + Southeast,
  family = Kuma(mu.link = "logit", sigma.link = "log"), data = datafix)

# --- Unit Weibull Distribution ---
uw_fixed <- gamlss(
  PBNVS ~., sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + North + Northeast + South + Southeast, 
  family = "UW"(mu.link = "logit", sigma.link = "log"), data = datafix)

# --- Reflected Unit Burr XII Distribution ---
rubxii_fixed <- gamlss(
  PBNVS ~., sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + North + Northeast + South + Southeast,
  family = "RUBXII"(mu.link = "logit", sigma.link = "log"), data = datafix)

# ==============================================================================
# Model Performance Metrics
# ==============================================================================

# Collect performance indicators: AIC, BIC, R², MAPE, MAE, RMSE
extract_metrics <- function(model, y) {
  c(model$aic, model$sbc, Rsq(model),
    forecast::accuracy(model$mu.fv, y)[, c(5, 3, 2)])
}

measures <- rbind(
  extract_metrics(beta_fixed, datafix$PBNVS),
  extract_metrics(simplex_fixed, datafix$PBNVS),
  extract_metrics(kuma_fixed, datafix$PBNVS),
  extract_metrics(uw_fixed, datafix$PBNVS),
  extract_metrics(rubxii_fixed, datafix$PBNVS)
)

colnames(measures) <- c("AIC", "BIC", "RSQ", "MAPE", "MAE", "RMSE")
rownames(measures) <- c("Beta", "Simplex", "Kuma", "UW", "RUBXII")

print(round(measures, 4))

# ==============================================================================
# Model Comparison (Best by Each Metric)
# ==============================================================================

which(measures[, "AIC"] == min(measures[, "AIC"]))
which(measures[, "BIC"] == min(measures[, "BIC"]))
which(measures[, "RSQ"] == max(measures[, "RSQ"]))
which(measures[, "MAPE"] == min(measures[, "MAPE"]))
which(measures[, "MAE"] == min(measures[, "MAE"]))
which(measures[, "RMSE"] == max(measures[, "RMSE"]))

# ==============================================================================
# Final Model Selection and Refinement (Beta chosen)
# ==============================================================================

# Stepwise selection using GAIC to refine the beta model
final1 <- stepGAIC(beta_fixed)

# Inspecting selected covariates and their statistical significance
summary(final1)

# ==============================================================================
# Refit with Selected Covariates - Full Dispersion Model
# ==============================================================================

# Model with selected covariates (mu and sigma modeled with covariates)
final2 <- gamlss(
  PBNVS ~ MHDI_H + MHDI_E + Capital + PBNVF + North + Northeast + South + Southeast,
  sigma.formula = ~ MHDI_I + MHDI_H + MHDI_E + Capital + North + Northeast + Southeast,
  family = BE(), data = datafix)
summary(final2)

round(summary(final2)[, c("Estimate", "Std. Error", "Pr(>|t|)")], 4)

# ==============================================================================
# Model with Constant Dispersion (Simplified Sigma)
# ==============================================================================

# Same mu structure as final2, but sigma is constant (no covariates)
final_sfixed <- gamlss(
  PBNVS ~ MHDI_H + MHDI_E + Capital + PBNVF + North + Northeast + South + Southeast,
  sigma.formula = ~ 1,
  family = BE(), data = datafix)

round(summary(final_sfixed)[, c("Estimate", "Std. Error", "Pr(>|t|)")], 4)

# Likelihood Ratio Test to assess whether modeling sigma improves fit
LR.test(final_sfixed, final2)

# ==============================================================================
# Residual Analysis and Diagnostics
# ==============================================================================

# Worm plots to visually assess normalized randomized quantile residuals
par(mfrow = c(2, 1))
wp(final2)
wp(final_sfixed)

# Fitted vs Observed Plot: Comparing models with and without dispersion modeling
par(mfrow = c(1, 1))
plot(fitted(final2), datareg$PBNVS,
     xlab = "Fitted values", ylab = "Observed values",
     main = "Fitted vs Observed: Sigma Mod (black) vs Sigma Fix (red)")
points(fitted(final_sfixed), datareg$PBNVS, col = "red")

# ==============================================================================
# Effect of Covariates on Dispersion (Sigma)
# ==============================================================================

# Visualizing partial effects of predictors on the dispersion parameter

layout(matrix(1:4, nrow = 2, ncol = 2, byrow = TRUE))
par(mar = c(5, 4, 2, 1))

term.plot(final2, what = "sigma")

# ==============================================================================
# Full Diagnostic Plots
# ==============================================================================

# General diagnostic plots from GAMLSS for both models
plot(final2)
plot(final_sfixed)

# ==============================================================================
# Histogram and Q-Q Plot for Normalized Quantile Residuals
# ==============================================================================

quant_residuals2 <- final2$residuals

# Histogram of residuals with normal curve overlay

layout(matrix(c(1, 2), 1, 2, byrow = TRUE))

par(mar = c(5, 4, 2, 1))
hist(quant_residuals2,
     main = "", freq = FALSE,
     ylab = "Density", xlab = "Leavings",
     cex.axis = 1.2, cex.lab = 1.3)

curve(dnorm(x, mean = mean(quant_residuals2), sd = sd(quant_residuals2)), 
      add = TRUE, col = "darkred", lwd = 2)

# Q-Q plot for assessing normality of residuals
par(mar = c(5, 4, 2, 1))
qqnorm(quant_residuals2,
       frame = TRUE,
       cex.main = 1.2, cex.lab = 1.3,
       main = "",
       ylab = "Sample Quantiles",
       xlab = "Standard Normal Quantiles")

qqline(quant_residuals2, col = "darkred", lwd = 2)
