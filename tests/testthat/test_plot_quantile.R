test_that("plot_quantile works for heatmap and bubble", {
  # Load test fixtures
  source("fixtures/test_data.R")

  # Test heatmap
  p1 <- plot_quantile(test_quantile_data, "heatmap")
  expect_true(inherits(p1, "ggplot"))

  # Test bubble plot
  p2 <- plot_quantile(test_quantile_data, "bubble")
  expect_true(inherits(p2, "ggplot"))
})
