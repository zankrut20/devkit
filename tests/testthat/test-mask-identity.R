# Tests for mask_identity()

test_that("mask_identity returns early when no data frames", {
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(mask_identity(), "No dataframes|cancelled")
})

test_that("mask_identity cancels when user selects empty", {
  assign("devkit_test_mask_df", data.frame(x = 1:3), envir = .GlobalEnv)
  on.exit(rm("devkit_test_mask_df", envir = .GlobalEnv), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(mask_identity(), "cancelled")
})

test_that("mask_identity keeps columns when user selects Keep", {
  assign("devkit_test_mask_keep", data.frame(a = 1:3, b = 4:6), envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_keep", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_keep_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  result <- mask_identity()
  masked <- get("devkit_test_mask_keep_masked", envir = .GlobalEnv)
  expect_equal(masked$a, 1:3)
  expect_equal(masked$b, 4:6)
})

test_that("mask_identity drops columns correctly", {
  assign("devkit_test_mask_drop", data.frame(a = 1:3, b = 4:6, c = 7:9),
         envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_drop", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_drop_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  mask_identity()
  masked <- get("devkit_test_mask_drop_masked", envir = .GlobalEnv)
  expect_false("b" %in% names(masked))
  expect_true("a" %in% names(masked))
  expect_true("c" %in% names(masked))
})

test_that("mask_identity scrambles numeric by shuffling", {
  set.seed(42)
  assign("devkit_test_mask_num", data.frame(val = c(10, 20, 30, 40, 50)),
         envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_num", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_num_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  mask_identity()
  masked <- get("devkit_test_mask_num_masked", envir = .GlobalEnv)
  expect_equal(sort(masked$val), c(10, 20, 30, 40, 50))
})

test_that("mask_identity scrambles text with placeholders", {
  assign("devkit_test_mask_text",
         data.frame(name = c("Alice", "Bob", "Charlie"), stringsAsFactors = FALSE),
         envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_text", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_text_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  mask_identity()
  masked <- get("devkit_test_mask_text_masked", envir = .GlobalEnv)
  expect_true(all(grepl("Masked_", masked$name)))
})

test_that("mask_identity generates dput output when requested", {
  assign("devkit_test_mask_dput", data.frame(x = 1:3), envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_dput", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_dput_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  out <- capture.output(mask_identity())
  expect_true(any(grepl("structure|data.frame", out)))
})

test_that("mask_identity handles empty action as Drop", {
  assign("devkit_test_mask_empty", data.frame(a = 1, b = 2), envir = .GlobalEnv)
  on.exit({
    suppressWarnings(rm("devkit_test_mask_empty", envir = .GlobalEnv))
    suppressWarnings(rm("devkit_test_mask_empty_masked", envir = .GlobalEnv))
  }, add = TRUE)

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

  mask_identity()
  masked <- get("devkit_test_mask_empty_masked", envir = .GlobalEnv)
  expect_false("a" %in% names(masked))
})
