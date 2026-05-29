#' Add Rolling Std Volatility Factor (Multi-period)
#'
#' Calculate rolling return volatility (standard deviation) for A-share stocks.
#' Support single period or vector multi-period batch calculation.
#' Volatility is based on periodic return series, reflecting price fluctuation risk.
#'
#' @param data Standard long data from get_data()
#' @param close_col Column name for close price, default "close"
#' @param new_col Prefix for output volatility columns, default "vol_std"
#' @param n Lookback period vector, default c(5,10,20)
#' @param type Return type for internal return calculation,
#'        "continuous" (log return) or "discrete" (simple return)
#' @param na.pad Logical, whether to pad leading NA values, default TRUE
#' @param append If TRUE, append new columns to original data;
#'        if FALSE, return only date + code + name + volatility columns
#' @param output "tibble" or "data.frame", define output object type
#'
#' @return Tibble or data.frame with volatility factor columns
#' @export
#' @importFrom dplyr group_by mutate ungroup arrange select all_of
#' @importFrom TTR ROC
#' @importFrom zoo rollapply
#' @importFrom tibble as_tibble
add_vol_std <- function(data,
                        close_col = "close",
                        new_col = "vol_std",
                        n = c(5, 10, 20),
                        type = c("continuous", "discrete"),
                        na.pad = TRUE,
                        append = TRUE,
                        output = c("tibble", "data.frame")) {
  # Match argument settings
  type <- match.arg(type)
  output <- match.arg(output)
  n <- as.integer(n)

  # Sort data by stock and date to ensure time series correctness
  res <- data %>%
    dplyr::group_by(code) %>%
    dplyr::arrange(date, .by_group = TRUE) %>%
    dplyr::ungroup()

  # Calculate 1-period return for rolling std calculation
  res <- res %>%
    dplyr::group_by(code) %>%
    dplyr::mutate(
      .ret_tmp = as.numeric(TTR::ROC(
        x = .data[[close_col]],
        n = 1,
        type = type,
        na.pad = na.pad
      ))
    ) %>%
    dplyr::ungroup()

  # Loop through all periods to calculate rolling volatility
  for (period in n) {
    colname <- paste0(new_col, "_", period)
    res <- res %>%
      dplyr::group_by(code) %>%
      dplyr::mutate(
        !!colname := zoo::rollapply(
          .ret_tmp,
          width = period,
          FUN = sd,
          fill = NA,
          align = "right"
        )
      ) %>%
      dplyr::ungroup()
  }

  # Remove temporary return column
  res <- res %>% dplyr::select(-.ret_tmp)

  # Slim output: only keep date/code/name + factor columns
  if (!append) {
    keep_cols <- c("date", "code", "name", paste0(new_col, "_", n))
    res <- res %>% dplyr::select(dplyr::all_of(keep_cols))
  }

  # Convert output format
  if (output == "data.frame") {
    res <- as.data.frame(res, stringsAsFactors = FALSE)
  } else {
    res <- tibble::as_tibble(res)
  }

  return(res)
}
