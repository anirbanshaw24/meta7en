# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[`%>%`, ],
    bslib[
      page_navbar, bs_theme, bs_add_variables, nav_panel, nav_spacer,
      nav_menu, card, nav_select, nav_item, card_body,
    ],
    config[get, ],
    bsicons[bs_icon, ],
    thematic[thematic_shiny, font_spec, ],
    datasets,
    markdown[markdownToHTML, ],
    knitr[knit, ],
    duckdb[duckdb, ],
    purrr[walk, ]
    # Import packages here
  )
)

# Logic and Function Modules
function_modules_code <- quote(
  box::use(
    app/logic/database_manager[
      database_manager, write_table_to_db, disconnect_database,
    ],
    app/logic/data_processor[get_valid_data_names],
    app/logic/app_utils[
      get_db_setup_code, get_n_colors,
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

Sys.setenv(ENVIRONMENT = "shinyapps")

app_config <- get(config = Sys.getenv("ENVIRONMENT"))
app_theme <- get(file = file.path("constants", "theme.yml"))

options(shiny.useragg = TRUE)
options(warn = app_config$warn_option)

thematic_shiny(
  bg = app_theme$light,
  fg = app_theme$dark,
  accent = app_theme$secondary,
  qualitative = get_n_colors(app_theme$primary, app_theme$success, n = 3),
  font = font_spec(
    scale = 1.75
  )
)

enableBookmarking(store = app_config$bookmark_location)

build_app_hex(app_theme)

#' @export
ui <- function(id) {
  ns <- NS(id)

  main_page_constants <- get(
    file = file.path("constants", "main_page_constants.yml")
  )

  page_navbar(
    id = ns("main_page_navbar"),
    position = "fixed-top",
    inverse = TRUE,
    bg = app_theme$secondary,
    theme = bs_theme(
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
        bs_add_variables,
        c(quote(.), app_theme$bs_var_settings)
      )
    },
    underline = FALSE,
    window_title = main_page_constants$app_title,
    title = title$ui(ns("title"), main_page_constants$app_title),
    footer = footer$ui(ns("footer"), main_page_constants),

    # Left Tabs
    nav_panel(
      title = main_page_constants$tab1_title,
      welcome_tab$ui(ns("welcome_tab"))
    ),
    nav_panel(
      icon = bs_icon("table"),
      title = "Process Data",
      data_tab$ui(ns("data_tab"))
    ),
    nav_panel(
      icon = bs_icon("graph-up"),
      title = main_page_constants$tab2_title,
      plot_tab$ui(ns("plot_tab")),
    ),
    nav_panel(
      icon = bs_icon("menu-button-wide-fill"),
      title = main_page_constants$tab3_title,
      inputs_demo_tab$ui(ns("inputs_demo_tab"))
    ),
    # Right Tabs
    nav_spacer(),
    nav_menu(
      title = "App Menu", nav_item(
        card_body(
          bookmarkButton(
            label = "Save State"
          )
        )
      ), icon = bs_icon("menu-down"),
      value = "app_menu"
    ),
    nav_panel(
      value = "read_me",
      icon = bs_icon("info-square"),
      title = "Read Me",
      card(
        includeMarkdown("README.md")
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
      nav_select(
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
        disconnect_database()
    })
    # Make sure DB is disconnected and shut down!
    onStop(function() {
      app_database_manager %>%
        disconnect_database()
    })
  })
}
