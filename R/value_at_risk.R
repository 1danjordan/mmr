#' Value at Risk
#'
#' Estimate a various parameteric and non-parametric value at risk
#' measures
#'
#' @param data      a dataframe of returns
#' @param ...       unquoted column names to use in computation
#' @param alpha     1 - confidence level
#' @param method    the method for computing VAR
#' @param weighting a function for weighting returns
#' @param params    a list of named parameters for specific methods
#'
#' @examples
#' # compute 5% VaR for the corporate portfolio
#' portfolio_returns %>%
#'   filter(portfolio == "corporate") %>%
#'   value_at_risk(
#'     returns,
#'     alpha = 0.05,
#'     method = "historical simulation"
#'   )
#'
#' # Compute 1% VaR for each portfolio
#' portfolio_returns %>%
#'   group_by(portfolio) %>%
#'   value_at_risk(
#'     returns,
#'     alpha = 0.01,
#'     method = "historical simulation",
#'     weighting = weight_vol(decay = 0.01)
#'   )

value_at_risk <- function(x) {
  UseMethod("value_at_risk")
}

value_at_risk.data.frame <- function(data, ..., method, weighting, params) {

}

value_at_risk.grouped_df <- function(data, ..., method, weighting, params) {
  dplyr::summarise(
    data,
    ...
  )
}

value_at_risk.numeric <- function(x, method, params) {

}

# Convert matrices to a data frame and dispatch to the dataframe method

value_at_risk.matrix <- function(x, ..., method, weighting, params) {
  df <- as.data.frame(x)
  value_at_risk(df, ..., method, weighting, params)
}

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
#' @return VaR measure (numeric)

var_historical <- function(x, conf = 0.95) {

  quantile(-x, probs = 1 - conf, na.rm = TRUE, names = FALSE)

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
#'
#' @return VaR measure (numeric)


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
#'
#' @return VaR measure (numeric)

var_lognormal <- function(mu, sigma, investment, conf = 0.95, holding = 1) {

  investment * (1 - exp(-var_normal(mu, sigma, conf, holding)))

}

var_cornishfisher <- function(mu, sigma, skew, kurt, conf = 0.95) {

  z <- quantile(1 - conf)
  adj <- (1/6) * (z ^ 2 - 1) + (1 / 24)*(z ^ 3 - 3 * z) * (kurt - 3) - (1 / 36) * (2 * z ^ 3 - 5 * z) * skew ^ 2
  -sigma* (z + adj) - mu

}
