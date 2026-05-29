#' Add Size-Neutralized Factor (Market Cap Neutralization)
#'
#' Compute size-neutralized factor by cross-sectional regression on log market cap.
#' Returns residuals after removing market capitalization effect.
#'
#' @param data A data.frame or tibble in standard long format
#' @param factor_col Column name of the raw factor to neutralize
#' @param size_col Column name of market cap (total cap / float cap)
#' @param by Grouping column for cross-section (default: "date")
#' @param append If TRUE, append to original data
#' @param new_col Prefix for output column
#'
#' @return A tibble or data frame with original columns and a size-neutralized factor.
#' \describe{
#'   \item{date}{Trading date}
#'   \item{code}{Stock code}
#'   \item{name}{Stock name}
#'   \item{size}{Market capitalization}
#'   \item{...}{All original input columns}
#'   \item{size_neu_xxx}{Size-neutralized factor (regression residuals)}
#' }
#' @export
#' @importFrom dplyr group_by mutate ungroup select all_of
#' @importFrom rlang sym !! :=
add_size_neutralize <- function(
  data,
  factor_col = NULL,
  size_col = "size",
  by = "date",
  append = TRUE,
  new_col = "size_neu"
) {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("dplyr is required")
  }
  if (!requireNamespace("stats", quietly = TRUE)) {
    stop("stats is required")
  }

  if (is.null(factor_col)) {
    stop("Please specify factor_col to neutralize")
  }

  new_name <- paste0(new_col, "_", factor_col)

  data <- data %>%
    dplyr::group_by(!!rlang::sym(by)) %>%
    dplyr::mutate(
      !!new_name := .resid_lm_size(
        y = !!rlang::sym(factor_col),
        x = !!rlang::sym(size_col)
      )
    ) %>%
    dplyr::ungroup()

  if (!append) {
    data <- data %>%
      dplyr::select(date, code, name, dplyr::all_of(new_name))
  }

  return(data)
}

# Internal: Linear regression residual for size neutralization
.resid_lm_size <- function(y, x) {
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 3) {
    return(rep(NA_real_, length(y)))
  }

  log_x <- log(x[valid])
  y_valid <- y[valid]

  fit <- stats::lm(y_valid ~ log_x)
  res <- rep(NA_real_, length(y))
  res[valid] <- stats::residuals(fit)
  return(res)
}
