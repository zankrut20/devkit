#' The Network Diplomat
#'
#' @description
#' Safely executes network requests across a list of URLs or endpoints, 
#' ensuring server politeness through interactive rate limiting and 
#' resilience via automatic retries with exponential backoff.
#'
#' @details
#' The function implements a robust network request manager:
#' \enumerate{
#'   \item \strong{Rate Limiting}: Prompts the user for the server's requests-per-minute 
#'       limit and calculates a precise sleep interval between requests to avoid 
#'       being blocked.
#'   \item \strong{Retry Logic}: Wraps each request in a `tryCatch` block. If a request 
#'       fails, it will retry up to `max_retries` times.
#'   \item \strong{Exponential Backoff}: After each failure, the function waits for 
#'       an increasing amount of time (5s, 10s, 20s, etc.) before retrying.
#'   \item \strong{HTTP 429 Handling}: If a "Too Many Requests" (HTTP 429) error is 
#'       detected, it adds an additional penalty delay to the backoff time.
#'   \item \strong{Graceful Failure}: If all retries are exhausted, the target is 
#'       marked as `NA` and the process continues to the next target.
#' }
#'
#' @param targets A vector of URLs or target IDs to process.
#' @param target_func The function that makes the network request (takes one target).
#' @param max_retries Integer. Maximum number of times to retry a single failure. Defaults to `3`.
#'
#' @return A list of successfully processed results, with `NA` for permanent failures.
#'
#' @examples
#' if (interactive()) {
#'   network_diplomat(targets = c('https://example.com'), target_func = function(x) x)
#' }
#' @export

network_diplomat <- function(targets, target_func, max_retries = 3) {
  total_targets <- length(targets)
  message(sprintf("Initializing Network Diplomat for %d targets...", total_targets))
  
  # 1. Interactively Determine the Rate Limit
  req_per_min <- .read_numeric(
    prompt = "Enter the server's rate limit (Requests per MINUTE). \n(If unsure, 30 is a safe default for most public APIs): ",
    default = 30,
    default_msg = "Invalid input. Defaulting to a highly polite 30 requests per minute."
  )
  
  # Calculate exact sleep time per request
  base_sleep <- 60 / req_per_min
  message(sprintf("-> Rate limit locked. The Diplomat will pause for %.2f seconds between requests.", base_sleep))
  
  results <- vector("list", total_targets)
  
  # 2. The Throttled Execution Loop
  for (i in seq_len(total_targets)) {
    target <- targets[i]
    success <- FALSE
    attempt <- 1
    
    # 3. The Retry & Backoff Manager
    while (!success && attempt <= max_retries) {
      
      result <- tryCatch({
        # Attempt the network request
        val <- target_func(target)
        success <- TRUE
        
        # Only sleep if it's not the very last item
        if (i < total_targets) {
          Sys.sleep(base_sleep)
        }
        
        val
      }, error = function(e) {
        # Catch timeouts, 404s, 429s, or disconnected networks
        err_msg <- trimws(e$message)
        message(sprintf("\n[!] Connection Error at index %d (Attempt %d of %d):", i, attempt, max_retries))
        message(sprintf("    Target: %s", target))
        message(sprintf("    Error:  %s", err_msg))
        
        if (attempt < max_retries) {
          # Exponential Backoff: Wait longer after each consecutive failure
          # e.g., 5 seconds, then 10 seconds, then 20 seconds
          backoff_time <- 5 * (2 ^ (attempt - 1))
          
          # If it's explicitly a 429 Too Many Requests, add a heavy penalty delay
          if (grepl("429|Too Many Requests", err_msg, ignore.case = TRUE)) {
            message("    -> Server explicitly requested a slow down (HTTP 429).")
            backoff_time <- backoff_time + 15
          }
          
          message(sprintf("-> Diplomat backing off for %.1f seconds before retrying...", backoff_time))
          Sys.sleep(backoff_time)
          
        } else {
          message("-> Max retries exhausted. Diplomat abandoning this target.")
        }
        NA
      })
      
      if (success) results[[i]] <- result
      
      attempt <- attempt + 1
    }
    
    # If all retries were exhausted, mark as failed
    if (!success) results[[i]] <- NA
    
    # Optional: Print a subtle progress tracker every 10% 
    if (i %% max(1, floor(total_targets / 10)) == 0) {
      message(sprintf("... Progress: %d / %d completed", i, total_targets))
    }
  }
  
  message(sprintf("\nDiplomacy Complete! All %d targets processed.", total_targets))
  return(invisible(results))
}
