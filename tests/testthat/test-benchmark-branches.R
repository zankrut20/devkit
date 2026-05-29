# Tests for benchmark_branches()

test_that("benchmark_branches returns early when not in a git repo", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  local_mocked_bindings(
    system = function(command, ...) {
      if (grepl("rev-parse", command)) return(128L)
      return(0L)
    },
    .package = "base"
  )

  expect_message(benchmark_branches(), "Not currently inside a Git repository")
})

test_that("benchmark_branches returns early with fewer than 2 branches", {
  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) return("main")
      return(0L)
    },
    .package = "base"
  )

  expect_message(benchmark_branches(), "fewer than 2")
})

test_that("benchmark_branches cancels when selection_type is empty", {
  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) {
        return(c("main", "dev"))
      }
      return(0L)
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(benchmark_branches(), "cancelled")
})

test_that("benchmark_branches errors on fewer than 2 branches selected", {
  select_count <- 0L
  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) {
        return(c("main", "dev", "feature"))
      }
      return(0L)
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Select specific branches")
      return("main")
    },
    .package = "devkit"
  )

  expect_message(benchmark_branches(), "at least two")
})

test_that("benchmark_branches errors when script file not found", {
  select_count <- 0L
  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) {
        return(c("main", "dev"))
      }
      return(0L)
    },
    readline = function(...) "nonexistent_script.R",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "Benchmark ALL branches",
    .package = "devkit"
  )

  expect_message(benchmark_branches(), "Cannot find")
})

test_that("benchmark_branches runs successfully on all branches", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1 + 1", "bench_script.R")

  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) {
        return(c("main", "dev"))
      }
      if (grepl("branch --show-current", command) && isTRUE(args$intern)) {
        return("main")
      }
      if (grepl("status --porcelain", command) && isTRUE(args$intern)) {
        return(character(0))
      }
      if (grepl("checkout", command)) return(0L)
      return(0L)
    },
    readline = function(...) "bench_script.R",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "Benchmark ALL branches",
    .package = "devkit"
  )

  capture.output(
    result <- benchmark_branches(),
    type = "output"
  )
  expect_s3_class(result, "data.frame")
  expect_true("Branch" %in% names(result))
  expect_true("Time_Seconds" %in% names(result))
})

test_that("benchmark_branches stashes uncommitted changes", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines("x <- 1", "bench_script.R")

  stash_called <- FALSE
  pop_called <- FALSE

  local_mocked_bindings(
    system = function(command, ...) {
      args <- list(...)
      if (grepl("rev-parse", command)) return(0L)
      if (grepl("branch --format", command) && isTRUE(args$intern)) {
        return(c("main", "dev"))
      }
      if (grepl("branch --show-current", command) && isTRUE(args$intern)) {
        return("main")
      }
      if (grepl("status --porcelain", command) && isTRUE(args$intern)) {
        return("M file.R")
      }
      if (grepl("stash -q", command)) { stash_called <<- TRUE; return(0L) }
      if (grepl("stash pop", command)) { pop_called <<- TRUE; return(0L) }
      if (grepl("checkout", command)) return(0L)
      return(0L)
    },
    readline = function(...) "bench_script.R",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "Benchmark ALL branches",
    .package = "devkit"
  )

  capture.output(benchmark_branches(), type = "output")
  expect_true(stash_called)
  expect_true(pop_called)
})
