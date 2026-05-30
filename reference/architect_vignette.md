# Interactive Vignette Architect

Scaffolds a CRAN-compliant RMarkdown vignette by interactively prompting
the user for metadata, narrative structure, and target functions to
highlight.

## Usage

``` r
architect_vignette()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `file_path`, `package`, `title`, `template`,
and `functions` (character vector).

## Details

The function guides the user through the following process:

1.  Collects package name and vignette title.

2.  Prompts for a structural template (Quick Start, Deep Dive, or Case
    Study).

3.  Requests a list of core functions to be featured in the vignette.

4.  Generates a \`.Rmd\` file with a proper YAML header and a narrative
    scaffold based on the selected template.
