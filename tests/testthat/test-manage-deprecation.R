# Tests for manage_deprecation()

test_that("manage_deprecation returns early when R dir missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(manage_deprecation(), "directory not found")
})

test_that("manage_deprecation aborts on empty old function name", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")

  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(manage_deprecation(), "Aborted")
})

test_that("manage_deprecation aborts on empty new function name", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("old_func")
      return("")
    },
    .package = "base"
  )

  expect_message(manage_deprecation(), "Aborted")
})

test_that("manage_deprecation creates R/deprecated.R when missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("old_func")
      return("new_func")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  manage_deprecation()
  expect_true(file.exists("R/deprecated.R"))
  content <- readLines("R/deprecated.R")
  expect_true(any(grepl("old_func", content)))
  expect_true(any(grepl(".Deprecated", content)))
  expect_true(any(grepl("new_func", content)))
})

test_that("manage_deprecation appends to existing deprecated.R", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")
  writeLines("# existing content", "R/deprecated.R")

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("another_old")
      return("another_new")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  manage_deprecation()
  content <- readLines("R/deprecated.R")
  expect_true(any(grepl("existing content", content)))
  expect_true(any(grepl("another_old", content)))
})

test_that("manage_deprecation scans and replaces in test files", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")
  dir.create(file.path("tests", "testthat"), recursive = TRUE)
  writeLines("result <- old_func(x)", file.path("tests", "testthat", "test.R"))

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("old_func")
      return("new_func")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Yes", choices))) return("Yes")
      if (any(grepl("Replace", choices))) return("Replace")
      return("No")
    },
    .package = "devkit"
  )

  manage_deprecation()
  test_content <- readLines(file.path("tests", "testthat", "test.R"))
  expect_true(any(grepl("new_func", test_content)))
})

test_that("manage_deprecation handles no test files to scan", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("old_func")
      return("new_func")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("scan", choices, ignore.case = TRUE))) return("Yes")
      if (any(grepl("Yes", choices))) return("Yes")
      return("No")
    },
    .package = "devkit"
  )

  expect_message(manage_deprecation(), "No tests|No vignettes|not found")
})

test_that("manage_deprecation skips lines when user says Skip", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create("R")
  dir.create(file.path("tests", "testthat"), recursive = TRUE)
  writeLines("result <- old_func(x)", file.path("tests", "testthat", "test.R"))

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("old_func")
      return("new_func")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("scan", choices, ignore.case = TRUE))) return("Yes")
      if (any(grepl("Yes", choices))) return("Yes")
      if (any(grepl("Replace", choices))) return("Skip")
      return("No")
    },
    .package = "devkit"
  )

  manage_deprecation()
  test_content <- readLines(file.path("tests", "testthat", "test.R"))
  expect_true(any(grepl("old_func", test_content)))
})
