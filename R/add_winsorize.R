#' Add Winsorized (Outlier-Clipped) Factors
#'
#' Add cross-sectionally winsorized columns to limit the impact of extreme outliers.
#'
#' @param data data.frame or tibble in standard long format
#' @param cols vector of column names to winsorize
#' @param by cross-sectional grouping column (default = "date")
#' @param probs lower and upper quantile limits (default = c(0.01, 0.99))
#' @param append if TRUE, append results to input data
#' @param new_col prefix for new columns
#'
#' @return A tibble or data frame with original columns and winsorized factors:
#' \describe{
#'   \item{date}{Trading date}
#'   \item{code}{Stock code}
#'   \item{...}{All original input columns}
#'   \item{\code{win_xxx}}{Winsorized factor (outliers clipped to quantile limits)}
#' }
#' @export
#' @importFrom dplyr group_by mutate ungroup select starts_with
#' @importFrom rlang sym !! :=
add_winsorize <- function(
  data,
  cols = NULL,
  by = "date",
  probs = c(0.01, 0.99),
  append = TRUE,
  new_col = "win"
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
        !!new_name := .winsorize(!!rlang::sym(col), probs)
      )
  }

  data <- data %>% dplyr::ungroup()

  if (!append) {
    data <- data %>%
      dplyr::select(date, code, dplyr::starts_with(new_col))
  }

  return(data)
}

.winsorize <- function(x, probs) {
  q <- stats::quantile(x, probs = probs, na.rm = TRUE)
  x[x < q[1]] <- q[1]
  x[x > q[2]] <- q[2]
  x
}
