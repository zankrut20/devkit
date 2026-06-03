# Tests for remove_user_installed_packages()

test_that("remove_user_installed_packages returns early when no user packages", {
  local_mocked_bindings(installed.packages = function(...) {
      mat <- data.frame(
        Package = c("base", "stats"),
        LibPath = c("/usr/lib/R", "/usr/lib/R"),
        Priority = c("base", "recommended"),
        stringsAsFactors = FALSE
      )
      as.matrix(mat)
    },
    .package = "utils"
  )

  expect_message(
    remove_user_installed_packages(),
    "No user-installed packages"
  )
})

test_that("remove_user_installed_packages filters out MRO lib paths", {
  local_mocked_bindings(
    installed.packages = function(...) {
      mat <- data.frame(
        Package = c("pkg1", "pkg2"),
        LibPath = c("/usr/lib/MRO", "/usr/lib/R"),
        Priority = c(NA, NA),
        stringsAsFactors = FALSE
      )
      as.matrix(mat)
    }, .package = "utils")
  local_mocked_bindings(remove.packages = function(pkg, ...) invisible(NULL), .package = "devkit")

  expect_message(
    remove_user_installed_packages(),
    "Removing 1 user-installed"
  )
})

test_that("remove_user_installed_packages filters out base and recommended", {
  local_mocked_bindings(installed.packages = function(...) {
      mat <- data.frame(
        Package = c("base", "recommended_pkg", "userpkg"),
        LibPath = rep("/home/user/R", 3),
        Priority = c("base", "recommended", NA),
        stringsAsFactors = FALSE
      )
      as.matrix(mat)
    }, .package = "utils")
  local_mocked_bindings(remove.packages = function(pkg, ...) invisible(NULL), .package = "devkit")

  expect_message(
    remove_user_installed_packages(),
    "Removing 1 user-installed"
  )
})

test_that("remove_user_installed_packages calls remove.packages for each user pkg", {
  removed_pkgs <- character(0)
  local_mocked_bindings(installed.packages = function(...) {
      mat <- data.frame(
        Package = c("userpkg1", "userpkg2"),
        LibPath = rep("/home/user/R", 2),
        Priority = c(NA, NA),
        stringsAsFactors = FALSE
      )
      as.matrix(mat)
    }, .package = "utils")
  local_mocked_bindings(remove.packages = function(pkg, ...) {
      removed_pkgs <<- c(removed_pkgs, pkg)
      invisible(NULL)
    }, .package = "devkit")

  remove_user_installed_packages()
  expect_true("userpkg1" %in% removed_pkgs)
  expect_true("userpkg2" %in% removed_pkgs)
})

test_that("remove_user_installed_packages reports success", {
  local_mocked_bindings(installed.packages = function(...) {
      mat <- data.frame(
        Package = "userpkg",
        LibPath = "/home/user/R",
        Priority = NA,
        stringsAsFactors = FALSE
      )
      as.matrix(mat)
    }, .package = "utils")
  local_mocked_bindings(remove.packages = function(pkg, ...) invisible(NULL), .package = "devkit")

  expect_message(
    remove_user_installed_packages(),
    "removed successfully"
  )
})
