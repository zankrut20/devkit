#' Interactive Lifecycle Manager
#'
#' @description
#' Scaffolds CRAN-compliant deprecation wrappers and interactively 
#' refactors old function calls across tests and vignettes to ensure 
#' a smooth transition to new API versions.
#'
#' @details
#' The function manages the deprecation lifecycle through the following steps:
#' \enumerate{
#'   \item Prompts the user for the name of the function to be deprecated and its replacement.
#'   \item Automatically generates a deprecated wrapper function that calls `.Deprecated()` 
#'       and then forwards arguments to the new function.
#'   \item Appends this wrapper to `R/deprecated.R`, ensuring the package remains 
#'       backward compatible while warning users.
#'   \item Optionally scans the `tests/` and `vignettes/` directories for occurrences 
#'       of the old function and interactively replaces them with the new one.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @return 
#' Invisibly returns a named list with components: \code{status} ("done",
#' "cancelled", or "error"), \code{old_function}, \code{new_function},
#' \code{wrapper_file}, and \code{replacements} (integer count).
#'
#' @importFrom utils select.list
#' @examples
#' if (interactive()) {
#'   manage_deprecation()
#' }
#' @export

manage_deprecation <- function() {
  message("Initializing Lifecycle Manager...")
  
  # 1. Verify Package Environment
  if (!dir.exists("R")) {
    message("Error: 'R/' directory not found. Please run from the package root.")
    return(invisible(list(status = "error")))
  }
  
  # 2. Gather Function Names
  old_func <- readline(prompt = "Enter the name of the function to DEPRECATE: ")
  if (trimws(old_func) == "") {
    message("Aborted.")
    return(invisible(list(status = "cancelled")))
  }
  
  new_func <- readline(prompt = sprintf("Enter the name of the REPLACEMENT function for '%s': ", old_func))
  if (trimws(new_func) == "") {
    message("Aborted.")
    return(invisible(list(status = "cancelled")))
  }
  
  # 3. Scaffold the Deprecated Wrapper
  dep_file <- "R/deprecated.R"
  
  wrapper_code <- c(
    "",
    sprintf("#' @title Deprecated functions"),
    sprintf("#' @description `%s()` was deprecated in favor of `%s()`.", old_func, new_func),
    sprintf("#' @name %s-deprecated", old_func),
    "#' @keywords internal",
    "#' @export",
    sprintf("%s <- function(...) {", old_func),
    sprintf("  .Deprecated(\"%s\")", new_func),
    sprintf("  %s(...)", new_func),
    "}"
  )
  
  # Append to or create R/deprecated.R
  if (!file.exists(dep_file)) {
    writeLines(c("#' @name package-deprecated", "#' @aliases NULL", ""), dep_file)
    message(sprintf("-> Created %s", dep_file))
  }
  
  cat(paste(wrapper_code, collapse = "\n"), "\n", file = dep_file, append = TRUE)
  message(sprintf("-> Scaffolded deprecated wrapper for `%s()` in %s", old_func, dep_file))
  
  replacements_made <- 0L
  
  # 4. Internal Refactoring (Tests & Vignettes)
  refactor <- select.list(
    choices = c("Yes", "No"),
    title = sprintf("\nScan tests/ and vignettes/ to replace `%s()` with `%s()`?", old_func, new_func)
  )
  
  if (refactor == "Yes") {
    target_dirs <- c("tests", "vignettes")
    files_to_scan <- character()
    
    for (d in target_dirs) {
      if (dir.exists(d)) {
        files_to_scan <- c(files_to_scan, list.files(d, pattern = "\\.(R|Rmd)$", full.names = TRUE, recursive = TRUE, ignore.case = TRUE))
      }
    }
    
    if (length(files_to_scan) == 0) {
      message("No tests or vignettes found to scan.")
      return(invisible(list(status = "done", old_function = old_func, new_function = new_func, wrapper_file = dep_file, replacements = 0L)))
    }
    
    message("\n--- Scanning for Internal Usage ---")
    regex_pattern <- paste0("\\b", old_func, "\\(")
    replacements_made <- 0
    
    for (f in files_to_scan) {
      lines <- readLines(f, warn = FALSE)
      matches <- grep(regex_pattern, lines)
      
      if (length(matches) > 0) {
        message(sprintf("\nFound %d instance(s) in: %s", length(matches), f))
        
        for (idx in matches) {
          # Show the user the exact line of code
          message(sprintf("Line %d: %s", idx, trimws(lines[idx])))
          action <- select.list(
            c("Replace", "Skip"), 
            title = "Action:"
          )
          
          if (action == "Replace") {
            # Safely replace only the exact function call
            lines[idx] <- gsub(regex_pattern, paste0(new_func, "("), lines[idx])
            replacements_made <- replacements_made + 1
          }
        }
        # Write the updated lines back to the file
        writeLines(lines, f)
      }
    }
    
    message(sprintf("\nRefactoring complete. Made %d replacements.", replacements_made))
  }
  
  message("\nLifecycle update finished. Remember to remove the original definition of the deprecated function from your R/ scripts!")
  return(invisible(list(
    status = "done",
    old_function = old_func,
    new_function = new_func,
    wrapper_file = dep_file,
    replacements = replacements_made
  )))
}
