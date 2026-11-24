# 05_diagnostics.R -- how good / how trustworthy is the final model?
# Prints test AUC with CI, calibration table, conf. matrix, max. cook's distance
# Plot ROC curve + save calibration_test.png

source(here::here("R", "00_packages.R"))
library(here)
obj <- readRDS(here("data", "processed", "model.rds"))
m <- obj$m_final; test <- obj$test; train <- obj$train

# 1. Discrimination on held-out data: ROC curve and AUC
p_test <- predict(m, newdata = test, type = "response")
roc_obj <- pROC::roc(test$excellent, p_test, quiet = TRUE)
print(pROC::auc(roc_obj)); print(pROC::ci.auc(roc_obj))
# Area under the curve: 0.6699 <- no overfitting
# 95% CI: 0.6532-0.6865 (DeLong)
png(here("output", "figures", "roc_test.png"), width = 1600, height = 1600, res = 300)
plot(roc_obj, legacy.axes = TRUE, col = poster_red, lwd = 3, main = sprintf("Test AUC = %.3f", pROC::auc(roc_obj)))
dev.off()

# 2. Calibration: predicted vs observed proportion in 10 groups (by predicted prob.)
# Compare predicted w/ actual share excellent.
cal <- data.frame(p = p_test, y = test$excellent) |>
  mutate(bin = ntile(p, 10)) |>
  group_by(bin) |> summarise(pred = mean(p), obs = mean(y), n = n())
print(cal)
#   bin  pred   obs     n
#     1 0.187 0.185   400
#     2 0.255 0.27    400
#     3 0.317 0.332   400
#     4 0.363 0.35    400
#     5 0.410 0.448   400
#     6 0.462 0.505   400
#     7 0.528 0.512   400
#     8 0.576 0.541   399
#     9 0.613 0.617   399
#    10 0.659 0.667   399
pc <- ggplot(cal, aes(pred, obs)) + geom_abline(linetype = "dashed", colour = "grey50") + geom_point(size = 2.5, colour = poster_red) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "Mean predicted probability", y = "Observed proportion excellent")
ggsave(here("output", "figures", "calibration_test.png"), pc, width = 4.5, height = 4.5, dpi = 300)

# 3. Confusion matrix at a threshold (DECIDE: 0.5, or the base rate?)
thr <- 0.5
print(table(predicted = as.integer(p_test >= thr), observed = test$excellent))
#          observed
# predicted    0    1
#         0 1574  849
#         1  654  920

# 4. Influential points on the training fit
infl <- cooks.distance(m)
message("Max Cook's distance: ", signif(max(infl), 3))
head(sort(infl, decreasing = TRUE))
# Max Cook's distance: 0.00201 <- no single listing is messing up the model wooo
# 8713        8708        8869        1977        8605        8438
# 0.002008650 0.001957173 0.001953376 0.001946394 0.001668170 0.001619049

# 5. Train vs test AUC (overfitting?)
pROC::auc(train$excellent, fitted(m))
# 0.6734 compared to test at 0.6699
# no overfitting - 0.004 gap (nearly identical)

# --- LIMITATIONS SECTION ---
# - listings from the same host are not independent
# - rating is only observed for listings with >= 10 reviews (selection)
# - Ratings bunch near 5, and 4.9 is an arbitrary cut-off (optimistic airbnb users)
# - one snapshot in time; results are associations rather causes
# - host tenure unavailable in September 2026 data
# - tor dominant data (~65%)
# - modest interaction evidence
