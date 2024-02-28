# Packages
#' @export
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib,
    shinymeta,
    reactable,
    purrr,
    glue,
    # Import packages here
  )
)

# Logic and Function Modules
#' @export
function_modules_code <- quote(
  box::use(
    app/logic/data_processor[get_col_types_df, set_col_classes],
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/reactable_module,
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
    bslib$card(
      bslib$card_header("Current Variable Types"),
      reactable_module$ui(ns("reactable_module"))
    ),
    bslib$card(
      bslib$card_header("Change Variable Types"),
      uiOutput(
        outputId = ns("set_column_classes"),
        fill  = TRUE
      )
    )
  )
}

#' @export
server <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$set_column_classes <- renderUI({
      req(dataset())
      purrr$map(colnames(dataset()), function(colname) {
        div(
          class = "update_col_class",
          selectInput(
            inputId = ns(make.names(colname)),
            label = paste("Change", colname, "to type"),
            choices = list(
              "Numeric" = "as.numeric",
              "String" = "as.character",
              "Categorical" = "as.factor"
            ), selected = glue$glue(
              "as.{class(dataset()[[colname]])}"
            )
          )
        )
      })
    })

    col_class_set_data <- shinymeta$metaReactive2({
      purrr$walk(colnames(dataset()), function(colname) {
        req(input[[make.names(colname)]])
      })

      col_classses <- purrr$map_chr(colnames(dataset()), function(colname) {
        input[[make.names(colname)]]
      })

      shinymeta$metaExpr({

        ..(dataset()) %>%
          set_col_classes(..(col_classses))
      })
    }, varname = "col_class_set_data")

    col_types_data <- shinymeta$metaReactive({
      ..(col_class_set_data()) %>%
        get_col_types_df(reactive = FALSE)
    }, varname = "col_types_data")

    reactable_module$server("reactable_module", col_types_data)

    list(
      data = col_class_set_data
    )
  })
}
