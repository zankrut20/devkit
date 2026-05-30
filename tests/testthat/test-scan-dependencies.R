# Tests for scan_dependencies()

test_that("scan_dependencies returns early when no R scripts found", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(scan_dependencies(), "No R scripts found")
})

test_that("scan_dependencies cancels when user selects empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(scan_dependencies(), "cancelled")
})

test_that("scan_dependencies returns early when no external packages", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) "script.R",
    .package = "devkit"
  )
  local_mocked_bindings(
    search = function() c(".GlobalEnv", "package:base", "package:stats",
                          "package:utils"),
    .package = "base"
  )

  expect_message(scan_dependencies(), "No external packages")
})

test_that("scan_dependencies detects Package Development context", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")
  writeLines(c("Package: testpkg", "Version: 1.0.0"), "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("script.R", choices))) return("script.R")
      return(character(0))
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    search = function() c(".GlobalEnv", "package:testthat", "package:base",
                          "package:stats"),
    sample = function(x, size, ...) x[seq_len(min(length(x), size))],
    .package = "base"
  )

  expect_message(scan_dependencies(), "Package Development")
})

test_that("scan_dependencies handles Data Analysis context - detach", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("script.R")
      if (any(grepl("Data Analysis", choices))) return("Data Analysis (Free up RAM right now)")
      return(character(0))
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    search = function() c(".GlobalEnv", "package:testthat", "package:base",
                          "package:stats"),
    sample = function(x, size, ...) x[seq_len(min(length(x), size))],
    detach = function(...) invisible(NULL),
    gc = function() NULL,
    .package = "base"
  )

  expect_message(scan_dependencies(), "Active Memory|External")
})

test_that("scan_dependencies handles Raw Script context", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("script.R")
      if (any(grepl("Raw Script", choices))) return("Raw Script (Clean up the code file)")
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    search = function() c(".GlobalEnv", "package:testthat", "package:dplyr",
                          "package:base", "package:stats"),
    sample = function(x, size, ...) x[seq_len(min(length(x), size))],
    .package = "base"
  )

  out <- capture.output(scan_dependencies())
  expect_true(any(grepl("Optimized|library", out)))
})

test_that("scan_dependencies returns invisible TRUE on completion", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "script.R")
  writeLines(c("Package: testpkg"), "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("script.R", choices))) return("script.R")
      return(character(0))
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    search = function() c(".GlobalEnv", "package:testthat", "package:base"),
    sample = function(x, size, ...) x[seq_len(min(length(x), size))],
    .package = "base"
  )

  result <- scan_dependencies()
  expect_equal(result$status, "done")
})
