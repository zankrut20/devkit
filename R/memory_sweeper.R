#' Interactive Memory Sweeper
#'
#' @description
#' Scans the global environment for memory-intensive objects and interactively 
#' prompts the user to remove them to free up system RAM.
#'
#' @details
#' The function implements a simple memory management workflow:
#' \enumerate{
#'   \item Prompts the user to define a size threshold (in MB) for flagging objects.
#'   \item Calculates the size of all objects currently residing in the global environment.
#'   \item Identifies and sorts objects that exceed the specified threshold.
#'   \item Presents a selection menu allowing the user to choose one or more large 
#'       objects for removal.
#'   \item Executes `rm()` on the selected objects and immediately calls `gc()` 
#'       to ensure the memory is released back to the system.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @return 
#' Invisibly returns a named list with components: \code{status} ("done",
#' "clean", or "cancelled"), \code{threshold_mb} (numeric), and
#' \code{objects_removed} (character vector of removed object names).
#'
#' @importFrom utils object.size select.list
#' @examples
#' if (interactive()) {
#'   sweep_memory()
#' }
#' @export

sweep_memory <- function() {
  # Dynamically ask for the threshold during execution
  threshold <- .read_numeric(
    prompt = "Enter minimum object size to flag (in MB, e.g., 50): ",
    default = 50,
    default_msg = "Invalid input. Defaulting to 50 MB."
  )

  env_objs <- ls(envir = .GlobalEnv)
  if (length(env_objs) == 0) {
    message("The global environment is empty.")
    return(invisible(list(status = "clean", threshold_mb = threshold, objects_removed = character(0))))
  }

  # Calculate object sizes in MB
  obj_sizes <- sapply(env_objs, function(x) object.size(get(x, envir = .GlobalEnv)) / (1024^2))
  large_objs <- obj_sizes[obj_sizes >= threshold]

  if (length(large_objs) == 0) {
    message(sprintf("No objects found larger than %s MB.", threshold))
    return(invisible(list(status = "clean", threshold_mb = threshold, objects_removed = character(0))))
  }

  # Format choices for the selection menu
  large_objs <- sort(large_objs, decreasing = TRUE)
  display_names <- sprintf("%s (%.2f MB)", names(large_objs), large_objs)

  # Trigger interactive prompt
  to_remove <- select.list(
    choices = display_names,
    multiple = TRUE,
    title = "Select large objects to wipe from memory (0 to cancel):"
  )

  if (length(to_remove) > 0) {
    actual_names <- sapply(strsplit(to_remove, " \\("), `[`, 1)
    rm(list = actual_names, envir = .GlobalEnv)
    gc() # Force garbage collection to instantly free up RAM
    message(sprintf("Successfully removed %d objects and cleared memory.", length(actual_names)))
    return(invisible(list(status = "done", threshold_mb = threshold, objects_removed = actual_names)))
  } else {
    message("Memory sweep cancelled.")
    return(invisible(list(status = "cancelled", threshold_mb = threshold, objects_removed = character(0))))
  }
}
