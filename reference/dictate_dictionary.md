# Interactive Data Dictionary Dictator

Generates roxygen2 documentation for a data frame by interactively
prompting the user for a dataset title, a general description, and
individual column descriptions.

## Usage

``` r
dictate_dictionary()
```

## Value

Invisibly returns \`TRUE\` upon completion.

## Details

The function performs the following steps:

1.  Scans the global environment for all available data frames.

2.  Prompts the user to select a target data frame for documentation.

3.  Collects high-level metadata (title and description) for the
    dataset.

4.  Iterates through each column, displaying its type and prompting the
    user for a descriptive label.

5.  Assembles the collected information into a CRAN-compliant roxygen2
    block using the \`

    \` tag.

6.  Offers the user the choice to either print the resulting block to
    the console or append it to \`R/data.R\`.
