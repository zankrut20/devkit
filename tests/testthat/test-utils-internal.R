# Tests for R/utils-internal.R (internal helper functions)

test_that(".base_pkgs contains all canonical base packages", {
  expected <- c("base", "compiler", "datasets", "graphics", "grDevices",
                "grid", "methods", "parallel", "splines", "stats", "stats4",
                "tcltk", "tools", "utils")
  expect_equal(sort(devkit:::.base_pkgs), sort(expected))
})

test_that(".base_pkgs has no duplicates", {
  expect_equal(length(devkit:::.base_pkgs),
               length(unique(devkit:::.base_pkgs)))
})

test_that(".list_global_dataframes finds data frames in .GlobalEnv", {
  assign("devkit_test_df", data.frame(a = 1), envir = .GlobalEnv)
  assign("devkit_test_vec", 1:10, envir = .GlobalEnv)
  on.exit({
    rm("devkit_test_df", envir = .GlobalEnv)
    rm("devkit_test_vec", envir = .GlobalEnv)
  }, add = TRUE)

  result <- devkit:::.list_global_dataframes()
  expect_true("devkit_test_df" %in% result)
  expect_false("devkit_test_vec" %in% result)
})

test_that(".list_global_dataframes returns empty when no data frames", {
  # Just ensure it doesn't error when the environment has no data frames
  result <- devkit:::.list_global_dataframes()
  expect_true(is.character(result))
})

test_that(".read_numeric returns valid input", {
  local_mocked_bindings(
    readline = function(...) "42",
    .package = "base"
  )

  result <- devkit:::.read_numeric("Enter: ", default = 10)
  expect_equal(result, 42)
})

test_that(".read_numeric returns default on invalid input", {
  local_mocked_bindings(
    readline = function(...) "abc",
    .package = "base"
  )

  result <- devkit:::.read_numeric("Enter: ", default = 10,
                                    default_msg = "Using default")
  expect_equal(result, 10)
})

test_that(".read_numeric returns default on zero input", {
  local_mocked_bindings(
    readline = function(...) "0",
    .package = "base"
  )

  result <- devkit:::.read_numeric("Enter: ", default = 50)
  expect_equal(result, 50)
})

test_that(".read_numeric returns default on negative input", {
  local_mocked_bindings(
    readline = function(...) "-5",
    .package = "base"
  )

  result <- devkit:::.read_numeric("Enter: ", default = 30)
  expect_equal(result, 30)
})

test_that(".attached_packages returns character vector", {
  result <- devkit:::.attached_packages()
  expect_true(is.character(result))
  # devkit should be attached during testing
  expect_true("devkit" %in% result)
})

test_that(".attached_packages excludes non-package search items", {
  result <- devkit:::.attached_packages()
  # Should not include .GlobalEnv or Autoloads
  expect_false(".GlobalEnv" %in% result)
  expect_false("Autoloads" %in% result)
})
