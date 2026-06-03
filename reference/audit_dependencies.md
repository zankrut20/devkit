# Interactive Dependency Diplomat (Base R Edition)

Scans package source code for external package calls and
cross-references them against the \`DESCRIPTION\` file to interactively
resolve missing, unused, or misclassified dependencies without requiring
any external tools.

## Usage

``` r
audit_dependencies()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"clean", or "error"), `ghost_deps`, `bloat_deps`, `misclassified`, and
`description_modified` (logical).

## Details

The function implements a zero-dependency approach to dependency
auditing:

1.  Parses the \`DESCRIPTION\` file to identify currently declared
    \`Imports\` and \`Suggests\`.

2.  Recursively scans the \`R/\`, \`tests/\`, and \`vignettes/\`
    directories for \`::\` calls, \`library()\` calls, and \`require()\`
    calls.

3.  Filters out base R packages.

4.  Interactively prompts the user to add missing dependencies or remove
    unused ones from the \`DESCRIPTION\` file.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (interactive()) {
  audit_dependencies()
}
```
