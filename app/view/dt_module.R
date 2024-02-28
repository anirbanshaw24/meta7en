# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib,
    shinymeta,
    DT,
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

  bslib$card(
    DT$dataTableOutput(
      ns("dt_output"), width = "99%"
    )
  )
}

#' @export
server <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      # Initialize reactive values to be used in this module here
    )

    output$dt_output <- shinymeta$metaRender2(DT$renderDataTable, {
      req(dataset())
      shinymeta$metaExpr({
        ..(dataset()) %>%
          DT$datatable(class = "cell-border stripe")
      })
    })

    list(
      dt_output = output$dt_output
    )
  })
}
