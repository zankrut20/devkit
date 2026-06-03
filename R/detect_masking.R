
#' Function Masking Detective
#'
#' @description
#' Scans for namespace conflicts among attached packages and interactively
#' helps the user resolve them. The function adapts its recommendations
#' based on whether it detects a package development environment or a
#' standalone analysis script.
#'
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Identifies all functions that are masked by multiple attached packages.
#'   \item Interactively prompts the user to select the preferred package for each conflicting function.
#'   \item If a \code{DESCRIPTION} file is present (Package Development context), it suggests
#'       updating the \code{Imports} field and adding \code{@importFrom} roxygen2 tags.
#'   \item If no \code{DESCRIPTION} file is present (Standalone context), it generates a
#'       code snippet to explicitly assign the preferred functions and offers to apply them.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @return
#' Invisibly returns a named list with components: \code{status} ("done" or
#' "clean"), \code{conflicts} (named list), \code{resolutions} (named list),
#' and \code{context} ("package" or "standalone").
#'
#' @importFrom utils select.list
#' @examples
#' if (interactive()) {
#'   detect_masking()
#' }
#' @export

detect_masking <- function() {
  # 1. Identify conflicts across all attached packages
  all_confs <- conflicts(detail = TRUE)

  # Filter for conflicts that only involve multiple attached packages
  pkg_confs <- list()
  for (func in names(all_confs)) {
    envs <- all_confs[[func]]
    # Extract only package environments, ignoring the global env
    pkg_envs <- envs[grepl("^package:", envs)]
    if (length(pkg_envs) > 1) {
      pkg_confs[[func]] <- gsub("^package:", "", pkg_envs)
    }
  }

  if (length(pkg_confs) == 0) {
    message("No cross-package function masking detected. Your namespace is clean.")
    return(invisible(list(status = "clean", conflicts = list(), resolutions = list())))
  }

  message(sprintf("Detected %d masked functions.", length(pkg_confs)))

  # 2. Interactive Step-by-Step Resolution
  resolutions <- list()
  for (func in names(pkg_confs)) {
    pkgs <- pkg_confs[[func]]

    prompt_title <- sprintf("Conflict for '%s()'. Which package should take priority?", func)
    chosen_pkg <- select.list(
      choices = c(pkgs, "Skip/Ignore"),
      title = prompt_title
    )

    if (chosen_pkg != "" && chosen_pkg != "Skip/Ignore") {
      resolutions[[func]] <- chosen_pkg
    }
  }

  if (length(resolutions) == 0) {
    message("No conflict resolutions selected.")
    return(invisible(list(status = "done", conflicts = pkg_confs, resolutions = list())))
  }

  # 3. Determine Context: Package Development vs. Standalone Script
  is_pkg_dev <- file.exists("DESCRIPTION")

  message("\n--- Recommended Resolution Actions ---")

  if (is_pkg_dev) {
    message("Context: Package Development (Detected DESCRIPTION file in root)")

    unique_pkgs <- unique(unlist(resolutions))
    message("\n1. Ensure the following are listed under 'Imports:' in your DESCRIPTION file:")
    message(paste("   Imports:", paste(unique_pkgs, collapse = ", ")))

    message("\n2. Add these roxygen2 tags to your package documentation to safely lock the namespace:")
    for (func in names(resolutions)) {
      message(sprintf("   #' @importFrom %s %s", resolutions[[func]], func))
    }
    message("\n   (Alternatively, strict `pkg::func()` syntax can be used within your source code).")

  } else {
    message("Context: Standalone Analysis Script")
    message("\nAdd the following snippet at the top of your script (immediately AFTER your library() calls) to lock in your namespace priorities:\n")

    # Generate copy-pasteable script block
    cat("# --- Namespace Conflict Resolutions ---\n")
    for (func in names(resolutions)) {
      cat(sprintf("%s <- %s::%s\n", func, resolutions[[func]], func))
    }
    cat("# --------------------------------------\n")

    # Optional: Apply instantly to the current session
    apply_now <- select.list(
      choices = c("Yes", "No"),
      title = "\nApply these resolutions to your current active session right now?"
    )

    if (apply_now == "Yes") {
      message("\nApplying resolutions to the calling environment...")
      caller_env <- parent.frame()
      for (func in names(resolutions)) {
        # Assign to caller's environment (user has explicitly consented via prompt above)
        assign(func, get(func, envir = asNamespace(resolutions[[func]])), envir = caller_env)
      }
      message("Success: Priorities applied to the current environment.")
    }
  }

  return(invisible(list(
    status = "done",
    conflicts = pkg_confs,
    resolutions = resolutions,
    context = ifelse(is_pkg_dev, "package", "standalone")
  )))
}
