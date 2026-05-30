# Zombie Data Hunter

Hunts down "invisible" memory hogs such as massive temporary files,
unclosed graphical devices, and uncollected garbage, prompting the user
for targeted cleaning to reclaim system resources.

## Usage

``` r
hunt_zombies()
```

## Value

Invisibly returns a named list with components: `status` ("done" or
"cancelled"), `actions_taken` (character vector), `temp_flushed_mb`
(numeric), and `devices_closed` (integer).

## Details

The function performs a system scan for three types of "zombie" data:

1.  **Temporary Files**: Calculates the total size of the current
    session's temporary directory. If it exceeds 5 MB, it offers to
    flush it.

2.  **Graphical Devices**: Checks for any open graphical devices (e.g.,
    PDF, PNG, or RStudioGD) and offers to close all of them.

3.  **Orphaned Memory**: Offers to perform a "deep" garbage collection
    by calling \`gc()\` twice, which forces R to clear both older and
    newer generations of memory.
