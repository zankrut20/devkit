# Unused Dependency Scanner

Scans a specified R script for function calls, cross-references them
against currently attached packages, and interactively helps the user
resolve unused dependencies based on their current workflow.

## Usage

``` r
scan_dependencies()
```

## Value

Invisibly returns \`TRUE\` upon successful completion of the scan and
resolution process.

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
