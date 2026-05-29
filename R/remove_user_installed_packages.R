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
#' @return 
#' Invisibly returns the result of the `sapply` call, which is a vector 
#' indicating the success or failure of each package removal.
#'
#' @importFrom utils installed.packages remove.packages
#' @export
remove_user_installed_packages <- function() {
  # create a list of all installed packages
  instpack <- as.data.frame(installed.packages())
  
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
    return(invisible(NULL))
  }
  
  message(sprintf("Removing %d user-installed packages...", length(pkgs.to.remove)))
  
  # remove the packages
  res <- sapply(pkgs.to.remove, remove.packages, lib = path)
  
  message("User-installed packages removed successfully.")
  return(invisible(res))
}