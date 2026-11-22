# 03_explore.R -- exploratory plots and tables (candidates for the poster).
source(here::here("R", "00_packages.R"))
library(here)
d <- read_rds(here("data", "processed", "listings_clean.rds"))

# 1. Why a binary outcome? Ratings pile up near 5.
p1 <- ggplot(d, aes(rating)) +
  geom_histogram(binwidth = 0.05, boundary = 5) +
  geom_vline(xintercept = 4.9, linetype = "dashed") +
  facet_wrap(~ city) +
  labs(x = "Overall rating", y = "Listings")
ggsave(here("output", "figures", "rating_distribution.png"), p1, width = 9, height = 3.5, dpi = 300)

# 2. Proportion excellent across price (binned) by city
p2 <- d |>
  group_by(city, price_bin = cut(log_price, breaks = 10)) |>
  summarise(p = mean(excellent), x = mean(log_price), n = n(), .groups = "drop") |>
  ggplot(aes(x, p, colour = city)) + geom_point(aes(size = n)) + geom_line() +
  labs(x = "log(nightly price)", y = "Proportion rated 4.9+")
ggsave(here("output", "figures", "excellent_vs_price.png"), p2, width = 7, height = 4, dpi = 300)

# 3. Simple cross-tabs
d |> group_by(city, superhost) |> summarise(p_excellent = mean(excellent), n = n(), .groups = "drop") |> print()
d |> group_by(room_type) |> summarise(p_excellent = mean(excellent), n = n()) |> print()

