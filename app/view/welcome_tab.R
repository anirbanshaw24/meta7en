# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[page_fluid, card, card_image, card_body, ],
    config[get, ],
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

welcome_page_constants <- get(
  file = file.path("constants", "page_constants", "welcome_page.yml")
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  page_fluid(
    card(
      class = "welcome-page",
      height = "75vh",
      card(
        card_image(
          class = "align-self-center",
          welcome_page_constants$image_path,
          fill = FALSE, width = "1300px"
        ),
        card_body(
          class = "welcome-text",
          h1(
            welcome_page_constants$text_header
          ),
          h4(
            welcome_page_constants$text_body
          ),
          actionButton(
            ns("read_me"),
            "More information ..."
          )
        )
      )
    )
  )
}


#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    read_me <- reactive({
      input$read_me
    })
    return(read_me)
  })
}
