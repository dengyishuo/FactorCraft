#' Full Factor Preprocessing Pipeline (One-Stop Function)
#'
#' One-click full standard factor preprocessing:
#' Winsorize -> Standardize -> Industry Neutralize -> Size Neutralize
#'
#' @param data data.frame or tibble
#' @param factor_col column name of raw factor to process
#' @param industry_col industry column name
#' @param size_col market cap column name
#' @param probs winsorize quantiles (default c(0.01, 0.99))
#' @param append if TRUE, append to data
#'
#' @return A tibble with FULL preprocessed factors:
#' \itemize{
#'   \item \strong{date}: trading date
#'   \item \strong{code}: stock code
#'   \item \strong{name}: stock name
#'   \item \strong{industry}: industry
#'   \item \strong{size}: market cap
#'   \item \strong{win_xxx}: winsorized factor
#'   \item \strong{std_xxx}: standardized factor
#'   \item \strong{ind_neu_xxx}: industry-neutralized factor
#'   \item \strong{full_neu_xxx}: FINAL fully processed factor (industry + size neutralized)
#' }
#' @export
add_factor_preprocess <- function(
  data,
  factor_col,
  industry_col = "industry",
  size_col = "size",
  probs = c(0.01, 0.99),
  append = TRUE
) {
  # Step 1: 去极值
  data <- add_winsorize(
    data = data,
    cols = factor_col,
    probs = probs,
    append = TRUE
  )

  win_col <- paste0("win_", factor_col)

  # Step 2: 标准化
  data <- add_standardize(
    data = data,
    cols = win_col,
    append = TRUE
  )

  std_col <- paste0("std_", win_col)

  # Step 3: 行业中性化
  data <- add_industry_neutralize(
    data = data,
    factor_col = std_col,
    industry_col = industry_col,
    append = TRUE
  )

  ind_col <- paste0("ind_neu_", std_col)

  # Step 4: 市值中性化（最终因子）
  data <- add_size_neutralize(
    data = data,
    factor_col = ind_col,
    size_col = size_col,
    append = TRUE
  )

  # Rename final column for clarity
  final_col <- paste0("full_neu_", factor_col)
  data[[final_col]] <- data[[paste0("size_neu_", ind_col)]]

  if (!append) {
    data <- data %>%
      dplyr::select(date, code, name, dplyr::all_of(final_col))
  }

  return(data)
}
