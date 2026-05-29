# Checkpoint Dispatcher

A crash-resilient wrapper for batch processing that silently caches
progress at defined intervals and interactively recovers from
interrupted sessions.

## Usage

``` r
dispatch_checkpoints(
  items,
  target_func,
  checkpoint_file = "batch_checkpoint.rds"
)
```

## Arguments

- items:

  A vector or list of items to process.

- target_func:

  The function to apply to each item.

- checkpoint_file:

  Character. The file path for the state cache. Defaults to
  \`"batch_checkpoint.rds"\`.

## Value

A list of successfully processed results.

## Details

The function provides a safety layer for long-running batch operations:

1.  Checks for an existing \`.rds\` checkpoint file. If found, it
    prompts the user to resume from the last saved index or restart the
    process.

2.  Prompts the user for a save frequency (e.g., every 100 items).

3.  Executes the \`target_func\` on each item in \`items\` within a
    \`tryCatch\` block.

4.  If a critical error occurs, it immediately saves the current state
    to the \`checkpoint_file\` and halts execution.

5.  Periodically saves the state based on the specified frequency.

6.  Upon successful completion of all items, the temporary checkpoint
    file is deleted.
