# ==============================================================================
# Data Preparation for Modeling
# ==============================================================================

# Remove unnecessary columns
datareg <- data |>
  select(-c(1:9, 14))

# Create dummy variables for Region
Dummy_reg <- createDummyFeatures(data$Region, cols = NULL)

# Combine dummy variables with cleaned data
dataran <- data[, -c(1:9)]

# ==============================================================================
# Load Distribution Families (Unit Weibull, Reflected Unit Burr XII, Kumaraswamy)
# ==============================================================================

source("UW_reg.R")
source("RUBXII_reg.R")
source("Kuma_reg.R")

# ==============================================================================
# GAMLSS Modeling - RANDOM EFFECTS
# ==============================================================================
# In this section, we fit GAMLSS models including random effects
# (Region as a random intercept).
# ==============================================================================

# --- Beta Distribution with Random Effects ---
beta_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  family = BE(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# --- Simplex Distribution with Random Effects ---
simplex_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  family = SIMPLEX(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# --- Kumaraswamy Distribution with Random Effects ---
kuma_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = Kuma(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# --- Unit Weibull Distribution with Random Effects ---
uw_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = "UW"(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# --- Reflected Unit Burr XII Distribution with Random Effects ---
rubxii_random <- gamlss(
  formula = PBNVS ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + Capital + random(as.factor(Region)),
  sigma.formula = ~ PBNVF + MHDI_I + MHDI_H + MHDI_E + DD + random(as.factor(Region)),
  family = "RUBXII"(mu.link = "logit", sigma.link = "log"),
  data = dataran
)

# ==============================================================================
# Model Performance Metrics (Random Effects Models)
# ==============================================================================
# Extract AIC, BIC, R², MAPE, MAE, and RMSE for each random effect model.
# ==============================================================================

extract_metrics <- function(model, y) {
  c(model$aic, model$sbc, Rsq(model),
    forecast::accuracy(model$mu.fv, y)[, c(5, 3, 2)])
}

measures_random <- rbind(
  extract_metrics(beta_random, dataran$PBNVS),
  extract_metrics(simplex_random, dataran$PBNVS),
  extract_metrics(kuma_random, dataran$PBNVS),
  extract_metrics(uw_random, dataran$PBNVS),
  extract_metrics(rubxii_random, dataran$PBNVS)
)

colnames(measures_random) <- c("AIC", "BIC", "RSQ", "MAPE", "MAE", "RMSE")
rownames(measures_random) <- c("Beta RE", "Simplex RE", "Kuma RE", "UW RE", "RUBXII RE")

print(round(measures_random, 4))

# ==============================================================================
# Model Comparison (Best Model per Metric - Random Effects)
# ==============================================================================

# Find the best model for each metric
which(measures_random[, "AIC"] == min(measures_random[, "AIC"]))
which(measures_random[, "BIC"] == min(measures_random[, "BIC"]))
which(measures_random[, "RSQ"] == max(measures_random[, "RSQ"]))
which(measures_random[, "MAPE"] == min(measures_random[, "MAPE"]))
which(measures_random[, "MAE"] == min(measures_random[, "MAE"]))
which(measures_random[, "RMSE"] == min(measures_random[, "RMSE"]))

# ==============================================================================
# Final Model Comparison - FIXED vs RANDOM Effects
# ==============================================================================
# Compare models fitted with and without random effects.
# ==============================================================================

# Combine metrics from fixed and random models
measures_combined <- rbind(
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

colnames(measures_combined) <- c("AIC", "BIC", "RSQ", "MAPE", "MAE", "RMSE")
rownames(measures_combined) <- c("Beta", "Beta RE", "Simplex", "Simplex RE",
                                 "Kuma", "Kuma RE", "UW", "UW RE", "RUBXII", "RUBXII RE")

print(round(measures_combined, 4))

# Prepare final comparison table
result <- cbind(rep(c("Fixed", "Random"), 5), round(measures_combined, 4))
colnames(result)[1] <- "Model_Type"

print(result)