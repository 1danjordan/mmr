#' Expcted Shortfall using the historical simulation approach
#'
#' Estimates the ES by averaging the losses in the tail. Holding time
#' is inferred by the frequency of the data.
#'
#' @param x      P/L data
#' @param conf   confidence level

es_historical <- function(x, conf = 0.95) {
  losses <- -x
  tail <- losses[losses > quantile(losses, 1 - conf, na.rm = TRUE)]
  mean(tail)
}

#' Expected Shortfall for normally distributed P/L
#'
#' This function estimates the ES of a portfolio assuming P/L is
#' normally distributed for a specified confidence level and holding period.
#'
#' @param mu        mean daily P/L data
#' @param sigma     standard deviation of daily P/L data
#' @param conf      the confidence level (double)
#' @param holding   the holding period in days (double)
#'

es_normal <- function(mu, sigma, conf = 0.95, holding = 1) {

  sigma * sqrt(holding) * dnorm(qnorm(1 - conf)) / (1 - conf) - (mu * holding)

}


#' Expected Shortfall for normally distributed geometric returns
#'
#' This function estimates the ES of P/L data assuming geometric returns
#' are normally distributed, for specified confidence level and holding period.
#' It does so by taking an average of the VaRs in the tail of the distribution.
#'
#' @inheritParams es_normal
#' @param investment          the size of investment

es_lognormal <- function(mu, sigma, investment, conf = 0.95, holding = 1) {

  conf <- seq(conf, 1, length.out = 1000)
  var_ln <- partial(var_lognormal, mu = mu, sigma = sigma, investment = investment, holding = holding)

  map_dbl(conf, ~ var_ln(conf = .x)) %>%
    mean()
}
