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
    echarts4r,
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/plotter[plot_echarts],
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
      position = "left",
      numericInput(
        ns("slice_head"), label = "Slice Head",
        value = 200
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    echarts4r$echarts4rOutput(ns("echarts_plot"))
  )
}

#' @export
server <- function(id, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      dataset = NULL,
    )

    module_reactive_values$dataset <- shinymeta$metaReactive({
      app_database_manager %>%
        database_manager$read_table_from_db(
          "EuStockMarkets"
        )
    }, varname = "data")

    output$echarts_plot <- shinymeta$metaRender(
      echarts4r$renderEcharts4r, {
        ..(module_reactive_values$dataset()) %>%
          plot_echarts(input$slice_head)
      }
    )

    source_code_module$server(
      "source_code_module", output$echarts_plot,
      packages = packages_code,
      modules = function_modules_code
    )
  })
}
