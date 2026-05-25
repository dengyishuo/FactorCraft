#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' Provides factor generation, industry/market cap neutralization,
#' orthogonalization, winsorizing, standardization, and multi-factor
#' combination, all in a chainable add_* style.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords factor quantitative finance
"_PACKAGE"

#' Pipe operator
#'
#' Import magrittr pipe to support chain syntax
#'
#' @return Pipe operator
#' @importFrom magrittr %>%
#' @export
#' @name %>%
#' @rdname pipe
NULL

#' Resolve dplyr & xts conflict for first()
#'
#' Force use dplyr::first
#' @importFrom dplyr first
#' @export
first <- dplyr::first

#' Resolve dplyr & xts conflict for last()
#'
#' Force use dplyr::last
#' @importFrom dplyr last
#' @export
last <- dplyr::last
