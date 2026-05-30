# Tests for setup_sentinel()

test_that("setup_sentinel cancels when user selects Cancel", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )

  expect_message(setup_sentinel(), "cancelled")
})

test_that("setup_sentinel cancels on empty selection", {
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(setup_sentinel(), "cancelled")
})

test_that("setup_sentinel creates log file with All Output mode", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "All Output (Messages, Warnings, Errors)",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "test_log.txt",
    globalCallingHandlers = function(...) invisible(NULL),
    .package = "base"
  )

  result <- setup_sentinel()
  expect_true(file.exists("test_log.txt"))
  content <- readLines("test_log.txt")
  expect_true(any(grepl("Session Log Started", content)))
  expect_equal(result$status, "done")
})

test_that("setup_sentinel creates log file with Errors Only mode", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "Errors Only",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "error_log.txt",
    globalCallingHandlers = function(...) invisible(NULL),
    .package = "base"
  )

  result <- setup_sentinel()
  expect_true(file.exists("error_log.txt"))
  expect_equal(result$status, "done")
})

test_that("setup_sentinel uses default filename when empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "Errors Only",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    globalCallingHandlers = function(...) invisible(NULL),
    .package = "base"
  )

  result <- setup_sentinel()
  log_files <- list.files(tmp, pattern = "^session_log_")
  expect_true(length(log_files) >= 1)
  expect_equal(result$status, "done")
})

test_that("setup_sentinel returns invisible TRUE on success", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "Errors Only",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "sentinel.txt",
    globalCallingHandlers = function(...) invisible(NULL),
    .package = "base"
  )

  result <- setup_sentinel()
  expect_equal(result$status, "done")
})

test_that("setup_sentinel writes header with timestamp", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "All Output (Messages, Warnings, Errors)",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "ts_log.txt",
    globalCallingHandlers = function(...) invisible(NULL),
    .package = "base"
  )

  setup_sentinel()
  content <- readLines("ts_log.txt")
  expect_true(any(grepl("Session Log Started", content)))
})
