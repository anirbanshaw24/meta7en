box::use(
  magrittr[`%>%`, ],
  purrr[map, ],
  config[get, ],
  rlang[expr, ],
)

box::use(
  app/logic/app_utils[get_db_setup_code],
)

# Import source code generation config
source_code_config <- get(file = "app/source_code_assets/source_code_config.yml")

#' @export
get_source_code_preffix <- function(packages_code, modules_code) {

  db_setup_code <- get_db_setup_code()

  expr({

    "# Import packages"
    box::use(
      config[get, ],
      duckdb[duckdb, ],
      purrr[walk, ],
      datasets,
      # Import packages here
    )
    !!packages_code

    "# Import modules"
    box::use(
      app/logic/database_manager[
        database_manager, disconnect_database, read_table_from_db,
      ],
      app/logic/data_processor[get_valid_data_names],
      # Import function modules here
    )
    !!modules_code

    !!db_setup_code

  })
}

#' @export
get_source_code_suffix <- function() {
  quote({
    "# Disconnect and shutdown database connection"
    app_database_manager %>%
      disconnect_database()
  })
}

#' @export
source_code_begin_comment <- "# Source Code of Interest"

#' Build named list of files to include from config in yml file
get_common_files_to_include <- function(
    common_files_to_include = source_code_config$common_files) {

  files_list <- map(common_files_to_include, function(file) {
    do.call(file.path, as.list(file$app_code))
  })
  names(files_list) <- map(common_files_to_include, function(file) {
    do.call(file.path, as.list(file$source_code))
  })

  files_list
}

#' Build named list of files to include from app folder
get_app_files_to_include <- function(dirs_to_scan = c("app/logic", "app/sql")) {

  full_file_paths <- as.list(
    unlist(
      map(dirs_to_scan, function(dir) {
        list.files(dir, recursive = TRUE, full.names = TRUE)
      })
    )
  )
  names(full_file_paths) <- full_file_paths

  full_file_paths
}

#' Build named list of files to include from db_setup
get_db_setup_files_include <- function(dirs_to_scan = c("db_setup/")) {

  full_file_paths <- as.list(
    unlist(
      map(dirs_to_scan, function(dir) {
        list.files(dir, recursive = TRUE, full.names = TRUE)
      })
    )
  )
  names(full_file_paths) <- full_file_paths

  full_file_paths
}

#' @export
files_to_include <- get_common_files_to_include() %>%
  append(get_app_files_to_include()) %>%
  append(get_db_setup_files_include())

#' @export
rendering_arguments <- list(
  output_format = source_code_config$rendering_options$output_format,
  clean = source_code_config$rendering_options$clean
)
