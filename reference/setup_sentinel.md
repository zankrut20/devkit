# Session Sentinel

Interactively configures dual-logging for the current R session, routing
messages, warnings, and errors to a text file while maintaining live
console output.

## Usage

``` r
setup_sentinel()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `log_file`, and `log_level`.

## Details

The function implements a background logging system using R's global
calling handlers:

1.  Verifies that the R version is 4.0.0 or higher, as global calling
    handlers are required.

2.  Prompts the user to select a logging level: either "All Output"
    (Messages, Warnings, and Errors) or "Errors Only".

3.  Prompts for a log filename, defaulting to a timestamped
    \`session_log_YYYYMMDD_HHMM.txt\`.

4.  Attaches \`globalCallingHandlers\` to the session, which intercepts
    conditions and appends them to the log file with a timestamp and
    type label.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (interactive()) {
  setup_sentinel()
}
```
