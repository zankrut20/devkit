# Clean-Room Simulator

Runs a specified R script in a background vanilla R session to verify
reproducibility. If the script fails due to missing dependencies or
variables, it interactively prompts the user to inject the necessary
fixes directly into the file.

## Usage

``` r
simulate_clean_room()
```

## Value

Invisibly returns a named list with components: `status` ("done" or
"cancelled"), `script`, `success` (logical), and `attempts` (integer).

## Details

The function implements a "stress-test" for script reproducibility:

1.  Prompts the user to select an R script from the current directory.

2.  Executes the script using \`system2("Rscript", args = c("–vanilla",
    ...))\`, ensuring no workspace variables or attached packages from
    the current session interfere.

3.  If the script crashes, it captures the \`stderr\` output and
    presents a crash report to the user.

4.  Interactively offers to fix the crash by:

    - Injecting a missing \`library()\` call at the top of the file.

    - Injecting a custom code snippet (e.g., a missing variable
      definition).

5.  Automatically updates the file and re-runs the simulation until the
    script executes successfully or the user aborts.

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
