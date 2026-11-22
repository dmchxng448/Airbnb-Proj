# 05_diagnostics.R -- how good / how trustworthy is the final model?
source(here::here("R", "00_packages.R"))
library(here)
obj <- readRDS(here("data", "processed", "model.rds"))
m <- obj$m_final; test <- obj$test; train <- obj$train

# 1. Discrimination on held-out data: ROC curve and AUC
p_test <- predict(m, newdata = test, type = "response")
roc_obj <- pROC::roc(test$excellent, p_test, quiet = TRUE)
print(pROC::auc(roc_obj)); print(pROC::ci.auc(roc_obj))
png(here("output", "figures", "roc_test.png"), width = 1600, height = 1600, res = 300)
plot(roc_obj, legacy.axes = TRUE, main = sprintf("Test AUC = %.3f", pROC::auc(roc_obj)))
dev.off()

# 2. Calibration: predicted vs observed proportion in deciles of predicted risk
cal <- data.frame(p = p_test, y = test$excellent) |>
  mutate(bin = ntile(p, 10)) |>
  group_by(bin) |> summarise(pred = mean(p), obs = mean(y), n = n())
print(cal)
pc <- ggplot(cal, aes(pred, obs)) + geom_abline(linetype = "dashed") + geom_point(size = 2) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "Mean predicted probability", y = "Observed proportion excellent")
ggsave(here("output", "figures", "calibration_test.png"), pc, width = 4.5, height = 4.5, dpi = 300)

# 3. Confusion matrix at a threshold (DECIDE: 0.5, or the base rate?)
thr <- 0.5
print(table(predicted = as.integer(p_test >= thr), observed = test$excellent))

# 4. Influential points on the training fit
infl <- cooks.distance(m)
message("Max Cook's distance: ", signif(max(infl), 3))
head(sort(infl, decreasing = TRUE))

# Weaknesses to think about for the poster (your words, not mine):
#  - listings from the same host are not independent
#  - rating is only observed for listings with >= 10 reviews (selection)
#  - one snapshot in time; observational, so associations not causes
