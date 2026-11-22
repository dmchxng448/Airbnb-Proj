# 00_packages.R -- install (once) and load the packages used in this project.
library(here)
pkgs <- c("dplyr", "readr", "ggplot2", "broom", "pROC", "car", "here")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

