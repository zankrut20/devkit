# Tests for detect_masking()

test_that("detect_masking returns clean when no conflicts", {
  local_mocked_bindings(
    conflicts = function(...) list(),
    .package = "base"
  )

  expect_message(detect_masking(), "clean")
})

test_that("detect_masking returns early when no resolutions selected", {
  local_mocked_bindings(
    conflicts = function(...) {
      list(filter = c("package:dplyr", "package:stats"))
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "Skip/Ignore",
    .package = "devkit"
  )

  expect_message(detect_masking(), "No conflict resolutions")
})

test_that("detect_masking filters out non-package environments", {
  local_mocked_bindings(
    conflicts = function(...) {
      list(myvar = c(".GlobalEnv"))
    },
    .package = "base"
  )

  expect_message(detect_masking(), "clean")
})

test_that("detect_masking handles package development context", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0"), "DESCRIPTION")

  local_mocked_bindings(
    conflicts = function(...) {
      list(filter = c("package:dplyr", "package:stats"))
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Skip", choices))) return("dplyr")
      return("No")
    },
    .package = "devkit"
  )

  expect_message(detect_masking(), "Package Development|importFrom")
})

test_that("detect_masking handles standalone context with apply", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    conflicts = function(...) {
      list(lag = c("package:dplyr", "package:stats"))
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("dplyr")
      if (any(grepl("Yes", choices))) return("No")
      return("No")
    },
    .package = "devkit"
  )

  capture.output(
    expect_message(detect_masking(), "Conflict|Resolution|lag"),
    type = "output"
  )
})

test_that("detect_masking handles multiple conflicts", {
  local_mocked_bindings(
    conflicts = function(...) {
      list(
        filter = c("package:dplyr", "package:stats"),
        lag = c("package:dplyr", "package:stats")
      )
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "Skip/Ignore",
    .package = "devkit"
  )

  expect_message(detect_masking(), "2 masked|No conflict")
})
