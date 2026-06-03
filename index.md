# devkit

`devkit` is a professional, zero-dependency R development toolkit
designed to streamline package management, environment setup, session
auditing, and batch processing. It provides a suite of utilities to help
developers maintain CRAN compliance and optimize their development
workflow.

## 🚀 Installation

Install the released version of `devkit` from CRAN with:

``` r

install.packages("devkit")
```

Or install the development version from
[GitHub](https://github.com/zankrut20/devkit) with:

``` r

# install.packages("devtools")
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

- [`audit_dependencies()`](https://zankrut20.github.io/devkit/reference/audit_dependencies.md):
  Verifies DESCRIPTION file vs actual code usage.
- [`remove_package()`](https://zankrut20.github.io/devkit/reference/remove_package.md):
  Smart package removal with orphan dependency checking.
- [`remove_user_installed_packages()`](https://zankrut20.github.io/devkit/reference/remove_user_installed_packages.md):
  Cleans all user-installed packages while preserving base/recommended
  ones.
- [`scan_dependencies()`](https://zankrut20.github.io/devkit/reference/scan_dependencies.md):
  Identifies unused packages in your session.

### 🧹 Memory Management

- [`sweep_memory()`](https://zankrut20.github.io/devkit/reference/sweep_memory.md):
  Removes large objects and triggers garbage collection.
- [`hunt_zombies()`](https://zankrut20.github.io/devkit/reference/hunt_zombies.md):
  Cleans hidden temp files and orphaned graphics devices.
- [`sweep_temp_cache()`](https://zankrut20.github.io/devkit/reference/sweep_temp_cache.md):
  Flushes R session caches across the system.

### 🔧 Development Environment

- [`bootstrap_dev_env()`](https://zankrut20.github.io/devkit/reference/bootstrap_dev_env.md):
  Installs and attaches core dev tools.
- [`manage_deprecation()`](https://zankrut20.github.io/devkit/reference/manage_deprecation.md):
  Scaffolds deprecation wrappers and refactors calls.
- [`setup_preflight()`](https://zankrut20.github.io/devkit/reference/setup_preflight.md):
  Configures Git pre-commit hooks for safety.
- [`setup_sentinel()`](https://zankrut20.github.io/devkit/reference/setup_sentinel.md):
  Enables dual-logging for session reproducibility.

### 📊 Session Management

- [`audit_script()`](https://zankrut20.github.io/devkit/reference/audit_script.md):
  Snapshots session state before and after script execution.
- [`detect_masking()`](https://zankrut20.github.io/devkit/reference/detect_masking.md):
  Resolves namespace conflicts and function masking.
- [`export_snapshot()`](https://zankrut20.github.io/devkit/reference/export_snapshot.md):
  Exports attached packages to an installation script.

### ⚙️ Batch Processing

- [`dispatch_checkpoints()`](https://zankrut20.github.io/devkit/reference/dispatch_checkpoints.md):
  Crash-resilient batch processing with recovery.
- [`loop_guardian()`](https://zankrut20.github.io/devkit/reference/loop_guardian.md):
  Memory-safe iteration with RAM monitoring.
- [`network_diplomat()`](https://zankrut20.github.io/devkit/reference/network_diplomat.md):
  Rate-limited network requests with exponential backoff.

### 🏗️ Code Generation

- [`architect_release()`](https://zankrut20.github.io/devkit/reference/architect_release.md):
  Automates version bumping and release notes.
- [`architect_vignette()`](https://zankrut20.github.io/devkit/reference/architect_vignette.md):
  Scaffolds CRAN-compliant vignettes.
- [`scaffold_parallel()`](https://zankrut20.github.io/devkit/reference/scaffold_parallel.md):
  Generates parallel processing boilerplate.
- [`scaffold_tests()`](https://zankrut20.github.io/devkit/reference/scaffold_tests.md):
  Generates testthat boilerplate.
- [`simulate_clean_room()`](https://zankrut20.github.io/devkit/reference/simulate_clean_room.md):
  Verifies script reproducibility in a vanilla session.

### 🔐 Privacy

- [`mask_identity()`](https://zankrut20.github.io/devkit/reference/mask_identity.md):
  Interactively anonymizes PII in datasets.

### 🛠️ Utilities

- [`benchmark_branches()`](https://zankrut20.github.io/devkit/reference/benchmark_branches.md):
  Compares performance across Git branches.
- [`dictate_dictionary()`](https://zankrut20.github.io/devkit/reference/dictate_dictionary.md):
  Generates roxygen2 documentation for data frames.

## 📝 License

This package is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please see
[CONTRIBUTING.md](https://github.com/zankrut20/devkit/blob/master/CONTRIBUTING.md)
for guidelines.
