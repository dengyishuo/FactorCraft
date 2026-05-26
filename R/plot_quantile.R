#' Factor Quantile Return Visualization (Heatmap / Binary Color Bubble Plot)
#'
#' Create professional heatmap or bubble plot for factor quantile returns.
#' Heatmap: color = return (red positive, green negative), show values.
#' Bubble plot: only red/green colors, bubble size = absolute return, no legend.
#'
#' @param quantile_table A data frame from quantile_analysis(), e.g. result$mom_5
#' @param plot_type Character, either "heatmap" or "bubble"
#' @param title Character, plot title
#'
#' @return A ggplot2 object
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @export
#'
#' @examples
#' \dontrun{
#' plot_quantile(result$mom_5, plot_type = "bubble", title = "5-day Momentum Bubble Plot")
#' plot_quantile(result$mom_5, plot_type = "heatmap", title = "5-day Momentum Heatmap")
#' }
plot_quantile <- function(quantile_table,
                          plot_type = c("heatmap", "bubble"),
                          title = "Factor Quantile Return") {
  plot_type <- match.arg(plot_type)

  data_long <- quantile_table %>%
    tidyr::pivot_longer(
      cols = dplyr::starts_with("forward"),
      names_to = "future",
      values_to = "ret"
    ) %>%
    dplyr::mutate(
      abs_ret = abs(ret),
      ret_label = round(ret, 3),
      direction = ifelse(ret >= 0, "positive", "negative"),
      future = factor(future,
        levels = c(
          "forward_5", "forward_10", "forward_20",
          "forward_60", "forward_90", "forward_120"
        )
      ),
      quantile_group = factor(quantile_group, levels = 1:10)
    )

  p <- ggplot2::ggplot(data_long, ggplot2::aes(x = future, y = quantile_group)) +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::labs(
      title = title,
      x = "Future Period",
      y = "Quantile (1=Worst, 10=Best)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", size = 14))

  # Heatmap
  if (plot_type == "heatmap") {
    p <- p +
      ggplot2::geom_tile(ggplot2::aes(fill = ret), color = "white", linewidth = 1) +
      ggplot2::geom_text(ggplot2::aes(label = ret_label), size = 3.5, fontface = "bold") +
      ggplot2::scale_fill_gradient2(low = "green", mid = "white", high = "red", midpoint = 0)
  }

  # Bubble plot (small size, no legend)
  if (plot_type == "bubble") {
    p <- p +
      ggplot2::geom_point(ggplot2::aes(size = abs_ret, color = direction), alpha = 0.8) +
      ggplot2::geom_text(ggplot2::aes(label = ret_label), size = 3.5, fontface = "bold") +
      ggplot2::scale_color_manual(values = c("positive" = "red", "negative" = "green")) +
      ggplot2::scale_size_continuous(range = c(3, 12)) +
      ggplot2::guides(color = "none", size = "none")
  }

  return(p)
}
