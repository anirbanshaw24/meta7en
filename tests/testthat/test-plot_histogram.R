box::use(
  testthat[...],
  datasets,
)

box::use(
  app/logic/plotter[plot_histogram],
)

test_that("plot_histogram", {
  # Given
  data <- datasets$iris
  selected_variable <- "Sepal.Length"
  plot_transparency <- 0.3

  # When
  result <- plot_histogram(
    data = data, selected_variable = as.name(selected_variable),
    plot_transparency = plot_transparency
  )

  # Then
  expect_equal(
    class(result), c("gg", "ggplot")
  )
})
