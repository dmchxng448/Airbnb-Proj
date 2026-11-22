# 04_model.R -- logistic regression: P(excellent = 1 | predictors).
source(here::here("R", "00_packages.R"))
library(here)
d <- read_rds(here("data", "processed", "listings_clean.rds"))

# Hold out 30% for an honest check of predictive performance
set.seed(429)
test_idx <- sample(nrow(d), size = round(0.3 * nrow(d)))
train <- d[-test_idx, ]; test <- d[test_idx, ]

# Full (starting) model -- your choice of terms; edit freely
m_full <- glm(excellent ~ log_price + room_type + accommodates + superhost +
                multi_host + city,
              family = binomial, data = train) # removed instant_books and host_years
summary(m_full)

# Multicollinearity check (GVIF^(1/(2*Df)) above ~2.2 deserves a look)
car::vif(m_full)

# Which terms earn their place? Likelihood-ratio tests, one term dropped at a time
drop1(m_full, test = "LRT")

# Candidate interaction: does the price effect differ by city?
m_int <- update(m_full, . ~ . + log_price:city)
anova(m_full, m_int, test = "LRT")

# --- DECIDE your final model here and justify it (LRT / AIC / interpretability) ---
m_final <- m_full

# Odds ratios with 95% profile-likelihood CIs -> poster table
or_table <- broom::tidy(m_final, exponentiate = TRUE, conf.int = TRUE)
print(or_table)
write_csv(or_table, here("output", "tables", "odds_ratios.csv"))

saveRDS(list(m_final = m_final, train = train, test = test),
        here("data", "processed", "model.rds"))
