# github-activity-r-c

Small R and C utilities for GitHub activity maintenance.

## R Summary Statistics

This project includes a simple R helper function for calculating basic summary statistics from a numeric vector.

```r
source("R/summary_stats.R")
summary_stats(c(1, 2, 3, NA, 5))
```

## R CSV Dimension Checker

This project includes a simple R helper function for checking the dimensions of a CSV file.

```r
source("R/csv_dimensions.R")
csv_dimensions("examples/sample_data.csv")
```

## R Moving Average

This project includes a simple R helper function for calculating moving averages over a numeric vector.

```r
source("R/moving_average.R")
moving_average(c(1, 2, 3, 4, 5), 3)
```
