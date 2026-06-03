# The Network Diplomat

Safely executes network requests across a list of URLs or endpoints,
ensuring server politeness through interactive rate limiting and
resilience via automatic retries with exponential backoff.

## Usage

``` r
network_diplomat(targets, target_func, max_retries = 3)
```

## Arguments

- targets:

  A vector of URLs or target IDs to process.

- target_func:

  The function that makes the network request (takes one target).

- max_retries:

  Integer. Maximum number of times to retry a single failure. Defaults
  to \`3\`.

## Value

A list of successfully processed results, with \`NA\` for permanent
failures.

## Details

The function implements a robust network request manager:

1.  **Rate Limiting**: Prompts the user for the server's
    requests-per-minute limit and calculates a precise sleep interval
    between requests to avoid being blocked.

2.  **Retry Logic**: Wraps each request in a \`tryCatch\` block. If a
    request fails, it will retry up to \`max_retries\` times.

3.  **Exponential Backoff**: After each failure, the function waits for
    an increasing amount of time (5s, 10s, 20s, etc.) before retrying.

4.  **HTTP 429 Handling**: If a "Too Many Requests" (HTTP 429) error is
    detected, it adds an additional penalty delay to the backoff time.

5.  **Graceful Failure**: If all retries are exhausted, the target is
    marked as \`NA\` and the process continues to the next target.

## Examples

``` r
if (interactive()) {
  network_diplomat(targets = c('https://example.com'), target_func = function(x) x)
}
```
