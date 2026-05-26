#' Add Cross-sectional Standardized (Z-score) Factors
#'
#' Add standardized columns by cross-section to normalize factor distributions.
#'
#' @param data data.frame or tibble in standard long format
#' @param cols vector of column names to standardize
#' @param by cross-sectional grouping column (default = "date")
#' @param append if TRUE, append results to input data
#' @param new_col prefix for new columns
#'
#' @return A tibble/data.frame with original columns plus new standardized columns:
#' \itemize{
#'   \item \strong{date}: trading date
#'   \item \strong{code}: stock code
#'   \item \strong{...}: original input columns
#'   \item \strong{std_xxx}: z-score normalized version of input column xxx
#' }
#' @export
add_standardize <- function(
    data,
    cols = NULL,
    by = "date",
    append = TRUE,
    new_col = "std"
) {
  if (!requireNamespace("dplyr", quietly = TRUE))
    stop("dplyr is required")

  data <- data %>%
    dplyr::group_by(!!rlang::sym(by))

  for (col in cols) {
    new_name <- paste0(new_col, "_", col)
    data <- data %>%
      dplyr::mutate(
        !!new_name := (!!rlang::sym(col) - mean(!!rlang::sym(col), na.rm = TRUE)) /
          stats::sd(!!rlang::sym(col), na.rm = TRUE)
      )
  }

  data <- data %>% dplyr::ungroup()

  if (!append) {
    data <- data %>%
      dplyr::select(date, code, dplyr::starts_with(new_col))
  }

  return(data)
}
