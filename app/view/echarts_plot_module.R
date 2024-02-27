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
    app/logic/plotter[
      line_plot_echarts, get_factor_columns
    ],
    app/logic/database_manager,
    app/logic/data_processor[process_data],
    app/logic/shiny_helpers[update_var_select_input],
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
      selectInput(
        ns("x_var"), "Select x variable :", selectize = FALSE,
        ""
      ),
      selectInput(
        ns("y_var"), "Select y variable :", selectize = FALSE,
        "", multiple = FALSE
      ),
      selectInput(
        ns("group_var"), "Separate lines on variable :", selectize = FALSE,
        "", multiple = FALSE
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    echarts4r$echarts4rOutput(ns("echarts_plot"))
  )
}

#' @export
server <- function(id, selected_data, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      dataset = NULL,
    )

    observeEvent(selected_data(), {
      update_var_select_input(
        inputId = "x_var", selected_data(),
        allowed_col_types = c("numeric", "integer"),
        preffix_choices = list(
          row_num = "row_num"
        ), session = session
      )
      update_var_select_input(
        inputId = "y_var", selected_data(),
        allowed_col_types = c("numeric", "integer"), session = session
      )
      update_var_select_input(
        inputId = "group_var", selected_data(),
        allowed_col_types = c("factor", "character"),
        preffix_choices = list(
          None = ""
        ), session = session
      )
    })

    output$echarts_plot <- shinymeta$metaRender(
      echarts4r$renderEcharts4r, {
        req(input$x_var)
        req(input$y_var)

        ..(isolate(selected_data())) %>%
          line_plot_echarts(
            x_var = ..(input$x_var),
            y_var = ..(input$y_var),
            group_var = ..(input$group_var)
          )
      }
    )

    source_code_module$server(
      "source_code_module", output$echarts_plot,
      packages = packages_code,
      modules = function_modules_code
    )
  })
}
