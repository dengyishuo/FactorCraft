#' Add Forward (Future) Returns Using Lead Prices
#'
#' Calculate forward-looking (future) returns for multiple holding periods,
#' grouped by stock code. Automatically generates columns like forward_5, forward_10.
#'
#' @param data Standard long data from get_data()
#' @param close_col Close price column
#' @param new_col Prefix for output columns (default: "forward")
#' @param n Vector of forward periods (e.g., c(5,10,20,60,120))
#' @param na.pad Pad trailing NAs
#' @param append If TRUE, append to data; if FALSE, return date+code+name+forward returns
#' @param output "tibble" or "data.frame"
#' @return Data frame or tibble with forward return columns
#' @export
#' @importFrom dplyr group_by mutate ungroup arrange select all_of
#' @importFrom tibble as_tibble
add_forward_return <- function(data,
                               close_col = "close",
                               new_col = "forward",
                               n = c(5, 10, 20, 60, 120),
                               na.pad = TRUE,
                               append = TRUE,
                               output = c("tibble", "data.frame")) {
  # Match arguments
  output <- match.arg(output)
  n <- as.integer(n)

  # Initialize sorted data
  res <- data %>%
    dplyr::group_by(code) %>%
    dplyr::arrange(date, .by_group = TRUE) %>%
    dplyr::ungroup()

  # Calculate forward returns for each period
  for (period in n) {
    colname <- paste0(new_col, "_", period)
    res <- res %>%
      dplyr::group_by(code) %>%
      dplyr::mutate(
        !!colname := as.numeric((dplyr::lead(.data[[close_col]], n = period) / .data[[close_col]]) - 1)
      ) %>%
      dplyr::ungroup()
  }

  # When append = FALSE: return core columns only
  if (!append) {
    keep_cols <- c("date", "code", "name", paste0(new_col, "_", n))
    res <- res %>% dplyr::select(dplyr::all_of(keep_cols))
  }

  # Output format
  if (output == "data.frame") {
    res <- as.data.frame(res, stringsAsFactors = FALSE)
  } else {
    res <- tibble::as_tibble(res)
  }

  return(res)
}
