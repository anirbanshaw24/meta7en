# Packages
#' @export
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[card, ],
    # Import packages here. Intead of library calls.
  )
)

# Logic and Function Modules
#' @export
function_modules_code <- quote(
  box::use(
    # Import function and other logic modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    # Import shiny modules here with ui and server
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card(
    "Add Your UI Code Here"
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    # Add Your Server Logic here
  })
}
