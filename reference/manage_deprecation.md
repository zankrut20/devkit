# Interactive Lifecycle Manager

Scaffolds CRAN-compliant deprecation wrappers and interactively
refactors old function calls across tests and vignettes to ensure a
smooth transition to new API versions.

## Usage

``` r
manage_deprecation()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `old_function`, `new_function`,
`wrapper_file`, and `replacements` (integer count).

## Details

The function manages the deprecation lifecycle through the following
steps:

1.  Prompts the user for the name of the function to be deprecated and
    its replacement.

2.  Automatically generates a deprecated wrapper function that calls
    \`.Deprecated()\` and then forwards arguments to the new function.

3.  Appends this wrapper to \`R/deprecated.R\`, ensuring the package
    remains backward compatible while warning users.

4.  Optionally scans the \`tests/\` and \`vignettes/\` directories for
    occurrences of the old function and interactively replaces them with
    the new one.
