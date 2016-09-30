#' Expcted Shortfall using the historical simulation approach
#'
#' Estimates the ES by averaging the losses in the tail. Holding time
#' is inferred by the frequency of the data.
#'
#' @param x      P/L data
#' @param conf   confidence level
#'
#' @return ES measure (numeric)

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
#' @return ES measure (numeric)

es_normal <- function(mu, sigma, conf = 0.95, holding = 1) {

  sigma * sqrt(holding) * dnorm(qnorm(1 - conf)) / (1 - conf) - (mu * holding)

}

#' Compute Expected Shortfall given a VaR measure
#'
#' Compute ES takes a VaR function and its arguments and computes the
#' expected shortfall by taking an average of the tail VaRs.
#'
#' @param .f     a VaR function to compute ES with
#' @param ...    further arguments to pass
#' @param conf   level of confidence
#' @param n      number of slices to approximate tail VaR with
#'
#' @example
#' # Compute lognormal expected shorfall function using lognormal VaR
#' compute_es(var_lognormal, conf = 0.9, mu, sigma, investment, holding)

compute_es <- function(.f, ..., conf = 0.9, n = 1000) {

  .f <- partial(.f, ...)
  conf_seq <- seq(conf, 1, length.out = n)
  map_dbl(conf_seq, ~ .f(conf = .x)) %>% mean()
}

#' Expected Shortfall for normally distributed geometric returns
#'
#' This function estimates the ES of P/L data assuming geometric returns
#' are normally distributed, for specified confidence level and holding period.
#' It does so by taking an average of the VaRs in the tail of the distribution.
#'
#' @inheritParams es_normal
#' @param investment          the size of investment
#' @return ES measure (numeric)

es_lognormal <- function(mu, sigma, investment, conf = 0.95, holding = 1) {

  conf <- seq(conf, 1, length.out = 1000)
  var_ln <- partial(var_lognormal, mu = mu, sigma = sigma, investment = investment, holding = holding)

  map_dbl(conf, ~ var_ln(conf = .x)) %>%
    mean()
}

#' Expected Shortall using the Cornish Fisher adjustment for non-normality
#'
#' Function estimates the ES for near normal P/L using the  Cornish Fisher
#' adjustment for non-normality for specified confidence level.
#'
#' @param mu        mean daily P/L data
#' @param sigma     standard deviation of daily P/L data
#' @param skew      skewness
#' @param kurt      kurtosis
#' @param conf      the confidence level (double)
#' @param holding   the holding period in days (double)
#'
#' @return ES measure (numeric)

es_cornishfisher <- function(mu, sigma, skew, kurt, conf = 0.95) {
  compute_es(var_cornishfisher, mu = mu, sigma = sigma, skew = skew, kurt = kurt, conf = conf)
}
