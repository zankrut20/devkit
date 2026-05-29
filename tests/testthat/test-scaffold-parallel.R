# Tests for scaffold_parallel()

test_that("scaffold_parallel returns early when parallel not available", {
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )

  expect_message(scaffold_parallel(), "parallel.*missing")
})

test_that("scaffold_parallel returns early when cores undetectable", {
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() NA,
    .package = "parallel"
  )

  expect_message(scaffold_parallel(), "Could not determine")
})

test_that("scaffold_parallel cancels when user selects empty", {
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() 4L,
    .package = "parallel"
  )

  expect_message(scaffold_parallel(), "cancelled")
})

test_that("scaffold_parallel generates and prints scaffold to console", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("^[0-9]+$", choices))) return("2")
      return("Done")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    readline = function(prompt = "", ...) {
      if (grepl("list|vector", prompt)) return("my_data")
      if (grepl("function", prompt)) return("process")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() 4L,
    .package = "parallel"
  )

  out <- capture.output(scaffold_parallel())
  expect_true(any(grepl("parLapply", out)))
  expect_true(any(grepl("my_data", out)))
  expect_true(any(grepl("process", out)))
})

test_that("scaffold_parallel saves to file when user selects Save", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("^[0-9]+$", choices))) return("4")
      return("Save to parallel_scaffold.R")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    readline = function(prompt = "", ...) {
      if (grepl("list|vector", prompt)) return("dataset")
      if (grepl("function", prompt)) return("heavy_func")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() 8L,
    .package = "parallel"
  )

  capture.output(scaffold_parallel(), type = "output")
  expect_true(file.exists("parallel_scaffold.R"))
  content <- readLines("parallel_scaffold.R")
  expect_true(any(grepl("parLapply", content)))
})

test_that("scaffold_parallel uses defaults when input is empty", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("^[0-9]+$", choices))) return("1")
      return("Done")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    readline = function(prompt = "", ...) "",
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() 4L,
    .package = "parallel"
  )

  out <- capture.output(scaffold_parallel())
  expect_true(any(grepl("my_data", out)))
  expect_true(any(grepl("my_heavy_function", out)))
})

test_that("scaffold_parallel returns invisible TRUE", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("^[0-9]+$", choices))) return("2")
      return("Done")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    readline = function(prompt = "", ...) "test",
    .package = "base"
  )
  local_mocked_bindings(
    detectCores = function() 4L,
    .package = "parallel"
  )

  result <- capture.output(res <- scaffold_parallel(), type = "output")
  expect_true(res)
})
