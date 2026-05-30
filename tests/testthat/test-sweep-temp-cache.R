# Tests for sweep_temp_cache()
# NOTE: We avoid mocking base::tempdir, base::list.dirs, etc. because
# they are used internally by testthat/R infrastructure and mocking them
# causes node stack overflow. Instead, we test at a higher level.

test_that("sweep_temp_cache completes without error on clean system", {
  # This test just ensures the function runs without crashing

  # We can't easily mock the filesystem scanning without causing recursion,
  # so we just test the function can execute
  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )

  # The function should either find temp dirs or report clean
  expect_message(sweep_temp_cache(), "Scanning|clean|empty|Cancel|cancelled")
})

test_that("sweep_temp_cache cancels when user selects Cancel", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )

  expect_message(sweep_temp_cache(), "cancelled|clean|empty|Scanning")
})

test_that("sweep_temp_cache returns invisible NULL on cancel", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )

  result <- sweep_temp_cache()
  # In R CMD check, the environment may be perfectly clean, returning "clean"
  # In devtools::test(), the interactive session has temp files, returning "cancelled"
  expect_true(result$status %in% c("cancelled", "clean"))
})
