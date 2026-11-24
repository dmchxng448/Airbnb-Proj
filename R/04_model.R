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

# --- ODDS RATIO FOREST PLOT (poster Fig 2) ---
# Left out city main effects: with the interaction they are ORs at log_price = 0 ($1/night)
or_labels <- c(
  "superhostTRUE"           = "Superhost",
  "multi_hostTRUE"          = "Multi-listing host",
  "accommodates"            = "Accommodates (+1 guest)",
  "room_typePrivate room"   = "Private room (vs entire home)",
  "citytoronto:log_price"   = "Toronto",
  "cityvancouver:log_price" = "Vancouver",
  "cityottawa:log_price"    = "Ottawa"
)

or_plot <- read_csv(here("output", "tables", "odds_ratios.csv"), show_col_types = FALSE) |>
  filter(!term %in% c("cityvancouver", "cityottawa")) |>
  mutate(
    label = unname(or_labels[term]),
    group = if_else(grepl("log_price", term), "log(price), by city", "Host & listing"),
    group = factor(group, levels = c("Host & listing", "log(price), by city")),
    label = factor(label, levels = rev(c("Superhost", "Multi-listing host",
                                         "Accommodates (+1 guest)", "Private room (vs entire home)",
                                         "Toronto", "Vancouver", "Ottawa"))),
    ci_crosses_1 = conf.low < 1 & conf.high > 1,
    or_text = sprintf("%.2f (%.2f-%.2f)", estimate, conf.low, conf.high)
  )

p_forest <- ggplot(or_plot, aes(x = estimate, y = label)) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), width = 0.2, orientation = "y", colour = poster_dark) +
  geom_point(aes(shape = ci_crosses_1), size = 2.8, colour = poster_red, fill = "white") +
  geom_text(aes(x = 4.2, label = or_text), hjust = 0, size = 3.2) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 21), guide = "none") +
  scale_x_log10(breaks = c(0.5, 0.75, 1, 1.5, 2, 3)) +
  coord_cartesian(xlim = c(0.5, 3.2), clip = "off") +
  facet_grid(group ~ ., scales = "free_y", space = "free_y") +
  labs(x = "Odds ratio of a 4.9+ rating (log scale, 95% CI)", y = NULL) +
  theme(plot.margin = margin(5.5, 95, 5.5, 5.5))
p_forest
ggsave(here("output", "figures", "odds_ratio_forest.png"), p_forest, width = 7, height = 4, dpi = 300)

saveRDS(list(m_final = m_final, train = train, test = test),
        here("data", "processed", "model.rds"))
