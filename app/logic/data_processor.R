box::use(
  magrittr[`%>%`, ],
  shiny[...],
  datasets,
  dplyr[mutate, mutate_at],
  purrr[map_chr, ],
  stats[na.omit, ],
)

#' @export
process_data <- function(data) {
  data %>%
    mutate(
      sepal_width_multiply_100 = Sepal.Width * 100
    )
}

#' @export
get_valid_data_names <- function(datasets = datasets) {
  map_chr(names(datasets), function(data_name) {
    if (all(class(datasets[[data_name]]) == "data.frame"))
      data_name
    else
      NA
  }) %>%
    na.omit() %>%
    as.character()
}

#' @export
get_col_types_df <- function(data, reactive = TRUE) {
  if (reactive) data <- data()
  col_types <- data.frame(
    column_names = colnames(data),
    column_types = map_chr(
      colnames(data), function(col_name) {
        class(data[[col_name]])
      }
    )
  )
  if (reactive) {
    return(
      reactive({
        col_types
      })
    )
  }
  col_types
}

#' @export
set_col_classes <- function(data, col_classes) {
  col_name_class_list <- as.list(col_classes)
  names(col_name_class_list) <- colnames(data)
  for (col in names(col_name_class_list)) {
    data <- data %>%
      mutate_at(
        col, col_name_class_list[[col]]
      )
  }
  data
}
