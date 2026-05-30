# Branch-Based Performance Benchmarker

Interactively selects Git branches, runs a target R script in an
isolated environment for each branch, and compares the execution times
to identify performance regressions or improvements across different
versions of the codebase.

## Usage

``` r
benchmark_branches()
```

## Value

A data frame containing the benchmark results, including the branch
name, execution time in seconds, and the execution status
(Success/Failed).

## Details

The function performs the following workflow:

- Verifies that the current directory is a Git repository.

- Extracts available branches and allows the user to select specific
  ones or benchmark all.

- Prompts for the path to the R script to be benchmarked.

- Stashes any uncommitted changes to ensure a clean state.

- Iterates through the selected branches, checking each one out and
  executing the target script within a fresh environment
  [`new.env()`](https://rdrr.io/r/base/environment.html).

- Restores the original branch and pops the stash to return the
  workspace to its initial state.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (FALSE) { # \dontrun{
# This is an interactive or file-system modifying function
# that requires manual user confirmation or action.
} # }
```
