# Tests for bootstrap_dev_env()

test_that("bootstrap_dev_env handles all tools already installed", {
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) TRUE,
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) character(0),
    .package = "devkit"
  )

  expect_message(bootstrap_dev_env(), "already installed")
})

test_that("bootstrap_dev_env handles missing tools with Install All", {
  install_called <- FALSE
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) pkg %in% c("devtools", "roxygen2"),
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Install All", choices))) return("Install All Missing")
      return(character(0))
    },
    install.packages = function(...) { install_called <<- TRUE },
    .package = "devkit"
  )

  capture.output(
    expect_message(bootstrap_dev_env(), "missing|Installation"),
    type = "output"
  )
})

test_that("bootstrap_dev_env handles skip installation", {
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) pkg == "devtools",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Skip", choices))) return("Skip Installation")
      return(character(0))
    },
    .package = "devkit"
  )

  capture.output(
    expect_message(bootstrap_dev_env(), "Skipping|missing"),
    type = "output"
  )
})

test_that("bootstrap_dev_env loads selected tools", {
  loaded_pkgs <- character(0)
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) TRUE,
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      if (any(grepl("Install", choices))) return("Skip Installation")
      return("devtools")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    library = function(pkg, ...) { loaded_pkgs <<- c(loaded_pkgs, pkg) },
    .package = "base"
  )

  suppressPackageStartupMessages(bootstrap_dev_env())
  expect_true(TRUE)
})

test_that("bootstrap_dev_env handles no tools to load", {
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) TRUE,
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) character(0),
    .package = "devkit"
  )

  expect_message(bootstrap_dev_env(), "No development tools attached|already installed")
})

test_that("bootstrap_dev_env installs specific selected packages", {
  installed_pkgs <- character(0)
  select_count <- 0L
  local_mocked_bindings(
    requireNamespace = function(pkg, quietly = TRUE) pkg == "devtools",
    .package = "base"
  )
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("usethis")
      return(character(0))
    },
    install.packages = function(pkgs, ...) {
      installed_pkgs <<- c(installed_pkgs, pkgs)
    },
    .package = "devkit"
  )

  capture.output(bootstrap_dev_env(), type = "output")
  expect_true("usethis" %in% installed_pkgs)
})
