#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' FactorCraft provides a complete, agent-friendly toolkit for quantitative
#' factor research, including data download, cleaning, momentum calculation,
#' industry/market cap neutralization, standardization, winsorization,
#' quantile analysis, and visualization.
#'
#' All functions use a unified, predictable interface and produce
#' standardized outputs for both human researchers and AI/LLM agents.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords quantitative finance factor engineering agent-friendly
"_PACKAGE"

globalVariables(c(
  "code", "name", "date", "close", "return", "industry", "cap",
  "mom_5", "mom_20", "vol_10", "quantile_group", "ret", "direction",
  ".ret1", ".ret_tmp", "future", "ret_label", "abs_ret"
))
