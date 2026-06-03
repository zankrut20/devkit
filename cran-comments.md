## Resubmission
This is a resubmission. In this version I have addressed all reviewer feedback:

* Replaced all uses of `installed.packages()` with faster alternatives:
  `requireNamespace()` for existence checks and `vapply()` for vectorised lookups.
  The one remaining use in `remove_user_installed_packages()` is intentional — that
  function's core purpose is to enumerate ALL installed packages for bulk removal,
  a task that cannot be replaced with simpler alternatives.

* Removed hardcoded modifications to `.GlobalEnv`. The `detect_masking()` function
  now uses `parent.frame()` to assign to the caller's environment. The
  `mask_identity()` function now accepts an `envir` parameter (default: `parent.frame()`)
  so the user explicitly controls where output is saved.

* Added executable `if (interactive())` examples to all 25 exported functions.

* No `References` field was added to `DESCRIPTION` as this package provides
  practical workflow utilities and does not implement novel methods or algorithms.

## Test environments
* local Windows 11 install, R 4.3.0
* GitHub Actions, windows-latest, release
* GitHub Actions, macos-latest, release
* GitHub Actions, ubuntu-latest, release
* GitHub Actions, ubuntu-latest, devel

## R CMD check results
0 errors | 0 warnings | 0 notes

## Reverse dependencies
There are no reverse dependencies.
