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
#' @return A tibble or data frame with original columns and standardized factors:
#' \describe{
#'   \item{date}{Trading date}
#'   \item{code}{Stock code}
#'   \item{...}{All original input columns}
#'   \item{\code{std_xxx}}{Z-score normalized factor (mean = 0, sd = 1)}
#' }
#' @export
#' @importFrom dplyr group_by mutate ungroup select starts_with
#' @importFrom rlang sym !! :=
add_standardize <- function(
  data,
  cols = NULL,
  by = "date",
  append = TRUE,
  new_col = "std"
) {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("dplyr is required")
  }

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
