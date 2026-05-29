#------------------------------------------------------------------------------#
# Documentation for FactorCraft Built-in Datasets
#------------------------------------------------------------------------------#

#' Sample Stock Data
#'
#' A dataset containing daily price and return information for testing.
#'
#' @format A data frame with 5 columns:
#' \describe{
#'   \item{code}{Stock ticker symbol}
#'   \item{date}{Trading date}
#'   \item{close}{Closing price}
#'   \item{volume}{Trading volume}
#'   \item{return}{Daily simple return}
#' }
#' @source Yahoo Finance using quantmod.
"sample_stock_data"

#' Sample Factor Data
#'
#' A dataset with momentum factors for factor analysis and visualization.
#'
#' @format A data frame with 6 columns:
#' \describe{
#'   \item{code}{Stock ticker symbol}
#'   \item{date}{Trading date}
#'   \item{close}{Closing price}
#'   \item{return}{Daily simple return}
#'   \item{mom_5}{5-day momentum}
#'   \item{mom_20}{20-day momentum}
#' }
#' @source Yahoo Finance using quantmod.
"sample_factor_data"

#' Sample Industry and Market Cap Data
#'
#' A dataset for industry neutralization and market capitalization neutralization.
#'
#' @format A data frame with 8 columns:
#' \describe{
#'   \item{code}{Stock ticker symbol}
#'   \item{date}{Trading date}
#'   \item{close}{Closing price}
#'   \item{return}{Daily simple return}
#'   \item{mom_5}{5-day momentum}
#'   \item{mom_20}{20-day momentum}
#'   \item{industry}{Industry classification}
#'   \item{cap_millions}{Market capitalization in millions USD}
#' }
#' @source Yahoo Finance using quantmod.
"sample_industry_data"
