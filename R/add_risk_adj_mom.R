#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' Provides factor generation, industry/market cap neutralization,
#' orthogonalization, winsorizing, standardization, and multi-factor
#' combination, all in a chainable add_* style.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords factor quantitative finance
"_PACKAGE"

#' Add Risk-Adjusted Momentum (RAM)
#'
#' Calculate risk-adjusted momentum using return / risk.
#' Uses consistent naming with add_return() and add_vol_std().
#'
#' @param data Standard long data from get_data()
#' @param close_col Close price column
#' @param new_col Prefix for final RAM factor (default: "ram")
#' @param n Lookback periods (default: c(5,10,20))
#' @param type Return type: "continuous" or "discrete"
#' @param risk_type "vol" (std), "VaR", "CVaR"
#' @param p Confidence level for VaR/CVaR (default 0.95)
#' @param na.pad Pad leading NAs
#' @param append Append to data or return clean factors
#' @param output "tibble" or "data.frame"
#'
#' @return Tibble/data.frame with columns:
#' \itemize{
#'   \item{\code{ret_{n}}}{: Period return (same as add_return)}
#'   \item{\code{vol_std_{n}}}{: Rolling volatility (same as add_vol_std)}
#'   \item{\code{ram_{n}}}{: Risk-adjusted momentum = ret / vol_std}
#' }
#' @export
#' @importFrom dplyr group_by mutate ungroup arrange select all_of
#' @importFrom TTR ROC
#' @importFrom zoo rollapply
#' @importFrom tibble as_tibble
#' @importFrom stats sd quantile
add_risk_adj_mom <- function(data,
                             close_col = "close",
                             new_col = "ram",
                             n = c(5, 10, 20),
                             type = c("continuous", "discrete"),
                             risk_type = c("vol", "VaR", "CVaR"),
                             p = 0.95,
                             na.pad = TRUE,
                             append = TRUE,
                             output = c("tibble", "data.frame")) {
  type <- match.arg(type)
  risk_type <- match.arg(risk_type)
  output <- match.arg(output)
  n <- as.integer(n)

  res <- data %>%
    group_by(code) %>%
    arrange(date, .by_group = TRUE) %>%
    ungroup()

  # 1-day returns for risk calculation
  res <- res %>%
    group_by(code) %>%
    mutate(.ret1 = as.numeric(ROC(
      x = .data[[close_col]], n = 1,
      type = type, na.pad = na.pad
    ))) %>%
    ungroup()

  for (period in n) {
    # === 统一命名：ret_10 ===
    col_ret <- paste0("ret_", period)

    # === 统一命名：vol_std_10 ===
    col_risk <- paste0("vol_std_", period)

    # === 最终因子：ram_10 ===
    col_ram <- paste0(new_col, "_", period)

    # 收益率
    res <- res %>%
      group_by(code) %>%
      mutate(!!col_ret := ROC(.data[[close_col]],
        n = period,
        type = type, na.pad = na.pad
      )) %>%
      ungroup()

    # 风险（滚动标准差 / VaR / CVaR）
    res <- res %>%
      group_by(code) %>%
      mutate(!!col_risk := rollapply(.ret1,
        width = period,
        FUN = function(x) {
          if (risk_type == "vol") {
            return(sd(x, na.rm = TRUE))
          } else if (risk_type == "VaR") {
            q <- quantile(x, 1 - p, na.rm = TRUE)
            return(abs(q))
          } else {
            q <- quantile(x, 1 - p, na.rm = TRUE)
            return(abs(mean(x[x <= q], na.rm = TRUE)))
          }
        },
        fill = NA, align = "right"
      )) %>%
      ungroup()

    # 风险调整动量 = ret / risk
    res <- res %>%
      mutate(!!col_ram := !!sym(col_ret) / !!sym(col_risk))
  }

  res <- res %>% select(-.ret1)

  if (!append) {
    keep_cols <- c("date", "code", "name", paste0(new_col, "_", n))
    res <- res %>% select(all_of(keep_cols))
  }

  if (output == "data.frame") {
    res <- as.data.frame(res, stringsAsFactors = FALSE)
  } else {
    res <- as_tibble(res)
  }

  return(res)
}
