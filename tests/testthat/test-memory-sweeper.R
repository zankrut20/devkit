# Tests for sweep_memory()

test_that("sweep_memory returns early when global env is empty", {
  local_mocked_bindings(
    readline = function(...) "50",
    ls = function(...) character(0),
    .package = "base"
  )

  expect_message(sweep_memory(), "empty")
})

test_that("sweep_memory defaults threshold on invalid input", {
  local_mocked_bindings(
    readline = function(...) "abc",
    ls = function(...) character(0),
    .package = "base"
  )

  expect_message(sweep_memory(), "Defaulting|empty|50")
})

test_that("sweep_memory returns early when no objects exceed threshold", {
  assign("devkit_test_small_obj", 1:10, envir = .GlobalEnv)
  on.exit(rm("devkit_test_small_obj", envir = .GlobalEnv), add = TRUE)

  local_mocked_bindings(
    readline = function(...) "9999",
    .package = "base"
  )

  expect_message(sweep_memory(), "No objects found")
})

test_that("sweep_memory removes selected objects", {
  assign("devkit_test_big_obj", rep(1, 1e6), envir = .GlobalEnv)
  on.exit(suppressWarnings(rm("devkit_test_big_obj", envir = .GlobalEnv)),
          add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) choices[1],
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "1",
    .package = "base"
  )

  expect_message(sweep_memory(), "removed.*cleared")
})

test_that("sweep_memory cancels when user selects nothing", {
  assign("devkit_test_cancel_obj", rep(1, 1e6), envir = .GlobalEnv)
  on.exit(suppressWarnings(rm("devkit_test_cancel_obj", envir = .GlobalEnv)),
          add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) character(0),
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "1",
    .package = "base"
  )

  expect_message(sweep_memory(), "cancelled")
})

test_that("sweep_memory sorts objects by size descending", {
  assign("devkit_test_big", rep(1, 1e6), envir = .GlobalEnv)    # ~8 MB
  assign("devkit_test_small", rep(1, 2e5), envir = .GlobalEnv)  # ~1.6 MB
  on.exit({
    suppressWarnings(rm("devkit_test_big", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_small", envir = .GlobalEnv))
  }, add = TRUE)

  choices_offered <- NULL
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices_offered <<- choices
      character(0)
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "1",
    .package = "base"
  )

  suppressMessages(sweep_memory())
  expect_true(!is.null(choices_offered))
  expect_gte(length(choices_offered), 2)
  # First item should be the bigger object
  expect_true(grepl("devkit_test_big", choices_offered[1]))
})
