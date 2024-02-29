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

# Write dataframes from datasets to duckdb
walk(get_valid_data_names(datasets = datasets), function(dataset) {
  app_database_manager %>%
    database_manager$write_table_to_db(
      table_name = dataset,
      dataset = datasets[[dataset]]
    )
})

app_database_manager %>%
  database_manager$get_query_command("SHOW TABLES;")

app_database_manager %>%
  database_manager$disconnect_database()
