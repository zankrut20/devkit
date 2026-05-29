# Tests for dictate_dictionary()

test_that("dictate_dictionary returns early when no data frames exist", {
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  # Ensure no test data frames leak into .GlobalEnv
  expect_message(dictate_dictionary(), "No data frames|cancelled")
})

test_that("dictate_dictionary cancels when user selects empty", {
  assign("devkit_test_df_abc", data.frame(x = 1:3), envir = .GlobalEnv)
  on.exit(rm("devkit_test_df_abc", envir = .GlobalEnv), add = TRUE)

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(dictate_dictionary(), "cancelled")
})

test_that("dictate_dictionary generates roxygen block for console output", {
  assign("devkit_test_df_dict", data.frame(x = 1:3, y = letters[1:3],
                                           stringsAsFactors = FALSE),
         envir = .GlobalEnv)
  on.exit(rm("devkit_test_df_dict", envir = .GlobalEnv), add = TRUE)

  readline_count <- 0L
  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("devkit_test_df_dict")
      return("Print to console")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("Test Dataset")
      if (readline_count == 2L) return("A test dataset")
      if (readline_count == 3L) return("Column x desc")
      if (readline_count == 4L) return("Column y desc")
      return("")
    },
    .package = "base"
  )

  out <- capture.output(dictate_dictionary())
  expect_true(any(grepl("format", out)))
  expect_true(any(grepl("describe", out)))
})

test_that("dictate_dictionary handles empty column description", {
  assign("devkit_test_df_empty", data.frame(a = 1), envir = .GlobalEnv)
  on.exit(rm("devkit_test_df_empty", envir = .GlobalEnv), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("devkit_test_df_empty", choices))) return("devkit_test_df_empty")
      return("Print to console")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("Title")
      if (readline_count == 2L) return("Desc")
      return("")
    },
    .package = "base"
  )

  out <- capture.output(dictate_dictionary())
  expect_true(any(grepl("No description provided", out)))
})

test_that("dictate_dictionary saves to R/data.R", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  assign("devkit_test_df_save", data.frame(z = 1:2), envir = .GlobalEnv)
  on.exit(rm("devkit_test_df_save", envir = .GlobalEnv), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("devkit_test_df_save", choices))) return("devkit_test_df_save")
      return("Save to R/data.R")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("Title")
      if (readline_count == 2L) return("Description")
      return("col desc")
    },
    .package = "base"
  )

  dictate_dictionary()
  expect_true(file.exists(file.path("R", "data.R")))
})

test_that("dictate_dictionary creates R directory when saving", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  assign("devkit_test_df_dir", data.frame(a = 1), envir = .GlobalEnv)
  on.exit(rm("devkit_test_df_dir", envir = .GlobalEnv), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("devkit_test_df_dir", choices))) return("devkit_test_df_dir")
      return("Save to R/data.R")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count <= 2L) return("test")
      return("desc")
    },
    .package = "base"
  )

  expect_false(dir.exists("R"))
  dictate_dictionary()
  expect_true(dir.exists("R"))
})
