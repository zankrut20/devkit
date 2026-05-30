# Tests for scaffold_tests()

test_that("scaffold_tests returns FALSE when tests/testthat missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  result <- scaffold_tests()
  expect_equal(result$status, "error")
})

test_that("scaffold_tests cancels when function name is empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(scaffold_tests(), "cancelled")
})

test_that("scaffold_tests creates test file for data.frame output", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("data.frame", choices))) return("data.frame / tibble")
      if (any(grepl("Yes|No", choices))) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "my_func",
    .package = "base"
  )

  scaffold_tests()
  file_path <- file.path("tests", "testthat", "test-my_func.R")
  expect_true(file.exists(file_path))
  content <- readLines(file_path)
  expect_true(any(grepl("expect_s3_class", content)))
  expect_true(any(grepl("nrow", content)))
})

test_that("scaffold_tests creates test file for list output", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("list", choices))) return("list")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "list_func",
    .package = "base"
  )

  scaffold_tests()
  content <- readLines(file.path("tests", "testthat", "test-list_func.R"))
  expect_true(any(grepl("expect_type.*list", content)))
})

test_that("scaffold_tests creates test file for character output", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("character", choices))) return("character")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "char_func",
    .package = "base"
  )

  scaffold_tests()
  content <- readLines(file.path("tests", "testthat", "test-char_func.R"))
  expect_true(any(grepl("expect_type.*character", content)))
})

test_that("scaffold_tests creates test file for numeric output", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("numeric", choices))) return("numeric")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "num_func",
    .package = "base"
  )

  scaffold_tests()
  content <- readLines(file.path("tests", "testthat", "test-num_func.R"))
  expect_true(any(grepl("expect_type.*double", content)))
})

test_that("scaffold_tests includes error handling tests", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("None", choices))) return("None/Unknown")
      if (any(grepl("Yes", choices))) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "err_func",
    .package = "base"
  )

  scaffold_tests()
  content <- readLines(file.path("tests", "testthat", "test-err_func.R"))
  expect_true(any(grepl("expect_error", content)))
})

test_that("scaffold_tests aborts when file exists and user says No", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)
  writeLines("# existing", file.path("tests", "testthat", "test-existing.R"))

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Overwrite", deparse(match.call())))) return("No")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "existing",
    .package = "base"
  )

  expect_message(scaffold_tests(), "Aborted|protect")
})

test_that("scaffold_tests skips dimension tests for non-data.frame", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("list", choices))) return("list")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "nodim_func",
    .package = "base"
  )

  scaffold_tests()
  content <- readLines(file.path("tests", "testthat", "test-nodim_func.R"))
  expect_false(any(grepl("nrow", content)))
})
