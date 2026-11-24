# 03_explore.R -- exploratory plots and summary tables (candidates for the poster).
# Save rating_distribution.png and excellent_vs_price.png to output/figures/
# Print excellent rate by city and superhost, and by room type.

source(here::here("R", "00_packages.R"))
library(here)
d <- read_rds(here("data", "processed", "listings_clean.rds"))

# Plot 1 : rating dist.
p1 <- ggplot(d, aes(rating)) +
  geom_histogram(binwidth = 0.05, boundary = 5, fill = poster_red) +
  geom_vline(xintercept = 4.9, linetype = "dashed", colour = poster_dark) +
  facet_wrap(~ city) +
  labs(x = "Overall rating", y = "Listings")
ggsave(here("output", "figures", "rating_distribution.png"), p1, width = 9, height = 3.5, dpi = 300)

# Plot 2 : excellent rate vs price
p2 <- d |>
  group_by(city, price_bin = cut(log_price, breaks = 10)) |>
  summarise(p = mean(excellent), x = mean(log_price), n = n(), .groups = "drop") |>
  ggplot(aes(x, p, colour = city)) + geom_point(aes(size = n)) + geom_line() + scale_colour_manual(values = city_cols) +
  labs(x = "log(nightly price)", y = "Proportion rated 4.9+")
ggsave(here("output", "figures", "excellent_vs_price.png"), p2, width = 7, height = 4, dpi = 300)

# --- ADDITIONAL DATA EXPLOR. ---
# Summaries and Missingness
summary(d)
colSums(is.na(d))   # 0 across the board

# Overall class balance
d |> count(excellent) |> mutate(share = n / sum(n)) |> print()
# excellent     n share
#         0  7499 0.563
#         1  5823 0.437

# Cutoff sensitivity
sapply(c(4.7, 4.8, 4.9, 5.0), \(k) mean(d$rating >= k))   # 4.9 ideal - once start accounting for anything lower, sample size spikes by min. 30%
# [1] 0.8402642 0.7014713 0.4370965 0.1113196

# superhost more likely to be >4.9
d |> group_by(city, superhost) |> summarise(p_excellent = mean(excellent), n = n(), .groups = "drop") |> print()
# city      superhost p_excellent     n
# toronto   FALSE           0.296  3586
# toronto   TRUE            0.537  5042
# vancouver FALSE           0.306  1372
# vancouver TRUE            0.554  2030
# ottawa    FALSE           0.221   524
# ottawa    TRUE            0.510   768

# hotel types tend to have higher ratings (makes sense - company vs individually run)
d |> group_by(room_type) |> summarise(p_excellent = mean(excellent), n = n()) |> print()
# room_type         p_excellent     n
# 1 Entire home/apt       0.458  9906
# 2 Private room          0.377  3416

d |> group_by(multi_host) |> summarise(p = mean(excellent), n = n()) |> print()   # little effect - ignore
# multi_host     p     n
# FALSE      0.486  8350
# TRUE       0.355  4972

d |> group_by(accommodates) |> summarise(p = mean(excellent), n = n()) |> print()   # little effect - ignore
# accommodates     p     n
#            1 0.384   898
#            2 0.448  4662
#            3 0.455  1258
#            4 0.424  3127
#            5 0.437   792
#            6 0.435  1454
#            7 0.429   219
#            8 0.484   488
#            9 0.458    59
#           10 0.448   183
#           11 0.409    22
#           12 0.430    79
#           13 0.333     3
#           14 0.375    32
#           15 0.286     7
#           16 0.436    39

d |> group_by(host_listings) |> summarise(p = mean(excellent), n = n()) |> print()    # little effect - ignore
# host_listings     p     n
#             1 0.486  8350
#             2 0.394  1640
#             3 0.358  1274
#             4 0.358   461
#             5 0.35    300
#             6 0.322   183
#             7 0.370   138
#             8 0.331   130
#             9 0.447    85
#            10 0.361    36
# ℹ 32 more rows

# Rare categories and correlation
count(d, room_type, sort = TRUE)
# room_type           n
# Entire home/apt  9906
# Private room     3416
# REMOVEDHotel room         51
# REMOVEDShared room        13

cor(d[, c("log_price", "accommodates", "host_listings")], use = "complete.obs")
#               log_price accommodates  host_listings
# log_price      1.0000000   0.61027360   -0.08956090
# accommodates   0.6102736   1.00000000   -0.02519145
# host_listings -0.0895609  -0.02519145    1.00000000
