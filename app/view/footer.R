# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    glue,
    purrr,
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
ui <- function(id, main_page_constants) {
  ns <- NS(id)

  latest_commit <- system(
    intern = TRUE,
    "git log -1 --pretty='format:%cd' --date=format:'%Y-%m-%d'"
  )

  div(
    class = "app-footer",
    glue$glue(
      "App v{main_page_constants$app_version}
      built on {latest_commit} | "
    ),
    glue$glue("Maintained by"),
    HTML("&nbsp;"),
    tags$a(
      href = "https://www.linkedin.com/in/anirban-shaw",
      target = "_blank",
      "O"
    ),
    div(
      class = "footer-images",
      "Built With",
      purrr$map(main_page_constants$footer_images, function(x) {
        img(src = file.path("static", "images", x))
      })
    )
  )
}

#' @export
server <- function(id, app_reactive_values) {
  moduleServer(id, function(input, output, session) {
    # Add your server logic here
  })
}
