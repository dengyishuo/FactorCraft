#' Full Factor Preprocessing Pipeline (One-Stop Function)
#'
#' One-click full standard factor preprocessing:
#' Winsorize -> Standardize -> Industry Neutralize -> Size Neutralize
#'
#' @param data data.frame or tibble in long format (required: date, code, name)
#' @param factor_col Character. Column name of the raw factor to process.
#' @param industry_col Character. Column name for industry classification. Default: "industry".
#' @param size_col Character. Column name for market capitalization (size). Default: "size".
#' @param probs Numeric vector. Winsorization quantiles (lower, upper). Default: c(0.01, 0.99).
#' @param append Logical. If TRUE, append new columns to input data; if FALSE, return only key columns + final factor. Default: TRUE.
#'
#' @return A tibble with fully preprocessed factor columns:
#' \describe{
#'   \item{date}{Trading date (Date format)}
#'   \item{code}{Stock ticker symbol (character)}
#'   \item{name}{Stock name (character)}
#'   \item{\code{win_*}}{Winsorized version of the raw factor}
#'   \item{\code{std_*}}{Standardized (z-score) version after winsorization}
#'   \item{\code{ind_neu_*}}{Industry-neutralized factor (residuals from industry regression)}
#'   \item{\code{full_neu_*}}{Final fully processed factor (industry + size neutralized)}
#' }
#' @export
#' @importFrom dplyr select all_of
add_factor_preprocess <- function(
  data,
  factor_col,
  industry_col = "industry",
  size_col = "size",
  probs = c(0.01, 0.99),
  append = TRUE
) {
  # Step 1: Winsorize
  data <- add_winsorize(
    data = data,
    cols = factor_col,
    probs = probs,
    append = TRUE
  )
  win_col <- paste0("win_", factor_col)

  # Step 2: Standardize
  data <- add_standardize(
    data = data,
    cols = win_col,
    append = TRUE
  )
  std_col <- paste0("std_", win_col)

  # Step 3: Industry neutralize
  data <- add_industry_neutralize(
    data = data,
    factor_col = std_col,
    industry_col = industry_col,
    append = TRUE
  )
  ind_col <- paste0("ind_neu_", std_col)

  # Step 4: Size neutralize (final factor)
  data <- add_size_neutralize(
    data = data,
    factor_col = ind_col,
    size_col = size_col,
    append = TRUE
  )

  # Rename final column for clarity
  final_col <- paste0("full_neu_", factor_col)
  data[[final_col]] <- data[[paste0("size_neu_", ind_col)]]

  # Subset if not appending
  if (!append) {
    data <- data %>%
      dplyr::select(date, code, name, dplyr::all_of(final_col))
  }

  return(data)
}
