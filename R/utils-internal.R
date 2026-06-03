# Internal utility functions for devkit
# None of these are exported.

# Canonical list of base R packages (ships with every R installation).
# Used by: audit_dependencies, scan_dependencies, session_snapshot
.base_pkgs <- c("base", "compiler", "datasets", "graphics", "grDevices",
                 "grid", "methods", "parallel", "splines", "stats", "stats4",
                 "tcltk", "tools", "utils")

# List data frame names in the global environment.
# Used by: dictate_dictionary
.list_global_dataframes <- function() {
  objs <- ls(envir = .GlobalEnv)
  objs[vapply(objs, function(x) is.data.frame(get(x, envir = .GlobalEnv)), logical(1))]
}

# List data frame names in a given environment.
# Used by: mask_identity
.list_dataframes_in <- function(envir) {
  objs <- ls(envir = envir)
  objs[vapply(objs, function(x) is.data.frame(get(x, envir = envir)), logical(1))]
}

# Prompt the user for a numeric value with a fallback default.
# Used by: memory_sweeper, network_diplomat
.read_numeric <- function(prompt, default, default_msg = NULL) {
  input <- readline(prompt = prompt)
  value <- suppressWarnings(as.numeric(input))
  if (is.na(value) || value <= 0) {
    if (!is.null(default_msg)) message(default_msg)
    value <- default
  }
  value
}

# Get names of non-base attached packages.
# Used by: session_snapshot, scan_dependencies
.attached_packages <- function() {
  s <- search()
  gsub("package:", "", s[grepl("^package:", s)])
}
