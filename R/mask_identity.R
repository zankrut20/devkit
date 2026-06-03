#' Interactive Identity Masker
#'
#' @description
#' Safely anonymizes Personally Identifiable Information ('PII') in a dataset
#' by interactively prompting the user to keep, drop, or scramble each column.
#'
#' @details
#' The function provides a guided workflow for data anonymization:
#' \enumerate{
#'   \item Scans the calling environment for available data frames and prompts the user to select one.
#'   \item Iterates through every column in the selected data frame, displaying its name and type.
#'   \item For each column, the user chooses one of three actions:
#'       \itemize{
#'         \item \strong{Keep}: Leaves the column unchanged.
#'         \item \strong{Scramble}: For numeric data, it shuffles the values to preserve the distribution while breaking the link to individuals. For text/factors, it replaces values with sequential placeholders (e.g., "Masked_0001").
#'         \item \strong{Drop}: Removes the column entirely from the dataset.
#'       }
#'   \item Saves the resulting anonymized data frame back to \code{envir} with a \code{_masked} suffix.
#'   \item Optionally generates a \code{dput()} output of the first 20 rows for easy, safe sharing.
#' }
#'
#' @section Warning:
#' This function modifies files on disk or the global environment. Please ensure you have a backup or are using version control (e.g., Git) before execution.
#'
#' @param envir The environment to search for data frames and in which to save
#'   the anonymized dataset. Defaults to the calling environment.
#'
#' @return
#' Invisibly returns the anonymized data frame.
#'
#' @importFrom utils select.list head
#' @examples
#' if (interactive()) {
#'   mask_identity()
#' }
#' @export

mask_identity <- function(envir = parent.frame()) {
  message("Initializing Identity Masker...")

  # 1. Select the Dataframe from the supplied environment
  df_names <- .list_dataframes_in(envir)

  if (length(df_names) == 0) {
    message("No dataframes found in the environment.")
    return(invisible(NULL))
  }

  target_df_name <- select.list(df_names, title = "Select the dataset to anonymize:")
  if (target_df_name == "") {
    message("Masking cancelled.")
    return(invisible(NULL))
  }

  df <- get(target_df_name, envir = envir)
  col_names <- names(df)
  n_rows <- nrow(df)

  message(sprintf("\n--- Masking Dataset: '%s' (%d rows, %d columns) ---",
                  target_df_name, n_rows, length(col_names)))

  masked_df <- df
  cols_to_drop <- character()

  # 2. Iterate and Prompt
  for (col in col_names) {
    col_type <- class(df[[col]])[1]

    prompt_msg <- sprintf("Column: '%s' (Type: %s). Action:", col, col_type)
    action <- select.list(
      choices = c("Keep", "Scramble", "Drop"),
      title = prompt_msg
    )

    if (action == "Drop" || action == "") {
      cols_to_drop <- c(cols_to_drop, col)
      message(sprintf("  -> Dropped '%s'", col))

    } else if (action == "Scramble") {
      if (col_type %in% c("numeric", "integer")) {
        masked_df[[col]] <- sample(df[[col]])
        message(sprintf("  -> Scrambled (Shuffled) numeric data in '%s'", col))
      } else {
        masked_df[[col]] <- sprintf("Masked_%04d", seq_len(n_rows))
        message(sprintf("  -> Scrambled (Replaced) text data in '%s'", col))
      }
    } else {
      message(sprintf("  -> Kept '%s' as is", col))
    }
  }

  # Remove dropped columns
  if (length(cols_to_drop) > 0) {
    masked_df <- masked_df[, !(names(masked_df) %in% cols_to_drop), drop = FALSE]
  }

  # 3. Save to the user-supplied environment (user is in control of where output goes)
  out_name <- paste0(target_df_name, "_masked")
  assign(out_name, masked_df, envir = envir)
  message(sprintf("\nSuccess! Anonymized dataset saved as '%s'.", out_name))

  # 4. Reprex Generation (Reproducible Example)
  gen_reprex <- select.list(
    choices = c("Yes", "No"),
    title = "Would you like to print the dput() output to the console for easy sharing?"
  )

  if (gen_reprex == "Yes") {
    cat("\n--- Copy the code below to share your data safely ---\n")
    dput(head(masked_df, 20))
    cat("------------------------------------------------------\n")
    if (n_rows > 20) message("Note: dput() output was limited to the first 20 rows for brevity.")
  }

  return(invisible(masked_df))
}
