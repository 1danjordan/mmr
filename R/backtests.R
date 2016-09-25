#' Binomial Test (Kupiec Test/Frequency-of-tail-losses Test)
#'
#' Kupiec test carries out the binomial backtest for a VaR
#' risk measurement model, for specified VaR confidenve level,
#' for a one sided hypothesis test.
#'
#' @param x     the number of tail losses
#' @param n     the number of observations
#' @param conf  the level of confidence
#'
#' @return probability model is correct (numeric)

test_kupiec <- function(x, n, conf) {
  if(x >= n*p) {
    1 - pbinom(x - 1, n, 1 - conf)
  } else {
    pbinom(x, n, 1 - conf)
  }
}

#' Christoffersen Conditional Backtesting Approach
#'



#' Jarque Bera Backtest
#'
#' @param n     the number of observations
#' @param skew  the sample skewness
#' @param kurt  the sample kurtosis

test_jb <- function() {
  jb_t_stat <- (n / 6) * (s ^ 2 + (k - 3) ^ 2 / 4)
  p_stat <-  1 - pchisq(jb_t_stat, 2)

  list("Test Statistic" = jb_t_stat, "P value" = p_stat)
}

