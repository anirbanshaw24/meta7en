# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    shinymeta[...],
    magrittr[`%>%`, ],
    bslib[card, card_body, ],
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/source_code_assets[
      files_to_include, rendering_arguments, source_code_begin_comment,
      get_source_code_suffix, get_source_code_preffix
    ],
    app/logic/app_utils[date_time_filename, ],
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
    actionButton(ns("view_code"), "View Code", icon("code")),
    downloadButton(ns("download_code"), "Reproducible ZIP")
  )
}

#' @export
server <- function(id, output_to_trace, packages, modules) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    observeEvent(input$view_code, {
      source_code <- expandChain(
        get_source_code_preffix(packages, modules),
        source_code_begin_comment,
        output_to_trace(),
        get_source_code_suffix()
      )

      module_reactive_values$source_code <- source_code
      displayCodeModal(
        module_reactive_values$source_code,
        title = "Code",
        size = "l",
        clip = NULL,
        wordWrap = TRUE,
        setBehavioursEnabled = TRUE
      )
    })

    observeEvent(input$enter_password, {
      if (input$set_environment == Sys.getenv("APP_PASSWORD"))
        Sys.setenv(ENVIRONMENT = "dev")
      else Sys.setenv(ENVIRONMENT = "shinyapps")
      removeModal()
    })

    output$download_code <- downloadHandler(
      filename = function() {
        date_time_filename("source_code_bundle")
      },
      content = function(file) {

        if (Sys.getenv("ENVIRONMENT") != "dev") {
          showModal(
            modalDialog(
              card(
                h2("Not Allowed"),
                passwordInput(
                  ns("set_environment"), label = NULL,
                  placeholder = "Enter Password"
                ),
                actionButton(
                  ns("enter_password"), "Unlock"
                )
              )
            )
          )
          return()
        } else {
          Sys.setenv(ENVIRONMENT = "shinyapps")
          ec <- newExpansionContext()

          buildRmdBundle(
            file.path("app", "reports", "source_code_report.Rmd"),
            file,
            render = TRUE,
            vars = list(
              shinymeta_code = expandChain(
                get_source_code_preffix(packages, modules),
                source_code_begin_comment,
                output_to_trace(),
                get_source_code_suffix(),
                .expansionContext = ec
              )
            ),
            include_files = files_to_include,
            render_args = rendering_arguments
          )
        }
      }
    )
  })
}
