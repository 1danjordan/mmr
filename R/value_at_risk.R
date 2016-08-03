#' Historical Value at Risk
#'
#' Estimate the VaR of a portfolio using the historical simulation approach
#' for specified confidence levels. The holding period is implied by the P/L
#' data passed to the function. This function uses the quantile, rather than
#' the method used in Measuring Market Risk - that is approximating the pdf
#' by drawing lines through the midpoints of a histogram.
#'
#' @param x       a vector of P/L data
#' @param conf    the confidence level
#'

var_historical <- function(x, conf) {

  quantile(-x, probs = 1 - conf, na.rm = TRUE)

  }


#' Value At Risk for normally distributed P/L
#'
#' Estimate the VaR of a portfolio assuming P/L is =
#' normally distributed for specified confidence level and holding period.
#'
#' @param mu       mean daily P/L
#' @param sigma    standard deviation of daily P/L
#' @param conf     the confidence level
#' @param holding  the holding period in days


var_normal <- function(mu, sigma, conf = 0.95, holding = 1) {

  -sigma * sqrt(holding) * qnorm(1 - conf) - (mu * holding)

  }

#' Value at Risk for lognormally distributed P/L
#'
#' Estimate the VaR of a portfolio assuming that geometric returns are
#' normally distributed, for specified confidence level and holding
#' period.
#'
#' @inheritParams var_normal
#' @param investment  the size of investment

var_lognormal <- function(mu, sigma, investment, conf = 0.95, holding = 1) {

  investment * (1 - exp(-var_normal(mu, sigma, conf, holding)))

  }
