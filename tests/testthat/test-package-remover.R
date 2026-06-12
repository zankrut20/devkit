# Tests for remove_package() (package-remover.R)

test_that("remove_package offers target pkg even when no orphan deps", {
  local_mocked_bindings(
    package_dependencies = function(...) {
      list(mypkg = character(0))
    },
    select.list = function(choices, ...) choices,
    remove.packages = function(...) invisible(NULL),
    .package = "devkit"
  )

  result <- remove_package("mypkg")
  expect_true("mypkg" %in% result)
})

test_that("remove_package prompts user when orphan deps exist", {
  local_mocked_bindings(
    package_dependencies = function(...) {
      list(
        mypkg = c("dep1", "dep2"),
        otherpkg = character(0)
      )
    },
    select.list = function(choices, ...) choices,
    remove.packages = function(...) invisible(NULL),
    .package = "devkit"
  )

  result <- remove_package("mypkg")
  expect_true("mypkg" %in% result)
})

test_that("remove_package filters out deps required by other packages", {
  local_mocked_bindings(
    package_dependencies = function(...) {
      list(
        mypkg = c("dep1", "shared_dep"),
        otherpkg = c("shared_dep")
      )
    },
    select.list = function(choices, ...) choices,
    remove.packages = function(...) invisible(NULL),
    .package = "devkit"
  )

  result <- remove_package("mypkg")
  expect_false("shared_dep" %in% result)
  expect_true("dep1" %in% result)
})

test_that("remove_package handles package with NULL dependencies", {
  local_mocked_bindings(
    package_dependencies = function(...) {
      list(mypkg = NULL)
    },
    select.list = function(choices, ...) choices,
    remove.packages = function(...) invisible(NULL),
    .package = "devkit"
  )

  result <- remove_package("mypkg")
  expect_true("mypkg" %in% result)
})

test_that("remove_package with recursive = TRUE passed to package_dependencies", {
  dep_args <- NULL
  local_mocked_bindings(
    package_dependencies = function(recursive, ...) {
      dep_args <<- list(recursive = recursive)
      list(mypkg = character(0))
    },
    select.list = function(choices, ...) character(0),
    .package = "devkit"
  )

  remove_package("mypkg", recursive = TRUE)
  expect_true(dep_args$recursive)
})
