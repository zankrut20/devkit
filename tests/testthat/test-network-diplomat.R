# Tests for network_diplomat()

test_that("network_diplomat processes all targets successfully", {
  local_mocked_bindings(
    readline = function(...) "60",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  result <- network_diplomat(1:3, function(x) x * 10, max_retries = 1)
  expect_type(result, "list")
  expect_equal(length(result), 3)
  expect_equal(result[[1]], 10)
  expect_equal(result[[3]], 30)
})

test_that("network_diplomat defaults rate limit on invalid input", {
  local_mocked_bindings(
    readline = function(...) "abc",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  expect_message(
    network_diplomat(1:2, identity, max_retries = 1),
    "Defaulting"
  )
})

test_that("network_diplomat defaults rate limit on negative input", {
  local_mocked_bindings(
    readline = function(...) "-10",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  expect_message(
    network_diplomat(1:2, identity, max_retries = 1),
    "Defaulting"
  )
})

test_that("network_diplomat retries on failure and eventually succeeds", {
  call_count <- 0L
  local_mocked_bindings(
    readline = function(...) "60",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  result <- network_diplomat("url1", function(x) {
    call_count <<- call_count + 1L
    if (call_count == 1L) stop("connection timeout")
    "success"
  }, max_retries = 3)

  expect_equal(result[[1]], "success")
})

test_that("network_diplomat marks permanently failed targets as NA", {
  local_mocked_bindings(
    readline = function(...) "60",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  result <- network_diplomat("bad_url", function(x) {
    stop("permanent failure")
  }, max_retries = 2)

  expect_true(is.na(result[[1]]))
})

test_that("network_diplomat handles HTTP 429 with extra backoff", {
  local_mocked_bindings(
    readline = function(...) "60",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  call_count <- 0L
  expect_message(
    network_diplomat("url", function(x) {
      call_count <<- call_count + 1L
      if (call_count <= 1L) stop("HTTP 429 Too Many Requests")
      "ok"
    }, max_retries = 3),
    "429"
  )
})

test_that("network_diplomat calculates correct sleep interval", {
  local_mocked_bindings(
    readline = function(...) "120",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  expect_message(
    network_diplomat(1:2, identity, max_retries = 1),
    "0\\.50 seconds"
  )
})

test_that("network_diplomat reports progress at intervals", {
  local_mocked_bindings(
    readline = function(...) "999",
    Sys.sleep = function(...) invisible(NULL),
    .package = "base"
  )

  expect_message(
    network_diplomat(1:10, identity, max_retries = 1),
    "Progress"
  )
})

test_that("network_diplomat skips sleep after last target", {
  sleep_called <- FALSE
  local_mocked_bindings(
    readline = function(...) "60",
    Sys.sleep = function(time) {
      if (time > 0 && time < 5) sleep_called <<- TRUE
      invisible(NULL)
    },
    .package = "base"
  )

  network_diplomat("single_target", identity, max_retries = 1)
  # For a single target, no inter-request sleep should occur
  expect_false(sleep_called)
})
