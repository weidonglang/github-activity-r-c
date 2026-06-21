#' Calculate basic summary statistics for a numeric vector
#'
#' @param x A numeric vector
#' @return A named list with count, mean, median, min, max, and sd
summary_stats <- function(x) {
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  valid_x <- x[!is.na(x)]

  if (length(valid_x) == 0) {
    return(list(
      count = 0,
      mean = NA,
      median = NA,
      min = NA,
      max = NA,
      sd = NA
    ))
  }

  list(
    count = length(valid_x),
    mean = mean(valid_x),
    median = median(valid_x),
    min = min(valid_x),
    max = max(valid_x),
    sd = sd(valid_x)
  )
}

# Example usage (run only if script is executed directly)
if (interactive()) {
  cat("Example: summary_stats(c(1, 2, 3, NA, 5))\n")
  print(summary_stats(c(1, 2, 3, NA, 5)))
}