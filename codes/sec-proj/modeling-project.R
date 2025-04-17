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
library(stargazer)

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
desc

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
# Visualizations - Histogram and Boxplots
# ==============================================================================

# Histogram and Boxplot of PBNVS
par(mfrow = c(1, 2))
par(mar = c(5, 5, 4, 2))

hist(data$PBNVS, freq = FALSE,
     main = "", xlab = "Proportion of Blank and Null Votes (2nd Round)",
     ylab = "Frequency")
lines(density(data$PBNVS), col = "darkred", lwd = 2)

boxplot(data$PBNVS, ylab = "Proportion of Votes", notch = TRUE, horizontal = TRUE)

# Boxplots by Region and Capital
boxplot(PBNVS ~ Region, data = data,
        xlab = "Region", ylab = "Proportion of Blank and Null Votes",
        cex.axis = 1.2, cex.lab = 1.3, boxwex = 0.4,
        names = c("CW", "NE", "N", "SE", "S"))

boxplot(PBNVS ~ as.factor(Capital), data = data,
        xlab = "Capital", ylab = "Proportion of Blank and Null Votes",
        cex.axis = 1.2, cex.lab = 1.3, boxwex = 0.4,
        names = c("No", "Yes"))

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
dataran <- data[, -c(1:9)]

# ==============================================================================
# Load Distribution Families (Unit Weibull, Reflected Unit Burr XII, Kumaraswamy)
# ==============================================================================

source("UW_reg.R")
source("RUBXII_reg.R")
source("Kuma_reg.R")

# ==============================================================================
# GAMLSS Modeling (Fixed and Random Effects)
# ==============================================================================

# --- Beta Distribution ---
beta_fixed <- gamlss(formula = PBNVS ~., sigma.formula = ~., family = BE(), data = datafix)

beta_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  family = BE(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# --- Simplex Distribution ---
simplex_fixed <- gamlss(PBNVS ~., sigma.formula = ~., family = SIMPLEX(), data = datafix)

simplex_random <- gamlss(
  PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  family = SIMPLEX(mu.link = "logit", sigma.link = "log"), data = dataran)

# --- Kumaraswamy Distribution ---
kuma_fixed <- gamlss(
  PBNVS ~., sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + North + Northeast + South + Southeast,
  family = Kuma(mu.link = "logit", sigma.link = "log"), data = datafix)

kuma_random <- gamlss(
  PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = Kuma(mu.link = "logit", sigma.link = "log"), data = dataran)

# --- Unit Weibull Distribution ---
uw_fixed <- gamlss(PBNVS ~., sigma.formula = ~., family = "UW"(mu.link = "logit", sigma.link = "log"), data = datareg)

uw_random <- gamlss(
  PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = "UW"(mu.link = "logit", sigma.link = "log"), data = dataran)

# --- Reflected Unit Burr XII Distribution ---
rubxii_fixed <- gamlss(
  PBNVS ~., sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + North + Northeast + South + Southeast,
  family = "RUBXII"(mu.link = "logit", sigma.link = "log"), data = datafix)

rubxii_random <- gamlss(
  PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = "RUBXII"(mu.link = "logit", sigma.link = "log"), data = dataran)

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
  extract_metrics(beta_random, dataran$PBNVS),
  extract_metrics(simplex_fixed, datafix$PBNVS),
  extract_metrics(simplex_random, dataran$PBNVS),
  extract_metrics(kuma_fixed, datafix$PBNVS),
  extract_metrics(kuma_random, dataran$PBNVS),
  extract_metrics(uw_fixed, datafix$PBNVS),
  extract_metrics(uw_random, dataran$PBNVS),
  extract_metrics(rubxii_fixed, datafix$PBNVS),
  extract_metrics(rubxii_random, dataran$PBNVS)
)

colnames(measures) <- c("AIC", "BIC", "RSQ", "MAPE", "MAE", "RMSE")
rownames(measures) <- c("Beta", "Beta RE", "Simplex", "Simplex RE",
                        "Kuma", "Kuma RE", "UW", "UW RE", "RUBXII", "RUBXII RE")

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

# Final comparison table
result <- cbind(rep(c("Fit 1", "Fit 2"), 5), round(measures, 4))
result

stargazer::stargazer(result, digits = 4)


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
  sigma.formula = ~ MHDI_I + MHDI_H + MHDI_E + Capital + DD + North + Northeast + Southeast,
  family = BE(), data = datafix)
summary(final2)

# ==============================================================================
# Model with Constant Dispersion (Simplified Sigma)
# ==============================================================================

# Same mu structure as final2, but sigma is constant (no covariates)
final_sfixed <- gamlss(
  PBNVS ~ MHDI_H + MHDI_E + Capital + PBNVF + North + Northeast + South + Southeast,
  sigma.formula = ~ 1,
  family = BE(), data = datafix)

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
plot(fitted(final2), datareg$PBNVS,
     xlab = "Fitted values", ylab = "Observed values",
     main = "Fitted vs Observed: Sigma Mod (black) vs Sigma Fix (red)")
points(fitted(final_sfixed), datareg$PBNVS, col = "red")

# ==============================================================================
# Effect of Covariates on Dispersion (Sigma)
# ==============================================================================

# Visualizing partial effects of predictors on the dispersion parameter
par(mfrow = c(2,4))
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
par(mfrow = c(1,2))
hist(quant_residuals2,
     main = "", freq = FALSE,
     ylab = "Density", xlab = "Leavings",
     cex.axis = 1.8, cex.lab = 1.8)

curve(dnorm(x, mean = mean(quant_residuals2), sd = sd(quant_residuals2)), 
      add = TRUE, col = "darkred", lwd = 2)

# Q-Q plot for assessing normality of residuals
qqnorm(quant_residuals2,
       frame = TRUE,
       cex.main = 1.8, cex.lab = 1.8,
       ylab = "Sample Quantiles",
       xlab = "Standard Normal Quantiles")

qqline(quant_residuals2, col = "darkred", lwd = 2)
