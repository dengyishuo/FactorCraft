#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' Provides factor generation, industry/market cap neutralization,
#' orthogonalization, winsorizing, standardization, and multi-factor
#' combination, all in a chainable add_* style.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords factor quantitative finance
"_PACKAGE"

#' Batch Download Stock Data and Generate Standard Long Format Data
#'
#' Download historical K-bar data from Yahoo Finance, handle missing values,
#' and return a standardized long format data frame for quantitative analysis
#' and backtesting.
#' Prices are forward-filled; volume is linearly interpolated.
#'
#' @param stock_df Data frame containing code and name columns
#' @param start_date Start date as "YYYY-MM-DD"
#' @param end_date End date as "YYYY-MM-DD"
#'
#' @return Standard long format data frame
#' \itemize{
#'   \item date: Trading date
#'   \item code: Stock code
#'   \item name: Stock name
#'   \item open: Open price
#'   \item high: Highest price
#'   \item low: Lowest price
#'   \item close: Close price
#'   \item adjusted: Adjusted close price
#'   \item volume: Trading volume
#' }
#'
#' @import quantmod
#' @import dplyr
#' @import zoo
#' @import xts
#' @export
#'
#' @examples
#' \dontrun{
#' stock_list <- data.frame(
#'   code = c("000001.SS", "000300.SS"),
#'   name = c("Ping An Bank", "CSI 300")
#' )
#'
#' data <- get_data(
#'   stock_df = stock_list,
#'   start_date = "2020-01-01",
#'   end_date = "2025-01-01"
#' )
#' }
get_data <- function(stock_df, start_date, end_date) {
  if (!all(c("code", "name") %in% colnames(stock_df))) {
    stop("stock_df must contain code and name columns!")
  }

  long_df <- data.frame()

  for (i in 1:nrow(stock_df)) {
    code <- stock_df$code[i]
    name <- stock_df$name[i]
    message("Downloading: ", code, " - ", name)

    obj <- tryCatch(
      {
        suppressWarnings(
          quantmod::getSymbols(code,
            src = "yahoo",
            from = start_date,
            to = end_date,
            auto.assign = FALSE
          )
        )
      },
      error = function(e) {
        warning("Download failed: ", code, " => ", e$message)
        return(NULL)
      }
    )

    if (is.null(obj)) next

    colnames(obj) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")

    price_cols <- c("Open", "High", "Low", "Close", "Adjusted")
    obj[, price_cols] <- zoo::na.locf(obj[, price_cols], na.rm = FALSE)
    obj[, "Volume"] <- zoo::na.approx(obj[, "Volume"], na.rm = FALSE)

    df <- data.frame(
      date = zoo::index(obj),
      code = code,
      name = name,
      open = as.numeric(obj$Open),
      high = as.numeric(obj$High),
      low = as.numeric(obj$Low),
      close = as.numeric(obj$Close),
      adjusted = as.numeric(obj$Adjusted),
      volume = as.numeric(obj$Volume),
      stringsAsFactors = FALSE
    )

    long_df <- dplyr::bind_rows(long_df, df)
  }

  long_df <- long_df %>% dplyr::arrange(date, code)
  message("✅ Download completed. Total rows: ", nrow(long_df))
  return(long_df)
}
