box::use(
  hexSticker[sticker, ],
  magick[image_read, image_write, image_resize, image_extent, ],
)

build_app_hex <- function(
    app_theme, hex_image = "app/static/images/hex_image.png",
    hex_output = "app/static/images/app_hex.png") {
  sticker(
    package = "safety data pool",
    h_fill = app_theme$white,
    h_color = app_theme$secondary,
    p_color = app_theme$dark,
    hex_image,
    p_size = 45,
    s_x = 1,
    s_y = 0.7,
    s_width = 0.42,
    dpi = 800,
    filename = hex_output
  )
}
app_theme <- get(file = file.path("constants", "theme.yml"))
build_app_hex(app_theme)

app_hex <- image_read("app/static/images/app_hex.png") %>%
  image_resize("512x512") %>%
  image_extent("512x512") %>%
  image_write("app/static/favicon.ico")
