# Interactive Release Candidate Architect

Automates the process of preparing a package release by bumping the
version in the \`DESCRIPTION\` file and interactively drafting release
notes in \`NEWS.md\`.

## Usage

``` r
architect_release()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `package`, `old_version`, `new_version`,
`bump_type`, `description_updated` (logical), and `news_updated`
(logical).

## Details

The function performs the following steps:

1.  Verifies the existence of the \`DESCRIPTION\` file.

2.  Parses the current version and prompts the user to choose between a
    Patch, Minor, or Major bump.

3.  Updates the \`Version\` and \`Date\` fields in the \`DESCRIPTION\`
    file upon confirmation.

4.  Interactively collects changelog items from the user and prepends
    them to \`NEWS.md\`.
