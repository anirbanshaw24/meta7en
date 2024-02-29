box::use(
  magrittr[`%>%`, ],
  datasets,
  config[get, ],
  duckdb[duckdb, ],
  purrr[walk, ],
  glue[glue, ],
)

box::use(
  app/logic/database_manager,
  app/logic/data_processor[get_valid_data_names],
)

# Get app config
db_config <- get(file = file.path("db_setup", "db_config.yml"))

app_database_manager <- database_manager$database_manager(
  db_config = db_config,
  db_driver = duckdb()
)

app_database_manager %>%
  database_manager$execute_query_from_file(
    sql_file_path = "db_setup/sql/export_db.sql",
    target_directory = glue("{normalizePath('db_setup/sample_db/')}")
  )

"# Import Duck DB from path"
app_database_manager %>%
  database_manager$execute_query_from_file(
    sql_file_path = "db_setup/sql/import_db.sql",
    target_directory = glue("{normalizePath('db_setup/sample_db/')}")
  )

app_database_manager %>%
  database_manager$disconnect_database()
