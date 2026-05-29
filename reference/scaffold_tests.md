# Interactive Test-Suite Architect

Scaffolds CRAN-compliant \`testthat\` boilerplate for a specific
function by interactively prompting the user about expected behaviors,
output types, and edge cases.

## Usage

``` r
scaffold_tests()
```

## Value

Invisibly returns \`FALSE\` if the testing infrastructure is missing,
otherwise returns \`NULL\` (implicitly) upon successful file creation.

## Details

The function automates the creation of a test file in the
\`tests/testthat/\` directory:

1.  Verifies that the \`tests/testthat\` directory exists (suggesting
    \`usethis::use_testthat()\` if it does not).

2.  Prompts for the name of the function to be tested and creates a
    corresponding \`test-functionname.R\` file.

3.  Interactively determines the expected output type (e.g., data frame,
    list, numeric) to generate appropriate \`expect\_\*\` calls.

4.  Asks whether to include tests for output dimensions or error
    handling for invalid inputs.

5.  Writes a structured boilerplate file containing \`test_that\` blocks
    with TODO comments for the user to fill in mock data.
