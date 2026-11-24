# 00_packages.R -- install (once) and load the packages used in this project.
library(here)
pkgs <- c("dplyr", "readr", "ggplot2", "broom", "pROC", "car", "here")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

# --- POSTER COLOURS ---
poster_red  <- "#c41f3b"
poster_dark <- "#7a1426"
city_cols   <- c(toronto = "#e0284a", vancouver = "#484848", ottawa = "#d99a0b")

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.background  = element_rect(fill = "white", colour = NA),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "#fbe9ec", colour = NA),
      strip.text       = element_text(face = "bold", colour = poster_dark),
      axis.title       = element_text(colour = poster_dark),
      plot.title       = element_text(face = "bold", colour = poster_dark)
    )
)
