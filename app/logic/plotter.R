box::use(
  ggplot2[...],
  echarts4r[...],
  magrittr[`%>%`, ],
  rlang[sym, ],
  datasets,
  dplyr[mutate, n, ],
  purrr[keep, ],
)

#' @export
get_type_columns <- function(data, column_types) {
  if (!all(class(data) == "data.frame"))
    return(NULL)
  data %>%
    colnames() %>%
    keep(function(x) {
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

  ggplot(data = data) +
    aes(x = !!sym(x_var), fill = !!sym(fill_var)) +
    geom_density(alpha = plot_transparency)
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

  ggplot(data = data) +
    aes(
      x = !!sym(x_var), y = !!sym(y_var)
    ) +
    geom_violin(trim = trim)
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
      group_by(!!sym(group_var))
  }

  data %>%
    mutate(row_num = seq_len(n())) %>%
    e_charts_(x_var) %>%
    e_line_(y_var) %>%
    e_y_axis(scale = TRUE) %>%
    e_axis_labels(
      x = x_var,
      y = y_var
    )
}
