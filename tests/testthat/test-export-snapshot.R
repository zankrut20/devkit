# Tests for export_snapshot()

test_that("export_snapshot returns early when no external packages", {
  local_mocked_bindings(
    readline = function(...) "test_snapshot.R",
    search = function() c(".GlobalEnv", "package:base", "package:stats",
                          "package:utils"),
    .package = "base"
  )

  expect_message(export_snapshot(), "No external packages")
})

test_that("export_snapshot generates flexible install script", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("flex_snapshot.R")
      return("n")
    },
    search = function() c(".GlobalEnv", "package:testthat", "package:base",
                          "package:stats"),
    .package = "base"
  )
  local_mocked_bindings(
    packageVersion = function(pkg) "1.0.0",
    .package = "devkit"
  )

  export_snapshot()
  expect_true(file.exists("flex_snapshot.R"))
  content <- readLines("flex_snapshot.R")
  expect_true(any(grepl("install.packages", content)))
})

test_that("export_snapshot generates strict version script", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("strict_snapshot.R")
      return("y")
    },
    search = function() c(".GlobalEnv", "package:ggplot2", "package:base"),
    .package = "base"
  )
  local_mocked_bindings(
    packageVersion = function(pkg) "3.4.0",
    .package = "devkit"
  )

  export_snapshot()
  expect_true(file.exists("strict_snapshot.R"))
  content <- readLines("strict_snapshot.R")
  expect_true(any(grepl("install_version", content)))
})

test_that("export_snapshot uses default filename when empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("")
      return("n")
    },
    search = function() c(".GlobalEnv", "package:dplyr", "package:base"),
    .package = "base"
  )
  local_mocked_bindings(
    packageVersion = function(pkg) "1.0.0",
    .package = "devkit"
  )

  export_snapshot()
  expect_true(file.exists("requirements.R"))
})

test_that("export_snapshot writes Snapshot header", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("out.R")
      return("n")
    },
    search = function() c(".GlobalEnv", "package:jsonlite", "package:base"),
    .package = "base"
  )
  local_mocked_bindings(
    packageVersion = function(pkg) "1.8.0",
    .package = "devkit"
  )

  export_snapshot()
  content <- readLines("out.R")
  expect_true(any(grepl("Snapshot", content)))
})
