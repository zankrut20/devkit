# Temp-Cache Janitor

Scans hidden R temporary directories for abandoned session data and
caches, categorizes the storage waste, and interactively prompts the
user for safe deletion to reclaim disk space.

## Usage

``` r
sweep_temp_cache()
```

## Value

Invisibly returns \`NULL\`. The function operates primarily through side
effects (deleting files from the disk).

## Details

The function performs a deep scan of the OS-level temporary directory
where R stores session data:

1.  Identifies all directories matching the \`RtmpXXXXXX\` pattern.

2.  Scans these directories and categorizes files into buckets:

    - **Knitr/RMarkdown Caches**: \`.knit.md\`, \`.utf8.md\`, and
      \`\_cache\` files.

    - **Downloaded Packages**: \`.tar.gz\`, \`.zip\`, and \`.tgz\`
      files.

    - **Raster/Image Files**: \`.tif\`, \`.png\`, \`.jpg\`, and \`.grd\`
      files.

    - **General Session Data**: All other temporary files.

3.  Calculates the total size of each bucket in megabytes.

4.  Interactively prompts the user to select which buckets to
    permanently flush.
