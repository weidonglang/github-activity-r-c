#' Validate that the data contains all required columns
#'
#' @param data A data frame
#' @return Invisible TRUE if valid; stops with error otherwise
validate_sales_columns <- function(data) {
  required <- c("order_id", "product", "category", "quantity", "unit_price")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop("Missing required columns")
  }
  invisible(TRUE)
}

#' Parse quantity and unit_price columns as numeric
#'
#' Invalid entries become NA, which will be caught by later validation.
#'
#' @param data A data frame with quantity and unit_price columns
#' @return Data frame with quantity and unit_price coerced to numeric
parse_sales_numeric <- function(data) {
  data$quantity <- suppressWarnings(as.numeric(data$quantity))
  data$unit_price <- suppressWarnings(as.numeric(data$unit_price))
  data
}

#' Validate that parsed sales values are meaningful
#'
#' @param data Data frame with parsed numeric columns
#' @return Invisible TRUE if valid; stops with error otherwise
validate_sales_values <- function(data) {
  if (any(data$product == "" | is.na(data$product)) ||
      any(data$category == "" | is.na(data$category))) {
    stop("Product and category cannot be empty")
  }

  if (any(is.na(data$quantity)) || any(data$quantity <= 0)) {
    stop("Quantity must be positive numbers")
  }

  if (any(is.na(data$unit_price)) || any(data$unit_price < 0)) {
    stop("Unit price cannot be negative")
  }

  invisible(TRUE)
}

#' Calculate revenue for each row
#'
#' @param data A validated data frame with numeric quantity and unit_price
#' @return Data frame with an additional revenue column
calculate_revenue <- function(data) {
  data$revenue <- data$quantity * data$unit_price
  data
}

#' Summarize revenue by a grouping column
#'
#' @param data Data frame with revenue and group_col columns
#' @param group_col Character string, name of the grouping column
#' @return Data frame with columns name and revenue, sorted descending
summarize_revenue_by_group <- function(data, group_col) {
  result <- aggregate(revenue ~ data[[group_col]], data = data, FUN = sum)
  names(result) <- c("name", "revenue")
  result <- result[order(result$revenue, decreasing = TRUE), ]
  rownames(result) <- NULL
  result
}

#' Find the group with the highest revenue
#'
#' @param summary_data A data frame with columns name and revenue
#' @return Named list with name and revenue
find_top_revenue_group <- function(summary_data) {
  top <- summary_data[which.max(summary_data$revenue), ]
  list(
    name = top$name,
    revenue = top$revenue
  )
}

#' Analyze a sales CSV file and return summary statistics
#'
#' @param file_path Path to the CSV file
#' @return A named list with order_count, total_quantity, total_revenue,
#'         average_order_revenue, product_revenue, category_revenue,
#'         top_product, and top_category
analyze_sales_csv <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File does not exist")
  }

  data <- read.csv(file_path, stringsAsFactors = FALSE)

  if (nrow(data) == 0) {
    stop("No sales records found")
  }

  validate_sales_columns(data)

  data <- parse_sales_numeric(data)

  validate_sales_values(data)

  data <- calculate_revenue(data)

  order_count <- nrow(data)
  total_quantity <- sum(data$quantity)
  total_revenue <- sum(data$revenue)
  average_order_revenue <- total_revenue / order_count

  product_revenue <- summarize_revenue_by_group(data, "product")
  category_revenue <- summarize_revenue_by_group(data, "category")

  top_product <- find_top_revenue_group(product_revenue)
  top_category <- find_top_revenue_group(category_revenue)

  list(
    order_count = order_count,
    total_quantity = total_quantity,
    total_revenue = total_revenue,
    average_order_revenue = average_order_revenue,
    product_revenue = product_revenue,
    category_revenue = category_revenue,
    top_product = top_product,
    top_category = top_category
  )
}

#' Print a formatted sales summary
#'
#' @param summary A named list returned by analyze_sales_csv()
#' @return Invisible NULL; prints output to console
print_sales_summary <- function(summary) {
  cat("Order Count:", summary$order_count, "\n")
  cat("Total Quantity:", summary$total_quantity, "\n")
  cat("Total Revenue:", sprintf("%.2f", summary$total_revenue), "\n")
  cat("Average Order Revenue:", sprintf("%.2f", summary$average_order_revenue), "\n")
  cat("Top Product:", summary$top_product$name,
      sprintf("(%.2f)", summary$top_product$revenue), "\n")
  cat("Top Category:", summary$top_category$name,
      sprintf("(%.2f)", summary$top_category$revenue), "\n")
  invisible(NULL)
}

if (sys.nframe() == 0) {
  result <- analyze_sales_csv("examples/r_sales.csv")
  print_sales_summary(result)
}