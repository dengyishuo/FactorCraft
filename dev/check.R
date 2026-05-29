# Run package check (R CMD check)
rm(list = ls())

if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

devtools::check(
  document = FALSE,
  args = "--no-manual"
)
