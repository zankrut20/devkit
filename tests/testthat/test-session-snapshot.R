# Tests for export_snapshot() (session_snapshot.R)
# Note: export_snapshot is already tested in test-export-snapshot.R
# This file tests the same function from a different angle

test_that("export_snapshot generates valid R script", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    packageVersion = function(pkg) "3.2.0",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("snapshot_test.R")
      return("n")
    },
    search = function() c(".GlobalEnv", "package:testthat", "package:base"),
    .package = "base"
  )

  export_snapshot()
  content <- readLines("snapshot_test.R")
  expect_true(any(grepl("install.packages", content)))
  # Should contain the package name
  expect_true(any(grepl("testthat", content)))
})

test_that("export_snapshot with strict version includes devtools", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    packageVersion = function(pkg) "3.2.0",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("strict_test.R")
      return("y")
    },
    search = function() c(".GlobalEnv", "package:testthat", "package:base"),
    .package = "base"
  )

  export_snapshot()
  content <- readLines("strict_test.R")
  expect_true(any(grepl("install_version", content)))
  expect_true(any(grepl("3.2.0", content)))
})

test_that("export_snapshot filters base packages correctly", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    packageVersion = function(pkg) "1.0.0",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("filter_test.R")
      return("n")
    },
    search = function() c(".GlobalEnv", "package:base", "package:methods",
                          "package:stats", "package:utils",
                          "package:ggplot2"),
    .package = "base"
  )

  export_snapshot()
  content <- paste(readLines("filter_test.R"), collapse = "\n")
  expect_true(grepl("ggplot2", content))
  expect_false(grepl("\"base\"", content))
  expect_false(grepl("\"methods\"", content))
})
