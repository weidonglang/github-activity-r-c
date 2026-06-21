#' Validate that the data contains all required inventory columns
#'
#' @param data A data frame
#' @return Invisible TRUE if valid; stops with error otherwise
validate_inventory_columns <- function(data) {
  required <- c("sku", "product", "category", "stock", "reorder_point", "unit_cost", "monthly_sales")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop("Missing required columns")
  }
  invisible(TRUE)
}

#' Parse stock, reorder_point, unit_cost, and monthly_sales as numeric
#'
#' Invalid entries become NA, which triggers an error.
#'
#' @param data A data frame with the required numeric columns
#' @return Data frame with numeric columns coerced
parse_inventory_numeric_columns <- function(data) {
  numeric_cols <- c("stock", "reorder_point", "unit_cost", "monthly_sales")
  for (col in numeric_cols) {
    orig <- data[[col]]
    parsed <- suppressWarnings(as.numeric(orig))
    if (any(is.na(parsed) & !is.na(orig))) {
      stop("Invalid numeric value")
    }
    data[[col]] <- parsed
  }
  data
}

#' Validate that inventory values are meaningful
#'
#' @param data Data frame with validated columns
#' @return Invisible TRUE if valid; stops with error otherwise
validate_inventory_values <- function(data) {
  if (any(data$sku == "" | is.na(data$sku)) ||
      any(data$product == "" | is.na(data$product)) ||
      any(data$category == "" | is.na(data$category))) {
    stop("Text fields cannot be empty")
  }

  if (any(data$stock < 0) || any(data$reorder_point < 0)) {
    stop("Stock and reorder point cannot be negative")
  }

  if (any(data$unit_cost < 0)) {
    stop("Unit cost cannot be negative")
  }

  if (any(data$monthly_sales <= 0)) {
    stop("Monthly sales must be positive")
  }

  invisible(TRUE)
}

#' Calculate inventory metrics
#'
#' Adds inventory_value, reorder_quantity, estimated_days_left, and status columns.
#'
#' @param data A validated data frame with numeric metric columns
#' @return Data frame with additional derived columns
calculate_inventory_metrics <- function(data) {
  data$inventory_value <- data$stock * data$unit_cost
  data$reorder_quantity <- pmax(data$reorder_point - data$stock, 0)
  data$estimated_days_left <- data$stock / data$monthly_sales * 30

  data$status <- ifelse(data$stock == 0,
    "OUT_OF_STOCK",
    ifelse(data$stock <= data$reorder_point,
      "LOW_STOCK",
      "OK"))

  data
}

#' Summarize inventory by category
#'
#' @param data Data frame with category, stock, inventory_value, and reorder_quantity
#' @return Data frame with category-level aggregates, sorted by total_inventory_value descending
summarize_inventory_by_category <- function(data) {
  result <- aggregate(
    cbind(stock, inventory_value, reorder_quantity) ~ category,
    data = data,
    FUN = sum
  )
  names(result) <- c("category", "total_stock", "total_inventory_value", "total_reorder_quantity")
  result <- result[order(result$total_inventory_value, decreasing = TRUE), ]
  rownames(result) <- NULL
  result
}

#' Find the item with the highest reorder quantity
#'
#' @param data Data frame with sku, product, and reorder_quantity columns
#' @return Named list with sku, product, and reorder_quantity
find_top_reorder_item <- function(data) {
  top <- data[which.max(data$reorder_quantity), ]
  list(
    sku = top$sku,
    product = top$product,
    reorder_quantity = top$reorder_quantity
  )
}

#' Find the category with the highest total inventory value
#'
#' @param category_summary Data frame with category and total_inventory_value columns
#' @return Named list with category and total_inventory_value
find_top_inventory_category <- function(category_summary) {
  top <- category_summary[which.max(category_summary$total_inventory_value), ]
  list(
    category = top$category,
    total_inventory_value = top$total_inventory_value
  )
}

#' Analyze an inventory CSV file and return summary statistics
#'
#' @param file_path Path to the CSV file
#' @return A named list with item_count, total_stock, total_inventory_value,
#'         low_stock_count, out_of_stock_count, total_reorder_quantity,
#'         inventory_data, category_summary, top_reorder_item, and top_inventory_category
analyze_inventory_csv <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File does not exist")
  }

  data <- read.csv(file_path, stringsAsFactors = FALSE)

  if (nrow(data) == 0) {
    stop("No inventory records found")
  }

  validate_inventory_columns(data)

  data <- parse_inventory_numeric_columns(data)

  validate_inventory_values(data)

  data <- calculate_inventory_metrics(data)

  item_count <- nrow(data)
  total_stock <- sum(data$stock)
  total_inventory_value <- sum(data$inventory_value)
  low_stock_count <- sum(data$status == "LOW_STOCK")
  out_of_stock_count <- sum(data$status == "OUT_OF_STOCK")
  total_reorder_quantity <- sum(data$reorder_quantity)

  category_summary <- summarize_inventory_by_category(data)

  top_reorder_item <- find_top_reorder_item(data)
  top_inventory_category <- find_top_inventory_category(category_summary)

  list(
    item_count = item_count,
    total_stock = total_stock,
    total_inventory_value = total_inventory_value,
    low_stock_count = low_stock_count,
    out_of_stock_count = out_of_stock_count,
    total_reorder_quantity = total_reorder_quantity,
    inventory_data = data,
    category_summary = category_summary,
    top_reorder_item = top_reorder_item,
    top_inventory_category = top_inventory_category
  )
}

#' Print a formatted inventory summary
#'
#' @param summary A named list returned by analyze_inventory_csv()
#' @return Invisible NULL; prints output to console
print_inventory_summary <- function(summary) {
  cat("Item Count:", summary$item_count, "\n")
  cat("Total Stock:", summary$total_stock, "\n")
  cat("Total Inventory Value:", sprintf("%.2f", summary$total_inventory_value), "\n")
  cat("Low Stock Items:", summary$low_stock_count, "\n")
  cat("Out of Stock Items:", summary$out_of_stock_count, "\n")
  cat("Total Reorder Quantity:", summary$total_reorder_quantity, "\n")
  cat("Top Reorder Item:", summary$top_reorder_item$product,
      sprintf("(%d)", summary$top_reorder_item$reorder_quantity), "\n")
  cat("Top Inventory Category:", summary$top_inventory_category$category,
      sprintf("(%.2f)", summary$top_inventory_category$total_inventory_value), "\n")
  invisible(NULL)
}

if (sys.nframe() == 0) {
  result <- analyze_inventory_csv("examples/inventory.csv")
  print_inventory_summary(result)
}