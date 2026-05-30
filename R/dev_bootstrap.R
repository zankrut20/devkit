#' Initialize Development Environment
#'
#' @description
#' Scans the system for core R package development tools, prompts the user to 
#' install any missing packages, and allows for the selective loading of these 
#' tools into the current R session.
#'
#' @details
#' The function focuses on a standard toolkit for CRAN-ready development, 
#' including `devtools`, `roxygen2`, `usethis`, `testthat`, and `knitr`.
#' 
#' The process follows these steps:
#' \enumerate{
#'   \item Compares the list of core tools against the currently installed packages.
#'   \item If tools are missing, it provides an interactive menu to install all 
#'       missing packages, specific ones, or skip installation entirely.
#'   \item After ensuring availability, it prompts the user to select which 
#'       of the available tools should be attached to the current session using `library()`.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'

#' @return 
#' Invisibly returns a named list with components: \code{status} ("done"),
#' \code{initially_missing}, \code{available}, and \code{loaded} (character vectors).
#'
#' @importFrom utils installed.packages select.list install.packages
#' @examples
#' \dontrun{
#' # This is an interactive or file-system modifying function
#' # that requires manual user confirmation or action.
#' }
#' @export

bootstrap_dev_env <- function() {
  # The essential toolkit for CRAN-ready package development
  core_tools <- c("devtools", "roxygen2", "usethis", "testthat", "knitr")
  
  # Identify what is currently installed
  installed <- rownames(installed.packages())
  missing_tools <- setdiff(core_tools, installed)
  
  message("Checking development environment...")
  
  # Step 1: Handle missing packages interactively
  if (length(missing_tools) > 0) {
    message("The following development tools are missing from your system:")
    print(missing_tools)
    
    to_install <- select.list(
      choices = c("Install All Missing", missing_tools, "Skip Installation"),
      multiple = TRUE,
      title = "Select packages to install right now:"
    )
    
    if (!"Skip Installation" %in% to_install && length(to_install) > 0) {
      if ("Install All Missing" %in% to_install) {
        install.packages(missing_tools)
      } else {
        install.packages(to_install)
      }
      message("Installation complete.")
    } else {
      message("Skipping installation.")
    }
  } else {
    message("All core development tools are already installed on your system.")
  }
  
  # Step 2: Dynamically load tools for the current session
  # Re-evaluate installed packages in case new ones were just added
  available_tools <- intersect(core_tools, rownames(installed.packages()))
  
  to_load <- select.list(
    choices = available_tools,
    multiple = TRUE,
    title = "Select development tools to attach to this session:"
  )
  
  if (length(to_load) > 0) {
    for (pkg in to_load) {
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    }
    message(sprintf("Successfully attached: %s", paste(to_load, collapse = ", ")))
  } else {
    message("No development tools attached.")
  }
  
  return(invisible(list(
    status = "done",
    initially_missing = missing_tools,
    available = available_tools,
    loaded = to_load
  )))
}
