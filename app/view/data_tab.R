# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[layout_sidebar, accordion, accordion_panel, card, sidebar, ],
    shinymeta[metaReactive2, metaExpr, ],
    rlang[expr, ],
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager[read_table_from_db, ],
    app/logic/plotter[plot_histogram],
    app/logic/data_processor[process_data],
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/data_creator/select_data_module,
    app/view/data_creator/set_col_class_module,
    app/view/dt_module,
    app/view/source_code_module,
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

#' @export
ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      id = ns("sidebar"),
      width = "25vw",
      accordion(
        id = ns("sidebar_accordion"),
        multiple = FALSE,
        accordion_panel(
          value = "select_data",
          "Select Data",
          select_data_module$ui(ns("select_data_module"))
        ),
        accordion_panel(
          value = "set_var_types",
          "Set Variable Types",
          set_col_class_module$ui(ns("set_col_class_module"))
        ),
        accordion_panel(
          value = "select_vars",
          "Select",
          selectInput(
            ns("select_column"), "Select variable",
            NULL
          )
        )
      )
    ),
    card(
      layout_sidebar(
        sidebar = sidebar(
          width = "12vw",
          position = "right",
          source_code_module$ui(ns("source_code_module")),
        ),
        dt_module$ui(ns("dt_module"))
      )

    )
  )
}

#' @export
server <- function(id, app_database_manager) {
  moduleServer(id, function(input, output, session) {
    # Initialize reactive values to be used in this module here
    module_reactive_values <- reactiveValues()

    data_name <- select_data_module$server("select_data_module")

    selected_data <- metaReactive2({
      req(data_name$data_name())
      metaExpr({
        app_database_manager %>%
          read_table_from_db(
            ..(data_name$data_name())
          )
      })
    }, varname = "selected_data")

    col_class_set_list <- set_col_class_module$server(
      "set_col_class_module", dataset = selected_data
    )
    col_class_set_data <- col_class_set_list$data

    data_to_show <- metaReactive2({
      to_show <- selected_data
      req(input$sidebar_accordion)
      if (input$sidebar_accordion == "select_data") to_show <- selected_data
      else if (input$sidebar_accordion == "set_var_types") to_show <- col_class_set_data
      metaExpr({
        ..(to_show())
      })
    }, varname = "data_to_show")

    dt_output <- dt_module$server("dt_module", dataset = data_to_show)

    source_code_module$server(
      "source_code_module", dt_output$dt_output,
      packages = expr({
        !!packages_code
        !!set_col_class_module$packages_code
      }),
      modules = expr({
        !!function_modules_code
        !!set_col_class_module$function_modules_code
      })
    )
  })
}
