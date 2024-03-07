# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    DT[...],
    magrittr[`%>%`, ],
    bslib[card, ],
    shinymeta[metaRender2, metaExpr, ],
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
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

  card(
    dataTableOutput(
      ns("dt_output"), width = "99%"
    )
  )
}

#' @export
server <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    output$dt_output <- metaRender2(renderDataTable, {
      req(dataset())
      metaExpr({
        ..(dataset()) %>%
          datatable(class = "cell-border stripe")
      })
    })

    list(
      dt_output = output$dt_output,
      dt_code = list(
        packages_code = packages_code,
        function_modules_code = function_modules_code
      )
    )
  })
}
