# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    datasets,
    brio,
    bsicons,
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
    app/logic/app_utils,
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

  bslib$card_body(
    actionButton(ns("view_code"), "View Code", icon("code")),
    downloadButton(ns("download_code"), "Reproducible ZIP")
  )
}

#' @export
server <- function(id, output_to_trace, packages, modules) {
  moduleServer(id, function(input, output, session) {

    module_reactive_values <- reactiveValues(
      source_code = NULL,
    )

    observeEvent(input$view_code, {
      source_code <- shinymeta$expandChain(
        get_source_code_preffix(packages, modules),
        source_code_begin_comment,
        output_to_trace(),
        get_source_code_suffix()
      )

      module_reactive_values$source_code <- source_code
      shinymeta$displayCodeModal(
        module_reactive_values$source_code,
        title = "Code",
        size = "l",
        clip = NULL,
        wordWrap = TRUE,
        setBehavioursEnabled = TRUE
      )
    })

    output$download_code <- downloadHandler(
      filename = function() {
        app_utils$date_time_filename("source_code_bundle")
      },
      content = function(file) {

        if (Sys.getenv("ENVIRONMENT") != "dev") {
          showModal(
            modalDialog(
              bslib$card(
                "Not Allowed"
              )
            )
          )
          return()
        } else {
          ec <- shinymeta$newExpansionContext()

          shinymeta$buildRmdBundle(
            file.path("app", "reports", "source_code_report.Rmd"),
            file,
            render = TRUE,
            vars = list(
              shinymeta_code = shinymeta$expandChain(
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
