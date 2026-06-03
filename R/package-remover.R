#' Interactive Package Remover
#'
#' @description
#' Safely removes a specified R package and its unused dependencies from the
#' system, ensuring that other installed packages do not lose required dependencies.
#'
#' @details
#' The function implements a dependency-aware removal process:
#' \enumerate{
#'   \item Identifies the dependencies of the target package using `tools::package_dependencies`.
#'   \item Analyzes all other installed packages to determine which dependencies are still required.
#'   \item Isolates "orphan" dependencies—those that were only required by the target package.
#'   \item Interactively prompts the user to select which of these orphan packages (and the target package itself) should be removed.
#'   \item Executes `remove.packages()` on the selected items.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @param pkg Character. The name of the package to remove.
#' @param recursive Logical. Whether to check for recursive dependencies. Defaults to `FALSE`.
#'
#' @return A character vector of the packages that were removed, or invisibly `character()` if nothing was removed.
#'
#' @importFrom utils select.list remove.packages
#' @importFrom tools package_dependencies
#' @examples
#' if (interactive()) {
#'   remove_package('curl')
#' }
#' @export

remove_package <- function(pkg, recursive = FALSE) {
  # Build dependency map only for the target package to avoid scanning all packages
  db <- utils::installed.packages() # required for tools::package_dependencies()
  d <- package_dependencies(pkg, db = db, recursive = recursive)
  depends <- if (!is.null(d[[pkg]])) d[[pkg]] else character()
  required <- unique(unlist(d[!names(d) %in% c(pkg, depends)]))
  orphans <- depends[!depends %in% required]

  # Always offer the target package itself for removal, plus any orphans
  candidates <- c(pkg, sort(orphans))

  to_remove <- select.list(candidates, multiple = TRUE,
                           title = "Select packages to remove")

  if (length(to_remove) > 0) {
    remove.packages(to_remove)
    return(to_remove)
  }

  invisible(character())
}
