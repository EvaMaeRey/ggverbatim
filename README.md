
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggverbatim

<!-- badges: start -->

<!-- badges: end -->

The goal of ggverbatim is to reproduce visual table arrangement of
tabular input to ggplot2. It feels a bit wrong; not likely to pursue
further.

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
that you’ve already worked wth). And you might just want to reproduce it
ggplot2 ‘verbatim’.

Currently, this would be accomplished via a pivot to long (unpivot) and
then repivot in the visual. That is what ggverbatim actually does under
the hood. But if feels like a A -\> A process, not an A -\> B -\> A
process.

``` r
# library(ggverbatim)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
#> ✓ tibble  3.1.6     ✓ dplyr   1.0.8
#> ✓ tidyr   1.0.2     ✓ stringr 1.4.0
#> ✓ readr   1.3.1     ✓ forcats 0.5.0
#> Warning: package 'ggplot2' was built under R version 3.6.2
#> Warning: package 'tibble' was built under R version 3.6.2
#> Warning: package 'purrr' was built under R version 3.6.2
#> Warning: package 'dplyr' was built under R version 3.6.2
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(magrittr)
#> Warning: package 'magrittr' was built under R version 3.6.2
#> 
#> Attaching package: 'magrittr'
#> The following object is masked from 'package:purrr':
#> 
#>     set_names
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
```

``` r
vis_arrangement %>% 
  ggverbatim(rows_var = Survived) + 
  geom_text() + 
  geom_tile(alpha = .2) +
  labs(x = "Sex")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
