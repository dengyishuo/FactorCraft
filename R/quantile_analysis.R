#' Multi-Factor Quantile Return Analysis
#'
#' Automatically split all momentum factors into quantile groups,
#' calculate average forward returns for each group, and return a list.
#'
#' @param data Clean data (no NA) with factors and forward returns
#' @param mom_cols Vector of momentum factor columns (e.g., c("mom_5","mom_10"))
#' @param forward_cols Vector of forward return columns (e.g., c("forward_5"))
#' @param n_groups Number of quantile groups (default = 10)
#' @param output "tibble" or "data.frame"
#'
#' @return List of quantile return tables (one per momentum factor)
#' @export
#' @importFrom dplyr group_by mutate ungroup summarise across arrange
#' @importFrom tibble as_tibble
#' @importFrom stats quantile
quantile_analysis <- function(data,
                              mom_cols,
                              forward_cols,
                              n_groups = 10,
                              output = c("tibble", "data.frame")) {
  output <- match.arg(output)
  result_list <- list()

  for (mom in mom_cols) {
    # Assign quantile groups
    data$quantile_group <- as.integer(
      cut(
        x = data[[mom]],
        breaks = stats::quantile(data[[mom]],
          probs = seq(0, 1, length.out = n_groups + 1),
          na.rm = TRUE
        ),
        include.lowest = TRUE,
        labels = 1:n_groups
      )
    )

    # Summarize group returns
    group_ret <- data %>%
      dplyr::group_by(quantile_group) %>%
      dplyr::summarise(
        dplyr::across(dplyr::all_of(forward_cols), mean, na.rm = TRUE),
        count = dplyr::n(),
        .groups = "drop"
      ) %>%
      dplyr::arrange(quantile_group)

    # Format output
    if (output == "data.frame") {
      group_ret <- as.data.frame(group_ret)
    } else {
      group_ret <- tibble::as_tibble(group_ret)
    }

    result_list[[mom]] <- group_ret
  }

  return(result_list)
}
