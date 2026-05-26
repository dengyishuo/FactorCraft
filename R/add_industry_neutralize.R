#' Add Industry-Neutralized Factor (Residuals)
#'
#' Compute industry-neutralized factor by cross-sectional regression.
#' The function returns residuals (pure alpha) after removing industry fixed effects.
#'
#' @param data A data.frame or tibble in standard long format
#' @param factor_col Column name of the raw factor to neutralize
#' @param industry_col Column name of industry classification (e.g., "industry")
#' @param by Grouping column for cross-section (default: "date")
#' @param append If TRUE, append to original data
#' @param new_col Prefix for output column
#'
#' @return A tibble/data.frame with original columns plus neutralized factor:
#' \itemize{
#'   \item \strong{date}: Trading date
#'   \item \strong{code}: Stock code
#'   \item \strong{name}: Stock name
#'   \item \strong{industry}: Industry classification
#'   \item \strong{...}: Original input columns
#'   \item \strong{ind_neu_xxx}: Industry-neutralized factor (residual)
#' }
#' @export
add_industry_neutralize <- function(
  data,
  factor_col = NULL,
  industry_col = "industry",
  by = "date",
  append = TRUE,
  new_col = "ind_neu"
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
      !!new_name := .resid_lm(
        y = !!rlang::sym(factor_col),
        x = !!rlang::sym(industry_col)
      )
    ) %>%
    dplyr::ungroup()

  if (!append) {
    data <- data %>%
      dplyr::select(date, code, name, dplyr::all_of(new_name))
  }

  return(data)
}

# Internal: Linear regression residuals (SAFE VERSION)
.resid_lm <- function(y, x) {
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 5) {
    return(y)
  } # 样本太少直接返回

  x_val <- x[valid]
  y_val <- y[valid]

  # 安全判断：行业数 >=2 才做回归
  if (length(unique(x_val)) >= 2) {
    x_val <- as.factor(x_val)
    fit <- tryCatch(
      {
        stats::lm(y_val ~ 0 + x_val)
      },
      error = function(e) NULL
    )

    if (!is.null(fit)) {
      res <- rep(NA_real_, length(y))
      res[valid] <- stats::residuals(fit)
      return(res)
    }
  }

  # 单行业 / 回归失败 → 直接返回原序列
  return(y)
}
