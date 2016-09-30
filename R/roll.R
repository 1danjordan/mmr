#' Rolling Window function
#'
#' A simple roll function, "rolling the window" across a series of data,
#' applying a function, to produce a vector of results
#'
#' @param x       a vector passed into \code{.f}
#' @param .f      a function or formula
#'
#'   If a \strong{function}, it is used as is.
#'
#'   If a \strong{formula}, e.g. \code{~ .x + 2}, it is converted to a
#'   function with two arguments, \code{.x} or \code{.} and \code{.y}. This
#'   allows you to create very compact anonymous functions with up to
#'   two inputs.
#'
#' @param ...     further arguments to pass .f
#' @param width   the width of the window
#' @param extend  extend the window as it rolls (logical)
#'
#' @example
#' # Simulate 4 years of daily returns
#' x <- rnorm(1000)
#' # compute the historical var across a window of a year
#' roll(x, var_historical, conf = 0.8, width = 250)
#'
#' Really the decision lies with:
#' if kept simple, we map(df, ~ roll(~ .f(.x)))
#' but this means we cannot use roll to compute
#' functions that require interactions like cov(x,y)
#'
#' That seems like the best way to deal with dataframes

roll <- function(x, .f, ..., width = 1, extend = FALSE) {

  .f <- as_function(.f, ...)

  idxs <- if(extend) {
    map(seq(1, length(x) - width + 1), ~ seq(1, .x + width - 1))
  } else {
    map(seq(1, length(x) - width + 1), ~ seq(.x, .x + width - 1))

  }

  map_dbl(idxs, ~ .f(x[.x]))
}
