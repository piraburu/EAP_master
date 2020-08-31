#
# Introductory R Course: Homework 
#
# Author: Pedro Iraburu Muñoz
# 2019
#
# Master in Economics: Empirical Applications and Policies
# Quantitative Methods and Time Series

####################################################################################################################
####################################################################################################################
#https://rpubs.com/heruwiryanto/multinom-reg
#https://www.tutorialgateway.org/r-ggplot2-dot-plot/
#https://stats.idre.ucla.edu/r/dae/logit-regression/


# 1. PRELIMINARIES ---------------------------------

# Clearing memory
rm(list = ls())

# Working directory
#setwd("C:/Users/pimpeter/Desktop/Quantitative Methods")

# Reading the data
data <- read.csv(file="data2.csv", header=TRUE, sep=",", dec=".") 

#Loading the libraries
library("stargazer")                   #package for latex output
library("pastecs")
library("ggplot2")
library("doBy")
library("lmtest")
library("aod")
library("margins")
library("lmtest")
# 2. Descriptive data analysis  ---------------------------------

# Basic statistics
summary(data)


# Checking if there are nas, and how many: missing count
sum(is.na(data))


# eliminating rows with nas
data <- data[complete.cases(data),]


# Number of rows: count
nrow(data)


# Class of each column
sapply(data,class)


# Classifying non-numeric variables 
dummies <- c("Weekend", "Revenue")
categ <- c("VisitorType", "Month", "TrafficType", "Region", "Browser","OperatingSystems")


data.dummies <- data[,dummies]
data.categ <- data[,categ]
data.num <- data[,-c(10:18)] # selecting just the numeric variables


# Summary Statistics
stargazer(data.num)
summary(data.num)
stat.desc(data.num)


# DUMMY VAR #1
ggplot(data.frame(data.dummies$Weekend), aes(x=data.dummies$Weekend)) +
  geom_bar(aes(y = (..count..)/sum(..count..))) + ggtitle("Fig.1: Weekend Distribution") +xlab("Weekend") 
+ ylab("Percentage")

# DUMMY VAR #2
ggplot(data.frame(data.dummies$Revenue), aes(x=data.dummies$Revenue)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))


# CATEG VAR #1
ggplot(data.frame(data.categ$VisitorType), aes(x=data.categ$VisitorType)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))


# CATEG VAR #2
ggplot(data.frame(data.categ$Month), aes(x=data.categ$Month)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))

# CATEG VAR #3
ggplot(data.frame(data.categ$TrafficType), aes(x=data.categ$TrafficType)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))

# CATEG VAR #4
ggplot(data.frame(data.categ$Region), aes(x=data.categ$Region)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))

# CATEG VAR #5
ggplot(data.frame(data.categ$Browser), aes(x=data.categ$Browser)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))

# CATEG VAR #6
ggplot(data.frame(data.categ$OperatingSystems), aes(x=data.categ$OperatingSystems)) +
  geom_bar(aes(y = (..count..)/sum(..count..)))

# Another table to check how many purchases each month have
summaryBy(Revenue ~ Month, FUN=sum, data=data)

# 3. A simple regression  ---------------------------------

# As we have a dataset suited for a logit/probit regression:

logit <- glm(Revenue ~ Informational_Duration + BounceRates + ExitRates+PageValues+OperatingSystems+Browser+VisitorType+Month, data = data, family = "binomial"(link = "logit"))  
summary(logit)

# Cleaning the database for the regression:

# Assigning numerical values to the "Visitor" variable (from categorical to dummy)
data$visitor <- as.numeric(data$VisitorType=="Returning_Visitor")

# Computing the regression:

logit <- glm(Revenue ~ Informational_Duration + BounceRates + ExitRates+PageValues+OperatingSystems+Browser+VisitorType+Month, data = data, family = "binomial"(link = "logit"))  
summary(logit)

# Not all months are relevant, we make a variable for those which are:
# Dec, feb, mar, may, nov

data$relev_months_neg <- as.numeric(data$Month=="Dec"|data$Month=="Feb"
                                |data$Month=="Mar"|data$Month=="May")
data$relev_months_pos <- as.numeric(data$Month=="Nov")

# Making the new regression, this time without "Browser", "visitor" and "Bounce Rates", as they are not a
# relevant variable at \alpha=0.05:

logit <- glm(Revenue ~ Informational_Duration+  ExitRates+PageValues+OperatingSystems+relev_months_pos+relev_months_neg, data = data, family = "binomial"(link = "logit"))  
summary(logit)

# Once again, another variable is not significant at \alpha=0.05:"Operating System"

logit <- glm(Revenue ~ Informational_Duration+  ExitRates+PageValues+relev_months_pos+relev_months_neg, data = data, family = "binomial"(link = "logit"))  
summary(logit)

# We can also comput the probit model:
probit <- glm(Revenue ~ Informational_Duration+  ExitRates+PageValues+relev_months_pos+relev_months_neg, data = data, family = binomial(link = "probit"))
summary(probit)

# The coefficients differ because of the assumption of the Var(e), 1 for probit, 
# and \pi^2/3 for the logit.

# We cannot interpret the numerical value coefficients, although the signs of those
# tell us if the effect is positive or negative on the probability of buying


# Regression output for latex:
stargazer(logit, probit, title="Results", align=TRUE)

### Making a few tests

# Wald test for Operating systems 

logit.w <- glm(Revenue ~ Informational_Duration +  ExitRates + PageValues
               +OperatingSystems+relev_months_pos+relev_months_neg, 
               data = data, family = "binomial"(link = "logit"))  
summary(logit.w)
wald.test(b=coef(logit.w), Sigma=vcov(logit.w), Terms = 5)

# Not relevant at \alpha=0.05



# We can test the same H_0 by LR test #
# Full model #
NR <- glm(Revenue ~ Informational_Duration+  ExitRates+PageValues+OperatingSystems+relev_months_pos+relev_months_neg, data = data, family = "binomial"(link = "logit"))  

# Restricted model #

R <-  glm(Revenue ~ Informational_Duration+  ExitRates+PageValues+relev_months_pos+relev_months_neg, data = data, family = "binomial"(link = "logit"))  


library(lmtest)
# LR test #
lrtest.default(NR,R)

#(LR = 3.8393, df = 1, p < .05006) we accept null hypothesis

# Checking if there is MultiCollinearity with the VIF function:

vif <-function(regression){
  n1=length(regression$coefficients)-1                    # Length of coefficients (minus the constant)
  n2=length(regression$residuals)                         # Length of residuals
  n3=length(regression$coefficients)-2                    # length of coefficients for the aux. regression
  output<-matrix(,n2,n1)                                  # empty matrix for the output
  r<-matrix(,n1)                                     
  i=2
  for(var in 1:n1){
    a=unlist(model.frame(regression)[i], use.names=FALSE)  #creates an output with all the variables
    output[,var]=a
    i=i+1
  }
  for(j in 1:n1){
    output_2=output[,-j]  
    if(n3==1){
      reg=paste("lm(formula = output[,",j,"]~output_2)")
    }
    if(n3>1){
      reg=paste("lm(formula = output[,",j,"]~output_2[,1]")
      for(k in 2:n3){
        reg=paste(reg,"+output_2[,",k,"]")
        if(k==n3){
          reg=paste(reg,")")
        }
      }
    }
    r[j]=summary(eval(parse(text=reg)))$r.squared
  }
  vif=matrix(,n1)
  for(k in 1:n1){
    vif[k]=1/(1-r[k])
  }
  return(vif)
}
vif(logit)


### GRAPHICAL REPRESENTATION

# Dotplot of the probabilities
logit <- glm(Revenue ~ Informational_Duration + ExitRates + PageValues
             + relev_months_pos+relev_months_neg, data = data, 
             family = "binomial"(link = "logit"))  
summary(logit)
prlogit <- logit$fitted.values
summary(prlogit)
ggplot(logit, aes(x = prlogit)) +geom_dotplot(dotsize = 0.0080, stackdir = "up")
histogram(prlogit)

# Change axis to reflect actual count, very difficult using ggplot2:
# https://stackoverflow.com/questions/49330742/change-y-axis-of-dot-plot-to-reflect-actual-count-using-geom-dotplot/54499877
# https://github.com/tidyverse/ggplot2/issues/2203



#####  INTERPRETATION TABLE OF PR CHANGES


# Benchmark:
newdata <- data.frame(
  Informational_Duration <- median(data$Informational_Duration),
  ExitRates              <-  median(data$ExitRates),
  PageValues             <-  median(data$PageValues),
  relev_months_pos       <- 0,
  relev_months_neg       <- 0
)

benchmark_prob  <- predict(logit, newdata,type="response")
benchmark_prob

inform <- data.frame(
  Informational_Duration <- median(data$Informational_Duration)+ var(data$Informational_Duration)^(1/2),
  ExitRates              <-  median(data$ExitRates),
  PageValues             <-  median(data$PageValues),
  relev_months_pos       <- 0,
  relev_months_neg       <- 0
)

inform_prob     <- predict(logit, inform,type="response")
inform_prob

exit <- data.frame(
  Informational_Duration <- median(data$Informational_Duration),
  ExitRates              <-  median(data$ExitRates)+ var(data$ExitRates)^(1/2),
  PageValues             <-  median(data$PageValues),
  relev_months_pos       <- 0,
  relev_months_neg       <- 0
)
exit_prob       <- predict(logit, exit,type="response")
exit_prob

page <- data.frame(
  Informational_Duration <- median(data$Informational_Duration),
  ExitRates              <-  median(data$ExitRates),
  PageValues             <-  median(data$PageValues)+ var(data$PageValues)^(1/2),
  relev_months_pos       <- 0,
  relev_months_neg       <- 0
)
page_prob       <- predict(logit, page,type="response")
page_prob

months_p <- data.frame(
  Informational_Duration <- median(data$Informational_Duration),
  ExitRates              <-  median(data$ExitRates),
  PageValues             <-  median(data$PageValues),
  relev_months_pos       <- 1,
  relev_months_neg       <- 0
)
monthsp_prob    <- predict(logit, months_p,type="response")
monthsp_prob

months_n <- data.frame(
  Informational_Duration <- median(data$Informational_Duration),
  ExitRates              <-  median(data$ExitRates),
  PageValues             <-  median(data$PageValues),
  relev_months_pos       <- 0,
  relev_months_neg       <- 1 
)
monthsn_prob    <- predict(logit, months_n,type="response")
monthsn_prob

 
# Changes in probabilities:

# if page increases its sd
inform_prob  - benchmark_prob  
# if page increases its sd
exit_prob    - benchmark_prob 
# if page increases its sd
page_prob    - benchmark_prob
# if page increases its sd
monthsp_prob - benchmark_prob
# if page months_p
monthsn_prob - benchmark_prob


#####  Marginal Changes

library("margins")
average.marginal.change <- margins(logit)
average.marginal.change


#  CDF

# Coefficients
b0                     <- logit$coef[1] # intercept
Informational_Duration <- logit$coef[2]
ExitRates              <- logit$coef[3]
PageValues             <- logit$coef[4]
relev_months_pos       <- logit$coef[5]
relev_months_neg       <- logit$coef[6]

# Range of the indep. variable
X_range <- seq(from=min(data$ExitRates ), to=max(data$ExitRates ), by=.01)

# Values
a_logits <- b0 + 
  Informational_Duration*mean(data$Informational_Duration) + 
  ExitRates*X_range + 
  PageValues*mean(data$PageValues) + 
  relev_months_pos*0 + 
  relev_months_neg*0 

#Probabilities
a_probs <- exp(a_logits)/(1 + exp(a_logits))

# Plotting CDF
plot(X_range, a_probs, 
     ylim=c(0,1),
     type="l", 
     lwd=3, 
     lty=2, 
     col="gold", 
     xlab="ExitRates", ylab="P(outcome)", main="Probability of Revenue")


#_____________





