# Quickly generate documentation using roxygen2
rm(list = ls())

if (!requireNamespace("roxygen2", quietly = TRUE)) {
  install.packages("roxygen2")
}

roxygen2::roxygenise()
message("✅ Documentation updated.")
