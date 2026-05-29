# Tests for simulate_clean_room()

test_that("simulate_clean_room returns early when no scripts found", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(simulate_clean_room(), "No R scripts found")
})

test_that("simulate_clean_room cancels when user selects empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "test_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(simulate_clean_room(), "cancelled")
})

test_that("simulate_clean_room reports success for clean script", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1 + 1", "clean_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("clean_script", choices))) return("clean_script.R")
      return("")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      res <- character(0)
      attr(res, "status") <- 0L
      res
    },
    .package = "base"
  )

  result <- simulate_clean_room()
  expect_true(result)
})

test_that("simulate_clean_room reports failure and user aborts", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("library(nonexistentpkg123)", "failing_script.R")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("failing", choices))) return("failing_script.R")
      if (any(grepl("Abort", choices))) return("Abort Simulation")
      return("")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      res <- c("Error in library(nonexistentpkg123) : there is no package called 'nonexistentpkg123'")
      attr(res, "status") <- 1L
      res
    },
    .package = "base"
  )

  result <- simulate_clean_room()
  expect_false(result)
})

test_that("simulate_clean_room injects library call and reruns", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("ggplot2::ggplot()", "needs_lib.R")

  system2_count <- 0L
  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("needs_lib", choices))) return("needs_lib.R")
      if (any(grepl("Inject missing library", choices))) return("Inject missing library() call")
      if (any(grepl("Yes", choices))) return("Yes")
      return("")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "ggplot2",
    system2 = function(command, args, ...) {
      system2_count <<- system2_count + 1L
      if (system2_count == 1L) {
        res <- c("Error: could not find function 'ggplot'")
        attr(res, "status") <- 1L
        return(res)
      }
      # Second run succeeds
      res <- character(0)
      attr(res, "status") <- 0L
      res
    },
    .package = "base"
  )

  result <- simulate_clean_room()
  expect_true(result)
  content <- readLines("needs_lib.R")
  expect_true(any(grepl("library(ggplot2)", content, fixed = TRUE)))
})

test_that("simulate_clean_room injects custom snippet", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("print(my_var)", "needs_var.R")

  system2_count <- 0L
  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("needs_var", choices))) return("needs_var.R")
      if (any(grepl("custom", choices, ignore.case = TRUE))) {
        return("Inject custom code snippet (e.g., missing variable)")
      }
      if (any(grepl("Yes", choices))) return("No")
      return("")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) 'my_var <- "hello"',
    system2 = function(command, args, ...) {
      system2_count <<- system2_count + 1L
      res <- c("Error: object 'my_var' not found")
      attr(res, "status") <- 1L
      res
    },
    .package = "base"
  )

  simulate_clean_room()
  content <- readLines("needs_var.R")
  expect_true(any(grepl("my_var", content)))
  expect_true(any(grepl("Auto-injected", content)))
})

test_that("simulate_clean_room handles no valid snippet", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("stop('error')", "err_script.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("err_script", choices))) return("err_script.R")
      if (any(grepl("Inject missing library", choices))) return("Inject missing library() call")
      return("")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    system2 = function(command, args, ...) {
      res <- c("Error: error")
      attr(res, "status") <- 1L
      res
    },
    .package = "base"
  )

  expect_message(simulate_clean_room(), "No valid snippet")
})

test_that("simulate_clean_room handles error lines without Error keyword", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "fallback_script.R")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (any(grepl("fallback", choices))) return("fallback_script.R")
      return("Abort Simulation")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    system2 = function(command, args, ...) {
      res <- c("some output", "without error keyword", "something went wrong")
      attr(res, "status") <- 1L
      res
    },
    .package = "base"
  )

  result <- simulate_clean_room()
  expect_false(result)
})
