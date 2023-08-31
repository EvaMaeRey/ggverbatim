#' Title
#'
#' @param data
#' @param row_var_name
#' @param cols_var_name
#'
#' @return
#' @export
#'
#' @examples
#' Titanic %>%
#'   data.frame() %>%
#'   tibble() %>%
#'   uncount(Freq) %>%
#'   count(Survived, Sex) %>%
#'   pivot_wider(names_from = Sex, values_from = n) ->
#'   vis_arrangement
#'
#'   vis_arrangement %>%
#'   ggverbatim()
ggverbatim <- function(data, cat_cols = 1,  row_var_name = NULL, cols_var_name = "x", value_var_name = NULL){

  row_var_name <- names(data)[1]
  names(data)[1] <- "row_var"


  col_headers <- names(data)
  col_headers <- col_headers[2:length(col_headers)]

  message("Variables that represented visually are ; e.g.  aesthetic mappying are 'x', and " |> paste(row_var_name))


  data %>%
    mutate(row_var = fct_inorder(row_var)) %>%
    pivot_longer(cols = -cat_cols) %>%
    mutate(name = factor(name, levels = col_headers)) %>%
    rename(x = name) ->
  pivoted

  pivoted %>%
    ggplot() +
    aes(x = x) +
    labs(x = cols_var_name) +
    aes(y = row_var) +
    labs(y = row_var_name) +
    aes(label = value) +
    aes(fill = value) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(limits=rev)

}


