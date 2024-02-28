# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[layout_sidebar, sidebar, accordion, accordion_panel, card, ],
    shinymeta[metaReactive2, metaExpr, ],
    bsicons[bs_icon, ],
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager,
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/histogram_plot_module,
    app/view/violin_plot_module,
    app/view/echarts_plot_module,
    app/view/data_creator/select_data_module,
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
      id = ns("plot_tab_sidebar"),
      accordion(
        multiple = FALSE,
        accordion_panel(
          id = ns("plot_tab_sidebar_accordion"),
          value = "select_data",
          "User Inputs", icon = bs_icon("menu-app"),
          select_data_module$ui(ns("select_data_module")),
        )
      )
    ),
    accordion(
      id = ns("plot_tab_main_accordion"),
      open = c("Density Plot"),
      multiple = FALSE,
      accordion_panel(
        "Density Plot",
        card(
          height = "60vh",
          histogram_plot_module$ui(ns("histogram_plot_module")),
          full_screen = TRUE
        )
      ),
      accordion_panel(
        "Violin Plot",
        card(
          height = "60vh",
          violin_plot_module$ui(ns("violin_plot_module")),
          full_screen = TRUE
        )
      ),
      accordion_panel(
        "echarts Plot",
        card(
          height = "60vh",
          echarts_plot_module$ui(ns("echarts_plot")),
          full_screen = TRUE
        )
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
          database_manager$read_table_from_db(
            ..(data_name$data_name())
          )
      })
    }, varname = "selected_data")

    histogram_plot_module$server(
      "histogram_plot_module", selected_data = selected_data,
      app_database_manager = app_database_manager
    )

    violin_plot_module$server(
      "violin_plot_module", selected_data = selected_data,
      app_database_manager = app_database_manager
    )

    echarts_plot_module$server(
      "echarts_plot", selected_data = selected_data,
      app_database_manager
    )
  })
}
