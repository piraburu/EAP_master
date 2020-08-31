#
# ENERGY MARKETS: Homework #2
#
# Author: Pedro Iraburu Muñoz
# 2020
#
# Master in Economics: Empirical Applications and Policies
# Energy Markets
#######################################################

# Clearing the Memory
rm(list = ls()) 

# Reading data

library(readxl) 
data_2011_6 <- read_excel("6_2011.xls")
data_2012_6 <- read_excel("6_2012.xls")
data_2013_6 <- read_excel("6_2013.xls")
data_2014_6 <- read_excel("6_2014.xls")

data_2011_9 <- read_excel("9_2011.xls")
data_2012_9 <- read_excel("9_2012.xls")
data_2013_9 <- read_excel("9_2013.xls")
data_2014_9 <- read_excel("9_2014.xls")

# Function for printing graphs

grafic <- function(input){
  input$Q <- as.numeric(input$...6)
  input$P <- as.numeric(input$...7)
  input$B <- input$...8
  input <- subset(input,...5=="V")
  input <- input[order(input$P),]
  
  #### COMPLEX_BIDS ---------
  V_C <- subset(input, B=="C")
  # Making the cum. quantities column
  V_C$CUM <-  V_C$Q
  for (i in 1:length(V_C$Q)) {
    if(i==1){
      V_C$CUM[i] <- V_C$Q[i]
    }
    else{
      V_C$CUM[i] <-V_C$CUM[i-1]+ V_C$Q[i]
    }
  }

  #### SIMPLE BIDS ----- 
  V_O <- subset(input, B=="O")
 
  # Making the cum. quantities column
  V_O$CUM <-  V_O$Q
  for (i in 1:length(V_O$Q)) {
    if(i==1){
      V_O$CUM[i] <- V_O$Q[i]
    }
    else{
      V_O$CUM[i] <-V_O$CUM[i-1]+ V_O$Q[i]
    }
  }
  
  jpeg(file="simple.jpg")

  plot(V_O$CUM, V_O$P, main="Supply curve for simple bids",
       xlab='Mwh', ylab="???/Mwh",type="l", col="blue", lwd=1.3)
  dev.off()
  
  jpeg(file="complex.jpg")
  plot(V_C$CUM, V_C$P, main="Supply curve for complex bids",
       xlab='Mwh', ylab="???/Mwh", col="red")
  dev.off()
}

# Function for getting the results for the table
# in the follwing order: sqr R, Tot Q, first for
# the complex bids, second for the simple bids
# I also added the slope (5th and 6th) first simple
# then conplex

R <- function(input){
  input$Q <- as.numeric(input$...6)
  input$P <- as.numeric(input$...7)
  input$B <- input$...8
  input <- subset(input,...5=="V")
  input <- input[order(input$P),]
  
  #### COMPLEX_BIDS ---------
  V_C <- subset(input, B=="C")
  # QUANTITY SUM WHEN P=0
  V_C_q <- subset(V_C, P==0)
  Q <- sum(V_C_q$Q)
  
  # REGRESSION WHEN P!=0
  V_C_r <- subset(V_C, P!=0)
  
  # Making the cum. quantities column
  V_C_r$CUM <-  V_C_r$Q
  for (i in 1:length(V_C_r$Q)) {
    if(i==1){
      V_C_r$CUM[i] <- V_C_r$Q[i]
    }
    
    else{
      V_C_r$CUM[i] <-V_C_r$CUM[i-1]+ V_C_r$Q[i]
    }
  }
  
  # regression 
  Reg <- lm(data = V_C_r, formula = P ~ CUM)
  
  R <- summary(Reg) # regression summary
  R$r.squared
  results <- c(1,2,3,4,5,6)
  results[1] <- R$r.squared
  results[2] <- Q
  results[6] <- R$coefficients[2,1]
  
  #### SIMPLE BIDS ----- 
  V_O <- subset(input, B=="O")
  # QUANTITY SUM WHEN P=0
  V_O_q <- subset(V_O, P==0)
  Q <- sum(V_O_q$Q)
  
  
  # REGRESSION WHEN P!=0
  V_O_r <- subset(V_O, P!=0)
  
  # Making the cum. quantities column
  V_O_r$CUM <-  V_O_r$Q
  for (i in 1:length(V_O_r$Q)) {
    if(i==1){
      V_O_r$CUM[i] <- V_O_r$Q[i]
    }
    
    else{
      V_O_r$CUM[i] <-V_O_r$CUM[i-1]+ V_O_r$Q[i]
    }
  }
  
  # regression 
  Reg <- lm(data = V_O_r, formula = P ~ CUM)
  
  R <- summary(Reg) # regression summary
  R$r.squared
  
  results[3] <- R$r.squared
  results[4] <- Q
  results[5] <- R$coefficients[2,1]
  return(results)
}


## TABLE RESULTS

R(input=data_2011_6)
R(input=data_2012_6)
R(input=data_2013_6)
R(input=data_2014_6)

R(input=data_2011_9)
R(input=data_2012_9)
R(input=data_2013_9)
R(input=data_2014_9)


## GRAPHS

grafic(input=data_2011_6)
grafic(input=data_2012_6)
grafic(input=data_2013_6)
grafic(input=data_2014_6)

grafic(input=data_2011_9)
grafic(input=data_2012_9)
grafic(input=data_2013_9)
grafic(input=data_2014_9)
