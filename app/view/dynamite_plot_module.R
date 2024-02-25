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
    app/logic/plotter[plot_dynamite],
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
        ns("bar_width"), label = "Bar Width",
        value = 0.3, min = 0.01, max = 0.99, step = 0.1
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    plotOutput(ns("dynamite_plot"))
  )
}

#' @export
server <- function(id, selected_variable, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      dataset = NULL,
    )

    tryCatch({
      module_reactive_values$dataset <- shinymeta$metaReactive({
        app_database_manager %>%
          database_manager$read_table_from_db(
            table_name = "iris"
          ) %>%
          process_data() %>%
          dplyr$mutate(
            sepal_length_multiply_100 = Sepal.Length * 100
          )
      }, varname = "data")
    }, finally = {
      rlang$inform("Fetched data for Dynamite Module!")
    })

    output$dynamite_plot <- shinymeta$metaRender2(renderPlot, {
      req(class(module_reactive_values$dataset()[[selected_variable()]]) == "numeric")

      shinymeta$metaExpr({
        ..(module_reactive_values$dataset()) %>%
          plot_dynamite(
            selected_variable = ..(selected_variable()),
            bar_width = ..(input$bar_width)
          )
      })
    })

    source_code_module$server(
      "source_code_module", output$dynamite_plot,
      packages = packages_code,
      modules = function_modules_code
    )
  })
}
