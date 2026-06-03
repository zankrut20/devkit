# Bulk Loop Guardian

A memory-safe wrapper for heavy iterations that monitors RAM usage and
triggers an interactive failsafe if the environment approaches critical
capacity.

## Usage

``` r
loop_guardian(
  items,
  target_func,
  limit_mb = 4000,
  save_path = "emergency_checkpoint.rds"
)
```

## Arguments

- items:

  A vector or list of items to process.

- target_func:

  The function to apply to each item.

- limit_mb:

  Numeric. The memory limit in megabytes before triggering the alarm.
  Defaults to \`4000\`.

- save_path:

  Character. Where to dump the emergency checkpoint data. Defaults to
  \`"emergency_checkpoint.rds"\`.

## Value

A list of successfully processed results.

## Details

The function provides a safeguard against memory-related crashes during
large-scale batch processing:

1.  Iterates through the \`items\` vector, applying \`target_func\` to
    each element.

2.  Every 50 iterations, it checks the current memory usage using
    \`gc()\`.

3.  If the memory usage exceeds \`limit_mb\`, it first attempts a deep
    garbage collection to recover RAM.

4.  If memory remains above the threshold after GC, it triggers an
    interactive alarm, allowing the user to:

    - Save current progress to \`save_path\` and abort.

    - Ignore the limit and attempt to continue.

    - Abort immediately without saving.

## Warning

This function modifies files on disk or the global environment. Please
ensure you have a backup or are using version control (e.g., Git) before
execution.

## Examples

``` r
if (interactive()) {
  loop_guardian(items = 1:5, target_func = print)
}
```
