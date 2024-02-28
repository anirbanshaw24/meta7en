# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[card_body, ],
    shinymeta[metaReactive2, metaExpr],
    datasets,
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/data_processor[
      get_valid_data_names,
    ],
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card_body(
    selectInput(
      inputId = ns("select_data"), label = "Select Data",
      choices = ""
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    observe({
      data_choices <- get_valid_data_names(
        datasets = datasets
      )
      updateSelectInput(
        inputId = "select_data", choices = data_choices
      )
    })

    data_name <- metaReactive2({
      req(input$select_data)
      metaExpr({
        ..(input$select_data)
      })
    }, varname = "data_name")

    onBookmark(function(state) {
      state$values$select_data <- input$select_data
    })

    onRestored(function(state) {
      updateSelectInput(
        "select_data", selected = state$values$select_data, session = session
      )
    })

    list(
      data_name = data_name
    )
  })
}
