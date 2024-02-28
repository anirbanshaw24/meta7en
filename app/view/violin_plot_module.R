# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[layout_sidebar, sidebar, ],
    shinymeta[metaRender2, metaExpr, ],
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager,
    app/logic/plotter[plot_violin, ],
    app/logic/shiny_helpers[
      update_var_select_input, get_true_false_choices
    ],
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

  layout_sidebar(
    sidebar = sidebar(
      position = "left",
      selectInput(
        ns("x_var"), "Select x variable :",
        "", selectize = FALSE,
      ),
      selectInput(
        ns("y_var"), "Select y variable :",
        "", multiple = FALSE, selectize = FALSE,
      ),
      selectInput(
        ns("trim"), label = "Trim ?",
        choices = get_true_false_choices(),
        selected = get_true_false_choices()[["No"]],
        selectize = FALSE
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    plotOutput(ns("dynamite_plot"))
  )
}

#' @export
server <- function(id, selected_data, app_database_manager) {
  moduleServer(id, function(input, output, session) {

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    observeEvent(selected_data(), {

      update_var_select_input(
        input_id = "x_var", selected_data(), session = session
      )
      update_var_select_input(
        input_id = "y_var", selected_data(),
        session = session
      )
    })

    output$dynamite_plot <- metaRender2(renderPlot, {
      req(input$x_var)
      req(input$y_var)

      metaExpr({
        ..(isolate(selected_data())) %>%
          plot_violin(
            x_var = ..(input$x_var),
            y_var = ..(input$y_var),
            trim = ..(input$trim)
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
