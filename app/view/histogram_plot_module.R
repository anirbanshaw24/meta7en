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
    app/logic/plotter[plot_histogram, ],
    app/logic/shiny_helpers[update_var_select_input],
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
      id = ns("histogram_sidebar"),
      position = "right",
      selectInput(
        ns("x_var"), "Select x variable :",
        "", selectize = FALSE,
      ),
      selectInput(
        ns("fill_var"), "Select fill variable :",
        "", multiple = FALSE, selectize = FALSE
      ),
      numericInput(
        ns("plot_transparency"), label = "Transparency :",
        value = 0.3, min = 0.01, max = 0.99, step = 0.1
      ),
      source_code_module$ui(ns("source_code_module")),
    ),
    plotOutput(ns("density_plot"))
  )
}

#' @export
server <- function(id, selected_data) {
  moduleServer(id, function(input, output, session) {

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    observeEvent(selected_data(), {
      update_var_select_input(
        input_id = "x_var", selected_data(),
        allowed_col_types = c("numeric", "integer"), session = session
      )
      update_var_select_input(
        input_id = "fill_var", selected_data(),
        allowed_col_types = c("factor", "character"),
        preffix_choices = list(
          None = ""
        ), session = session
      )
    })

    output$density_plot <- metaRender2(renderPlot, {
      req(input$x_var)

      metaExpr({
        ..(isolate(selected_data())) %>%
          plot_histogram(
            x_var = ..(input$x_var),
            fill_var = ..(input$fill_var),
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
