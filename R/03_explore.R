# 03_explore.R -- exploratory plots and summary tables (candidates for the poster).
# Save rating_distribution.png and excellent_vs_price.png to output/figures/
# Print excellent rate by city and superhost, and by room type.

source(here::here("R", "00_packages.R"))
library(here)
d <- read_rds(here("data", "processed", "listings_clean.rds"))

# Plot 1 : rating dist.
p1 <- ggplot(d, aes(rating)) +
  geom_histogram(binwidth = 0.05, boundary = 5) +
  geom_vline(xintercept = 4.9, linetype = "dashed") +
  facet_wrap(~ city) +
  labs(x = "Overall rating", y = "Listings")
ggsave(here("output", "figures", "rating_distribution.png"), p1, width = 9, height = 3.5, dpi = 300)

# Plot 2 : excellent rate vs price
p2 <- d |>
  group_by(city, price_bin = cut(log_price, breaks = 10)) |>
  summarise(p = mean(excellent), x = mean(log_price), n = n(), .groups = "drop") |>
  ggplot(aes(x, p, colour = city)) + geom_point(aes(size = n)) + geom_line() +
  labs(x = "log(nightly price)", y = "Proportion rated 4.9+")
ggsave(here("output", "figures", "excellent_vs_price.png"), p2, width = 7, height = 4, dpi = 300)

# --- ADDITIONAL DATA EXPLOR. ---
# Summaries and Missingness
summary(d)
colSums(is.na(d))   # 0 across the board

# Overall class balance
d |> count(excellent) |> mutate(share = n / sum(n)) |> print()
# excellent     n share
#         0  7524 0.562
#         1  5862 0.438

# Cutoff sensitivity
sapply(c(4.7, 4.8, 4.9, 5.0), \(k) mean(d$rating >= k))   # 4.9 ideal - once start accounting for anything lower, sample size spikes by min. 30%
# [1] 0.8405050 0.7021515 0.4379202 0.1123562

# superhost more likely to be >4.9
d |> group_by(city, superhost) |> summarise(p_excellent = mean(excellent), n = n(), .groups = "drop") |> print()
#   city      superhost p_excellent     n
# 1 toronto   FALSE           0.296  3592
# 2 toronto   TRUE            0.539  5094
# 3 vancouver FALSE           0.306  1374
# 4 vancouver TRUE            0.554  2031
# 5 ottawa    FALSE           0.220   527
# 6 ottawa    TRUE            0.510   768

# hotel types tend to have higher ratings (makes sense - company vs individually run)
d |> group_by(room_type) |> summarise(p_excellent = mean(excellent), n = n()) |> print()
# room_type         p_excellent     n
# 1 Entire home/apt       0.458  9906
# 2 Hotel room            0.706    51
# 3 Private room          0.377  3416
# 4 Shared room           0.231    13

#
d |> group_by(multi_host) |> summarise(p = mean(excellent), n = n()) |> print()   # little effect - ignore
# multi_host     p     n
# FALSE      0.486  8356
# TRUE       0.358  5030

d |> group_by(accommodates) |> summarise(p = mean(excellent), n = n()) |> print()   # little effect - ignore
# accommodates     p     n
# 1            1 0.383   904
# 2            2 0.447  4669
# 3            3 0.459  1268
# 4            4 0.425  3140
# 5            5 0.439   800
# 6            6 0.435  1463
# 7            7 0.442   226
# 8            8 0.485   491
# 9            9 0.458    59
# 10           10 0.451   184
# 11           11 0.409    22
# 12           12 0.430    79
# 13           13 0.333     3
# 14           14 0.375    32
# 15           15 0.286     7
# 16           16 0.436    39

d |> group_by(host_listings) |> summarise(p = mean(excellent), n = n()) |> print()    # little effect - ignore
# host_listings     p     n
#             1 0.486  8356
#             2 0.392  1649
#             3 0.359  1278
#             4 0.357   462
#             5 0.351   308
#             6 0.322   183
#             7 0.370   138
#             8 0.331   130
#             9 0.480   102
#            10 0.477    44

# Rare categories and correlation
count(d, room_type, sort = TRUE)
# room_type           n
# Entire home/apt  9906
# Private room     3416
# Hotel room         51
# Shared room        13

cor(d[, c("log_price", "accommodates", "host_listings")], use = "complete.obs")
#                 log_price accommodates host_listings
# log_price      1.00000000   0.61099725   -0.08700397
# accommodates   0.61099725   1.00000000   -0.02365224
# host_listings -0.08700397  -0.02365224    1.00000000
