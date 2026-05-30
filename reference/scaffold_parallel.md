# Interactive CPU Architect

Scans local hardware to determine available CPU cores and generates a
robust parallel processing scaffold for high-volume data tasks,
automating the setup of a local cluster.

## Usage

``` r
scaffold_parallel()
```

## Value

Invisibly returns a named list with components: `status` ("done",
"cancelled", or "error"), `cores` (integer), `data_object`,
`function_name`, and `saved_to` (file path or `NULL`).

## Details

The function guides the user through the creation of a parallel
processing pipeline:

1.  Detects the total number of available CPU cores using
    \`parallel::detectCores()\`.

2.  Prompts the user to select the number of cores to dedicate to the
    task, recommending leaving at least one core free for OS stability.

3.  Collects the names of the target data object and the processing
    function.

4.  Generates a complete R code snippet that:

    - Initializes a cluster using \`makeCluster()\`.

    - Exports the required function to the worker nodes via
      \`clusterExport()\`.

    - Executes the computation using \`parLapply()\`.

    - Safely shuts down the cluster using \`stopCluster()\`.

5.  Offers to print the snippet to the console or save it directly to
    \`parallel_scaffold.R\`.
