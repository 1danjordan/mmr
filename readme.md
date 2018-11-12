# Measuring Market Risk

The mmr (Measuring Market Risk) package ports the Matlab code associated with Kevin Dowd's Measuring Market Risk (2002) to R, as well as adding some functions mentioned in the text but not implemented in Matlab. Dowd provides the motivation for this package in his preface via a quote:

> You are responsible for managing your company’s foreign exchange positions. Your boss, or your boss’s boss, has been reading about derivatives losses suffered by other companies, and wants to know if the same thing could happen to his company. That is, he wants to know just how much market risk the company is taking. What do you say? You could start by listing and describing the company’s positions, but this isn’t likely to be helpful unless there are only a handful. Even then, it helps only if your superiors understand all of the positions and instruments, and the risks inherent in each. Or you could talk about the portfolio’s sensitivities, i.e., how much the value of the portfolio changes when various underlying market rates or prices change, and perhaps option delta’s and gamma’s. However, you are unlikely to win favour with your superiors by putting them to sleep. Even if you are confident in your ability to explain these in English, you still have no natural way to net the risk of your short position in Deutsche marks against the long position in Dutch guilders. ... You could simply assure your superiors that you never speculate but rather use derivatives only to hedge, but they understand that this statement is vacuous. They know that the word ‘hedge’ is so ill-defined and flexible that virtually any transaction can be characterized as a hedge. So what do you say? ... Perhaps the best answer starts: ‘The value at risk is ...’”. (Linsmeier and Pearson (1996))

The package is written in a functional style using `purrr`. And to take a quote from Dowd himself:

> As always in risk measurement, we should keep our wits about us and not be too trusting of the software we use or the results we get.

So I ask users to do the same of my own work. Any issues or pull requests are welcome. 

# To Do

Vignette where we use multiple VaR functions to estimate VaR for the same portfolio returns. Do this by creating a list of functions, and mapping over the functions. Then we can gather the wide data frame and plot very easily. Use partials in the list of functions. 

Example showing sub-additivity of ES and where VaR is not sub-additive.

Potentially use `tsibble`? 

Theme this package around *tidy risk analysis* - so make it simple to:

  * import data (using API)
  * define risk measure (VaR, ES, etc.)
  * apply risk measure functions to data
  * plot results 

Doing this analysis should be super easy using the tools the tidyverse has given us.

Think about API - there's many types of  VaR and ES. Should there be one VaR and function with an argument to specify which VaR measure like `value_at_risk(x, type = "normal")` or should we have a function for every type of VaR like `var_normal(x)`? I'm leaning towards the first...  
