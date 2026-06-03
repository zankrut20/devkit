# Silent State Auditor

Takes a snapshot of global options, graphical parameters, and the
working directory, sources a specified R script, and then interactively
helps the user identify and revert any "hijacked" settings changed by
the script.

## Usage

``` r
audit_script()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `script`, and `changes_found` (logical).

## Details

The function operates as follows:

1.  Captures the current state of \`getwd()\`, \`options()\`, and
    \`par()\`.

2.  Prompts the user to select an R script from the current directory to
    execute.

3.  Sources the selected script, catching any errors that occur during
    execution.

4.  Captures the "Before" state (working directory, loaded packages,
    global objects).

5.  Executes the target script.

6.  Captures the "After" state and reports the delta.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (interactive()) {
  audit_script()
}
```
