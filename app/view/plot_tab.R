# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    datasets,
    ggplot2,
    bsicons,
    brio,
    rlang,
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager,
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/histogram_plot_module,
    app/view/dynamite_plot_module,
    app/view/echarts_plot_module,
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bslib$card(
    bslib$page_sidebar(
      sidebar = bslib$sidebar(
        bslib$accordion(
          multiple = FALSE,
          bslib$accordion_panel(
            "User Inputs", icon = bsicons$bs_icon("menu-app"),
            selectInput(
              ns("var"), "Select variable",
              NULL
            )
          )
        )
      ),
      bslib$accordion(
        open = c("echarts Plot"),
        multiple = FALSE,
        bslib$accordion_panel(
          "Density Plot",
          bslib$card(
            height = "60vh",
            histogram_plot_module$ui(ns("histogram_plot_module")),
            full_screen = TRUE
          )
        ),
        bslib$accordion_panel(
          "Dynamite Plot",
          bslib$card(
            height = "60vh",
            dynamite_plot_module$ui(ns("dynamite_plot_module")),
            full_screen = TRUE
          )
        ),
        bslib$accordion_panel(
          "echarts Plot",
          bslib$card(
            height = "60vh",
            echarts_plot_module$ui(ns("echarts_plot")),
            full_screen = TRUE
          )
        )
      )
    )
  )
}

#' @export
server <- function(id, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      # Initialize reactive values to be used in this module here
    )

    tryCatch({
      sql_script <- app_database_manager %>%
        database_manager$get_script_from_sql_file(
          file.path("app", "sql", "get_data_header.sql"),
          table_name = "iris"
        )
      data_colnames <- app_database_manager %>%
        database_manager$get_query_command(
          sql_script = sql_script
        )
      module_reactive_values$data_colnames <- data_colnames[["column_name"]]
    }, finally = {
      rlang$inform("Fetched data for Plot tab!")
    })

    observeEvent(module_reactive_values$data_colnames, {
      updateSelectInput(
        inputId = "var", choices = module_reactive_values$data_colnames
      )
    })

    histogram_plot_module$server(
      "histogram_plot_module", selected_variable = reactive({
        input$var
      }),
      app_database_manager = app_database_manager
    )

    dynamite_plot_module$server(
      "dynamite_plot_module", selected_variable = reactive({
        input$var
      }),
      app_database_manager = app_database_manager
    )

    echarts_plot_module$server("echarts_plot", app_database_manager)
  })
}
