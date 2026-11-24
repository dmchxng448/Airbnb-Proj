# Above 4.9: Modelling Excellence Across Canadian Airbnb Markets

STAT 429 individual poster project, University of Calgary, Fall 2026

Inspired by past trips to **Toronto, Vancouver, and Ottawa,** this project investigates what makes a Canadian Airbnb listing truly "excellent". Using Inside Airbnb data for listings with at least 10 reviews, I apply **logistic regression** to identify which host and property characteristics increase the odds of earning a **4.9+ overall rating** - and test whether those drivers differ across the three cities.

### Research Questions:

1. Which listing and host characteristics are associated with the odds that an established Canadian Airbnb listing holds an overall rating of 4.9 or higher?
2. Do these predictors of "excellence" differ across Toronto, Vancouver, and Ottawa

### Data Sources:

This project uses publicly available short-term rental data from [Inside Airbnb](https://insideairbnb.com), licensed under [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org).

- **Toronto:** Inside Airbnb (2026). *Toronto listings*, 16 September, 2026. Retrieved November 20 2026 from https://insideairbnb.com
- **Vancouver:** Inside Airbnb (2026). *Vancouver listings*, 17 September, 2026. Retrieved November 20, 2026 from https://insideairbnb.com
- **Ottawa:** Inside Airbnb (2026). *Ottawa listings*, 19 September, 2026. Retrieved November 20, 2026 from https://insideairbnb.com

### Variables:

| Variable | Role | Definition |
|---|---|---|
| `excellent` | Outcome | 1 if overall rating ≥ 4.9, else 0 |
| `log_price` | Predictor | Natural log of the nightly price (CAD), after parsing `"$1,234.00"` to a number |
| `room_type` | Predictor | Entire home/apt, private room, shared room, hotel room |
| `accommodates` | Predictor | Maximum number of guests |
| `superhost` | Predictor | Host has Superhost status |
| `instant_book` | Predictor | Listing can be booked without host approval |
| `multi_host` | Predictor | Host has more than 1 listing in the city snapshot |
| `host_years` | Predictor (candidate) | Years since the host joined Airbnb, at scrape date |
| `city` | Predictor | Toronto (reference), Vancouver, Ottawa |
| `rating` | Used for outcome / plots | Overall rating, 0-5 scale |
| `n_reviews` | Inclusion filter | Total number of reviews |
| `price` | Used for `log_price` | Nightly price as listed (CAD) |

### Repository Structure:

```
airbnb-poster/
├── R/                  analysis scripts to be run in numbered order
├── data/
│   ├── raw/            downloaded snapshots (git-ignored)
│   └── processed/      cleaned data and fitted model (git-ignored)
├── output/
│   ├── figures/        PNGs used on the poster
│   └── tables/         odds-ratio table
├── AI_USE.md           log of AI assistance
├── SETUP.md            one-time R / Git / GitHub setup
└── README.md
```

### Workflow:

1. Open `airbnb-poster.Rproj` in RStudio (scripts assume project root is the working directory)
2. Paste the three download URLs into `R/01_download.R`.
3. Run the scripts in order: `01_download.R` → `02_clean.R` → `03_explore.R` → `04_model.R` → `05_diagnostics.R`.
4. Figures go to `output/figures/` and the odds-ratio table to `output/tables/`.

### Limitations:

TBD

### Moving Forward:

TBD

### Acknowledgements:

- Data from [Inside Airbnb](https://insideairbnb.com/), used under CC BY 4.0.
- Sun, B. (2026). STAT 429 lecture notes. University of Calgary.
- AI assistance as disclosed in [AI_USE.md](AI_USE.md).