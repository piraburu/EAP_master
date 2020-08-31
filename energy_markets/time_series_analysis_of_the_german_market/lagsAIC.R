lagsAIC <- function(series, order, trend=F) {
  series <- ts(series)
  library(dynlm)      # dynlm() included in this library
  source("aic.R")     # a function I have created to calculate Akaike
  # loop AIC over models of different orders
  if (trend) {
    t <- c(0:(length(series)-1))
    AICs <- sapply(order, function(x)
      "AR" = aic(dynlm(series ~ L(series, 1:x) + t)))
  } else {
    AICs <- sapply(order, function(x)
      "AR" = aic(dynlm(series ~ L(series, 1:x))))
  }
  # Para comprobar qué estoy haciendo:
  ##summary(dynlm(series ~ L(series, 4)))
  ##lagp <- lag(series, -1)
  ##lagp2 <- lag(series, -2)
  ##lagp3 <- lag(series, -3)
  ##View(cbind(series, lagp, lagp2, lagp3))
  ##summary(dynlm(series ~ lagp))
  ##aic(dynlm(series ~ lagp))
  ##AICs
  ##summary(dynlm(series ~ lagp + lagp2))
  ##show(aic(dynlm(series ~ lagp + lagp2)))
  ##AICs
  ##summary(dynlm(series ~ lagp + lagp2 + lagp3))
  ##aic(dynlm(series ~ lagp + lagp2 + lagp3))
  ##AICs

  return("lags" = order[which.min(AICs)]) # Returns the optimal number of lags
}