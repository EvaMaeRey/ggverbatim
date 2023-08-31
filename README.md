
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggverbatim

<!-- badges: start -->

<!-- badges: end -->

A class of tables exists where table body values are like-in-kind. These
tables differ from data-frames, in that for most data-frames, columns
contain values of different types.

Such tables can be stored in a ‘long form’ of the data, which may be
more analytic- friendly. For example the long form, enables direct use
in tools like ggplot2 and tidypivot.

The inspiration for ggverbatim is to reproduce tables that have values
that are like-in-kind in ggplot2 in a way that feels natural. Products
like heat maps and correlations tables can be prepped as tables and then
ported to the popular data visualization tool without pivoting to
longer. This yields a closer visual match between the table input and
the visual output.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("EvaMaeRey/ggverbatim")
```

## Motivation

ggplot requires ‘tidy’ data, usually ‘long’. You may build a table in
ggplot2, the visual arrangement isn’t tidy, but is nice for humans.

Sometimes, you will have data in an untidy format (your raw data or data
that you’ve already worked with). And you might just want to reproduce
it ggplot2 ‘verbatim’.

Currently, this would be accomplished via a pivot to long (‘unpivot’)
and then repivot through the visual specification. That is what
ggverbatim actually does under the hood. But if feels like a A1 -\> A2
process, not an A1 -\> B -\> A2 process.

``` r
# library(ggverbatim)
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.0     ✔ readr     2.1.4
#> ✔ forcats   1.0.0     ✔ stringr   1.5.0
#> ✔ ggplot2   3.4.1     ✔ tibble    3.2.0
#> ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
#> ✔ purrr     1.0.1     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
library(magrittr)
#> 
#> Attaching package: 'magrittr'
#> 
#> The following object is masked from 'package:purrr':
#> 
#>     set_names
#> 
#> The following object is masked from 'package:tidyr':
#> 
#>     extract

Titanic %>% 
  data.frame() %>% 
  tibble() %>% 
  uncount(Freq) %>% 
  count(Survived, Sex) %>% 
  pivot_wider(names_from = Sex, values_from = n) ->
vis_arrangement

vis_arrangement
#> # A tibble: 2 × 3
#>   Survived  Male Female
#>   <fct>    <int>  <int>
#> 1 No        1364    126
#> 2 Yes        367    344
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
vis_arrangement %>% 
  pivot_longer(cols = -1) %>% 
  ggplot() + 
  aes(x = name) + 
  labs(x = "Sex") + 
  aes(y = Survived) + 
  aes(label = value) + 
  aes(fill = value) + 
  geom_tile() + 
  geom_text() + 
  scale_x_discrete(position = "top") + 
  scale_y_discrete(limits=rev)
```

<img src="man/figures/README-cars-1.png" width="100%" />

# Therefore

``` r
readLines("R/ggverbatim.R") ->
verbatim_code
```

``` r
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
ggverbatim <- function(data, row_var_name = NULL, cols_var_name = "x"){

  row_var_name <- names(data)[1]
  names(data)[1] <- "row_var"

  data %>%
    pivot_longer(cols = -1) %>%
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
```

``` r
vis_arrangement %>% 
  ggverbatim() +
  geom_tile(alpha = .8) +
  aes(fill = value) +
  aes(labels = value) +
  geom_text(color = "oldlace") + 
  labs(x = "Sex") + 
  theme_minimal() 
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" /> \#
Another example; corrr

The corrr project is designed to make correlation fit the ‘tidy’
paradigmn. corrr table outputs can be manipulated like data frames.

``` r
library(MASS)
#> 
#> Attaching package: 'MASS'
#> The following object is masked from 'package:dplyr':
#> 
#>     select
library(corrr)

# Simulate three columns correlating about .7 with each other
mu <- rep(0, 3)
Sigma <- matrix(.7, nrow = 3, ncol = 3) + diag(3)*.3
seven <- mvrnorm(n = 1000, mu = mu, Sigma = Sigma)

# Simulate three columns correlating about .4 with each other
mu <- rep(0, 3)
Sigma <- matrix(.4, nrow = 3, ncol = 3) + diag(3)*.6
four <- mvrnorm(n = 1000, mu = mu, Sigma = Sigma)

# Bind together
d <- cbind(seven, four)
colnames(d) <- paste0("v", 1:ncol(d))

# Insert some missing values
d[sample(1:nrow(d), 100, replace = TRUE), 1] <- NA
d[sample(1:nrow(d), 200, replace = TRUE), 5] <- NA

# Correlate
corrr_example <- correlate(d)
#> Correlation computed with
#> • Method: 'pearson'
#> • Missing treated using: 'pairwise.complete.obs'

corrr_example %>% 
  ggverbatim() + 
  geom_tile() + 
  scale_fill_viridis_c()
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

``` r

corrr_example %>% 
  ggverbatim() + 
  geom_point(aes(size = value))
#> Warning: Removed 6 rows containing missing values (`geom_point()`).
```

<img src="man/figures/README-unnamed-chunk-5-2.png" width="100%" />

``` r

corrr_example %>% 
  shave() %>% 
  ggverbatim() + 
  geom_tile() + 
  geom_text(aes(label = round(value, 2), color = value >.1)) +
  scale_fill_viridis_c()
#> Warning: Removed 21 rows containing missing values (`geom_text()`).
```

<img src="man/figures/README-unnamed-chunk-5-3.png" width="100%" />
