
box::use(
  grDevices,
  echarts4r,
  jsonlite,
  hexSticker,
)

#' @export
date_time_filename <- function(
    filename = "file", ext = "zip", date_time_format = "%m-%d-%Y %H:%M", separator = "_") {
  date_time <- format(Sys.time(), date_time_format)
  paste0(
    filename, separator,
    date_time, ".", ext
  )
}

#' @export
get_db_setup_code <- function() {
  quote({
    "# Get app config"
    app_config <- config$get(config = Sys.getenv("ENVIRONMENT"))

    "# Create new database_manager object"
    app_database_manager <- database_manager$database_manager(
      db_config = app_config$database,
      db_driver = duckdb$duckdb()
    )

    "# Write dataframes from datasets to duckdb"
    purrr$walk(get_valid_data_names(datasets = datasets), function(dataset) {
      app_database_manager %>%
        database_manager$write_table_to_db(
          table_name = dataset,
          dataset = datasets[[dataset]] %>%
            as.data.frame()
        )
    })
  })
}

#' @export
get_n_colors <- function(hex_1, hex_2, ..., n) {
  fun_color_range <- grDevices$colorRampPalette(
    c(hex_1, hex_2, ...)
  )
  my_colors <- fun_color_range(n)
  plot(1:n, pch = 17, col = my_colors)
  my_colors
}

#' @export
register_echarts_theme <- function(app_theme) {
  echarts4r$e_theme_register(
    jsonlite$toJSON(
      list(color = c(app_theme$secondary, app_theme$primary, app_theme$success))
    ), name = "myTheme"
  )
}

#' @export
build_app_hex <- function(
    app_theme, hex_image = "app/static/images/hex_image.png",
    hex_output = "app/static/images/app_hex.png") {
  hexSticker$sticker(
    package = "meta7en",
    h_fill = app_theme$primary,
    p_color = app_theme$light,
    h_color = app_theme$secondary,
    u_color = app_theme$success,
    hex_image,
    p_size = 80,
    s_x = 1,
    s_y = 0.65,
    s_width = 0.4,
    dpi = 800,
    filename = hex_output
  )
}
