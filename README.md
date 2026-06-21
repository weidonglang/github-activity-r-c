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

## C Student Score Analyzer

This project includes a C command-line utility for reading student scores from a CSV file and printing summary statistics.

### Build

```bash
gcc c/student_score_analyzer.c -o student_score_analyzer
```

### Usage

```bash
./student_score_analyzer examples/student_scores.csv
```

Expected output:

```text
Student Count: 8
Minimum Score: 58
Maximum Score: 95
Average Score: 81.75
Passing Count: 7
Failing Count: 1
Top Student: Hannah (95)
```

## C Sales CSV Report Analyzer

This project includes a C command-line utility for reading sales records from a CSV file and printing summary statistics.

### Build

```bash
gcc c/sales_report.c -o sales_report
```

### Usage

```bash
./sales_report examples/sales.csv
```

Expected output:

```text
Order Count: 8
Total Quantity: 31
Total Revenue: 726.00
Average Order Revenue: 90.75
Top Product: Laptop Stand (275.00)
Top Category: Accessories (463.50)
```

## R Sales CSV Summary Analyzer

This project includes an R utility for reading sales records from a CSV file and printing summary statistics.

### Usage

```r
source("R/sales_summary.R")
result <- analyze_sales_csv("examples/r_sales.csv")
print_sales_summary(result)
```

Expected output:

```text
Order Count: 8
Total Quantity: 28
Total Revenue: 638.48
Average Order Revenue: 79.81
Top Product: Desk Chair (180.00)
Top Category: Electronics (313.50)
```
