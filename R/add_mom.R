#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' Provides factor generation, industry/market cap neutralization,
#' orthogonalization, winsorizing, standardization, and multi-factor
#' combination, all in a chainable add_* style.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords factor quantitative finance
"_PACKAGE"

#' Add Momentum Factor(s)
#'
#' Calculate momentum factors using TTR::ROC for multiple periods, grouped by stock.
#' Accepts n as a single value OR a vector (e.g., n = c(2,5,10)).
#'
#' @param data Standard long data from get_data()
#' @param close_col Close price column
#' @param new_col Prefix for auto-naming (default: "mom")
#' @param n Lookback period(s) (single value or vector, e.g., c(2,5,10))
#' @param type "continuous" (log) or "discrete" (simple)
#' @param na.pad Pad leading NAs
#' @param append If TRUE, append to data; if FALSE, return date+code+name+factors
#' @param output "tibble" or "data.frame"
#'
#' @return Data frame or tibble with momentum factor(s)
#' @export
#' @importFrom dplyr group_by mutate ungroup arrange select across all_of
#' @importFrom TTR ROC
#' @importFrom tibble as_tibble
add_mom <- function(data,
                    close_col = "close",
                    new_col = "mom",
                    n = c(2, 5, 10),
                    type = c("continuous", "discrete"),
                    na.pad = TRUE,
                    append = TRUE,
                    output = c("tibble", "data.frame")) {
  # Match official arguments
  type <- match.arg(type)
  output <- match.arg(output)
  n <- as.integer(n)

  # Group & sort data
  res <- data %>%
    dplyr::group_by(code) %>%
    dplyr::arrange(date, .by_group = TRUE) %>%
    dplyr::ungroup()

  # Loop over all n periods to compute momentum
  for (period in n) {
    colname <- paste0(new_col, "_", period)
    res <- res %>%
      dplyr::group_by(code) %>%
      dplyr::mutate(
        !!colname := as.numeric(TTR::ROC(
          x = .data[[close_col]],
          n = period,
          type = type,
          na.pad = na.pad
        ))
      ) %>%
      dplyr::ungroup()
  }

  # If append = FALSE, keep date + code + name + momentum columns
  if (!append) {
    keep_cols <- c("date", "code", "name", paste0(new_col, "_", n))
    res <- res %>% dplyr::select(dplyr::all_of(keep_cols))
  }

  # Output format
  if (output == "data.frame") {
    res <- as.data.frame(res, stringsAsFactors = FALSE)
  } else {
    res <- tibble::as_tibble(res)
  }

  return(res)
}
