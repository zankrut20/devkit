# Function Masking Detective

Scans for namespace conflicts among attached packages and interactively
helps the user resolve them. The function adapts its recommendations
based on whether it detects a package development environment or a
standalone analysis script.

## Usage

``` r
detect_masking()
```

## Value

Invisibly returns a named list with components: `status` ("done" or
"clean"), `conflicts` (named list), `resolutions` (named list), and
`context` ("package" or "standalone").

## Details

The function performs the following steps:

1.  Identifies all functions that are masked by multiple attached
    packages.

2.  Interactively prompts the user to select the preferred package for
    each conflicting function.

3.  If a \`DESCRIPTION\` file is present (Package Development context),
    it suggests updating the \`Imports\` field and adding
    \`@importFrom\` roxygen2 tags.

4.  If no \`DESCRIPTION\` file is present (Standalone context), it
    generates a code snippet to explicitly assign the preferred
    functions in the global environment and offers to apply these
    assignments immediately.

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
