#' Get the dimensions and column names of a CSV file
#'
#' @param file_path Path to the CSV file
#' @return A named list with rows, columns, and column_names
csv_dimensions <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  data <- read.csv(file_path)

  list(
    rows = nrow(data),
    columns = ncol(data),
    column_names = colnames(data)
  )
}

# Example usage (run only if script is executed directly)
if (interactive()) {
  result <- csv_dimensions("examples/sample_data.csv")
  cat("rows:", result$rows, "\n")
  cat("columns:", result$columns, "\n")
  cat("column_names:", result$column_names, "\n")
}