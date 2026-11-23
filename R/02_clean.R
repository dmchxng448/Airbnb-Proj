# 02_clean.R -- build the analysis dataset.
# Print row counts per city and each city's share of excellent listings.
# Saves data/processed/listings_clean.rds

source(here::here("R", "00_packages.R"))
library(here)

read_city <- function(city) {
  read_csv(here("data", "raw", paste0(city, "_listings.csv.gz")),
           show_col_types = FALSE, guess_max = 50000) |>
    mutate(city = city)
}

raw <- bind_rows(lapply(c("toronto", "vancouver", "ottawa"), read_city))

# --- BEFORE CLEANING CHECK ---
dim(raw)            # rows x cols
glimpse(raw)        # every col name, type, first vals rows: 30987, cols: 91
count(raw, city)    # listings per city yow=2806, tor=22050, yvr=6131
summary(raw$review_scores_rating)
colSums(is.na(raw))[c("review_scores_rating", "price", "host_is_superhost")]    # null entries 5550, 6749, 0

# Inside Airbnb stores booleans as "t"/"f"; readr may already parse them as logical
tf <- function(x) if (is.logical(x)) x else x == "t"
log_step <- function(df, label) { message(label, ": ", nrow(df), " rows"); df }   # defn helper

listings <- raw |>
  transmute(
    id, city,
    rating        = review_scores_rating,
    n_reviews     = number_of_reviews,
    price         = readr::parse_number(price),         # "$1,234.00" -> 1234
    room_type,
    accommodates,
    superhost     = tf(host_is_superhost),
    host_listings = calculated_host_listings_count
    # host_years    = as.numeric(as.Date(last_scraped) - as.Date(host_since)) / 365.25      # LIMITATION: host tenure unavailable - cannot recover
  ) |>
  log_step("start") |>

  # --- Inclusion criteria ---
  filter(n_reviews >= 10) |> log_step("after >= 10 reviews") |>         # rating is unstable with few reviews
  filter(!is.na(rating)) |> log_step ("after non-missing rating") |>    # ratings should have comments to be reliable source
  filter(!is.na(price), price > 0) |> log_step("after valid price") |>  # filter out listings without price points

  # New variables
  mutate(
    excellent  = as.integer(rating >= 4.9),          # excellence cut-off
    log_price  = log(price),
    multi_host = host_listings > 1,
    room_type  = factor(room_type),
    city       = factor(city, levels = c("toronto", "vancouver", "ottawa"))
  ) |>
  filter(!is.na(superhost)) |> log_step("after non-missing superhost")

# --- AFTER CLEANING ---
message("Rows after cleaning: ", nrow(listings))                    # total rows 13386
message("Rows per city (cleaned):"); print(table(listings$city))    # yow=1295, tor=8686, yvr=3405
message("Share of excellent listings per city:"); print(round(
  tapply(listings$excellent, listings$city, mean), 3))              # yow=0.392, tor=0.439, yvr=0.454
message("Rows dropped: ", nrow(raw) - nrow(listings), " (", round(
  100 * (1 - nrow(listings) / nrow(raw)), 1), "%)")                 # dropped 17601 (56.8%)

write_rds(listings, here("data", "processed", "listings_clean.rds"))
