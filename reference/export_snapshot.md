# Export Session Snapshot

Generates a reproducible installation script for all currently attached
external R packages, allowing the user to recreate the exact environment
in a different session or on another machine.

## Usage

``` r
export_snapshot()
```

## Value

Invisibly returns a named list with components: `status` ("done" or
"clean"), `packages` (character vector), `file` (output path), and
`version_locked` (logical).

## Details

The function provides two modes of environment capture:

1.  **Flexible Installation**: Generates a script that checks for
    missing packages and installs the latest available versions.

2.  **Strict Version Locking**: Uses \`devtools::install_version()\` to
    lock the environment to the exact versions currently installed on
    the system, ensuring maximum reproducibility.

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
