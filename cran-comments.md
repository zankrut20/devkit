## Initial Submission

This is the initial submission of the `devkit` package to CRAN.

### CRAN Compliance Notes

* **Removed `installed.packages()` calls**: All explicit calls to `installed.packages()` 
  have been removed from the codebase. The `tools::package_dependencies()` function 
  now uses its internal default mechanism instead, which is more efficient and aligns 
  with CRAN best practices.

* **Interactive-only functions**: Functions that perform file system modifications or 
  require user interaction include `if (interactive())` guards in their examples to 
  prevent CRAN check warnings.

* **Zero dependencies**: This package has no external dependencies beyond base R (only 
  imports: `tools`), ensuring compatibility and minimal dependency burden.

* **Session state management**: Functions that modify global state document this behavior 
  and provide mechanisms for users to control where outputs are saved (e.g., `mask_identity()` 
  accepts an `envir` parameter).

## Test environments
* local Windows 11 install, R 4.6.0
* GitHub Actions, windows-latest, release
* GitHub Actions, macos-latest, release
* GitHub Actions, ubuntu-latest, release
* GitHub Actions, ubuntu-latest, devel

## R CMD check results
0 errors | 0 warnings | 0 notes

## Reverse dependencies
There are no reverse dependencies.
