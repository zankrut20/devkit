# Interactive Memory Sweeper

Scans the global environment for memory-intensive objects and
interactively prompts the user to remove them to free up system RAM.

## Usage

``` r
sweep_memory()
```

## Value

Invisibly returns \`NULL\`. The function operates primarily through side
effects (modifying the global environment).

## Details

The function implements a simple memory management workflow:

1.  Prompts the user to define a size threshold (in MB) for flagging
    objects.

2.  Calculates the size of all objects currently residing in the global
    environment.

3.  Identifies and sorts objects that exceed the specified threshold.

4.  Presents a selection menu allowing the user to choose one or more
    large objects for removal.

5.  Executes \`rm()\` on the selected objects and immediately calls
    \`gc()\` to ensure the memory is released back to the system.
