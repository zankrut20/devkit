# Tests for loop_guardian()

test_that("loop_guardian processes all items successfully", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Ignore",
    .package = "devkit"
  )
  local_mocked_bindings(
    gc = function(...) {
      mat <- matrix(c(10, 10, 10, 10), nrow = 2, ncol = 2)
      colnames(mat) <- c("used", "(Mb)")
      mat
    },
    .package = "base"
  )

  result <- loop_guardian(1:5, function(x) x^2, limit_mb = 4000)
  expect_type(result, "list")
  expect_equal(length(result), 5)
  expect_equal(result[[3]], 9)
})

test_that("loop_guardian handles error in target_func gracefully", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Ignore",
    .package = "devkit"
  )

  result <- loop_guardian(1:3, function(x) {
    if (x == 2) stop("test error")
    x
  }, limit_mb = 99999)

  expect_true(is.na(result[[2]]))
  expect_equal(result[[1]], 1)
  expect_equal(result[[3]], 3)
})

test_that("loop_guardian triggers memory alarm and user saves+aborts", {
  tmp <- withr::local_tempdir()
  save_file <- file.path(tmp, "emergency.rds")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      "Save current progress to disk and Abort"
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    gc = function(...) {
      mat <- matrix(c(5000, 5000, 5000, 5000), nrow = 2, ncol = 2)
      colnames(mat) <- c("used", "(Mb)")
      mat
    },
    .package = "base"
  )

  items <- 1:50
  result <- loop_guardian(items, identity, limit_mb = 1, save_path = save_file)
  expect_true(file.exists(save_file))
  file.remove(save_file)
})

test_that("loop_guardian user aborts without saving", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      "Abort immediately (Lose unsaved progress)"
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    gc = function(...) {
      mat <- matrix(c(5000, 5000, 5000, 5000), nrow = 2, ncol = 2)
      colnames(mat) <- c("used", "(Mb)")
      mat
    },
    .package = "base"
  )

  result <- loop_guardian(1:50, identity, limit_mb = 1)
  expect_type(result, "list")
})

test_that("loop_guardian user continues past memory limit", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      "Ignore limit and attempt to Continue"
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    gc = function(...) {
      mat <- matrix(c(5000, 5000, 5000, 5000), nrow = 2, ncol = 2)
      colnames(mat) <- c("used", "(Mb)")
      mat
    },
    .package = "base"
  )

  result <- loop_guardian(1:55, identity, limit_mb = 1)
  expect_equal(length(result), 55)
})

test_that("loop_guardian processes few items without memory check", {
  result <- loop_guardian(1:3, function(x) x * 2, limit_mb = 99999)
  expect_equal(result[[1]], 2)
  expect_equal(result[[3]], 6)
})

test_that("loop_guardian checks memory every 50 iterations", {
  gc_call_count <- 0L
  local_mocked_bindings(
    gc = function(...) {
      gc_call_count <<- gc_call_count + 1L
      mat <- matrix(c(10, 10, 10, 10), nrow = 2, ncol = 2)
      colnames(mat) <- c("used", "(Mb)")
      mat
    },
    .package = "base"
  )

  result <- loop_guardian(1:100, identity, limit_mb = 99999)
  expect_equal(length(result), 100)
  expect_gte(gc_call_count, 2L)
})
