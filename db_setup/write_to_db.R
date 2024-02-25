box::use(
  magrittr[...],
  datasets,
  config,
  duckdb,
  purrr,
  glue,
)

box::use(
  app/logic/database_manager,
  app/logic/data_processor[get_valid_data_names],
)
box::reload(
  database_manager
)

# Get app config
app_config <- config$get(config = Sys.getenv("ENVIRONMENT"))

app_database_manager <- database_manager$database_manager(
  db_config = app_config$database,
  db_driver = duckdb$duckdb()
)

# Write dataframes from datasets to duckdb
purrr$walk(get_valid_data_names(datasets = datasets), function(dataset) {
  app_database_manager %>%
    database_manager$write_table_to_db(
      table_name = dataset,
      dataset = datasets[[dataset]]
    )
})

app_database_manager %>%
  database_manager$get_query_command("SHOW TABLES;")

unlink("db_setup/sample_db/*", recursive = TRUE)

app_database_manager %>%
  database_manager$execute_query_from_file(
    sql_file_path = "db_setup/sql/export_db.sql",
    target_directory = glue$glue("{normalizePath('db_setup/sample_db/')}")
  )

"# Import Duck DB from path"
app_database_manager %>%
  database_manager$execute_query_from_file(
    sql_file_path = "db_setup/sql/import_db.sql",
    target_directory = glue$glue("{normalizePath('db_setup/sample_db/')}")
  )

app_database_manager %>%
  database_manager$disconnect_database()
