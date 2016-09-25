#' Rolling Window function
#'
#' Roll the window across a series of data, applying a function.
#' Use \code{purrr::partial} to partially fill a function with arguments
#' before passing it into \code{roll}.
#'
#' @param x        a vector/matrix passed into \code{fun}
#' @param fun      a partial function to pass x into
#' @param length   the length of the window
#' @param extend   extend the window as it rolls (logical)
#'
#' @example
#' # Simulate 4 years of daily returns
#' x <- rnorm(1000)
#' # compute the historical var across a window of a year
#' var_h <- partial(var_historical, conf = 0.8) %>%
#' roll(x, var_h, 250)

roll <- function(x, fun, length, extend = FALSE) {

  idxs <- ifelse(extend,
                 map(seq(1, length(x) - length - 1), ~ seq(1, .x + length)),
                 map(seq(1, length(x) - length - 1), ~ seq(.x, .x + length)))

  map_dbl(idxs, ~ fun(x[.x]))

}
