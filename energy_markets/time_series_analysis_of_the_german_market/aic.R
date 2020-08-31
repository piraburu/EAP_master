aic <- function(model) {
  
  ssr <- sum(model$residuals^2)
  t <- length(model$residuals)
  npar <- length(model$coef)
  
  return(
    "AIC" = log(ssr/t) + npar * 2/t
  )
}