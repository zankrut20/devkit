# Tests for architect_release()

test_that("architect_release returns early when DESCRIPTION is missing", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_message(architect_release(), "DESCRIPTION file not found")
})

test_that("architect_release cancels when user selects Cancel", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0"), "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )

  expect_message(architect_release(), "cancelled")
})

test_that("architect_release cancels when user selects empty string", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0"), "DESCRIPTION")

  local_mocked_bindings(
    select.list = function(choices, ...) "",
    .package = "devkit"
  )

  expect_message(architect_release(), "cancelled")
})

test_that("architect_release handles Patch bump correctly", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.2.3", "Date: 2024-01-01"), "DESCRIPTION")

  call_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      call_count <<- call_count + 1L
      if (call_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (call_count == 2L) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(architect_release(), "v1\\.2\\.4")
  desc <- read.dcf("DESCRIPTION")
  expect_equal(as.character(desc[, "Version"]), "1.2.4")
})

test_that("architect_release handles Minor bump correctly", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.2.3", "Date: 2024-01-01"), "DESCRIPTION")

  call_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      call_count <<- call_count + 1L
      if (call_count == 1L) return("Minor (New features: x.Y+1.0)")
      if (call_count == 2L) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(architect_release(), "v1\\.3\\.0")
})

test_that("architect_release handles Major bump correctly", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.2.3", "Date: 2024-01-01"), "DESCRIPTION")

  call_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      call_count <<- call_count + 1L
      if (call_count == 1L) return("Major (Breaking changes: X+1.0.0)")
      if (call_count == 2L) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(architect_release(), "v2\\.0\\.0")
})

test_that("architect_release pads version with fewer than 3 parts", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0", "Date: 2024-01-01"), "DESCRIPTION")

  call_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      call_count <<- call_count + 1L
      if (call_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (call_count == 2L) return("Yes")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  expect_message(architect_release(), "v1\\.0\\.1")
})

test_that("architect_release writes NEWS.md with changelog bullets", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0", "Date: 2024-01-01"), "DESCRIPTION")

  select_count <- 0L
  readline_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (select_count == 2L) return("Yes")
      if (select_count == 3L) return("Yes")
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("Fixed a bug")
      if (readline_count == 2L) return("Added feature")
      return("")
    },
    .package = "base"
  )

  architect_release()
  expect_true(file.exists("NEWS.md"))
  news <- readLines("NEWS.md")
  expect_true(any(grepl("Fixed a bug", news)))
  expect_true(any(grepl("Added feature", news)))
})

test_that("architect_release prepends to existing NEWS.md", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0", "Date: 2024-01-01"), "DESCRIPTION")
  writeLines("# testpkg 1.0.0\n\n* Initial release", "NEWS.md")

  select_count <- 0L
  readline_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (select_count == 2L) return("Yes")
      if (select_count == 3L) return("Yes")
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) {
      readline_count <<- readline_count + 1L
      if (readline_count == 1L) return("New fix")
      return("")
    },
    .package = "base"
  )

  architect_release()
  news <- readLines("NEWS.md")
  expect_true(any(grepl("New fix", news)))
  expect_true(any(grepl("Initial release", news)))
})

test_that("architect_release skips NEWS.md when no bullets entered", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0", "Date: 2024-01-01"), "DESCRIPTION")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (select_count == 2L) return("Yes")
      if (select_count == 3L) return("Yes")
      return("Yes")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(prompt = "", ...) "",
    .package = "base"
  )

  expect_message(architect_release(), "No items entered")
})

test_that("architect_release skips DESCRIPTION update when user says No", {
  tmp <- withr::local_tempdir()
  old_wd <- setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  writeLines(c("Package: testpkg", "Version: 1.0.0"), "DESCRIPTION")

  select_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      select_count <<- select_count + 1L
      if (select_count == 1L) return("Patch (Bug fixes: x.y.Z+1)")
      if (select_count == 2L) return("No")
      return("No")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    readline = function(...) "",
    .package = "base"
  )

  architect_release()
  desc <- read.dcf("DESCRIPTION")
  expect_equal(as.character(desc[, "Version"]), "1.0.0")
})
