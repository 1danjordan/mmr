#' Age Weighting function
#'
#' Weight P/L data according to age, using an exponentially decreasing
#' factor.
#'
#' @param x       P/L data
#' @param decay   decay factor (0 < x < 1)
#'
#' @return P/L data weighted by age (numeric)

weight_by_age <- function(x, decay = 0.9) {
  if(decay <= 0 || decay >= 1) stop("Decay factor must be between 0 and 1")

  n <- length(x)
  i <- seq_along(x)
  w <- decay ^ (i - 1) * (1 - decay) / (1 - decay ^ n)

  x * w
}

#' Volatility Weighting function
#'
#' Weight P/L data according to past volatility. This function uses
#' \code{EWMA_vol} to compute volatility. Proposed by Hull and White (1998).
#'
#' @param x       P/L data
#' @param decay   decay factor (0 < x < 1)
#'
#' @return P/L data weighted by volatility (numeric)

weight_by_vol <- function(x, decay) {
  if(decay <= 0 || decay >= 1) stop("Decay factor must be between 0 and 1")

  vols <- EWMA_vol(x, decay)
  x * vols / tail(vols, 1L)

}

#' TODO: Filtered Historical Simulation (pg. 69 4.4.3)

#' Exponentially Weigthed Moving Average for estimating volatility
#'
#' Estimate volatilities of time series of returns using an EWMA
#'
#' @param x      P/L data
#' @param decay  decay factor (0 < x < 1)
#'
#' @return EWMA volatilities (numeric)

EWMA_vol <- function(x, decay = 0.85) {
  if(decay <= 0 || decay >= 1) stop("Decay factor must be between 0 and 1")

  accumulate(x, ~ ((1 - decay) * (.y ^ 2)) + (decay * .x)) %>%
    sqrt()

}

#' Exponentially Weighted Moving Average covariance between
#' two series of returns
#'
#' @params x, y  P/L data
#' @param  decay decay factor (0 < x < 1)
#'
#' @return EWMA covariance (numeric)

EWMA_cov <- function(x, y, decay = 0.85) {
  if(decay <= 0 || decay >= 1) stop("Decay factor must be between 0 and 1")
  if(length(x) != length(y)) stop("Series x and y must have the same length")

  accumulate(x * y, ~ (1 - decay) * .y + (decay * .x))
}

#' Exponentially Weighted Moving Average correlation between
#' two series of returns
#'
#' @inheritParams EWMA_cov
#'
#' @return EWMA correlation

EWMA_corr <- function(x, y, decay = 0.85) {
  if(decay <= 0 || decay >= 1) stop("Decay factor must be between 0 and 1")
  if(length(x) != length(y)) stop("Series x and y must have the same length")

  vol_1 <- EWMA_vol(x, decay)
  vol_2 <- EWMA_vol(y, decay)
  cov   <- EWMA_cov(x, y, decay)

  cov / vol_1 * vol_2
}
