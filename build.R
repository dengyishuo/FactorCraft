#------------------------------------------------------------------------------#
# FactorCraft R Package - Build Script
# Author: Deng Yishuo
#------------------------------------------------------------------------------#

# Clear environment
rm(list = ls())

# Install and load required packages
if (!require("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
if (!require("roxygen2", quietly = TRUE)) {
  install.packages("roxygen2")
}

library(devtools)
library(roxygen2)

# Get current package root path
pkg_path <- getwd()
message("Package root directory: ", pkg_path)

#------------------------------------------------------------------------------#
# Step 1: Generate documentation and NAMESPACE using roxygen2
#------------------------------------------------------------------------------#
message("\n=== Generating documentation and NAMESPACE ===")
roxygen2::roxygenise(pkg_path)

#------------------------------------------------------------------------------#
# Step 2: Check package for errors and warnings
#------------------------------------------------------------------------------#
message("\n=== Checking package ===")
devtools::check(pkg_path, document = FALSE)

#------------------------------------------------------------------------------#
# Step 3: Build the package source file
#------------------------------------------------------------------------------#
message("\n=== Building package ===")
devtools::build(pkg_path)

message("\n✅ Build completed successfully!")
