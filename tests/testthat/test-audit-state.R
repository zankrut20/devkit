# Tests for audit_script()

test_that("audit_script returns early when no scripts found", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(audit_script(), "No R scripts found")
})

test_that("audit_script cancels when user selects empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "test_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(audit_script(), "cancelled")
})

test_that("audit_script detects clean script with no side effects", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1 + 1", "clean_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("clean_script", choices))) return("clean_script.R")
      return("Keep New Setting")
    },
    .package = "devkit"
  )

  expect_message(audit_script(), "No global state changes|safe")
})

test_that("audit_script detects working directory change", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  sub_dir <- file.path(tmp, "subdir")
  dir.create(sub_dir)
  writeLines(sprintf('setwd("%s")', gsub("\\\\", "/", sub_dir)), "wd_changer.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("wd_changer.R")
      return("Revert to Old Snapshot")
    },
    .package = "devkit"
  )

  expect_message(audit_script(), "changed|Revert")
})

test_that("audit_script handles script that crashes", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("stop('intentional error')", "crashing_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("crashing", choices))) return("crashing_script.R")
      return("Keep New Setting")
    },
    .package = "devkit"
  )

  expect_message(audit_script(), "crashed|error")
})

test_that("audit_script detects options changes", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("options(scipen = 999)", "opts_changer.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("opts_changer.R")
      return("Revert to Old Snapshot")
    },
    .package = "devkit"
  )

  old_scipen <- getOption("scipen")
  on.exit(options(scipen = old_scipen), add = TRUE)

  expect_message(audit_script(), "changed|Revert|state")
})

test_that("audit_script user keeps new settings", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("options(devkit_test_opt_xyz = TRUE)", "opts_script.R")
  on.exit(options(devkit_test_opt_xyz = NULL), add = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("opts_script.R")
      return("Keep New Setting")
    },
    .package = "devkit"
  )

  audit_script()
  expect_true(isTRUE(getOption("devkit_test_opt_xyz")))
})
