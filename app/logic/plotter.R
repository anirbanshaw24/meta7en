box::use(
  magrittr[...],
  datasets,
  ggplot2,
  rlang,
  echarts4r,
  dplyr,
  purrr,
)

#' @export
get_type_columns <- function(data, column_types) {
  if (!all(class(data) == "data.frame"))
    return(NULL)
  data %>%
    colnames() %>%
    purrr$keep(function(x) {
      any(class(data[[x]]) %in% column_types)
    })
}

#' @export
get_numeric_columns <- function(data_frame) {
  col_names <- colnames(data_frame)
  data_frame %>%
    get_type_columns(c("numeric", "integer"))
}

#' @export
get_factor_columns <- function(data_frame) {
  col_names <- colnames(data_frame)
  data_frame %>%
    get_type_columns(c("factor", "character"))
}

#' Plot Histogram
#'
#' @param data
#' @param selected_variable
#' @param bins
#'
#' @return
#' @export
#'
plot_histogram <- function(
    data = datasets$iris, x_var = get_numeric_columns(data)[1],
    fill_var = get_factor_columns(data)[1], color_var = NULL,
    plot_transparency = 0.3, ...) {

  ggplot2$ggplot(data = data) +
    ggplot2$aes(x = !!rlang$sym(x_var), fill = !!rlang$sym(fill_var)) +
    ggplot2$geom_density(alpha = plot_transparency)
}


#' Plot Dynamite
#'
#' @param data
#' @param selected_variable
#' @param plot_width
#'
#' @return
#' @export
#'
plot_violin <- function(
    data = datasets$iris, x_var = get_factor_columns(data)[1],
    y_var = get_numeric_columns(data)[1], trim) {

  ggplot2$ggplot(data = data) +
    ggplot2$aes(
      x = !!rlang$sym(x_var), y = !!rlang$sym(y_var)
    ) +
    ggplot2$geom_violin(trim = trim)
}

#' Plot echarts
#'
#' @param data
#' @param slice_head
#'
#' @return
#' @export
#'
line_plot_echarts <- function(
    data = datasets$iris, x_var = get_numeric_columns(data)[1],
    y_var = get_numeric_columns(data)[2], group_var = NULL) {
  if (group_var != "") {
    data <- data %>%
      echarts4r$group_by(!!rlang$sym(group_var))
  }

  data %>%
    dplyr$mutate(row_num = 1:dplyr$n()) %>%
    echarts4r$e_charts_(x_var) %>%
    echarts4r$e_line_(y_var) %>%
    echarts4r$e_y_axis(scale = TRUE) %>%
    echarts4r$e_axis_labels(
      x = x_var,
      y = y_var
    ) %>%
    echarts4r$e_theme("myTheme")
}
