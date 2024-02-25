# Packages
packages_code <- quote(
  box::use(
    shiny[...],
    magrittr[...],
    bslib,
    shinymeta,
    datasets,
    ggplot2,
    bsicons,
    brio,
    shinyWidgets,
    stats,
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
    app/view/dynamite_plot_module,
    # Import shiny modules here
  )
)

eval(packages_code)
eval(function_modules_code)
eval(shiny_modules_code)

cities <- data.frame(
  continent = c("America", "America", "America", "Africa",
                "Africa", "Africa", "Africa", "Africa",
                "Europe", "Europe", "Europe", "Antarctica"),
  country = c("Canada", "Canada", "USA", "Tunisia", "Tunisia",
              "Tunisia", "Algeria", "Algeria", "Italy", "Germany", "Spain", NA),
  city = c("Trois-Rivières", "Québec", "San Francisco", "Tunis",
           "Monastir", "Sousse", "Alger", "Oran", "Rome", "Berlin", "Madrid", NA),
  stringsAsFactors = FALSE
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bslib$card(
    bslib$page_sidebar(
      sidebar = bslib$sidebar(
        width = "50vw",
        bslib$accordion(
          multiple = FALSE,
          bslib$accordion_panel(
            "Some Inputs", icon = bsicons$bs_icon("menu-app"),

            shinyWidgets$pickerInput(
              ns("picker_input"), label = "Picker Input",
              choices = list(
                a = list(
                  c = 1,
                  d = 2
                ),
                e = list(
                  f = 3,
                  g = 4
                )
              ), multiple  = TRUE, autocomplete = TRUE
            ),

            shinyWidgets$multiInput(
              ns("multi_input"), label = "Multi Input",
              choices = list(
                f = 3,
                g = 4
              ), autocomplete = TRUE, options = list(
                enable_search = TRUE
              )
            ),

            shinyWidgets$multiInput(
              ns("multi_input"), label = "Multi Input",
              choices = list(
                f = 3,
                g = 4
              ), autocomplete = TRUE, options = list(
                enable_search = TRUE
              )
            ),

            shinyWidgets$airDatepickerInput(
              inputId = "multiple",
              label = "Select multiple dates:",
              placeholder = "You can pick 5 dates",
              multiple = 5, clearButton = TRUE
            ),

            shinyWidgets$airDatepickerInput(
              inputId = "multiple",
              label = "Select multiple dates:",
              placeholder = "You can pick 5 dates",
              multiple = 5, clearButton = TRUE
            ),

            shinyWidgets$airDatepickerInput(
              inputId = "multiple",
              label = "Select multiple dates:",
              placeholder = "You can pick 5 dates",
              multiple = 5, clearButton = TRUE
            ),
            shinyWidgets$airDatepickerInput(
              inputId = "multiple",
              label = "Select multiple dates:",
              placeholder = "You can pick 5 dates",
              multiple = 5, clearButton = TRUE
            ),
            shinyWidgets$autonumericInput(
              inputId = "id1",
              label = "Default Input",
              value = 1234.56
            ),
            shinyWidgets$autonumericInput(
              inputId = "id2",
              label = "Custom Thousands of Dollars Input",
              value = 1234.56,
              align = "right",
              currencySymbol = "$",
              currencySymbolPlacement = "p",
              decimalCharacter = ".",
              digitGroupSeparator = ",",
              divisorWhenUnfocused = 1000,
              symbolWhenUnfocused = "K"
            ),
            shinyWidgets$autonumericInput(
              inputId = "id3",
              label = "Custom Millions of Euros Input with Positive Sign",
              value = 12345678910,
              align = "right",
              currencySymbol = "\u20ac",
              currencySymbolPlacement = "s",
              decimalCharacter = ",",
              digitGroupSeparator = ".",
              divisorWhenUnfocused = 1000000,
              symbolWhenUnfocused = " (millions)",
              showPositiveSign = TRUE
            ),
            shinyWidgets$awesomeCheckbox(
              inputId = "somevalue",
              label = "A single checkbox",
              value = TRUE
            ),
            shinyWidgets$awesomeCheckboxGroup(
              inputId = "id2", label = "Make a choice:",
              choices = c("base", "dplyr", "data.table"),
              inline = TRUE
            ),
            shinyWidgets$awesomeRadio(
              inputId = "id2", label = "Make a choice:",
              choices = c("base", "dplyr", "data.table"),
              inline = TRUE
            ),
            shinyWidgets$checkboxGroupButtons(
              inputId = "somevalue2",
              label = "With custom status:",
              choices = names(datasets$iris),
              status = "primary"
            ),
            shinyWidgets$noUiSliderInput(
              "obs2", "Customized range slider:",
              min = 0, max = 100, value = c(40, 80)
            ),
            shinyWidgets$colorSelectorInput(
              inputId = "mycolor1", label = "Pick a color :",
              choices = c("steelblue", "cornflowerblue",
                          "firebrick", "palegoldenrod",
                          "forestgreen")
            ),
            shinyWidgets$currencyInput(
              "id2", "Dollar:", value = 1234,
              format = "dollar", width = 200, align = "right"
            ),
            shinyWidgets$formatNumericInput(
              "id5", "Percent:", value = 1234,
              width = 200, format = "percentageEU2dec"
            ),
            shinyWidgets$actionBttn("btn_text", "Text Input"),
            shinyWidgets$knobInput(
              inputId = "myKnob",
              label = "Display previous:",
              value = 50,
              min = -100,
              displayPrevious = TRUE,
              fgColor = "#428BCA",
              inputColor = "#428BCA"
            ),
            shinyWidgets$multiInput(
              inputId = "id", label = "Fruits :",
              choices = c("Banana", "Blueberry", "Cherry",
                          "Coconut", "Grapefruit", "Kiwi",
                          "Lemon", "Lime", "Mango", "Orange",
                          "Papaya"),
              selected = "Banana", width = "400px",
              options = list(
                enable_search = FALSE,
                non_selected_header = "Choose between:",
                selected_header = "You have selected:"
              )
            ),
            shinyWidgets$noUiSliderInput(
              inputId = "noui2", label = "Slider vertical:",
              min = 0, max = 1000, step = 50,
              value = c(100, 400), margin = 100,
              orientation = "vertical",
              width = "100px", height = "300px"
            ),
            shinyWidgets$numericInputIcon(
              inputId = "ex5",
              label = "Sizing",
              value = 10000,
              icon = list(icon("dollar-sign"), ".00"),
              size = "lg"
            ),
            shinyWidgets$numericRangeInput(
              inputId = "my_id", label = "Numeric Range Input:",
              value = c(100, 400)
            ),
            shinyWidgets$searchInput(
              inputId = "search", label = "Enter your text",
              placeholder = "A placeholder",
              btnSearch = icon("magnifying-glass"),
              btnReset = icon("xmark"),
              width = "450px"
            ),
            shinyWidgets$sliderTextInput(
              inputId = "mySliderText",
              label = "Month range slider:",
              choices = month.name,
              selected = month.name[c(4, 7)]
            ),
            shinyWidgets$switchInput(inputId = "somevalue"),
            shinyWidgets$textInputIcon(
              inputId = "ex3",
              label = "With text",
              icon = list("https://")
            ),
            shinyWidgets$treeInput(
              inputId = "ID3",
              label = "Select cities:",
              choices = shinyWidgets$create_tree(cities),
              selected = c("San Francisco", "Monastir"),
              returnValue = "text",
              closeDepth = 2
            ),
            shinyWidgets$virtualSelectInput(
              inputId = "multiple",
              label = "Multiple select:",
              choices = stats$setNames(month.abb, month.name),
              multiple = TRUE
            ),



            varSelectInput(
              ns("var_select_input"), "Var Select Input",
              datasets$iris, selected = colnames(datasets$iris)[1]
            ),
            fileInput(
              ns("file_input"),
              "Upload File"
            ),
            dateInput(
              ns("date_input"),
              "Date Input"
            ),
            textInput(
              ns("text_input"),
              "Text Input"
            ),
            sliderInput(
              ns("slider_input"),
              "Slider Input",
              0, 100, 34
            ),
            checkboxInput(
              ns("checkbox_input"),
              "Checkbox Input"
            )
          ),
          bslib$accordion_panel(
            "Some More Inputs", icon = bsicons$bs_icon("sliders"),
            numericInput(ns("bins"), "Number of bins", 30) %>%
              bslib$tooltip("Tooltip message"),
            passwordInput(
              ns("password_input"),
              "Password Input"
            ),
            dateRangeInput(
              ns("date_range_input"),
              "Date range input"
            ),
            varSelectInput(
              ns("var_select"),
              "Var select",
              datasets$iris
            ),
            checkboxGroupInput(
              ns("checkbox_group_input"),
              "Checkbox group input",
              c("a", "b", "c")
            )
          )
        )
      ),
      bslib$card(
        full_screen = TRUE
      )
    )
  )
}
