# Getting Started with devkit

## Introduction

`devkit` is a zero-dependency toolkit designed to assist R package
developers and data scientists in maintaining high standards of code
quality, session reproducibility, and system efficiency.

This guide provides an overview of the toolkit’s core modules and how to
integrate them into your workflow.

## 📦 Package Development Workflow

### Dependency Management

Maintaining a clean `DESCRIPTION` file is critical for CRAN compliance.

- **[`audit_dependencies()`](../reference/audit_dependencies.md)**:
  Scans your `R/` and `tests/` directories to ensure all used packages
  are declared in `DESCRIPTION`.
- **[`scan_dependencies()`](../reference/scan_dependencies.md)**:
  Identifies packages currently attached to your session that are not
  actually used in your code.
- **[`remove_package()`](../reference/remove_package.md)**: Safely
  removes a package while checking for orphan dependencies.

### Scaffolding & Automation

Reduce boilerplate and avoid manual errors with automated generators.

- **[`architect_release()`](../reference/architect_release.md)**:
  Interactively bumps the package version and generates a `NEWS.md`
  entry.
- **[`architect_vignette()`](../reference/architect_vignette.md)**:
  Creates a CRAN-compliant RMarkdown vignette structure.
- **[`scaffold_tests()`](../reference/scaffold_tests.md)**: Generates
  `testthat` boilerplate for your functions.
- **[`scaffold_parallel()`](../reference/scaffold_parallel.md)**:
  Generates the necessary code to set up a parallel cluster.

## 🛡️ Session Auditing & Reproducibility

### State Management

Ensure your scripts don’t leave the user’s environment in a messy state.

- **[`audit_script()`](../reference/audit_script.md)**: Captures the
  state of [`options()`](https://rdrr.io/r/base/options.html),
  [`par()`](https://rdrr.io/r/graphics/par.html), and
  [`getwd()`](https://rdrr.io/r/base/getwd.html) before and after a
  script runs, prompting you to revert changes.
- **[`detect_masking()`](../reference/detect_masking.md)**: Identifies
  when functions from different packages share the same name and helps
  you lock in the priority.
- **[`export_snapshot()`](../reference/export_snapshot.md)**: Creates a
  script to recreate your current session’s package environment.

### Reproducibility Testing

- **[`simulate_clean_room()`](../reference/simulate_clean_room.md)**:
  Runs your script in a completely vanilla R session (`--vanilla`) to
  ensure it doesn’t rely on hidden local state.

## 🧹 System & Memory Optimization

### Memory Cleanup

Prevent R from crashing during large-scale data processing.

- **[`sweep_memory()`](../reference/sweep_memory.md)**: Interactively
  identifies and removes large objects from the global environment.
- **[`hunt_zombies()`](../reference/hunt_zombies.md)**: Cleans up
  orphaned graphics devices and temporary files.
- **[`sweep_temp_cache()`](../reference/sweep_temp_cache.md)**: Flushes
  hidden temporary caches (e.g., knitr, raster).

### Safe Processing

- **[`loop_guardian()`](../reference/loop_guardian.md)**: Wraps long
  loops with a memory monitor that alerts you before you hit your RAM
  limit.
- **[`dispatch_checkpoints()`](../reference/dispatch_checkpoints.md)**:
  Implements a save-and-resume system for batch processing, protecting
  your work from crashes.

## 🔐 Data Privacy & Documentation

### Anonymization

- **[`mask_identity()`](../reference/mask_identity.md)**: A guided
  workflow to scramble or drop PII columns in a dataframe while
  preserving statistical distributions.

### Documentation

- **[`dictate_dictionary()`](../reference/dictate_dictionary.md)**:
  Interactively generates a roxygen2 `@format` block for your datasets,
  ensuring your data dictionaries are professional and complete.

## 🌐 Network Utilities

- **[`network_diplomat()`](../reference/network_diplomat.md)**: A
  wrapper for network requests that implements exponential backoff and
  respects rate limits (HTTP 429).

## Summary Table

| Module | Key Function | Primary Goal |
|:---|:---|:---|
| **Meta** | [`architect_release()`](../reference/architect_release.md) | Versioning & News |
| **Audit** | [`audit_dependencies()`](../reference/audit_dependencies.md) | CRAN Compliance |
| **State** | [`audit_script()`](../reference/audit_script.md) | Session Integrity |
| **Memory** | [`hunt_zombies()`](../reference/hunt_zombies.md) | Resource Cleanup |
| **Privacy** | [`mask_identity()`](../reference/mask_identity.md) | PII Anonymization |
| **Batch** | [`dispatch_checkpoints()`](../reference/dispatch_checkpoints.md) | Crash Resilience |
