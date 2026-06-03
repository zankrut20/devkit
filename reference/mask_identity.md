# Interactive Identity Masker

Safely anonymizes Personally Identifiable Information ('PII') in a
dataset by interactively prompting the user to keep, drop, or scramble
each column.

## Usage

``` r
mask_identity(envir = parent.frame())
```

## Arguments

- envir:

  The environment to search for data frames and in which to save the
  anonymized dataset. Defaults to the calling environment.

## Value

Invisibly returns the anonymized data frame.

## Details

The function provides a guided workflow for data anonymization:

1.  Scans the calling environment for available data frames and prompts
    the user to select one.

2.  Iterates through every column in the selected data frame, displaying
    its name and type.

3.  For each column, the user chooses one of three actions:

    - **Keep**: Leaves the column unchanged.

    - **Scramble**: For numeric data, it shuffles the values to preserve
      the distribution while breaking the link to individuals. For
      text/factors, it replaces values with sequential placeholders
      (e.g., "Masked_0001").

    - **Drop**: Removes the column entirely from the dataset.

4.  Saves the resulting anonymized data frame back to `envir` with a
    `_masked` suffix.

5.  Optionally generates a [`dput()`](https://rdrr.io/r/base/dput.html)
    output of the first 20 rows for easy, safe sharing.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (interactive()) {
  mask_identity()
}
```
