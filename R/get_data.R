#' Get Standardized Long-Format Stock Data from Yahoo Finance
#'
#' Download OHLCV data for multiple stocks, clean missing values,
#' and return a structured long-format panel data frame.
#' This function is designed for quantitative research, factor engineering,
#' and backtesting pipelines.
#'
#' @param stock_df A data frame with **code** and **name** columns.
#'   Each row represents one stock.
#' @param start_date Character string in "YYYY-MM-DD" format.
#' @param end_date Character string in "YYYY-MM-DD" format.
#' @param output Output type: either `"data.frame"` (default) or `"tibble"`.
#'
#' @return A data frame or tibble with standardized columns:
#' \describe{
#'   \item{date}{Trading date (Date object)}
#'   \item{code}{Stock ticker code}
#'   \item{name}{Stock name}
#'   \item{open}{Opening price}
#'   \item{high}{Highest price}
#'   \item{low}{Lowest price}
#'   \item{close}{Closing price}
#'   \item{adjusted}{Adjusted closing price}
#'   \item{volume}{Trading volume}
#' }
#'
#' @importFrom quantmod getSymbols
#' @importFrom dplyr bind_rows arrange
#' @importFrom zoo na.locf na.approx
#' @importFrom xts as.xts
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # ------------------------------
#' # Example 1: Basic usage (US stocks)
#' # ------------------------------
#' stock_df <- data.frame(
#'   code = c("AAPL", "MSFT", "GOOG"),
#'   name = c("Apple", "Microsoft", "Alphabet")
#' )
#' data <- get_data(
#'   stock_df = stock_df,
#'   start_date = "2023-01-01",
#'   end_date = "2024-01-01"
#' )
#'
#' # ------------------------------
#' # Example 2: Chinese A-shares
#' # ------------------------------
#' stock_df_cn <- data.frame(
#'   code = c("000001.SS", "600000.SS", "000300.SS"),
#'   name = c("PingAn Bank", "SPD Bank", "CSI 300 Index")
#' )
#' data_cn <- get_data(
#'   stock_df = stock_df_cn,
#'   start_date = "2022-01-01",
#'   end_date = "2025-01-01"
#' )
#'
#' # ------------------------------
#' # Example 3: Single stock download
#' # ------------------------------
#' single_stock <- data.frame(
#'   code = "NVDA",
#'   name = "NVIDIA"
#' )
#' data_nvda <- get_data(single_stock, "2023-06-01", "2024-06-01")
#'
#' # ------------------------------
#' # Example 4: Inspect output structure
#' # ------------------------------
#' stock_df <- data.frame(code = "AMZN", name = "Amazon")
#' data <- get_data(stock_df, "2023-01-01", "2023-02-01")
#' str(data)
#' head(data)
#' colnames(data)
#'
#' # ------------------------------
#' # Example 5: Output as tibble
#' # ------------------------------
#' data_tb <- get_data(stock_df, "2023-01-01", "2023-02-01", output = "tibble")
#' }
get_data <- function(stock_df, start_date, end_date, output = c("data.frame", "tibble")) {
  # 匹配输出格式（自动容错）
  output <- match.arg(output)

  # Validate input structure
  if (!inherits(stock_df, "data.frame")) {
    stop("'stock_df' must be a data frame containing 'code' and 'name' columns.")
  }

  required_cols <- c("code", "name")
  if (!all(required_cols %in% colnames(stock_df))) {
    stop(paste0(
      "'stock_df' must contain columns: ",
      paste(required_cols, collapse = ", ")
    ))
  }

  if (nrow(stock_df) == 0) {
    stop("'stock_df' must contain at least one stock.")
  }

  long_df <- data.frame()

  # Download each stock
  for (i in seq_len(nrow(stock_df))) {
    code <- stock_df$code[i]
    name <- stock_df$name[i]
    message("Downloading: ", code, " | ", name)

    # Safe download
    obj <- tryCatch(
      {
        suppressWarnings({
          quantmod::getSymbols(
            Symbols = code,
            src = "yahoo",
            from = start_date,
            to = end_date,
            auto.assign = FALSE
          )
        })
      },
      error = function(e) {
        warning("Download failed for ", code, ": ", e$message)
        return(NULL)
      }
    )

    if (is.null(obj)) next

    # Standardize column names
    colnames(obj) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")

    # Clean missing data
    price_cols <- c("Open", "High", "Low", "Close", "Adjusted")
    obj[, price_cols] <- zoo::na.locf(obj[, price_cols], na.rm = FALSE)
    obj[, "Volume"] <- zoo::na.approx(obj[, "Volume"], na.rm = FALSE)

    # Convert to data frame
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

  # Final sort
  if (nrow(long_df) > 0) {
    long_df <- dplyr::arrange(long_df, date, code)
  }

  # ===================== 新增：输出格式转换 =====================
  if (output == "tibble") {
    long_df <- tibble::as_tibble(long_df)
  }

  message("Download complete. Total rows: ", nrow(long_df))
  return(long_df)
}

# Satisfy R CMD check
globalVariables(c("code", "name"))
