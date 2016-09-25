#' Rolling Window .fction
#'
#' Roll the window across a series of data, applying a .fction.
#' Use \code{purrr::partial} to partially fill a .fction with arguments
#' before passing it into \code{roll}.
#'
#' @param x       a vector/matrix passed into \code{.f}
#' @param .f      a partial function to pass x into
#' @param width   the width of the window
#' @param extend  extend the window as it rolls (logical)
#'
#' @example
#' # Simulate 4 years of daily returns
#' x <- rnorm(1000)
#' # compute the historical var across a window of a year
#' var_h <- partial(var_historical, conf = 0.8) %>%
#' roll(x, var_h, 250)

roll <- function(x, .f, ..., width = 10, extend = FALSE) {

  .f <- as_function(.f, ...)

  idxs <- if(extend) {
    map(seq(1, length(x) - width + 1), ~ seq(1, .x + width - 1))
  } else {
    map(seq(1, length(x) - width + 1), ~ seq(.x, .x + width - 1))

  }

  map_dbl(idxs, ~ .f(x[.x]))


}
