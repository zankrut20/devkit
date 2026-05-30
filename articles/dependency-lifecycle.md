# Dependency and Lifecycle Management Workflows

## Introduction

Maintaining dependencies, code lifecycles, and release procedures are
key responsibilities when developing R packages. `devkit` provides
modules to automate, audit, and safeguard these workflows.

------------------------------------------------------------------------

## 🚀 Bootstrapping the Development Environment

When onboarding a new developer or setting up a clean machine,
[`bootstrap_dev_env()`](https://zankrut20.github.io/devkit/reference/bootstrap_dev_env.md)
automates the installation of standard R development packages.

``` r

# Bootstrap standard development libraries (devtools, testthat, roxygen2, knitr, etc.)
bootstrap_dev_env()
```

------------------------------------------------------------------------

## 📦 Auditing & Scanning Dependencies

Keeping a clean and accurate `DESCRIPTION` file is critical for CRAN
compliance. `devkit` provides utilities to identify missing dependencies
and detect unused packages.

### Auditing DESCRIPTION Dependencies

[`audit_dependencies()`](https://zankrut20.github.io/devkit/reference/audit_dependencies.md)
scans your `R/` and `tests/` directories, compares the found namespaces
with those listed in your `DESCRIPTION` file, and flags discrepancies.

``` r

# Audit the current package's dependencies
audit_res <- audit_dependencies()

# Inspect results
print(audit_res$ghost_deps) # Packages used in code but missing from DESCRIPTION
print(audit_res$bloat_deps) # Packages listed in DESCRIPTION but never used in code
```

### Scanning Active Session Dependencies

[`scan_dependencies()`](https://zankrut20.github.io/devkit/reference/scan_dependencies.md)
looks at the packages currently attached or loaded in your R session and
compares them to the packages actually used by a specific script.

``` r

# Scan an active script for unused loaded packages
scan_res <- scan_dependencies("scripts/process_data.R")

print(scan_res$unused_packages) # Attached packages not used by the script
```

------------------------------------------------------------------------

## 🧹 Safely Uninstalling Packages

CRAN packages should avoid leaving system directories cluttered.
`devkit` includes safe package removal utilities.

### Uninstalling a Single Package

[`remove_package()`](https://zankrut20.github.io/devkit/reference/remove_package.md)
checks if other installed packages depend on the target package before
removing it, preventing broken dependencies.

``` r

# Remove a package safely
remove_package("unusedpkg")
```

### Resetting the User Library

[`remove_user_installed_packages()`](https://zankrut20.github.io/devkit/reference/remove_user_installed_packages.md)
cleans all user-installed packages from your library paths while
strictly preserving base and recommended R packages (such as `stats`,
`graphics`, `survival`, `Matrix`, etc.).

``` r

# Clear user-installed packages to restore a clean environment
remove_user_installed_packages()
```

------------------------------------------------------------------------

## 🛡️ Git Hooks & Safety Pre-flights

To prevent pushing broken code,
[`setup_preflight()`](https://zankrut20.github.io/devkit/reference/setup_preflight.md)
installs git pre-commit hooks that validate code styling, documentation,
and tests before a commit is finalized.

``` r

# Set up a pre-commit hook that runs checks
setup_preflight(run_docs = TRUE, run_tests = TRUE, run_style = TRUE)
```

Additionally,
[`setup_sentinel()`](https://zankrut20.github.io/devkit/reference/setup_sentinel.md)
can be used to set up automated session logging for debugging, writing
logs to a file in real time.

``` r

# Initialize session logging at the debug level
setup_sentinel(log_file = "logs/session.log", log_level = "debug")
```

------------------------------------------------------------------------

## 🔄 Managing Function Deprecations

When refactoring a package, you often need to deprecate old functions.
[`manage_deprecation()`](https://zankrut20.github.io/devkit/reference/manage_deprecation.md)
automates: 1. Writing a deprecation warning inside the old function. 2.
Creating/updating a wrapper that points to the new function. 3. Scanning
existing scripts, tests, and vignettes to automatically replace
occurrences of the old function.

``` r

# Deprecate an old function in favor of a new one
manage_deprecation(
  old_func = "old_calculate_mean",
  new_func = "calculate_mean",
  wrapper_file = "R/deprecated_wrappers.R",
  refactor = TRUE
)
```

------------------------------------------------------------------------

## 🚀 Automating Releases

When the package is ready for a new release,
[`architect_release()`](https://zankrut20.github.io/devkit/reference/architect_release.md)
orchestrates the version bump and drafts `NEWS.md`.

``` r

# Bump package version and write news bullets interactively
architect_release()
```

And
[`architect_vignette()`](https://zankrut20.github.io/devkit/reference/architect_vignette.md)
sets up a new CRAN-compliant vignette skeleton, inserting all standard
headers and boilerplate.

``` r

# Scaffold a new HTML vignette
architect_vignette(title = "Advanced Workflows")
```
