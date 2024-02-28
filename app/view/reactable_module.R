# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    reactable[...],
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
    reactableOutput(ns("reactable_output"))
  )
}

#' @export
server <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    output$reactable_output <- metaRender2(
      renderReactable, {
        req(dataset())
        metaExpr({
          ..(dataset()) %>%
            reactable()
        })
      }
    )

    list(
      reactable_output = output$reactable_output
    )
  })
}
