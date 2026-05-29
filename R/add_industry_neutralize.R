#' Add Industry-Neutralized Factor (Residuals)
#'
#' Compute industry-neutralized factor using cross-sectional regression.
#' Returns residuals after removing industry fixed effects.
#'
#' @param data Data.frame or tibble in long format
#' @param factor_col Column name of raw factor
#' @param industry_col Column name of industry indicator
#' @param by Grouping column for cross-section (default: date)
#' @param append If TRUE, append result to input data
#' @param new_col Prefix for new column name
#'
#' @return Data with industry-neutralized factor
#' @importFrom rlang sym !!
#' @export
add_industry_neutralize <- function(
  data,
  factor_col = NULL,
  industry_col = "industry",
  by = "date",
  append = TRUE,
  new_col = "ind_neu"
) {
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required")
  if (!requireNamespace("stats", quietly = TRUE)) stop("stats is required")

  if (is.null(factor_col)) stop("Specify factor_col to neutralize")

  new_name <- paste0(new_col, "_", factor_col)

  data <- data %>%
    dplyr::group_by(!!rlang::sym(by)) %>%
    dplyr::mutate(
      !!new_name := .resid_lm(!!rlang::sym(factor_col), !!rlang::sym(industry_col))
    ) %>%
    dplyr::ungroup()

  if (!append) {
    data <- data %>% dplyr::select(date, code, name, dplyr::all_of(new_name))
  }

  return(data)
}

.resid_lm <- function(y, x) {
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 5) {
    return(y)
  }

  x_val <- x[valid]
  y_val <- y[valid]

  if (length(unique(x_val)) >= 2) {
    x_val <- as.factor(x_val)
    fit <- tryCatch(stats::lm(y_val ~ 0 + x_val), error = function(e) NULL)

    if (!is.null(fit)) {
      res <- rep(NA_real_, length(y))
      res[valid] <- stats::residuals(fit)
      return(res)
    }
  }

  return(y)
}
