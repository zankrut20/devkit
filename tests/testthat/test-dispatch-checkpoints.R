# Tests for dispatch_checkpoints()

test_that("dispatch_checkpoints processes all items successfully", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp.rds")

  local_mocked_bindings(
    select.list = function(choices, ...) "Resume",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "5",
    .package = "base"
  )

  result <- dispatch_checkpoints(1:10, function(x) x^2, checkpoint_file = cp_file)
  expect_type(result, "list")
  expect_equal(length(result), 10)
  expect_equal(result[[1]], 1)
  expect_equal(result[[4]], 16)
  expect_false(file.exists(cp_file))
})

test_that("dispatch_checkpoints saves interval checkpoints", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp.rds")

  local_mocked_bindings(
    readline = function(...) "3",
    .package = "base"
  )

  result <- dispatch_checkpoints(1:9, function(x) x, checkpoint_file = cp_file)
  expect_equal(length(result), 9)
})

test_that("dispatch_checkpoints resumes from checkpoint", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_resume.rds")

  cached <- list(current_index = 4L, results = vector("list", 5))
  cached$results[[1]] <- "done1"
  cached$results[[2]] <- "done2"
  cached$results[[3]] <- "done3"
  saveRDS(cached, cp_file)

  local_mocked_bindings(
    select.list = function(choices, ...) choices[1],
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "10",
    .package = "base"
  )

  result <- dispatch_checkpoints(1:5, function(x) paste0("proc", x),
                                  checkpoint_file = cp_file)
  expect_equal(result[[4]], "proc4")
  expect_equal(result[[5]], "proc5")
})

test_that("dispatch_checkpoints aborts when user selects abort", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_abort.rds")

  cached <- list(current_index = 3L, results = vector("list", 5))
  saveRDS(cached, cp_file)

  local_mocked_bindings(
    select.list = function(choices, ...) "Abort completely",
    .package = "devkit"
  )

  expect_message(
    dispatch_checkpoints(1:5, identity, checkpoint_file = cp_file),
    "aborted"
  )
})

test_that("dispatch_checkpoints restarts fresh when user chooses", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_fresh.rds")

  cached <- list(current_index = 3L, results = vector("list", 5))
  saveRDS(cached, cp_file)

  local_mocked_bindings(
    select.list = function(choices, ...) "Wipe the cache and restart from the beginning",
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "10",
    .package = "base"
  )

  result <- dispatch_checkpoints(1:5, function(x) x * 10,
                                  checkpoint_file = cp_file)
  expect_equal(result[[1]], 10)
  expect_equal(result[[5]], 50)
})

test_that("dispatch_checkpoints defaults save_freq on invalid input", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_invalid.rds")

  local_mocked_bindings(
    readline = function(...) "abc",
    .package = "base"
  )

  expect_message(
    dispatch_checkpoints(1:3, identity, checkpoint_file = cp_file),
    "Defaulting"
  )
})

test_that("dispatch_checkpoints handles error in target_func", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_err.rds")

  local_mocked_bindings(
    readline = function(...) "10",
    .package = "base"
  )

  expect_error(
    dispatch_checkpoints(1:5, function(x) {
      if (x == 3) stop("intentional error")
      x
    }, checkpoint_file = cp_file),
    "halted"
  )

  expect_true(file.exists(cp_file))
  checkpoint <- readRDS(cp_file)
  expect_equal(checkpoint$current_index, 3L)
  file.remove(cp_file)
})

test_that("dispatch_checkpoints defaults save_freq on negative input", {
  tmp <- withr::local_tempdir()
  cp_file <- file.path(tmp, "cp_neg.rds")

  local_mocked_bindings(
    readline = function(...) "-5",
    .package = "base"
  )

  expect_message(
    dispatch_checkpoints(1:3, identity, checkpoint_file = cp_file),
    "Defaulting"
  )
})
