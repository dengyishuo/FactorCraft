# Test fixtures for FactorCraft unit tests
# Small, stable, predictable datasets for testing functions

# Small stock panel (1 stock, 30 days)
test_small_stock <- data.frame(
  code = rep("TEST", 30),
  date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
  close = c(
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
    110, 112, 114, 113, 112, 111, 110, 109, 108, 107,
    106, 108, 110, 112, 111, 110, 109, 108, 109, 110
  )
) %>%
  dplyr::mutate(return = close / dplyr::lag(close) - 1)

# 3-stock panel with industry + cap (for neutralization tests)
test_industry_data <- data.frame(
  code = rep(c("A", "B", "C"), each = 30),
  date = rep(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30), 3),
  close = c(rnorm(30, 100, 5), rnorm(30, 200, 10), rnorm(30, 150, 8)),
  industry = rep(c("Tech", "Finance", "Healthcare"), each = 30),
  cap = rep(c(1e9, 2e9, 3e9), each = 30)
) %>%
  dplyr::group_by(code) %>%
  dplyr::mutate(return = close / dplyr::lag(close) - 1) %>%
  dplyr::ungroup()

# Quantile test data (for quantile_analysis & plot_quantile)
test_quantile_data <- data.frame(
  quantile_group = 1:10,
  forward_5 = rnorm(10, 0, 0.02),
  forward_10 = rnorm(10, 0, 0.03),
  forward_20 = rnorm(10, 0, 0.04),
  forward_60 = rnorm(10, 0, 0.05),
  forward_90 = rnorm(10, 0, 0.06),
  forward_120 = rnorm(10, 0, 0.07),
  count = sample(200:500, 10)
)
