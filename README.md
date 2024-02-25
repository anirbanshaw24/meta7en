---
title: "meta7en"
---

<img align="right" width="100" height="120" src="app/static/images/app_hex.png">

# A bslib app built with Rhino and S7 classes

<!-- badges: start -->
[![r-unit-test-lint](https://github.com/anirbanshaw24/meta7en/actions/workflows/r-unit-test-lint.yml/badge.svg)](https://github.com/anirbanshaw24/meta7en/actions/workflows/r-unit-test-lint.yml)
[![build-js-sass](https://github.com/anirbanshaw24/meta7en/actions/workflows/build-js-sass.yml/badge.svg)](https://github.com/anirbanshaw24/meta7en/actions/workflows/build-js-sass.yml)
[![e2e-test](https://github.com/anirbanshaw24/meta7en/actions/workflows/e2e-test.yml/badge.svg)](https://github.com/anirbanshaw24/meta7en/actions/workflows/e2e-test.yml)
<!-- badges: end -->

The goal of rhino-app-example is to demostrate S7 classes, shinymeta, bslib and Rhino.

This application is designed to provide tools for data processing, visualization, and interactive exploration. Below you will find information about the structure of the application, its modules, and how to navigate its features.

## Packages

The application utilizes several R packages to enable its functionality. These packages are loaded and used within the application:

```
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
    # Import packages here
  )
)
```

## Logic and Function Modules

The logic and function modules are essential for the backend operations of the application. These modules handle database management, data processing, and utility functions. Here is how they are loaded:


```
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
```

## Shiny Modules

Shiny modules define the UI elements and interactive components of the application. They are responsible for creating the user interface that users interact with:

```
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

```

## Setting up the Application

To initialize the application with the necessary configurations and themes, the following code is executed:

```
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
```

## User Interface (UI)

The UI of the application is structured using bslib for styling and layout. Here is an overview of the main UI components:

- Navbar: The top navigation bar includes tabs for different sections of the application.
- Left Tabs: Tabs for main functionalities like data processing, visualization, and demos.
- Right Tabs: Additional menu options and information.

The UI is defined as a function `ui <- function(id) { ... }`. It includes elements like the title, tabs, and menu items. The UI is constructed using Bootstrap components and custom styles defined in the `theme.yml` file.

## Server Logic

The server logic defines the backend operations of the application. It includes setting up the database, handling user interactions, and managing sessions:

```
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- NS(id)

    module_reactive_values <- reactiveValues(
      data_colnames = NULL
    )

    db_setup_code <- get_db_setup_code()
    eval(db_setup_code)

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
```

## Using `shinymeta` for Source Code

`shinymeta` is used in the application to view and download the source code that generates the results. Below is an example of a module with source code generation:

```
source_code_module$server(
  "source_code_module", dt_output$dt_output,
  packages = rlang$expr({
    !!packages_code
    !!set_col_class_module$packages_code
  }),
  modules = rlang$expr({
    !!function_modules_code
    !!set_col_class_module$function_modules_code
  })
)
```

## Additional Notes

- The application is designed to be modular and extensible. New functionality can be added by creating additional logic and UI modules.
- Bookmarking is enabled to allow users to save and restore their application state.
- The `README.md` file is rendered within the application under the "Read Me" tab, providing users with documentation and information about the application.
- Thank you for using our web application! If you have any questions or feedback, please feel free to reach out to the development team.








