# Tests for hunt_zombies()

test_that("hunt_zombies cancels when user selects Cancel", {
  local_mocked_bindings(
    select.list = function(choices, ...) "Cancel",
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  expect_message(hunt_zombies(), "cancelled")
})

test_that("hunt_zombies cancels on empty selection", {
  local_mocked_bindings(
    select.list = function(choices, ...) character(0),
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  expect_message(hunt_zombies(), "cancelled")
})

test_that("hunt_zombies offers flush when temp size > 5 MB", {
  choices_offered <- NULL
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices_offered <<- choices
      return("Cancel")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) rep("fake.tmp", 100),
    file.info = function(...) {
      data.frame(size = rep(1e6, 100), isdir = rep(FALSE, 100))
    },
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  hunt_zombies()
  expect_true(any(grepl("Flush", choices_offered)))
})

test_that("hunt_zombies offers close devices when devices are open", {
  choices_offered <- NULL
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices_offered <<- choices
      return("Cancel")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() c(2L, 3L),
    .package = "devkit"
  )

  hunt_zombies()
  expect_true(any(grepl("Graphical", choices_offered)))
})

test_that("hunt_zombies executes flush temp directory", {
  unlink_called <- FALSE
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices[grepl("Flush", choices)]
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) rep("fake.tmp", 100),
    file.info = function(...) {
      data.frame(size = rep(1e6, 100), isdir = rep(FALSE, 100))
    },
    unlink = function(...) { unlink_called <<- TRUE },
    dir.create = function(...) NULL,
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  expect_message(hunt_zombies(), "Flushed")
})

test_that("hunt_zombies executes close graphics devices", {
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices[grepl("Graphical", choices)]
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() c(2L, 3L),
    graphics.off = function() NULL,
    .package = "devkit"
  )

  expect_message(hunt_zombies(), "Closed")
})

test_that("hunt_zombies executes deep garbage collection", {
  gc_count <- 0L
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices[grepl("Garbage", choices)]
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    gc = function(...) { gc_count <<- gc_count + 1L; NULL },
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  expect_message(hunt_zombies(), "Garbage|freed")
})

test_that("hunt_zombies always includes GC option", {
  choices_offered <- NULL
  local_mocked_bindings(
    select.list = function(choices, ...) {
      choices_offered <<- choices
      return("Cancel")
    },
    .package = "devkit"
  )
  local_mocked_bindings(
    list.files = function(...) character(0),
    file.info = function(...) data.frame(size = numeric(0)),
    .package = "base"
  )
  local_mocked_bindings(
    dev.list = function() NULL,
    .package = "devkit"
  )

  hunt_zombies()
  expect_true(any(grepl("Garbage", choices_offered)))
})
