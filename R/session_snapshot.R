#' Export Session Snapshot
#'
#' @description
#' Generates a reproducible installation script for all currently attached 
#' external R packages, allowing the user to recreate the exact environment 
#' in a different session or on another machine.
#'
#' @details
#' The function provides two modes of environment capture:
#' \enumerate{
#'   \item \strong{Flexible Installation}: Generates a script that checks for 
#'       missing packages and installs the latest available versions.
#'   \item \strong{Strict Version Locking}: Uses `devtools::install_version()` 
#'       to lock the environment to the exact versions currently installed 
#'       on the system, ensuring maximum reproducibility.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @return 
#' Invisibly returns a named list with components: \code{status} ("done" or
#' "clean"), \code{packages} (character vector), \code{file} (output path),
#' and \code{version_locked} (logical).
#'
#' @importFrom utils packageVersion
#' @examples
#' if (interactive()) {
#'   export_snapshot()
#' }
#' @export

export_snapshot <- function() {
  # Dynamically ask for output preferences
  filename <- readline(prompt = "Enter filename for the snapshot (e.g., requirements.R): ")
  if (filename == "") filename <- "requirements.R"
  
  strict_version <- readline(prompt = "Lock exact package versions using devtools? (y/n): ")
  include_versions <- tolower(trimws(strict_version)) == "y"

  # Extract non-base attached packages
  pkg_names <- .attached_packages()
  
  base_pkgs <- .base_pkgs
  
  target_pkgs <- setdiff(pkg_names, base_pkgs)
  
  if (length(target_pkgs) == 0) {
    message("No external packages currently attached. Nothing to export.")
    return(invisible(list(status = "clean")))
  }

  script_lines <- c("# Auto-generated R Environment Snapshot", "")

  if (include_versions) {
    script_lines <- c(script_lines, "if (!requireNamespace('devtools', quietly = TRUE)) install.packages('devtools')")
    for (pkg in target_pkgs) {
      ver <- as.character(packageVersion(pkg))
      script_lines <- c(script_lines, sprintf("devtools::install_version('%s', version = '%s')", pkg, ver))
    }
  } else {
    pkg_vector <- paste(sprintf('"%s"', target_pkgs), collapse = ", ")
    script_lines <- c(script_lines, 
                      sprintf("req_packages <- c(%s)", pkg_vector),
                      "missing <- req_packages[!vapply(req_packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]",
                      "if(length(missing)) install.packages(missing)"
    )
  }

  writeLines(script_lines, con = filename)
  message(sprintf("Snapshot of %d packages saved to '%s'", length(target_pkgs), filename))
  return(invisible(list(status = "done", packages = target_pkgs, file = filename, version_locked = include_versions)))
}
