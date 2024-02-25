# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    brio,
    bsicons,
    dplyr,
    rlang,
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/plotter[plot_histogram],
    app/logic/database_manager,
    app/logic/data_processor[process_data],
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/source_code_module,
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bslib$layout_sidebar(
    sidebar = bslib$sidebar(
      position = "right",
      numericInput(
        ns("plot_transparency"), label = "Transparency",
        value = 0.3, min = 0.01, max = 0.99, step = 0.1
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    plotOutput(ns("density_plot"))
  )
}

#' @export
server <- function(id, selected_variable, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      dataset = NULL,
    )

    tryCatch({
      shinymeta$metaExpr({
        sql_script <- app_database_manager %>%
          database_manager$get_script_from_sql_file(
            sql_file_path = file.path("app", "sql", "get_table.sql"),
            table_name = "iris"
          )
      })
      module_reactive_values$dataset <- shinymeta$metaReactive({
        app_database_manager %>%
          database_manager$get_query_command(
            sql_script = sql_script
          ) %>%
          process_data() %>%
          dplyr$mutate(
            sepal_length_multiply_100 = Sepal.Length * 100
          )
      }, varname = "data")
    }, finally = {
      rlang$inform("Fetched data for Histogram Module!")
    })

    output$density_plot <- shinymeta$metaRender2(renderPlot, {
      req(class(module_reactive_values$dataset()[[selected_variable()]]) == "numeric")

      shinymeta$metaExpr({
        ..(module_reactive_values$dataset()) %>%
          plot_histogram(
            selected_variable = ..(selected_variable()),
            plot_transparency = ..(input$plot_transparency)
          )
      })
    })

    source_code_module$server(
      "source_code_module", output$density_plot,
      packages = packages_code,
      modules = function_modules_code
    )
  })
}
