# Initialize Development Environment

Scans the system for core R package development tools, prompts the user
to install any missing packages, and allows for the selective loading of
these tools into the current R session.

## Usage

``` r
bootstrap_dev_env()
```

## Value

Invisibly returns a named list with components: `status` ("done"),
`initially_missing`, `available`, and `loaded` (character vectors).

## Details

The function focuses on a standard toolkit for CRAN-ready development,
including \`devtools\`, \`roxygen2\`, \`usethis\`, \`testthat\`, and
\`knitr\`.

The process follows these steps:

1.  Compares the list of core tools against the currently installed
    packages.

2.  If tools are missing, it provides an interactive menu to install all
    missing packages, specific ones, or skip installation entirely.

3.  After ensuring availability, it prompts the user to select which of
    the available tools should be attached to the current session using
    \`library()\`.

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
