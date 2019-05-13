# Notes and Quotes from Measuring Market Risk 

## Coherent Risk Measures 
From coherent risk measures chapter:

> Thus the key to estimating any coherent risk measures is to be able to estimate quantiles or VaRs: the coherent risk measures can then be obtained as appropriately weighted averages of quantiles. From a practical point of view, this is extremely helpful as all the building blocks that go into quantile or VaR estimations - databases , calculation routines, etc. - are exactly what we need for the estimation of coherent risk measures as well. If an institution already has a VaR engine, then that engine needs only small adjustments to produce estimates of coherent risk measures: indeed, in many cases, all the needs changing is the last few lines of code in a long data processing system. *The costs of switching from VaR to more sophisticated risk measures are therefore very low.*

That last line is really of interest - it's easy to move from VaR to a coherent risk measure - so why not do it and what are the benefits of it? 

## Estimating Standard Errors of Coherent Risk Measures 

There's a chart on page 16 of FRM book one - Figure 1.9 - need to be able to easily recreate that chart. It's a very nice illustration of 1) the further into the tail you go, the larger the standard error becomes and 2) that a larger sample dramatically reduces the standard error. 

## Level of Analysis

Dowd makes a key point which is at what level do we want to do this analysis?

  * portfolio level
  * individual positions level

The portfolio level is much simpler - it is a univariate stochastic analysis because we just have one vector of returns: portfolio returns.

Modelling at the position level means we need a mutivariate stochastic framework. We need to use methods that incorporate the relationships between positions - covariance matrices, copulas and so on. `mmr` should include methods that can handle the univariate and the multivariate case. 

### API for portfolio level versus asset level

The API or a single asset portfolio with just one vector of returns has a number of options. 

Weighting of returns occurs in the VaR function as a parameter. This could be good or bad. 

```r
value_at_risk <- function(data, returns, alpha, method, weighting)

portfolio_returns %>% 
  value_at_risk(returns, alpha, method, weighting)
```

## Specifying the VaR Method

Specify the entire method name which refers to any distributions or weighting strategies in it:

```r
portfolio_returns %>% 
  value_at_risk(
    returns,
    alpha = 0.95, 
    method = "age weighted historical simulation"
  )
```

Although this is a horrendous API and would make it difficult/unclear on how to change parameters of the weighting functions. 

## Defaulting to Historical Simulation 

I think generally it's a good idea to default to using historical simulation. Then if the user specifies a distribution, it will use that distribution to estimate the paramaters and tail quantile.

## Specifying the Distribution 

Similar to the `glm` function which requires a link function, this could take a distribution argument.

```r
# logistic regression - a GLM with a binomial link fn
glm(y ~ x, data, link = binomial())

portfolio_returns %>% 
  value_at_risk(returns, 0.95, dist = normal())

portfolio_returns %>% 
  value_at_risk(returns, 0.95, dist = lognormal())
```

This would estimate the mean and variance from the data and then compute the VaR quantile using them. `normal` and `lognormal` are function factories returning functions that will do this for us. This makes it easy for others to add distributions they might want to use because they just need to write a distribution function that will:

  * estimate the paramaters they need from the data
  * estimate the quantile of that distribution with those parameters


## Specifying the Weighting Function

I think the best option is to pass a function into the weighting parameter:

```r
portfolio_returns %>% 
  value_at_risk(
    returns, 
    alpha = 0.05,
    weighting = weight_age(...)
  )

# Pass weight_age parameters and it returns a function 
# with those parameters that will output weights 
# (or maybe it should do the actual weighting?)

age_weighter <- weight_age(decay = 0.9)

# option 1 - just output the weights 
returns * age_weighter(length = length(returns))

# option 2 - have it take a vector and weight it appropriately
age_weighter(returns)

# or equivalently 
weight_age(decay = 0.9)(returns)
```

I quite like the second option. To be honest the weighting function could simply take either a vector to be weighted, or an length parameter that returns a vector of the actual weights. This might be confusing, but I think I like it regardless. 

Another nice property of this design is that then anyone can write a new weighting function that takes a vector of numbers and weights them however it wants. So yeah, I think this is the winner for this reason. 

## Working with Different Types of Vectors

One issue with these functions is that they are expecting equally spaced returns. What if the returns vector is a time series with uneven time spaces between each. The potentially add an option to reference the time series key,

```r
age_weighter(time_series = returns$date)
```

It would be as easy to write a generic function that does what you want for each different vector type. So you could do something like

```r
age_weighter.ts <- function(...) { 

  # return weighting vector according to ts
  ...
}
```

This makes it easy for users to write their own weighting functions. 

## API for Multi-Asset Portfolios 

OK so what would we do for this one - it would be nice if it was possible to use the same `value_at_risk` function and use selectors similar to the way `dplyr` does it. Like assume `portfolio_returns` has many columns of returns from different assets. `recipes` does this using functions like `all_predictors()` and `all_outcomes()`. `tidyselect` might offer some help here. 

Also what is the default behaviour when multiple columns are passed into the function? I guess if the method does not involve estimating variance-covariance matrices, then each column should just be considered independent and the same method should be used on each.

```r
portfolio_returns <- tibble(
  A = rnorm(100),
  B = rnorm(100, 0.05, 0.004),
  C = rnorm(100, 0.1, 0.01)
)

# Option 1 - long tidy output (similar to group_by method)

portfolio_returns %>% 
  value_at_risk(A:C, alpha = 0.01, method = "lognormal")

#> A tibble 3 x 2
#> asset       value_at_risk
#> <chr>       <dbl>
#>   A          0.45
#>   B          0.1
#>   C          0.5

# Option 2 - this might make sense... 
# probably should just match how yardstick does it

portfolio_returns %>% 
  value_at_risk(A:C, alpha = 0.01, method = "lognormal")

# Maybe

#> A tibble 1 x 3
#> <dbl>  <dbl>   <dbl>
#>   A      B      C
#>  0.45   0.1    0.5

# Or

#> A tibble 1 x 4
#> measure    A      B      C
#> <chr>    <dbl>  <dbl>   <dbl>
#>  VaR      0.45   0.1    0.5

```

The idea here is that we should respect the shape of the data that a user provides. So if they want to pass in return data in a long format, then they can just use `group_by` and call `value_at_risk` as normal. But if they want it in a wide format, then they get it in a wide format. 

Then when we have strategies for incorporating cross-correlations we can have:

```r
# correlation-weighted historical simulation
portfolio_returns %>% 
  value_at_risk(
    returns = A:C,
    alpha = 0.01,
    method = "historical simulation",
    weighting = weight_corr()
   ) 
```

## Bootstraps using `rsample` 

The other choice is whether to create methods that accept `rset` objects from `rsample` or to conceal this and do it all internally. Personally, I think the best option is to have `rset` methods. This way the user can clearly inspect each bootstrap and thus we are extending `rsample` rather than just leveraging it. 

```r
portfolio_returns %>% 
  bootstrap(times = 1000) %>% 
  value_at_risk(returns = splits, 0.01, "historical simulation")

#> A tibble 1000 x 2
#> splits                id            VaR
#> <list>               <chr>         <dbl>
#> <split [1000/312]>   Bootstrap1    0.05
#> <split [1000/297]>   Bootstrap2    0.77
#> ...
```

This seems like a nice way to do this. Although, why not the simplicity of this instead:

```r
portfolio_returns %>% 
  bootstrap(times = 1000) %>% 
  mutate(VaR = map(splits, value_at_risk(analysis(.x), 0.01)) %>% 
  unnest(VaR)
```

This is complicated... take the filtered historical simulation approach. How would we implement that in this framework?

```r
portfolio_returns %>% 
  bootstrap(times = 1000) %>% 
  value_at_risk(
    returns = A:C,
    alpha = 0.01,
    method = "historical simulation",
    weighting = weight_garch()
  )
```

The issue here is that the GARCH model should be fitted to the whole data, rather than the bootstrap samples. Complicate this again by having a multi-asset portfolio. 

Firstly `value_at_risk` would have to realise that it was being passed an `rset` object rather than a dataframe. Then it would have to extract the original data and train the multivarirate GARCH model. In this case `weight_garch` would have to pick up that it was being passed a matrix rather than a vector, and output all the bits needed for that. Then the GARCH model would be used in for weighting the bootstrapped samples and VaRs would be computed from them.

So I think ultimately it's best *not to mess with `rset` methods*. 

## Interpolating Between Points With Non-Parametric Models 

Also need to decide the best way best way to interpolate between data points when `alpha` sits between data points. Probably just do the linear interpolation way.

## Weighting Functions 

So I think actually a lot of this implementation will revolve around the weighting functions. I was confused by how a multivariate GARCH model would work in this context, but actually passing in a *function* that simply takes returns (in a dataframe or a matrix) and outputs those weighted returns mean that it's simple enough. Because let's say first we need to fit the GARCH model - well then that's the paramaters we pass our weighting function:

```r
garch_weighting <- portfolio_returns[1:3] %>% weight_garch()

portfolio_returns %>% 
  value_at_risk(A:C, 0.01, "historical simulation", garch_weighting)

# Equivalent to
portfolio_returns %>% 
  value_at_risk(A:C, 0.01, "historical simulation", weight_garch(.[1:3))
```

Is this enough though? We would need to check that the assets used to train the GARCH model existed in the data we were passing it. That's not that big a deal though. 

I think this fixes the issue with historical filtering approach because we can train the GARCH model independently, and then still use it in the bootstrap samples. So filtered historical simulation would look like this:

```r
garch <- weight_garch(portfolio_returns[1:3])
fhs <- portfolio_returns %>% 
  bootstrap(times = 1000) %>% 
  mutate(
    VaR = map(splits, 
      ~ value_at_risk(analysis(.x), 0.01, "historical", garch)
  ) %>% 
  unnest(VaR)

# A histogram of 
fhs %>% 
  ggplot(aes(VaR)) + 
  geom_histogram() + 
  theme_minimal()
```

This seems like a flexible enough API that it might work well.

## Standard Errors 

Have to include standard errors in these results. Simple solution is just to include the columns in the tibble:

```r 
# tibble with VaR and SE columns 
```

## Explanatory `summary` functions

While we want to keep output tidy in dataframes, there's a lot to be said for word explanations. For example, working through a delta-normal VaR example the final paragraph reads:

> This suggests that the loss will only exceed €1,324,800 once every 100 10-day periods. This is approximately once every 1,000 trading days or once every four years assuming 250 trading days a year

This would be over the top as an informative message, but being able to explain the computed VaR in money and day terms is a positive user experience. 

## References 

General text reference:

  * Measuring Market Risk, Dowd

Specific papers:

  * On multivariate extensions of Value-at-Risk. Cousin, Di Bernardino. 
  * Coherent risk measures under filtered historical simulation. Giannopoulos, Tunaru (2004).
    * https://pdfs.semanticscholar.org/9960/f6d6ad12a642182102151e68dcb25e0e1202.pdf
  * Spectral measures of risk: A coherent representation of subjective risk aversion
    * https://pdfs.semanticscholar.org/fafb/750be70a9853883a0d257da1352c202709ec.pdf


