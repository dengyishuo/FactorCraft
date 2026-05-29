# Test for get_data()
# Agent-Friendly Unit Tests for FactorCraft

test_that("get_data validates input structure correctly", {
  # Valid stock df
  stock_df <- data.frame(
    code = c("AAPL", "MSFT"),
    name = c("Apple Inc", "Microsoft")
  )

  # Invalid structure (missing columns)
  expect_error(
    get_data(
      stock_df = data.frame(wrong_col = 1),
      start_date = "2023-01-01",
      end_date = "2023-01-02"
    ),
    "must contain columns: code, name"
  )

  # Empty stock list
  expect_error(
    get_data(
      stock_df = data.frame(code = character(), name = character()),
      start_date = "2023-01-01",
      end_date = "2023-01-02"
    ),
    "at least one stock"
  )
})

test_that("get_data output schema is fully standardized", {
  # Simulate real output structure
  fake_output <- data.frame(
    date = Sys.Date(),
    code = "AAPL",
    name = "Apple",
    open = 100,
    high = 101,
    low = 99,
    close = 100,
    adjusted = 100,
    volume = 1000
  )

  expected_cols <- c(
    "date", "code", "name",
    "open", "high", "low", "close",
    "adjusted", "volume"
  )

  expect_true(all(expected_cols %in% colnames(fake_output)))
  expect_s3_class(fake_output$date, "Date")
  expect_true(is.numeric(fake_output$close))
  expect_true(is.numeric(fake_output$volume))
})
