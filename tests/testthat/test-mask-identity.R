# Tests for mask_identity()

test_that("mask_identity returns early when no data frames", {
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(mask_identity(envir = new.env()), "No dataframes|cancelled")
})

test_that("mask_identity cancels when user selects empty", {
  test_env <- new.env()
  test_env$devkit_test_mask_df <- data.frame(x = 1:3)

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(mask_identity(envir = test_env), "cancelled")
})

test_that("mask_identity keeps columns when user selects Keep", {
  test_env <- new.env()
  test_env$devkit_test_mask_keep <- data.frame(a = 1:3, b = 4:6)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_keep")
      if (select_count <= 3L) return("Keep")
      return("No")
    },
    .package = "devkit"
  )

  result <- mask_identity(envir = test_env)
  masked <- get("devkit_test_mask_keep_masked", envir = test_env)
  expect_equal(masked$a, 1:3)
  expect_equal(masked$b, 4:6)
})

test_that("mask_identity drops columns correctly", {
  test_env <- new.env()
  test_env$devkit_test_mask_drop <- data.frame(a = 1:3, b = 4:6, c = 7:9)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_drop")
      if (select_count == 2L) return("Keep")
      if (select_count == 3L) return("Drop")
      if (select_count == 4L) return("Keep")
      return("No")
    },
    .package = "devkit"
  )

  mask_identity(envir = test_env)
  masked <- get("devkit_test_mask_drop_masked", envir = test_env)
  expect_false("b" %in% names(masked))
  expect_true("a" %in% names(masked))
  expect_true("c" %in% names(masked))
})

test_that("mask_identity scrambles numeric by shuffling", {
  set.seed(42)
  test_env <- new.env()
  test_env$devkit_test_mask_num <- data.frame(val = c(10, 20, 30, 40, 50))

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_num")
      if (select_count == 2L) return("Scramble")
      return("No")
    },
    .package = "devkit"
  )

  mask_identity(envir = test_env)
  masked <- get("devkit_test_mask_num_masked", envir = test_env)
  expect_equal(sort(masked$val), c(10, 20, 30, 40, 50))
})

test_that("mask_identity scrambles text with placeholders", {
  test_env <- new.env()
  test_env$devkit_test_mask_text <- data.frame(
    name = c("Alice", "Bob", "Charlie"), stringsAsFactors = FALSE
  )

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_text")
      if (select_count == 2L) return("Scramble")
      return("No")
    },
    .package = "devkit"
  )

  mask_identity(envir = test_env)
  masked <- get("devkit_test_mask_text_masked", envir = test_env)
  expect_true(all(grepl("Masked_", masked$name)))
})

test_that("mask_identity generates dput output when requested", {
  test_env <- new.env()
  test_env$devkit_test_mask_dput <- data.frame(x = 1:3)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_dput")
      if (select_count == 2L) return("Keep")
      return("Yes")
    },
    .package = "devkit"
  )

  out <- capture.output(mask_identity(envir = test_env))
  expect_true(any(grepl("structure|data.frame", out)))
})

test_that("mask_identity handles empty action as Drop", {
  test_env <- new.env()
  test_env$devkit_test_mask_empty <- data.frame(a = 1, b = 2)

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_mask_empty")
      if (select_count == 2L) return("")
      if (select_count == 3L) return("Keep")
      return("No")
    },
    .package = "devkit"
  )

  mask_identity(envir = test_env)
  masked <- get("devkit_test_mask_empty_masked", envir = test_env)
  expect_false("a" %in% names(masked))
})
