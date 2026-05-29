# Interactive Package Remover

Safely removes a specified R package and its unused dependencies from
the system, ensuring that other installed packages do not lose required
dependencies.

## Usage

``` r
remove_package(pkg, recursive = FALSE)
```

## Arguments

- pkg:

  Character. The name of the package to remove.

- recursive:

  Logical. Whether to check for recursive dependencies. Defaults to
  \`FALSE\`.

## Value

A character vector of the packages that were removed, or invisibly
\`character()\` if nothing was removed.

## Details

The function implements a dependency-aware removal process:

1.  Identifies the dependencies of the target package using
    \`tools::package_dependencies\`.

2.  Analyzes all other installed packages to determine which
    dependencies are still required.

3.  Isolates "orphan" dependencies—those that were only required by the
    target package.

4.  Interactively prompts the user to select which of these orphan
    packages (and the target package itself) should be removed.

5.  Executes \`remove.packages()\` on the selected items.
