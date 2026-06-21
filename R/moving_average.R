#' Calculate moving average over a numeric vector
#'
#' @param x A numeric vector
#' @param window A positive integer specifying the window size
#' @return A numeric vector of length length(x) - window + 1
moving_average <- function(x, window) {
  if (!is.numeric(x)) {
    stop("x must be a numeric vector")
  }
  if (!is.numeric(window) || length(window) != 1 || window <= 0 || window != round(window)) {
    stop("window must be a positive integer")
  }
  if (window > length(x)) {
    stop("window must not be larger than length(x)")
  }

  n <- length(x)
  result_length <- n - window + 1

  result <- vapply(seq_len(result_length), function(i) {
    current_window <- x[i:(i + window - 1)]
    if (all(is.na(current_window))) {
      return(NA_real_)
    }
    mean(current_window, na.rm = TRUE)
  }, numeric(1))

  result
}

# Example usage (run only if script is executed directly)
if (interactive()) {
  cat("moving_average(c(1, 2, 3, 4, 5), 3):\n")
  print(moving_average(c(1, 2, 3, 4, 5), 3))

  cat("\nmoving_average(c(1, NA, 3, 4), 2):\n")
  print(moving_average(c(1, NA, 3, 4), 2))
}