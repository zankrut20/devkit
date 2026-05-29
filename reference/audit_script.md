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

Invisibly returns \`NULL\`. The function's primary purpose is to manage
the R session state through side effects.

## Details

The function operates as follows:

1.  Captures the current state of \`getwd()\`, \`options()\`, and
    \`par()\`.

2.  Prompts the user to select an R script from the current directory to
    execute.

3.  Sources the selected script, catching any errors that occur during
    execution.

4.  Compares the post-execution state with the pre-execution snapshot.

5.  Interactively prompts the user to either keep or revert each
    detected change in the working directory, global options, or
    graphical parameters.
