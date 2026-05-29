# Tests for setup_preflight()

test_that("setup_preflight returns early when not in git repo", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(setup_preflight(), "Not a Git repository")
})

test_that("setup_preflight creates .git/hooks if missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(".git", showWarnings = FALSE)

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(...) invisible(NULL),
    .package = "base"
  )

  setup_preflight()
  expect_true(dir.exists(".git/hooks"))
})

test_that("setup_preflight skips when all checks are No", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(setup_preflight(), "All checks skipped")
})

test_that("setup_preflight creates hook with docs check only", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Yes")   # docs
      if (select_count == 2L) return("No")    # tests
      if (select_count == 3L) return("No")    # style
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(...) invisible(NULL),
    .package = "base"
  )

  setup_preflight()
  hook <- readLines(".git/hooks/pre-commit")
  expect_true(any(grepl("devtools::document", hook)))
  expect_false(any(grepl("testthat", hook)))
  expect_false(any(grepl("styler", hook)))
})

test_that("setup_preflight creates hook with tests check only", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("No")    # docs
      if (select_count == 2L) return("Yes")   # tests
      if (select_count == 3L) return("No")    # style
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(...) invisible(NULL),
    .package = "base"
  )

  setup_preflight()
  hook <- readLines(".git/hooks/pre-commit")
  expect_true(any(grepl("testthat", hook)))
  expect_true(any(grepl("exit 1", hook)))
})

test_that("setup_preflight creates hook with style check only", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("No")    # docs
      if (select_count == 2L) return("No")    # tests
      if (select_count == 3L) return("Yes")   # style
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(...) invisible(NULL),
    .package = "base"
  )

  setup_preflight()
  hook <- readLines(".git/hooks/pre-commit")
  expect_true(any(grepl("styler", hook)))
})

test_that("setup_preflight creates hook with all checks", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "Yes",
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(...) invisible(NULL),
    .package = "base"
  )

  setup_preflight()
  hook <- readLines(".git/hooks/pre-commit")
  expect_true(any(grepl("#!/bin/sh", hook)))
  expect_true(any(grepl("styler", hook)))
  expect_true(any(grepl("devtools::document", hook)))
  expect_true(any(grepl("testthat", hook)))
})

test_that("setup_preflight aborts when existing hook and user says No", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)
  writeLines("#!/bin/sh\nexit 0", ".git/hooks/pre-commit")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count <= 3L) return("Yes")
      return("No")  # overwrite = No
    },
    .package = "devkit"
  )

  expect_message(setup_preflight(), "Aborted|protected")
})

test_that("setup_preflight makes hook executable", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)
  dir.create(file.path(".git", "hooks"), recursive = TRUE)

  chmod_called <- FALSE
  local_mocked_bindings(
    select.list = function(choices, ...) "Yes",
    .package = "devkit"
  )
  local_mocked_bindings(
    Sys.chmod = function(path, mode, ...) {
      chmod_called <<- TRUE
      expect_equal(mode, "0755")
    },
    .package = "base"
  )

  setup_preflight()
  expect_true(chmod_called)
})
