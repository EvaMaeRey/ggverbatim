ggverbatim <- function(data, rows_var = NULL, cols_var_name = "x"){

  data %>%
    pivot_longer(cols = -1) %>%
    ggplot() +
    aes(x = name) +
    labs(x = cols_var_name) +
    aes(y = {{rows_var}}) +
    aes(label = value) +
    aes(fill = value) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(limits=rev)

}
