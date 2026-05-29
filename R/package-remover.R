library("tools")

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
#' @param pkg Character. The name of the package to remove.
#' @param recursive Logical. Whether to check for recursive dependencies. Defaults to `FALSE`.
#'
#' @return A character vector of the packages that were removed, or invisibly `character()` if nothing was removed.
#'
#' @importFrom utils installed.packages select.list remove.packages
#' @importFrom tools package_dependencies
#' @export

remove<- function(pkg, recursive = FALSE){
  d<- package_dependencies(,installed.packages(), recursive = recursive)
  depends<- if(!is.null(d[[pkg]])) d[[pkg]] else character()
  required<- unique(unlist(d[!names(d) %in% c(pkg,depends)]))
  toRemove<- depends[!depends %in% required]
  if(length(toRemove)){
    toRmove <- select.list(c(pkg,sort(toRemove)), multiple = TRUE,
                           title = "Select packages to remove")
    remove.packages(toRmove)
    return(toRmove)
  } else {
    invisible(character())
  }
}

#remove("agricolae")