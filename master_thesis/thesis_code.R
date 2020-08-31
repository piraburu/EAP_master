## MASTER THESIS SCRIPT
## EAP MASTER 2019-2020
## AUTHOR: PEDRO IRABURU 
## TUTOR:  PETR MARIEL

### 1) PACKAGES -----------------------------------------------------------------------------------------------------------
#
# DESCRIPTION: this section includes all the necessary packages used in the script.
#
# Preliminaries      
rm(list = ls())                                         # Clear workspace
setwd("C:/Users/pimpeter/Desktop/TFM/PISA/intsvy")      # Directory

# Packages
library("gtable")               # for the custom table of the figures
library("grid")                 # for the custom table of the figures
library("gridExtra")            # for the custom table of the figures
library("intsvy")               # for the custom table of the figures
library("foreign")              # for the data manipulation
library("nnet")                 # for the model estimation
library("VGAM")                 # for the model estimation
library("dplyr")                # for the data manipulation
library("stargazer")            # for the latex tables
library("lmtest")               # for the data manipulation
library("tidyverse")            # for the data manipulation

#### 2) DATA IMPORT -------------------------------------------------------------------------------------------------------
#
# DESCRIPTION: this section includes the data import. Line 37 onwards, are only included to show how the 
#              initial database was created.
#

# Loading the database
load("pisa12_can.RData")                    # or
pisa12 <- read.delim("pisa12_can.txt")

# Importing the data using the intsvy package: PISA2012

pisa12 <- pisa.select.merge(folder = getwd(),
                            student.file="student.sav",                                     # name of the student file
                            school.file="school.sav",                                       # name of the school file
                            student= c("LANGN","MISCED", "FISCED","ST19Q01", "ST15Q01",     # variables imported (student)
                                       "FAMSTRUC", "ST11Q03", "ST11Q04", "ST11Q05",
                                       "CULTPOS", "MISCED", "FISCED", "WEALTH","HEDRES",
                                       "HISEI"),
                            school = c("STRATUM", "SUBNATIO","SCHLTYPE", "NC", "SC03Q01"),  # variables imported (school)
                            countries = c("CAN"))                             # countries imported

# Saving the data file
save(pisa12_can, file = "pisa12_can.RData")


# Saving as .txt
write.table(pisa12, "pisa12_can.txt", append = FALSE, sep = " ", dec = ".",
            row.names = TRUE, col.names = TRUE)

# Saving as .csv
write.csv(pisa12,'pisa12_can.csv')

##### 3) DATA MANIPULATION ------------------------------------------------------------------------------------------------
#
# DESCRIPTION: this section includes all the necessary data manipulation to properly make the models.
#

# Data subset for Canada only

CAN                 <- subset(pisa12, CNT=="CAN")


# Constructing dummies that discriminates by language: french or english

CAN$french_schools  <- as.numeric(CAN$STRATUM=="CAN0325"|CAN$STRATUM=="CAN0326"|CAN$STRATUM=="CAN0435"|
                       CAN$STRATUM=="CAN0436"|CAN$STRATUM=="CAN0437"| CAN$STRATUM=="CAN0545"|CAN$STRATUM=="CAN0546"|
                       CAN$STRATUM=="CAN0547"| CAN$STRATUM=="CAN0655"|CAN$STRATUM=="CAN0656"|CAN$STRATUM=="CAN0657"|
                       CAN$STRATUM=="CAN0765"|CAN$STRATUM=="CAN0766"|CAN$STRATUM=="CAN0875"| CAN$STRATUM=="CAN0876"|
                       CAN$STRATUM=="CAN0985"|CAN$STRATUM=="CAN0986"|CAN$STRATUM=="CAN1095"|CAN$STRATUM=="CAN1096")

CAN$english_schools <- as.numeric(CAN$STRATUM=="CAN0320"|CAN$STRATUM=="CAN0321"|CAN$STRATUM=="CAN0322"|
                       CAN$STRATUM=="CAN0430"|CAN$STRATUM=="CAN0431"|CAN$STRATUM=="CAN0540"|CAN$STRATUM=="CAN0541"|
                       CAN$STRATUM=="CAN0542"|CAN$STRATUM=="CAN0543"|CAN$STRATUM=="CAN0651"|CAN$STRATUM=="CAN0652"|
                       CAN$STRATUM=="CAN0760"|CAN$STRATUM=="CAN0761"|CAN$STRATUM=="CAN0762"|CAN$STRATUM=="CAN0870"|
                       CAN$STRATUM=="CAN0871"|CAN$STRATUM=="CAN0872"|CAN$STRATUM=="CAN0980"|CAN$STRATUM=="CAN0981"|
                       CAN$STRATUM=="CAN0982"|CAN$STRATUM=="CAN1091"|CAN$STRATUM=="CAN1092")


# Setting the values of the dependent variable: 
#                                              1: PUBLIC ENGLISH
#                                              2: PRIVATE ENGLISH
#                                              3: PUBLIC FRENCH
#                                              4: PRIVATE ENGLISH

CAN$dependent_var                                                                                    <- 0
CAN$dependent_var[CAN$english_schools==1 & CAN$SCHLTYPE==3]                                          <- 1
CAN$dependent_var[CAN$english_schools==1 & CAN$SCHLTYPE==1|CAN$english_schools==1 & CAN$SCHLTYPE==2] <- 2
CAN$dependent_var[CAN$french_schools==1 & CAN$SCHLTYPE==3]                                           <- 3
CAN$dependent_var[CAN$french_schools==1 & CAN$SCHLTYPE==1|CAN$english_schools==1 & CAN$SCHLTYPE==2]  <- 4

# Selecting only the data that distinguishes schools by language
# and deleting NAs

data <- CAN[CAN$dependent_var!=0,]
data <- data[data$WEALTH!=9999,] 
data <- data[data$CULTPOS!=9999,] 
data <- data[data$HISEI!=9999,]

# Transforming to a categorical variable

data$dependent_var <- as.factor(data$dependent_var)

# Constructing the independent variables

data$FEDUC             <- data$FISCED                                  # Education level of the father
data$MEDUC             <- data$MISCED                                  # Education level of the mother
data$OCUP_STATUS       <- data$HISEI                                   # Status of the highest ranking occupation 
data$FNWORKING         <- as.numeric(data$ST19Q01!=1)                  # Father not working=1
data$MNWORKING         <- as.numeric(data$ST15Q01!=1)                  # Mother not working=1
data$TWOPARENTS        <- as.numeric(data$FAMSTRUC==2)                 # Two parents in the Household=1
data$SIBLINGS          <- as.numeric(data$ST11Q03==1|data$ST11Q04==1)  # Siblings in the Household=1
data$GRANDPARENTS      <- as.numeric(data$ST11Q05==1)                  # Grandparents in the Household=1
data$HOME_LANG_NOT_ENG <- as.numeric(data$LANGN!="313")                # Language spoken in the HH, if not english, =1

# Setting the provinces as dummies:

data$QUEBEC        <- as.numeric(data$STRATUM=="CAN0540"|data$STRATUM=="CAN0541"|data$STRATUM=="CAN0542"|
                                 data$STRATUM=="CAN0543"|data$STRATUM=="CAN0545"|data$STRATUM=="CAN0546"|
                                 data$STRATUM=="CAN0547")

data$NBRUNSWICK    <- as.numeric(data$STRATUM=="CAN0430"|data$STRATUM=="CAN0431"|data$STRATUM=="CAN0435"|
                                 data$STRATUM=="CAN0436"|
                                 data$STRATUM=="CAN0437")

data$NEWFOUNDL     <- as.numeric(data$STRATUM=="CAN0101"|data$STRATUM=="CAN0102"|data$STRATUM=="CAN0103"|
                                 data$STRATUM=="CAN0104")

data$PRINCEEDISLE  <- as.numeric(data$STRATUM=="CAN0211"|data$STRATUM=="CAN0212"|data$STRATUM=="CAN0213")

data$NOVASCOTIA    <- as.numeric(data$STRATUM=="CAN0321"|data$STRATUM=="CAN0322"|data$STRATUM=="CAN0323"|
                                 data$STRATUM=="CAN0326"|data$STRATUM=="CAN0327")

data$ONTARIO       <- as.numeric(data$STRATUM=="CAN0652"|data$STRATUM=="CAN0653"|data$STRATUM=="CAN0655"|
                                 data$STRATUM=="CAN0656"|data$STRATUM=="CAN0657"|data$STRATUM=="CAN0658")

data$MANITOBA      <- as.numeric(data$STRATUM=="CAN0761"|data$STRATUM=="CAN0762"|data$STRATUM=="CAN0763"|
                                 data$STRATUM=="CAN0764"|data$STRATUM=="CAN0765"|data$STRATUM=="CAN0766"|
                                 data$STRATUM=="CAN0767")

data$SASKET        <- as.numeric(data$STRATUM=="CAN0871"|data$STRATUM=="CAN0872"|data$STRATUM=="CAN0873"|
                                 data$STRATUM=="CAN0874"|data$STRATUM=="CAN0876"|data$STRATUM=="CAN0877")

data$ALBERTA       <- as.numeric(data$STRATUM=="CAN0982"|data$STRATUM=="CAN0983"|data$STRATUM=="CAN0984"|
                                 data$STRATUM=="CAN0985"|data$STRATUM=="CAN0986"|data$STRATUM=="CAN0987")

data$BCOL          <- as.numeric(data$STRATUM=="CAN1092"|data$STRATUM=="CAN1093"|data$STRATUM=="CAN1094"|
                                 data$STRATUM=="CAN1096"|data$STRATUM=="CAN1097")

# Subsets of data for each model:
#                                -data1: corresponding for the first model (all 4 types)
#                                -data2: corresponding for the second model (only public)

data1 <- data[data$QUEBEC==1|data$MANITOBA==1|data$SASKET==1|data$BCOL==1,]
#
data2 <- data[data$NOVASCOTIA==1|data$ALBERTA==1|data$NBRUNSWICK==1|data$ONTARIO==1,] 
data2 <- data2[data2$dependent_var!=4 & data2$dependent_var!=2,] 




###### 4) THE MODELS ------------------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
# -In this section there are three models, one just for analyzing the provinces effect, and the other two for the 
# analysis of the language: "model1" and "model2". The first one includes all the provinces that have all four
# types of schools as potential outcomes. The second one only has those that only distinguishes between public
# french and public english.
#
# -I use two packages for the multilogit regression, one for instant visualization, which is the 
# first one; and another one for displaying the results in Latex code ("modelx.table").
#

### Model with all the provinces (only done in one package, for latex visualization.)

model.provinces <- multinom(formula= dependent_var ~  MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                          + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS+HOME_LANG_NOT_ENG+
                            NBRUNSWICK + ONTARIO+ QUEBEC + MANITOBA + SASKET+BCOL, data = data)

# For Latex:
stargazer(model.provinces,  title="Regression Results",omit.stat=c("LL","ser","f"), no.space=TRUE, align=TRUE )

# In order to analyze the data in each province:
NEWBRUNSWICK   <- data[data$NBRUNSWICK==1,]
ONTARIO        <- data[data$ONTARIO==1,]
QUEBEC         <- data[data$QUEBEC==1,]
MANITOBA       <- data[data$MANITOBA==1,]
SASKET         <- data[data$SAKSET==1,]
BCOL           <- data[data$BCOL==1,]
ALBERTA        <- data[data$ALBERTA==1,]
NOVASCOTIA     <- data[data$NOVASCOTIA==1,]
PRINCEEDISLE   <- data[data$PRINCEEDISLE==1,]
NEWFOUNDL      <- data[data$NEWFOUNDL==1,]

# *Substitute* the first line with the name of the province you want to analyze

ALBERTA %>%
  group_by(dependent_var) %>%
  summarise(n = n()) %>%
  mutate(totalN = (cumsum(n)),
         percent = round((n / sum(n)), 3),
         cumpercent = round(cumsum(freq = n / sum(n)),3))


### Model 1: including all the provinces with 4 outcomes in the dependent variable,
#            Quebec, Sasketchwan, British Columbia and Manitoba (benchmark).

model1         <- vglm(dependent_var ~ MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                       + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS+HOME_LANG_NOT_ENG
                       + QUEBEC*HOME_LANG_NOT_ENG + SASKET*HOME_LANG_NOT_ENG + BCOL*HOME_LANG_NOT_ENG 
                       + QUEBEC*WEALTH + SASKET*WEALTH + BCOL*WEALTH,
                       data = data1, family = multinomial(refLevel = 1))

# Instant Visualization of the Results:
summary(model1) 

# For the Latex table:
model1.table   <- multinom(formula= dependent_var ~ MNWORKING + TWOPARENTS + SIBLINGS 
                           + GRANDPARENTS + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS+HOME_LANG_NOT_ENG
                           + QUEBEC*HOME_LANG_NOT_ENG + SASKET*HOME_LANG_NOT_ENG + BCOL*HOME_LANG_NOT_ENG 
                           + QUEBEC*WEALTH + SASKET*WEALTH + BCOL*WEALTH, data = data1)

### Model 2: including all the provinces with only 2 outcomes in the dependent variable,
#            Nova Scotia (benchmark), New Brunswick, Alberta and Ontario.

model2        <- vglm(dependent_var ~  MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                      + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS + HOME_LANG_NOT_ENG
                      + ALBERTA*HOME_LANG_NOT_ENG + NBRUNSWICK*HOME_LANG_NOT_ENG 
                      + ONTARIO*HOME_LANG_NOT_ENG+ ALBERTA*WEALTH + NBRUNSWICK*WEALTH + ONTARIO*WEALTH,
                      data = data2, family = multinomial(refLevel = 1))

# Instant Visualization of the Results:
summary(model2) 

# For the Latex table:
model2.table   <- multinom(formula= dependent_var ~ MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                           + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS+HOME_LANG_NOT_ENG+
                             ALBERTA*HOME_LANG_NOT_ENG + NBRUNSWICK*HOME_LANG_NOT_ENG + ONTARIO*HOME_LANG_NOT_ENG
                           + ALBERTA*WEALTH + NBRUNSWICK*WEALTH + ONTARIO*WEALTH, data = data2)

## For the Latex tables:
stargazer(model1.table,  title="Regression Results: first model",omit.stat=c("LL","ser","f"), no.space=TRUE, align=TRUE )
stargazer(model2.table,  title="Regression Results: second model",omit.stat=c("LL","ser","f"), no.space=TRUE, align=TRUE )

# For the wald tests:
m1         <- vglm(dependent_var ~ MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                       + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS+HOME_LANG_NOT_ENG
                       + QUEBEC + SASKET + BCOL,
                       data = data1, family = multinomial(refLevel = 1))

m2        <- vglm(dependent_var ~ MNWORKING + TWOPARENTS + SIBLINGS + GRANDPARENTS
                      + CULTPOS + MEDUC + FEDUC + WEALTH  + OCUP_STATUS + HOME_LANG_NOT_ENG
                      + ALBERTA + NBRUNSWICK + ONTARIO,
                      data = data2, family = multinomial(refLevel = 1))


####### 5) WALD TESTS -----------------------------------------------------------------------------------------------------
#
# DESCRIPTION:
# This section contains a simple function that takes as input the model used, the variable you want
# to analyze, and the name of the dependent variable of the model, and gives as otuput the Wald test.
#

wald <- function(model, var, dep_var, database){
  # Getting the variables of the model
  names <- names(model@constraints)
  n=length(names(model@constraints))-1
  for(i in 1:n){
    if(names[i+1]==as.character(var)){
      position=i+1
    }
  }
  names <- names[-position]
  reg=paste("vglm(formula =",dep_var,"~")
  n2=length(names)-1
  for(j in 1:n2){
    reg=paste(reg,"+",names[j+1])
  }
  reg=paste(reg,", family = multinomial(refLevel = 1), data = ", database ,")")
  modelr <- eval(parse(text=reg))
  waldtest(model, modelr)
}

# A few examples:
wald(m1,"MNWORKING", "dependent_var", "data1")
wald(m1,"TWOPARENTS", "dependent_var", "data1")
wald(m1,"SIBLINGS", "dependent_var", "data1")
wald(m1,"GRANDPARENTS", "dependent_var", "data1")
wald(m1,"CULTPOS", "dependent_var", "data1")
wald(m1,"MEDUC", "dependent_var", "data1")
wald(m1,"FEDUC", "dependent_var", "data1")
wald(m1,"WEALTH", "dependent_var", "data1")
wald(m1,"OCUP_STATUS", "dependent_var", "data1")
wald(m1,"HOME_LANG_NOT_ENG", "dependent_var", "data1")
wald(m1,"QUEBEC", "dependent_var", "data1")
wald(m1,"SASKET", "dependent_var", "data1")
wald(m1,"BCOL", "dependent_var", "data1")

#
wald(m2,"MNWORKING", "dependent_var", "data2")
wald(m2,"TWOPARENTS", "dependent_var", "data2")
wald(m2,"SIBLINGS", "dependent_var", "data2")
wald(m2,"GRANDPARENTS", "dependent_var", "data2")
wald(m2,"CULTPOS", "dependent_var", "data2")
wald(m2,"MEDUC", "dependent_var", "data2")
wald(m2,"FEDUC", "dependent_var", "data2")
wald(m2,"WEALTH", "dependent_var", "data2")
wald(m2,"OCUP_STATUS", "dependent_var", "data2")
wald(m2,"HOME_LANG_NOT_ENG", "dependent_var", "data2")
wald(m2,"ONTARIO", "dependent_var", "data2")
wald(m2,"NBRUNSWICK", "dependent_var", "data2")
wald(m2,"ALBERTA", "dependent_var", "data2")

######## 6) PR. CHANGE CALCULATION AND DISPLAY: ---------------------------------------------------------------------------
#
# DESCRIPTION: this section includes a function that calculates the probability change, taking as input
# the variable, the benchmark, and the model, apart from boolean values that establishes if the variable
# is a dummy, and if its multiplied by "HOME_LANG_NOT_ENG" or by "WEALTH". The next two sections contains
# all of the code that is necessary for the display of the figures. It is not very efficient though, I 
# can create a function that tidies the thing a bit if you want.
#
# Function that calculates the probability change:
#     f("name of the variable", "dummy=1 if TRUE", "language=1 if variable is a language
#       differential effect", "wealth=1 if variable is a wealth differential effect",
#       "benchmark= benchmark for the model, just the values for the variables)",
#       "model=model from the NNET package")

prchange <- function(variable, dummy, language, wealth, benchmark, model){
  pr1 <- benchmark
  pr2 <- benchmark
  
  if(language==TRUE & dummy==TRUE & wealth==FALSE){
    pr1$HOME_LANG_NOT_ENG=0
    pr2$HOME_LANG_NOT_ENG=1
    eval(parse(text=paste("pr1$", variable, "=", "0", sep="")))
    eval(parse(text=paste("pr2$", variable, "=", "1", sep="")))
    pa  <- predict(model, type="probs", newdata=pr1) 
    pb  <- predict(model, type="probs", newdata=pr2) 
    return(result=pb-pa)
  }
  
  if(wealth==TRUE & dummy==TRUE & language==FALSE){
    pr1$WEALTH=mean(data$WEALTH)- sd(data$WEALTH)/2
    pr2$WEALTH=mean(data$WEALTH)+ sd(data$WEALTH)/2
    eval(parse(text=paste("pr1$", variable, "=", "0", sep="")))
    eval(parse(text=paste("pr2$", variable, "=", "1", sep="")))
    pa  <- predict(model, type="probs", newdata=pr1) 
    pb  <- predict(model, type="probs", newdata=pr2) 
    return(result=pb-pa)
  }

  if(dummy==FALSE){
    var=eval(parse(text=paste("data$", variable, sep="")))
    eval(parse(text=paste("pr1$", variable, "=", mean(var), "- (sd(data$", variable, "))/2", sep="")))
    eval(parse(text=paste("pr2$", variable, "=", mean(var), "+ (sd(data$", variable, "))/2", sep="")))
    pa  <- predict(model, type="probs", newdata=pr1) 
    pb  <- predict(model, type="probs", newdata=pr2) 
    return(result=pb-pa)
    }
  
  if(dummy==TRUE & language==FALSE & wealth==FALSE){
    eval(parse(text=paste("pr1$", variable, "=", "0", sep="")))
    eval(parse(text=paste("pr2$", variable, "=", "1", sep="")))
    pa  <- predict(model, type="probs", newdata=pr1) 
    pb  <- predict(model, type="probs", newdata=pr2) 
    return(result=pb-pa)
  }
}

# Setting the benchmarks:

benchmark1 <- data.frame(MNWORKING=0, TWOPARENTS=0, SIBLINGS=1, GRANDPARENTS=0,
                         CULTPOS=mean(data$CULTPOS), MEDUC=mean(data$MEDUC), FEDUC=mean(data$FEDUC),
                         WEALTH=mean(data$WEALTH), OCUP_STATUS= mean(data$OCUP_STATUS), 
                         HOME_LANG_NOT_ENG=0, QUEBEC=0, SASKET=0, BCOL=0)
                    
benchmark2 <- data.frame(MNWORKING=0, TWOPARENTS=1, SIBLINGS=1, GRANDPARENTS=0,
                         CULTPOS=mean(data$CULTPOS), MEDUC=mean(data$MEDUC), FEDUC=mean(data$FEDUC), 
                         WEALTH=mean(data$WEALTH), OCUP_STATUS= mean(data$OCUP_STATUS), HOME_LANG_NOT_ENG=0, 
                         ALBERTA=0, NBRUNSWICK=0, ONTARIO=0)


### MODEL 1 ---------------------------------------------------------------------------------------------------------------
#
# DESCRIPTION: this section includes all the necessary data manipulation to properly make the figure 
# of the first model.
#

# Vector containing all of the probability changes:


p1 <- rep(NA, 76)

p1[1]  <- as.numeric(prchange("MNWORKING", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[2]  <- as.numeric(prchange("TWOPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[3]  <- as.numeric(prchange("SIBLINGS", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[4]  <- as.numeric(prchange("GRANDPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[1]) 
p1[5]  <- as.numeric(prchange("CULTPOS", TRUE, FALSE, FALSE, benchmark1, model1.table)[1]) 
p1[6]  <- as.numeric(prchange("MEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[1]) 
p1[7]  <- as.numeric(prchange("FEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[8]  <-as.numeric(prchange("WEALTH", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[9] <-as.numeric(prchange("OCUP_STATUS", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[10] <-as.numeric(prchange("HOME_LANG_NOT_ENG", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[11] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[12] <-as.numeric(prchange("SAKSET", TRUE, FALSE, FALSE, benchmark1, model1.table)[1])
p1[13] <-as.numeric(prchange("BCOL", TRUE,FALSE, FALSE, benchmark1, model1.table)[1])
p1[14] <-as.numeric(prchange("QUEBEC", TRUE, TRUE, FALSE, benchmark1, model1.table)[1])
p1[15] <-as.numeric(prchange("SAKSET", TRUE, TRUE, FALSE, benchmark1, model1.table)[1])
p1[16] <-as.numeric(prchange("BCOL", TRUE,TRUE, FALSE, benchmark1, model1.table)[1])
p1[17] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, TRUE, benchmark1, model1.table)[1])
p1[18] <-as.numeric(prchange("SAKSET", TRUE, FALSE, TRUE, benchmark1, model1.table)[1])
p1[19] <-as.numeric(prchange("BCOL", TRUE,FALSE, TRUE, benchmark1, model1.table)[1])


p1[20]  <- as.numeric(prchange("MNWORKING", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[21]  <- as.numeric(prchange("TWOPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[22]  <- as.numeric(prchange("SIBLINGS", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[23]  <- as.numeric(prchange("GRANDPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[2]) 
p1[24]  <- as.numeric(prchange("CULTPOS", TRUE, FALSE, FALSE, benchmark1, model1.table)[2]) 
p1[25]  <- as.numeric(prchange("MEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[2]) 
p1[26]  <- as.numeric(prchange("FEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[27]  <-as.numeric(prchange("WEALTH", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[28] <-as.numeric(prchange("OCUP_STATUS", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[29] <-as.numeric(prchange("HOME_LANG_NOT_ENG", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[30] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[31] <-as.numeric(prchange("SAKSET", TRUE, FALSE, FALSE, benchmark1, model1.table)[2])
p1[32] <-as.numeric(prchange("BCOL", TRUE,FALSE, FALSE, benchmark1, model1.table)[2])
p1[33] <-as.numeric(prchange("QUEBEC", TRUE, TRUE, FALSE, benchmark1, model1.table)[2])
p1[34] <-as.numeric(prchange("SAKSET", TRUE, TRUE, FALSE, benchmark1, model1.table)[2])
p1[35] <-as.numeric(prchange("BCOL", TRUE,TRUE, FALSE, benchmark1, model1.table)[2])
p1[36] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, TRUE, benchmark1, model1.table)[2])
p1[37] <-as.numeric(prchange("SAKSET", TRUE, FALSE, TRUE, benchmark1, model1.table)[2])
p1[38] <-as.numeric(prchange("BCOL", TRUE,FALSE, TRUE, benchmark1, model1.table)[2])


p1[39]  <- as.numeric(prchange("MNWORKING", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[40]  <- as.numeric(prchange("TWOPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[41]  <- as.numeric(prchange("SIBLINGS", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[42]  <- as.numeric(prchange("GRANDPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[3]) 
p1[43]  <- as.numeric(prchange("CULTPOS", TRUE, FALSE, FALSE, benchmark1, model1.table)[3]) 
p1[44]  <- as.numeric(prchange("MEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[3]) 
p1[45]  <- as.numeric(prchange("FEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[46]  <-as.numeric(prchange("WEALTH", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[47] <-as.numeric(prchange("OCUP_STATUS", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[48] <-as.numeric(prchange("HOME_LANG_NOT_ENG", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[49] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[50] <-as.numeric(prchange("SAKSET", TRUE, FALSE, FALSE, benchmark1, model1.table)[3])
p1[51] <-as.numeric(prchange("BCOL", TRUE,FALSE, FALSE, benchmark1, model1.table)[3])
p1[52] <-as.numeric(prchange("QUEBEC", TRUE, TRUE, FALSE, benchmark1, model1.table)[3])
p1[53] <-as.numeric(prchange("SAKSET", TRUE, TRUE, FALSE, benchmark1, model1.table)[3])
p1[54] <-as.numeric(prchange("BCOL", TRUE,TRUE, FALSE, benchmark1, model1.table)[3])
p1[55] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, TRUE, benchmark1, model1.table)[3])
p1[56] <-as.numeric(prchange("SAKSET", TRUE, FALSE, TRUE, benchmark1, model1.table)[3])
p1[57] <-as.numeric(prchange("BCOL", TRUE,FALSE, TRUE, benchmark1, model1.table)[3])


p1[58]  <- as.numeric(prchange("MNWORKING", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[59]  <- as.numeric(prchange("TWOPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[60]  <- as.numeric(prchange("SIBLINGS", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[61]  <- as.numeric(prchange("GRANDPARENTS", TRUE, FALSE, FALSE, benchmark1, model1.table)[4]) 
p1[62]  <- as.numeric(prchange("CULTPOS", TRUE, FALSE, FALSE, benchmark1, model1.table)[4]) 
p1[63]  <- as.numeric(prchange("MEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[4]) 
p1[64]  <- as.numeric(prchange("FEDUC", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[65]  <-as.numeric(prchange("WEALTH", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[66] <-as.numeric(prchange("OCUP_STATUS", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[67] <-as.numeric(prchange("HOME_LANG_NOT_ENG", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[68] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[69] <-as.numeric(prchange("SAKSET", TRUE, FALSE, FALSE, benchmark1, model1.table)[4])
p1[70] <-as.numeric(prchange("BCOL", TRUE,FALSE, FALSE, benchmark1, model1.table)[4])
p1[71] <-as.numeric(prchange("QUEBEC", TRUE, TRUE, FALSE, benchmark1, model1.table)[4])
p1[72] <-as.numeric(prchange("SAKSET", TRUE, TRUE, FALSE, benchmark1, model1.table)[4])
p1[73] <-as.numeric(prchange("BCOL", TRUE,TRUE, FALSE, benchmark1, model1.table)[4])
p1[74] <-as.numeric(prchange("QUEBEC", TRUE, FALSE, TRUE, benchmark1, model1.table)[4])
p1[75] <-as.numeric(prchange("SAKSET", TRUE, FALSE, TRUE, benchmark1, model1.table)[4])
p1[76] <-as.numeric(prchange("BCOL", TRUE,FALSE, TRUE, benchmark1, model1.table)[4])

## Graphic

# Setting what will appear in the figure:
display <- data.frame(name=rep(c("Mother not working-0/1", "Two-parent family-0/1",
                                 "Siblings-0/1", "Grandparents-0/1", "Cultural possesions-std", "Educ. level mother-std",
                                 "Educ. level father-std", "Family wealth-std", "Occup. status-std", "Home lang. not English-0/1",
                                 "Quebec-0/1", "Saskatchewan-0/1", "British Col.-0/1", "Home lang. not English: Quebec-0/1",
                                 "Home lang. not English: Saskatchewan-0/1", "Home lang. not English: British Col.-0/1",
                                 "Family wealth: Quebec-0/1", "Family wealth: Saskatchewan-0/1", "Family wealth: British Col.-0/1")
                               , 4),
                 value=c(rep("1",19),rep("2",19),rep("3",19),rep("4",19)), p1)
# Table box for the figure

tt <- ttheme_minimal()

# for setting the box in bold
   # tt$core$fg_params <- list(fontface=matrix(c(2), ncol=ncol(table),nrow=nrow(table),byrow=TRUE))

table <- cbind(c("1:","2:","3:","4:"), 
               "School types"=c("Public English", "Private English", "Public French", "Private French"))
table <- tableGrob(table, theme=tt)
table <- gtable_add_grob(table,
                     grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
                     t = 2, b = nrow(table), l = 1, r = ncol(table))
table <- gtable_add_grob(table,
                     grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
                     t = 1, l = 1, r = ncol(table))


# Setting the graph: 

graph <- ggplot(display, aes(x=p1, y=name)) +
  geom_text(aes(label=value)) +
  geom_vline(xintercept=0) +
  labs(x="Probability Change", y="") +
  annotation_custom(table,xmin=0.30, ymin=13) +
  theme_bw()

graph <- graph + theme(axis.text = element_text(size = 15))
# The graph:
graph 



### MODEL 2 ---------------------------------------------------------------------------------------------------------------
#
# DESCRIPTION: this section includes all the necessary data manipulation to properly make the figure 
# of the second model.
#

# Vector containing all of the probability changes:
p2 <- rep(NA, 19)

p2[1]  <- as.numeric(prchange("MNWORKING", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[2]  <- as.numeric(prchange("TWOPARENTS", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[3]  <- as.numeric(prchange("SIBLINGS", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[4]  <- as.numeric(prchange("GRANDPARENTS", TRUE, FALSE, FALSE, benchmark2, model2.table)[1]) 
p2[5]  <- as.numeric(prchange("CULTPOS", TRUE, FALSE, FALSE, benchmark2, model2.table)[1]) 
p2[6]  <- as.numeric(prchange("MEDUC", TRUE, FALSE, FALSE, benchmark2, model2.table)[1]) 
p2[7]  <- as.numeric(prchange("FEDUC", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[8]  <-as.numeric(prchange("WEALTH", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[9] <-as.numeric(prchange("OCUP_STATUS", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[10] <-as.numeric(prchange("HOME_LANG_NOT_ENG", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[11] <-as.numeric(prchange("ALBERTA", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[12] <-as.numeric(prchange("NBRUNSWICK", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[13] <-as.numeric(prchange("ONTARIO", TRUE, FALSE, FALSE, benchmark2, model2.table)[1])
p2[14] <-as.numeric(prchange("ALBERTA", TRUE, TRUE, FALSE, benchmark2, model2.table)[1])
p2[15] <-as.numeric(prchange("NBRUNSWICK", TRUE, TRUE, FALSE, benchmark2, model2.table)[1])
p2[16] <-as.numeric(prchange("ONTARIO", TRUE, TRUE, FALSE, benchmark2, model2.table)[1])
p2[17] <-as.numeric(prchange("ALBERTA", TRUE, FALSE, TRUE, benchmark2, model2.table)[1])
p2[18] <-as.numeric(prchange("NBRUNSWICK", TRUE, FALSE, TRUE, benchmark2, model2.table)[1])
p2[19] <-as.numeric(prchange("ONTARIO", TRUE, FALSE, TRUE, benchmark2, model2.table)[1])



## GRAPHIC

# Setting what will appear in the figure:
display2 <- data.frame(name=rep(c("Mother not working-0/1", "Two-parent family-0/1",
                            "Siblings-0/1", "Grandparents-0/1", "Cultural possesions-std", "Educ. level mother-std",
                            "Educ. level father-std", "Family wealth-std", "Occup. status-std", "Home lang. not English-0/1",
                            "Alberta-0/1", "N. Brunswick-0/1", "Ontario-0/1", "Home lang. not English: Alberta-0/1",
                            "Home lang. not English: N. Brunswick-0/1", "Home lang. not English: Ontario-0/1",
                            "Family wealth: Alberta-0/1", "Family wealth: N. Brunswick-0/1", "Family wealth: Ontario-0/1"), 1),
                 value=c(rep("3",19)), p2)

# Table box for the figure

tt <- ttheme_minimal()

# for setting the box in bold
# tt$core$fg_params <- list(fontface=matrix(c(2), ncol=ncol(table),nrow=nrow(table),byrow=TRUE))

table <- cbind(c("1:","3:"), 
               "School types"=c("Public English",  "Public French"))
table <- tableGrob(table, theme=tt)
table <- gtable_add_grob(table,
                         grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
                         t = 2, b = nrow(table), l = 1, r = ncol(table))
table <- gtable_add_grob(table,
                         grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
                         t = 1, l = 1, r = ncol(table))

# Setting the graph:
tiff("test.tiff", units="px", width=1600, height=600, res=300)


graph2 <- ggplot(display2, aes(x=p2, y=name)) +
  geom_text(aes(label=value)) +
  geom_vline(xintercept=0) +
  labs(x="Probability Change", y="") +
  annotation_custom(table,xmin=0.6, ymin=15) +
  theme_bw()

graph2 <- graph2 + theme(axis.text = element_text(size = 15))

# The graph:
graph2 

dev.off()



######## TABLES -----------------------------------------------------------------------------------------

# Classifying non-numeric variables 
dummies <- c("FNWORKING", "MNWORKING", "TWOPARENTS", "SIBLINGS", "GRANDPARENTS","HOME_LANG_NOT_ENG" )
num <- c("CULTPOS", "MEDUC", "FEDUC", "WEALTH", "OCUP_STATUS")

data.num <- data[,num]
data.dummies <- data[,dummies]

stargazer(data.num, omit.summary.stat = c("n","p25", "p75"))
stargazer(data.dummies, omit.summary.stat = c("n","p25", "p75", "sd", "min", "max"))


data1.num <- data1[,num]
data2.num <- data2[,num]

stargazer(data1.num, omit.summary.stat = c("n","p25", "p75"))
stargazer(data2.num, omit.summary.stat = c("n","p25", "p75"))


data1.dummies <- data1[,dummies]
data2.dummies <- data2[,dummies]

stargazer(data1.dummies, omit.summary.stat = c("n","p25", "p75", "sd", "min", "max"))
stargazer(data2.dummies, omit.summary.stat = c("n","p25", "p75", "sd", "min", "max"))


######## END ---------------------------------------------------------------------------------------------------------