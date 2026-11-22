# 01_download.R -- download the detailed listings files from Inside Airbnb.
#
# Source: Inside Airbnb, https://insideairbnb.com/get-the-data/  (CC BY 4.0)
# On that page, scroll to each Canadian city, right-click the
# "listings.csv.gz" link (Detailed Listings data) and copy its address.
# Paste the three URLs below. Record the snapshot dates: you cite them on the poster.

source(here::here("R", "00_packages.R"))
library(here)

urls <- c(
  toronto   = "https://data.insideairbnb.com/canada/on/toronto/2026-09-16/data/listings.csv.gz",
  vancouver = "https://data.insideairbnb.com/canada/bc/vancouver/2026-09-17/data/listings.csv.gz",
  ottawa  = "https://data.insideairbnb.com/canada/on/ottawa/2026-09-19/data/listings.csv.gz"
)

for (city in names(urls)) {
  dest <- here("data", "raw", paste0(city, "_listings.csv.gz"))
  if (!file.exists(dest)) {
    message("Downloading ", city, " ...")
    download.file(urls[[city]], dest, mode = "wb")
  }
}
# Keep a record of exactly which snapshots you used
writeLines(paste(names(urls), urls, sep = ": "), here("data", "raw", "SOURCES.txt"))
