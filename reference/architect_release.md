# Interactive Release Candidate Architect

Automates the process of preparing a package release by bumping the
version in the \`DESCRIPTION\` file and interactively drafting release
notes in \`NEWS.md\`.

## Usage

``` r
architect_release()
```

## Value

Invisibly returns \`NULL\`. The function operates primarily through side
effects (modifying files and printing messages).

## Details

The function performs the following steps:

1.  Verifies the existence of the \`DESCRIPTION\` file.

2.  Parses the current version and prompts the user to choose between a
    Patch, Minor, or Major bump.

3.  Updates the \`Version\` and \`Date\` fields in the \`DESCRIPTION\`
    file upon confirmation.

4.  Interactively collects changelog items from the user and prepends
    them to \`NEWS.md\`.
