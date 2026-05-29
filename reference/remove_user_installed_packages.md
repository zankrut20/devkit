# Remove User-Installed Packages

Identifies and removes all user-installed R packages from the system,
while carefully preserving base and recommended packages, as well as
packages installed in specific system libraries (e.g., MRO).

## Usage

``` r
remove_user_installed_packages()
```

## Value

Invisibly returns the result of the \`sapply\` call, which is a vector
indicating the success or failure of each package removal.

## Details

The function performs the following steps:

1.  Retrieves a list of all installed packages.

2.  Filters out packages located in libraries containing "MRO" to avoid
    corrupting system-specific installations.

3.  Filters out packages with a priority of "base" or "recommended" to
    ensure core R functionality remains intact.

4.  Identifies the library paths where the remaining user packages are
    installed.

5.  Iteratively removes each identified user package using
    \`remove.packages()\`.
