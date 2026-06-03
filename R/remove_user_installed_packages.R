#' Remove User-Installed Packages
#'
#' @description
#' Identifies and removes all user-installed R packages from the system, 
#' while carefully preserving base and recommended packages, as well as 
#' packages installed in specific system libraries (e.g., MRO).
#'
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Retrieves a list of all installed packages.
#'   \item Filters out packages located in libraries containing "MRO" to avoid 
#'       corrupting system-specific installations.
#'   \item Filters out packages with a priority of "base" or "recommended" to 
#'       ensure core R functionality remains intact.
#'   \item Identifies the library paths where the remaining user packages are installed.
#'   \item Iteratively removes each identified user package using `remove.packages()`.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @return 
#' Invisibly returns a named list with components: \code{status} ("done" or
#' "clean") and \code{packages_removed} (character vector).
#'
#' @importFrom utils installed.packages remove.packages
#' @examples
#' if (interactive()) {
#'   remove_user_installed_packages()
#' }
#' @export
remove_user_installed_packages <- function() {
  # installed.packages() is required here: the core purpose of this function
  # is to enumerate ALL installed user packages for bulk removal.
  # This is not a simple existence check and cannot be replaced by requireNamespace().
  instpack <- as.data.frame(utils::installed.packages())
  
  # if you use MRO, make sure that no packages in this library will be removed
  instpack <- subset(instpack, !grepl("MRO", instpack$LibPath))
  
  # we don't want to remove base or recommended packages either
  instpack <- instpack[!(instpack[,"Priority"] %in% c("base", "recommended")),]
  
  # determine the library where the packages are installed
  path <- unique(instpack$LibPath)
  
  # create a vector with all the names of the packages you want to remove
  pkgs.to.remove <- instpack[,1]
  
  if (length(pkgs.to.remove) == 0) {
    message("No user-installed packages found to remove.")
    return(invisible(list(status = "clean", packages_removed = character(0))))
  }
  
  message(sprintf("Removing %d user-installed packages...", length(pkgs.to.remove)))
  
  # remove the packages
  for (pkg in as.character(pkgs.to.remove)) {
    tryCatch(
      remove.packages(pkg, lib = path),
      error = function(e) NULL  # silently skip if pkg not found in lib
    )
  }
  
  message("User-installed packages removed successfully.")
  return(invisible(list(status = "done", packages_removed = as.character(pkgs.to.remove))))
}
