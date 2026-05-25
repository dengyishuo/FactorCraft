# FactorCraft 自动化测试
# 运行方式：devtools::test()

test_that("add_return 函数正常运行", {
  # 构造测试数据
  dat <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 20),
    code = rep("TEST", 20),
    name = rep("测试股票", 20),
    close = c(100 + cumsum(rnorm(19, 0, 1)), 100)
  )

  res <- add_return(dat, n = c(1, 5))
  expect_true(all(c("ret_1", "ret_5") %in% colnames(res)))
})

test_that("add_vol_std 函数正常运行", {
  dat <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
    code = rep("TEST", 30),
    name = rep("测试股票", 30),
    close = c(100 + cumsum(rnorm(29, 0, 1)), 100)
  )

  res <- add_vol_std(dat, n = 5)
  expect_true("vol_std_5" %in% colnames(res))
})

test_that("add_risk_adj_mom 函数正常运行", {
  dat <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30),
    code = rep("TEST", 30),
    name = rep("测试股票", 30),
    close = c(100 + cumsum(rnorm(29, 0, 1)), 100)
  )

  res <- add_risk_adj_mom(dat, n = 10)
  expect_true(all(c("ret_10", "vol_std_10", "ram_10") %in% colnames(res)))
})

test_that("add_sma 函数正常运行", {
  dat <- data.frame(
    date = seq.Date(as.Date("2024-01-01"), by = "day", length.out = 20),
    code = rep("TEST", 20),
    name = rep("测试股票", 20),
    close = c(100 + cumsum(rnorm(19, 0, 1)), 100)
  )

  res <- add_sma(dat, n = 5)
  expect_true("sma_5" %in% colnames(res))
})

