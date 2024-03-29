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
  database_manager$read_table_from_db(table_name = "iris")

app_database_manager %>%
  database_manager$disconnect_database()
