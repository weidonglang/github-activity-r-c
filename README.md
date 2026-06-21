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

## C Integer File Statistics

This project includes a small C command-line utility for reading integers from a text file and printing basic statistics.

### Build

```bash
gcc c/integer_file_stats.c -o integer_file_stats
```

### Usage

```bash
./integer_file_stats examples/integers.txt
```

Expected output:

```text
Count: 5
Min: 4
Max: 19
Sum: 57
Mean: 11.40
```
```
