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

Invisibly returns \`NULL\`. The function modifies the \`DESCRIPTION\`
file in-place based on user interaction.

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
