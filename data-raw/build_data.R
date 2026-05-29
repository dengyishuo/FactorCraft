#------------------------------------------------------------------------------#
# Build built-in datasets for FactorCraft
# Source: Yahoo Finance via quantmod
#------------------------------------------------------------------------------#

if (!require("quantmod")) install.packages("quantmod")
if (!require("dplyr")) install.packages("dplyr")
if (!require("lubridate")) install.packages("lubridate")
if (!require("usethis")) install.packages("usethis")

library(quantmod)
library(dplyr)
library(lubridate)
library(usethis)

#------------------------------------------------------------------------------#
# Download data from Yahoo Finance
#------------------------------------------------------------------------------#
tickers <- c(
  "AAPL", "MSFT", "AMZN", "GOOG", "META",
  "JPM", "V", "NVDA", "JNJ", "WMT"
)

start_date <- "2022-01-01"
end_date <- "2025-01-01"

raw_data <- list()

for (ticker in tickers) {
  cat("Downloading:", ticker, "\n")

  # Download OHLC data
  ohlc <- getSymbols(ticker, from = start_date, to = end_date, auto.assign = FALSE)
  df <- as.data.frame(ohlc)
  df$date <- index(ohlc)

  # Standardize column names (remove ticker prefix)
  colnames(df) <- sub(paste0(ticker, "\\."), "", colnames(df))
  colnames(df) <- tolower(colnames(df))

  # Add stock code
  df$code <- ticker

  raw_data[[ticker]] <- df
}

# Combine all data
data <- bind_rows(raw_data)

#------------------------------------------------------------------------------#
# Compute returns and momentum factors
#------------------------------------------------------------------------------#
data <- data %>%
  group_by(code) %>%
  arrange(date) %>%
  mutate(
    return = close / lag(close) - 1,
    log_return = log(close / lag(close)),
    mom_5 = (close / lag(close, 5) - 1) * 100,
    mom_20 = (close / lag(close, 20) - 1) * 100
  ) %>%
  ungroup()

#------------------------------------------------------------------------------#
# Assign industry and market cap
#------------------------------------------------------------------------------#
industry_map <- data.frame(
  code = c("AAPL", "MSFT", "AMZN", "GOOG", "META", "JPM", "V", "NVDA", "JNJ", "WMT"),
  industry = c(
    "Technology", "Technology", "Consumer", "Technology", "Technology",
    "Finance", "Finance", "Technology", "Healthcare", "Consumer"
  )
)

data <- data %>% left_join(industry_map, by = "code")

set.seed(123)
cap_data <- data %>%
  distinct(code) %>%
  mutate(cap_millions = round(exp(runif(n(), 8, 12))))

data <- data %>% left_join(cap_data, by = "code")

#------------------------------------------------------------------------------#
# Create final clean datasets
#------------------------------------------------------------------------------#
sample_stock_data <- data %>%
  select(code, date, close, volume, return) %>%
  filter(complete.cases(.))

sample_factor_data <- data %>%
  select(code, date, close, return, mom_5, mom_20) %>%
  filter(complete.cases(.))

sample_industry_data <- data %>%
  select(code, date, close, return, mom_5, mom_20, industry, cap_millions) %>%
  filter(complete.cases(.))

#------------------------------------------------------------------------------#
# Save to R package
#------------------------------------------------------------------------------#
use_data(sample_stock_data, overwrite = TRUE)
use_data(sample_factor_data, overwrite = TRUE)
use_data(sample_industry_data, overwrite = TRUE)

message("✅ Datasets built successfully!")
