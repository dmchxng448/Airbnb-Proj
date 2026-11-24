# 04_model.R -- logistic regression: P(excellent = 1 | predictors).
# Print + saves odds ratio table as output/tables/odds_ratios.csv

source(here::here("R", "00_packages.R"))
library(here)
d <- read_rds(here("data", "processed", "listings_clean.rds"))

# Hold out 30% of listings - fits the model on remaining 70%
set.seed(42)
test_idx <- sample(nrow(d), size = round(0.3 * nrow(d)))
train <- d[-test_idx, ]; test <- d[test_idx, ]

# --- LOGISTIC REG. ---
# Model log-odds of an excellent listing
m_full <- glm(excellent ~ log_price + room_type + accommodates + superhost +
                multi_host + city,
              family = binomial, data = train) # removed instant_books and host_years
summary(m_full)

# --- MULTICOLLINEARITY CHECK ---
# Correlated predictors that rely heavily on eachother
# (GVIF^(1/(2*Df)) above ~2.2 deserves a look)
car::vif(m_full)    # all below 2.2 whew

# --- LIKELIHOOD-RATIO TESTS ---
# Effect on model when predictors are dropped one by one
drop1(m_full, test = "LRT")   # pvals <.05 besides city (primary design var.)

# --- INTERACTION TEST ---
# Does price effect differ by city?
# Small LRT p-val. : keep m_int
m_int <- update(m_full, . ~ . + log_price:city)
anova(m_full, m_int, test = "LRT")    # pval .02662 : effect of price DOES differ by city

# Interaction test proves valuable
m_final <- glm(excellent ~ room_type + accommodates + superhost + multi_host + city + city:log_price,
               family = binomial, data = train)

# --- AKAIKE INFORMATION CRITERION ---
AIC(m_full, m_int)    # backed by lower AIC
#        df      AIC
# m_full  8 11911.57
# m_int  10 11908.32

# Odds ratios with 95% profile-likelihood CIs -> poster table
# ADDED: drop int. row and round for cleaner output
or_table <- broom::tidy(m_final, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))
print(or_table)
# superhost 2.84: ~3x odds of 4.9+ rating
# multi-list host .60: ~.38 lower odds of 4.9+ rating
# accommodates .91: with every additional guest accom. lowers odds by .085
# private room .99: no diff. from entire homes
# higher odds, higher price (strongest in yvr - LRT)
# - yvr=1.81 yow=1.42 tor=1.45 : price matters more in yvr

write_csv(or_table, here("output", "tables", "odds_ratios.csv"))

saveRDS(list(m_final = m_final, train = train, test = test),
        here("data", "processed", "model.rds"))
