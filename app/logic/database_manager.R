box::use(
  S7[...],
  datasets,
  pool[
    dbPool, poolWithTransaction, dbReadTable, dbWriteTable,
    dbRemoveTable, dbIsValid, poolClose, dbGetQuery
  ],
  duckdb[duckdb_shutdown, duckdb, ],
  rlang[inform, abort, env_parent, ],
  glue[glue, glue_sql, ],
  brio[read_file, ],
  purrr[iwalk, ],
)

# Define the class ----
#' @export
database_manager <- new_class(
  "database_manager", properties = list(
    db_config = new_property(
      class_list, default = list()
    ),
    db_password_env_var = new_property(
      class_character, default = "DB_PASSWORD"
    ),
    db_driver = new_property(),
    db_pool = new_property()
  ),
  constructor = function(
      db_config, db_password_env_var = "DB_PASSWORD", db_driver) {
    db_config$db_dir <- do.call(file.path, as.list(db_config$db_dir))
    pool <- dbPool(
      drv = db_driver,
      dbname = db_config$db_name,
      dbdir = db_config$db_dir,
      host = db_config$host,
      username = db_config$user_name,
      password = Sys.getenv(db_password_env_var),
      maxSize = 5
    )
    inform("DB connected.")
    new_object(
      S7_object(),
      db_config = db_config, db_password_env_var = db_password_env_var,
      db_driver = db_driver,
      db_pool = pool
    )
  },
  validator = function(self) {
    if (is.null(self@db_driver)) {
      "Provide a valid Database Driver like duckdb::duckdb()"
    } else if (!any(class(self@db_pool) %in% c("Pool"))) {
      "Provide an object of class Pool."
    }
  }
)

# Create generics ----
get_query <- new_generic("get_query", "x")
method(get_query, database_manager) <- function(x, sql_script) {
  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      dbGetQuery(connection, sql_script)
    }),
    error = function(error) {
      abort(
        glue(
          "Error in get_query() -> {error$message}."
        )
      )
    }
  )
}

execute_query <- new_generic("execute_query", "x")
method(execute_query, database_manager) <- function(x, sql_script) {
  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      dbExecute(connection, sql_script)
    }),
    error = identity
  )
}

write_table <- new_generic("write_table", "x")
method(write_table, database_manager) <- function(x, table_name, dataset) {
  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      dbWriteTable(connection, table_name, dataset)
    }),
    error = identity
  )
}

read_table <- new_generic("read_table", "x")
method(read_table, database_manager) <- function(x, table_name) {
  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      dbReadTable(connection, table_name)
    }),
    error = identity
  )
}

remove_table <- new_generic("remove_table", "x")
method(remove_table, database_manager) <- function(x, table_name) {
  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      dbRemoveTable(connection, table_name)
    }),
    error = identity
  )
}

disconnect_db <- new_generic("disconnect_db", "x")
method(disconnect_db, database_manager) <- function(x) {
  if (dbIsValid(x@db_pool)) {
    inform("DB disconnecting.")
    poolClose(x@db_pool)
    duckdb_shutdown(duckdb())
  } else {
    inform("DB disconnected.")
  }
}

script_from_file <- new_generic("script_from_file", "x")
method(script_from_file, database_manager) <- function(x, sql_file_path, ...) {
  arg_list <- list(...)
  iwalk(arg_list, function(value, argument) {
    assign(argument, value, envir = env_parent())
  })

  tryCatch(
    poolWithTransaction(x@db_pool, function(connection) {
      glue_sql(
        .con = connection,
        read_file(
          sql_file_path
        )
      )
    }),
    error = identity
  )
}

# Add exported functions to be used in the app ----
#' @export
get_query_command <- function(app_database_manager, sql_script) {
  get_query(
    app_database_manager, sql_script
  )
}

#' @export
execute_query_command <- function(app_database_manager, sql_script) {
  execute_query(
    app_database_manager, sql_script
  )
}

#' @export
write_table_to_db <- function(app_database_manager, table_name = "iris", dataset = datasets$iris) {
  write_table(
    app_database_manager, table_name, dataset
  )
}

#' @export
read_table_from_db <- function(app_database_manager, table_name = "iris") {
  read_table(app_database_manager, table_name)
}

#' @export
remove_table_from_db <- function(app_database_manager, table_name = "iris") {
  remove_table(
    app_database_manager, table_name
  )
}

#' @export
disconnect_database <- function(app_database_manager) {
  disconnect_db(app_database_manager)
}

#' @export
get_script_from_sql_file <- function(
    app_database_manager, sql_file_path, ...) {
  script_from_file(
    app_database_manager, sql_file_path, ...
  )
}

#' @export
get_query_from_file <- function(app_database_manager, sql_file_path, ...) {
  sql_script <- get_script_from_sql_file(
    app_database_manager = app_database_manager, sql_file_path = sql_file_path, ...
  )
  get_query(app_database_manager, sql_script)
}

#' @export
execute_query_from_file <- function(app_database_manager, sql_file_path, ...) {
  sql_script <- get_script_from_sql_file(
    app_database_manager = app_database_manager, sql_file_path = sql_file_path, ...
  )
  execute_query(app_database_manager, sql_script)
}
