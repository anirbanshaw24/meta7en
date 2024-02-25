# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    config,
    bsicons,
    thematic,
    duckdb,
    datasets,
    purrr,
    rlang,
    markdown,
    knitr,
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager,
    app/logic/data_processor[get_valid_data_names],
    app/logic/app_utils[
      get_db_setup_code, get_n_colors, register_echarts_theme,
      build_app_hex
    ],
    # Import function modules here
  )
)

# Shiny Modules
shiny_modules_code <- quote(
  box::use(
    app/view/title,
    app/view/welcome_tab,
    app/view/data_tab,
    app/view/plot_tab,
    app/view/footer,
    app/view/inputs_demo_tab,
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)



app_config <- config$get(config = Sys.getenv("ENVIRONMENT"))
app_theme <- config$get(file = file.path("constants", "theme.yml"))

options(shiny.useragg = TRUE)
options(warn = app_config$warn_option)

thematic$thematic_shiny(
  bg = app_theme$light,
  fg = app_theme$dark,
  accent = app_theme$secondary,
  qualitative = get_n_colors(app_theme$primary, app_theme$success, n = 3),
  font = thematic$font_spec(
    scale = 1.75
  )
)

enableBookmarking(store = app_config$bookmark_location)

build_app_hex(app_theme)

#' @export
ui <- function(id) {
  ns <- NS(id)

  main_page_constants <- config$get(file = file.path("constants", "main_page_constants.yml"))

  bslib$page_navbar(
    id = ns("main_page_navbar"),
    position = "fixed-top",
    inverse = TRUE,
    bg = app_theme$secondary,
    theme = bslib$bs_theme(
      version = 5,
      bg = app_theme$light,
      fg = app_theme$dark,
      primary = app_theme$secondary,
      secondary = app_theme$primary,
      success = app_theme$success,
      info = app_theme$info,
      warning = app_theme$warning,
      danger = app_theme$danger,
    ) %>% {
      do.call(
        bslib$bs_add_variables,
        c(quote(.), app_theme$bs_var_settings)
      )
    },
    underline = FALSE,
    window_title = main_page_constants$app_title,
    title = title$ui(ns("title"), main_page_constants$app_title),
    footer = footer$ui(ns("footer"), main_page_constants),

    # Left Tabs
    bslib$nav_panel(
      title = main_page_constants$tab1_title,
      register_echarts_theme(app_theme),
      welcome_tab$ui(ns("welcome_tab"))
    ),
    bslib$nav_panel(
      icon = bsicons$bs_icon("table"),
      title = "Process Data",
      data_tab$ui(ns("data_tab"))
    ),
    bslib$nav_panel(
      icon = bsicons$bs_icon("graph-up"),
      title = main_page_constants$tab2_title,
      plot_tab$ui(ns("plot_tab")),
    ),
    bslib$nav_panel(
      icon = bsicons$bs_icon("menu-button-wide-fill"),
      title = main_page_constants$tab3_title,
      inputs_demo_tab$ui(ns("inputs_demo_tab"))
    ),
    # Right Tabs
    bslib$nav_spacer(),
    bslib$nav_menu(
      title = "App Menu", bslib$nav_item(
        bslib$card_body(
          bookmarkButton(
            label = "Save State"
          )
        )
      ), icon = bsicons$bs_icon("menu-down"),
      value = "app_menu"
    ),
    bslib$nav_panel(
      value = "read_me",
      icon = bsicons$bs_icon("info-square"),
      title = "Read Me",
      bslib$card(
        HTML(
          markdown$markdownToHTML(
            knitr$knit("README.md", quiet = TRUE),
            fragment.only = TRUE
          )
        )
      )
    )
  )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- NS(id)

    module_reactive_values <- reactiveValues(
      data_colnames = NULL
    )

    db_setup_code <- get_db_setup_code()
    eval(db_setup_code)

    read_me <- welcome_tab$server("welcome_tab")

    observeEvent(read_me(), ignoreInit = TRUE, {
      bslib$nav_select(
        id = "main_page_navbar", selected = "read_me"
      )
    })

    plot_tab$server(
      "plot_tab", app_database_manager
    )

    data_tab$server(
      "data_tab", app_database_manager
    )

    # DB is disconnected and shut down!
    onSessionEnded(function() {
      app_database_manager %>%
        database_manager$disconnect_database()
    })
    # Make sure DB is disconnected and shut down!
    onStop(function() {
      app_database_manager %>%
        database_manager$disconnect_database()
    })
  })
}
