# 02_clean.R -- build the analysis dataset.
# Every filtering choice here is a modelling decision: write down WHY in your
# notes, and report the final n per city on the poster.

source(here::here("R", "00_packages.R"))
library(here)

read_city <- function(city) {
  read_csv(here("data", "raw", paste0(city, "_listings.csv.gz")),
           show_col_types = FALSE, guess_max = 50000) |>
    mutate(city = city)
}

raw <- bind_rows(lapply(c("toronto", "vancouver", "ottawa"), read_city))

# Inside Airbnb stores booleans as "t"/"f"; readr may already parse them as logical
tf <- function(x) if (is.logical(x)) x else x == "t"

listings <- raw |>
  transmute(
    id, city,
    rating        = review_scores_rating,
    n_reviews     = number_of_reviews,
    price         = readr::parse_number(price),         # "$1,234.00" -> 1234
    room_type,
    accommodates,
    superhost     = tf(host_is_superhost),
    # instant_book  = tf(instant_bookable),
    host_listings = calculated_host_listings_count
    # host_years    = as.numeric(as.Date(last_scraped) - as.Date(host_since)) / 365.25
  ) |>
  # --- Inclusion criteria (DECIDE + JUSTIFY each one) ---
  filter(n_reviews >= 10,            # rating is unstable with few reviews
         !is.na(rating),
         !is.na(price), price > 0) |>
  mutate(
    excellent  = as.integer(rating >= 4.9),          # outcome (DECIDE: 4.9 cut-off?)
    log_price  = log(price),
    multi_host = host_listings > 1,                  # DECIDE: >1? >=3? (commercial host)
    room_type  = factor(room_type),
    city       = factor(city, levels = c("toronto", "vancouver", "ottawa"))
  ) |>
  filter(!is.na(superhost)) # , !is.na(instant_book))

# Optional: trim extreme prices (DECIDE: keep, trim, or justify)
# listings <- listings |> group_by(city) |> filter(price <= quantile(price, .99)) |> ungroup()

message("Rows per city:"); print(table(listings$city))
message("Share excellent by city:"); print(round(tapply(listings$excellent, listings$city, mean), 3))

write_rds(listings, here("data", "processed", "listings_clean.rds"))
