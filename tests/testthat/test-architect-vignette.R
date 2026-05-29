# Tests for architect_vignette()

test_that("architect_vignette returns early with empty package name", {
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(architect_vignette(), "required")
})

test_that("architect_vignette defaults title when empty", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Quick Start", choices))) return("Quick Start Guide")
      return("Done")
    },
    .package = "devkit"
  )

  architect_vignette()
  expect_true(file.exists(file.path("vignettes", "package_vignette.Rmd")))
})

test_that("architect_vignette cancels when vig_type is empty", {
  local_mocked_bindings(
    readline = function(prompt = "", ...) "mypkg",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(architect_vignette(), "cancelled")
})

test_that("architect_vignette creates Quick Start template", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("Getting Started")
      return("func_a, func_b")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Quick Start", choices))) return("Quick Start Guide")
      if (any(grepl("Overwrite", choices %||% ""))) return("No")
      return("Done")
    },
    .package = "devkit"
  )

  architect_vignette()
  rmd_path <- file.path("vignettes", "getting_started.Rmd")
  expect_true(file.exists(rmd_path))
  content <- readLines(rmd_path)
  expect_true(any(grepl("Installation", content)))
  expect_true(any(grepl("func_a", content)))
})

test_that("architect_vignette creates Deep Dive template", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("Advanced Usage")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Deep Dive", choices))) return("Deep Dive / Advanced Usage")
      return("Done")
    },
    .package = "devkit"
  )

  architect_vignette()
  content <- readLines(file.path("vignettes", "advanced_usage.Rmd"))
  expect_true(any(grepl("Core Concepts", content)))
})

test_that("architect_vignette creates Case Study template", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("My Workflow")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Case Study", choices))) return("Case Study / Workflow")
      return("Done")
    },
    .package = "devkit"
  )

  architect_vignette()
  content <- readLines(file.path("vignettes", "my_workflow.Rmd"))
  expect_true(any(grepl("Problem", content)))
})

test_that("architect_vignette creates vignettes directory if missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("Test")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Quick Start", choices))) return("Quick Start Guide")
      return("Done")
    },
    .package = "devkit"
  )

  expect_false(dir.exists("vignettes"))
  architect_vignette()
  expect_true(dir.exists("vignettes"))
})

test_that("architect_vignette aborts on existing file when user says No", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("vignettes", showWarnings = FALSE)
  writeLines("existing", file.path("vignettes", "test.Rmd"))

  readline_count <- 0L
  select_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("Test")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Quick Start Guide")
      return("No")
    },
    .package = "devkit"
  )

  expect_message(architect_vignette(), "aborted|protect")
})

test_that("architect_vignette YAML header contains VignetteEngine", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  readline_count <- 0L
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("mypkg")
      if (readline_count == 2L) return("My Vignette")
      return("")
    },
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Quick Start", choices))) return("Quick Start Guide")
      return("Done")
    },
    .package = "devkit"
  )

  architect_vignette()
  content <- readLines(file.path("vignettes", "my_vignette.Rmd"))
  expect_true(any(grepl("VignetteEngine", content)))
  expect_true(any(grepl("VignetteIndexEntry", content)))
})
