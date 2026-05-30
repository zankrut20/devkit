# Unused Dependency Scanner

Scans a specified R script for function calls, cross-references them
against currently attached packages, and interactively helps the user
resolve unused dependencies based on their current workflow.

## Usage

``` r
scan_dependencies()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", "clean", or "error"), `script`, `external_packages`, and
`unused_packages` (character vectors).

## Details

The function provides different resolution paths depending on the
detected context:

1.  **Package Development**: If a \`DESCRIPTION\` file is found, it
    flags unused packages that should be removed from the \`Imports\`
    field.

2.  **Data Analysis**: If the user is working in an active session, it
    offers to detach idle packages and call \`gc()\` to reclaim RAM.

3.  **Raw Script Cleaning**: It generates an optimized block of
    \`library()\` calls containing only the packages actually required
    by the script.

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
