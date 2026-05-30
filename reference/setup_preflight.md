# Interactive Pre-Flight Dispatcher

Generates a custom Git pre-commit hook by interactively prompting the
user to select which safety checks should be enforced before allowing a
commit.

## Usage

``` r
setup_preflight()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `hook_path`, and `checks` (named logical
list).

## Details

The function automates the creation of a \`.git/hooks/pre-commit\` shell
script that can enforce the following checks:

1.  **Code Styling**: Automatically runs \`styler::style_pkg()\` to
    standardize formatting and stages the modified files.

2.  **Documentation**: Automatically runs \`devtools::document()\` to
    ensure the \`NAMESPACE\` and help files are up to date.

3.  **Testing**: Executes \`testthat::test_local()\` and aborts the
    commit if any tests fail.

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
