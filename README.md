# What makes a Canadian Airbnb listing "excellent"?

*Logistic regression on Inside Airbnb data for Toronto, Vancouver and Montreal.*

> STAT 429 individual poster project. The sections marked TODO are yours to write.

## Research question
TODO: state it in your own words. (Working version: which listing and host
characteristics are associated with the odds that a listing with at least 10
reviews holds an overall rating of 4.9 or higher, and do these differ by city?)

## Data
- **Source:** Inside Airbnb, detailed `listings.csv.gz` for Toronto, Vancouver and
  Montreal, snapshots dated TODO. https://insideairbnb.com/get-the-data/
- **Licence:** CC BY 4.0. Cite as: Inside Airbnb (2026). *[City] listings,
  [snapshot date].* Retrieved [date] from https://insideairbnb.com/get-the-data/
- Raw data is not committed (it's large). Run `R/01_download.R` to recreate it.

## How to reproduce
1. Open `airbnb-poster.Rproj` in RStudio.
2. Paste the three download URLs into `R/01_download.R`.
3. Run the scripts in order: `01_download.R` → `02_clean.R` → `03_explore.R` → `04_model.R` → `05_diagnostics.R`.
4. Figures go to `output/figures/` and the odds-ratio table to `output/tables/`.

## Method
TODO: outcome definition, inclusion criteria, predictors, how you chose the final model.

## Key findings
TODO

## Limitations
TODO

## Use of AI
See [AI_USE.md](AI_USE.md).
