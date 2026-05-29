# devkit

`devkit` is a professional, zero-dependency R development toolkit
designed to streamline package management, environment setup, session
auditing, and batch processing. It provides a suite of utilities to help
developers maintain CRAN compliance and optimize their development
workflow.

## 🚀 Installation

You can install `devkit` directly from GitHub:

``` r

# Install devtools if not already installed
if (!require("devtools")) install.packages("devtools")

# Install devkit
devtools::install_github("zankrut20/devkit")
```

## 🛠️ Usage

Once installed, simply load the library to access all utilities:

``` r

library(devkit)

# Example: Audit your package dependencies
audit_dependencies()

# Example: Clean up memory hogs
hunt_zombies()
```

## 📦 Toolkit Overview

### 📦 Package Management

- [`audit_dependencies()`](reference/audit_dependencies.md): Verifies
  DESCRIPTION file vs actual code usage.
- [`remove_package()`](reference/remove_package.md): Smart package
  removal with orphan dependency checking.
- [`scan_dependencies()`](reference/scan_dependencies.md): Identifies
  unused packages in your session.

### 🧹 Memory Management

- [`sweep_memory()`](reference/sweep_memory.md): Removes large objects
  and triggers garbage collection.
- [`hunt_zombies()`](reference/hunt_zombies.md): Cleans hidden temp
  files and orphaned graphics devices.
- [`sweep_temp_cache()`](reference/sweep_temp_cache.md): Flushes R
  session caches across the system.

### 🔧 Development Environment

- [`bootstrap_dev_env()`](reference/bootstrap_dev_env.md): Installs and
  attaches core dev tools.
- [`manage_deprecation()`](reference/manage_deprecation.md): Scaffolds
  deprecation wrappers and refactors calls.
- [`setup_preflight()`](reference/setup_preflight.md): Configures Git
  pre-commit hooks for safety.
- [`setup_sentinel()`](reference/setup_sentinel.md): Enables
  dual-logging for session reproducibility.

### 📊 Session Management

- [`audit_script()`](reference/audit_script.md): Snapshots session state
  before and after script execution.
- [`detect_masking()`](reference/detect_masking.md): Resolves namespace
  conflicts and function masking.
- [`export_snapshot()`](reference/export_snapshot.md): Exports attached
  packages to an installation script.

### ⚙️ Batch Processing

- [`dispatch_checkpoints()`](reference/dispatch_checkpoints.md):
  Crash-resilient batch processing with recovery.
- [`loop_guardian()`](reference/loop_guardian.md): Memory-safe iteration
  with RAM monitoring.
- [`network_diplomat()`](reference/network_diplomat.md): Rate-limited
  network requests with exponential backoff.

### 🏗️ Code Generation

- [`architect_release()`](reference/architect_release.md): Automates
  version bumping and release notes.
- [`architect_vignette()`](reference/architect_vignette.md): Scaffolds
  CRAN-compliant vignettes.
- [`scaffold_parallel()`](reference/scaffold_parallel.md): Generates
  parallel processing boilerplate.
- [`scaffold_tests()`](reference/scaffold_tests.md): Generates testthat
  boilerplate.
- [`simulate_clean_room()`](reference/simulate_clean_room.md): Verifies
  script reproducibility in a vanilla session.

### 🔐 Privacy

- [`mask_identity()`](reference/mask_identity.md): Interactively
  anonymizes PII in datasets.

### 🛠️ Utilities

- [`benchmark_branches()`](reference/benchmark_branches.md): Compares
  performance across Git branches.
- [`dictate_dictionary()`](reference/dictate_dictionary.md): Generates
  roxygen2 documentation for data frames.

## 📝 License

This package is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md)
for guidelines.
