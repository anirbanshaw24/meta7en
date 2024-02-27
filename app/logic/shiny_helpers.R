box::use(
  magrittr[...],
  shiny[...],
)

box::use(
  app/logic/plotter[get_type_columns, ],
)

self_name_list <- function(list_to_name) {
  named_list <- as.list(
    list_to_name
  )
  names(named_list) <- list_to_name
  named_list
}

get_col_choices <- function(allowed_cols, preffix_choices, suffix_choices) {
  col_choices <- self_name_list(allowed_cols)
  col_choices <- append(
    preffix_choices, col_choices
  )
  col_choices <- append(
    col_choices, suffix_choices
  )
  col_choices
}

#' @export
update_var_select_input <- function(
    input_id, selected_data, allowed_col_types = c(
      "numeric", "integer", "character", "factor"
    ),
    preffix_choices = NULL,
    suffix_choices = NULL, session) {

  allowed_cols <- get_type_columns(
    selected_data, allowed_col_types
  )
  col_choices <- get_col_choices(
    allowed_cols, preffix_choices, suffix_choices
  )
  updateSelectInput(
    inputId = input_id, choices = col_choices,
    selected = col_choices[1], session = session
  )
}

#' @export
get_true_false_choices <- function() {
  list(
    "Yes" = TRUE,
    "No" = FALSE
  )
}
