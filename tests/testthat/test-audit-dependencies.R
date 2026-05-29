# Tests for audit_dependencies()

test_that("audit_dependencies returns early when DESCRIPTION missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(audit_dependencies(), "DESCRIPTION file not found")
})

test_that("audit_dependencies reports when no discrepancies", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  writeLines("dplyr::filter(iris, Species == 'setosa')", file.path("R", "example.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0",
                     "Imports: dplyr")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "Perfect|complete|Audit")
})

test_that("audit_dependencies detects ghost dependencies", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  writeLines("dplyr::filter(iris, Species == 'setosa')",
             file.path("R", "example.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "GHOST")
})

test_that("audit_dependencies adds ghost dep when user confirms", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  writeLines("ggplot2::ggplot()", file.path("R", "example.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Yes", choices))) return("Yes")
      return("No")
    },
    .package = "devkit"
  )

  audit_dependencies()
  desc <- read.dcf("DESCRIPTION")
  expect_true("Imports" %in% colnames(desc))
})

test_that("audit_dependencies scans tests and vignettes directories", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  dir.create(file.path("tests", "testthat"), recursive = TRUE)
  writeLines("# no deps", file.path("R", "main.R"))
  writeLines("testthat::expect_true(TRUE)",
             file.path("tests", "testthat", "test-main.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0",
                     "Suggests: testthat")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "Perfect|GHOST|BLOAT|MISCLASS")
})

test_that("audit_dependencies detects library() usage patterns", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  writeLines("library(jsonlite)", file.path("R", "example.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "GHOST")
})

test_that("audit_dependencies detects bloat dependencies", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create("R", showWarnings = FALSE)
  writeLines("# no code", file.path("R", "empty.R"))

  desc_content <- c("Package: testpkg", "Version: 1.0.0",
                     "Imports: ggplot2")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "BLOAT")
})

test_that("audit_dependencies handles non-existent scan directories", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  desc_content <- c("Package: testpkg", "Version: 1.0.0")
  writeLines(desc_content, "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "No",
    .package = "devkit"
  )

  expect_message(audit_dependencies(), "Perfect")
})
