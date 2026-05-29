# Export Session Snapshot

Generates a reproducible installation script for all currently attached
external R packages, allowing the user to recreate the exact environment
in a different session or on another machine.

## Usage

``` r
export_snapshot()
```

## Value

Invisibly returns \`NULL\`. The primary output is the creation of a
script file (e.g., \`requirements.R\`) in the current working directory.

## Details

The function provides two modes of environment capture:

1.  **Flexible Installation**: Generates a script that checks for
    missing packages and installs the latest available versions.

2.  **Strict Version Locking**: Uses \`devtools::install_version()\` to
    lock the environment to the exact versions currently installed on
    the system, ensuring maximum reproducibility.
