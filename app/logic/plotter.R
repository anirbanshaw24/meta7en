box::use(
  magrittr[...],
  datasets,
  ggplot2,
  rlang,
  echarts4r,
  dplyr,
)

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
    data = datasets$iris, selected_variable, plot_transparency) {

  ggplot2$ggplot(data = data) +
    ggplot2$aes(x = !!rlang$sym(selected_variable), fill = Species) +
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
plot_dynamite <- function(
    data = datasets$iris, selected_variable, bar_width) {

  mean_se <- ggplot2$mean_se
  ggplot2$ggplot(data = data) +
    ggplot2$aes(x = Species, y = !!rlang$sym(selected_variable), fill = Species) +
    ggplot2$stat_summary(geom = "bar", fun = "mean") +
    ggplot2$stat_summary(
      geom = "errorbar", fun.data = mean_se, width = bar_width
    )
}

#' Plot echarts
#'
#' @param data
#' @param slice_head
#'
#' @return
#' @export
#'
plot_echarts <- function(
    data = datasets$iris, slice_head) {

  data %>%
    dplyr$slice_head(n = slice_head) %>%
    dplyr$mutate(day = seq_len(dplyr$n())) %>%
    echarts4r$e_charts(day) %>%
    echarts4r$e_line(CAC, symbol = "none") %>%
    echarts4r$e_band2(DAX, FTSE) %>%
    echarts4r$e_band2(DAX, SMI, itemStyle = list(borderWidth = 0)) %>%
    echarts4r$e_y_axis(scale = TRUE) %>%
    echarts4r$e_datazoom(start = 50) %>%
    echarts4r$e_theme("myTheme")
}
