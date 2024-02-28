# Packages
#' @export
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[card, card_body, card_header, ],
    shinymeta[metaReactive2, metaReactive, metaExpr, ],
    purrr[map, map_chr, walk, ],
    glue[glue, ],
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

  card_body(
    card(
      card_header("Current Variable Types"),
      reactable_module$ui(ns("reactable_module"))
    ),
    card(
      card_header("Change Variable Types"),
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

    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    output$set_column_classes <- renderUI({
      req(dataset())
      map(colnames(dataset()), function(colname) {
        div(
          class = "update_col_class",
          selectInput(
            inputId = ns(make.names(colname)),
            label = paste("Change", colname, "to type"),
            choices = list(
              "Numeric" = "as.numeric",
              "String" = "as.character",
              "Categorical" = "as.factor"
            ), selected = glue(
              "as.{class(dataset()[[colname]])}"
            )
          )
        )
      })
    })

    col_class_set_data <- metaReactive2({
      walk(colnames(dataset()), function(colname) {
        req(input[[make.names(colname)]])
      })

      col_classses <- map_chr(colnames(dataset()), function(colname) {
        input[[make.names(colname)]]
      })

      metaExpr({

        ..(dataset()) %>%
          set_col_classes(..(col_classses))
      })
    }, varname = "col_class_set_data")

    col_types_data <- metaReactive({
      ..(col_class_set_data()) %>%
        get_col_types_df(reactive = FALSE)
    }, varname = "col_types_data")

    reactable_module$server("reactable_module", col_types_data)

    list(
      data = col_class_set_data
    )
  })
}
