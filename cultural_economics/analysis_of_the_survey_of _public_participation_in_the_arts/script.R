# Master in Economics: Empirical Applications and Policies (EAP)                #
# Growth and Development                                                        #
# Homework 1                                                                    #
# Pedro & Gustavo                                                               #


#### DATA MANIP                                                              ####
# Preliminaries                                                                 #
rm(list = ls())                                                 # Clear workspace
setwd("C:/Users/pimpeter/Desktop/Cultural/hw3")    # Setting directory
library(dplyr)                                 # na_if() included in this library
library(ggplot2)                              # ggplot() included in this library
data <- read.csv("notanreduc.csv", header=T, sep=";", dec=",")     # Loading data
#View(data)
#summary(data)
#dim(data)

# Renombrar variables
colnames(data) <- c("id", "asiste", "funciones", "renta", "tipociudad", "CSAcod",
                    "edad", "est.civil", "hombre", "raza", "famtipo", "pais",
                    "est.lab", "horas.trab", "trab.tipo", "trab.ind", "trab.ocu",
                    "major.ind", "major.ocu", "weight", "menores", "libros",
                    "clases.mus", "clases.foto", "clases.artes.vis", "clases.act",
                    "clases.danza", "clases.esc", "clases.arte.apr", "p.educ",
                    "m.educ", "educ")

# Mantener las observaciones válidas y arreglar variables:
  # Variable: asiste. ¿Ha asistido a algún espectáculo en el último año?
    # quitar -9 (no response), -3 (refused) y -1 (not in universe)
    data <- data[data$asiste != -9 & data$asiste != -3 & data$asiste != -1, ]
    data$asiste <- na_if(data$asiste, "#N/A")
    #class(data$asiste)
    data$asiste <- as.numeric(as.character(data$asiste))
    # sum(as.numeric(data$asiste==0))     # 1524 yes and 7231 no, as in codebook ¡BIEN!
  # Variable: funciones. ¿A cuántas funciones ha asistido?
    # quitar -1 (not in universe), pero conservar aquellos para los que tenemos
    # datos de asistencia
    data$funciones <- na_if(data$funciones, "#N/A")
    #class(data$funciones)
    data$funciones <- as.numeric(as.character(data$funciones))
    data[is.na(data$funciones),]$funciones <- -1
    data$funciones <- ifelse(data$asiste==0, 0, data$funciones)
    data$funciones <- na_if(data$funciones, -1)
    # sum(as.numeric(data$funciones==5), na.rm=T)     # 727 once,  44 went to 5, etc. ¡BIEN!
  # Variables de educación: p.educ y m.educ Convertir <0 en NA
    data[data$p.educ<0,]$p.educ <- rep(-1, length(data[data$p.educ<0,]$p.educ))
    data$p.educ <- na_if(data$p.educ, -1)
    data[data$p.educ<0,]$p.educ <- -1
    data$p.mduc <- na_if(data$m.educ, -1)
    
# Nuevas variables:
  # edad al cuadrado
    data$edad2 <- data$edad^2
  # gran ciudad, dummy
    data$metropoli <- as.numeric(data$tipociudad==1)
  # clases cultura
    data$clases.cult <- as.numeric(data$clases.mus==1 | data$clases.foto==1 |
                                     data$clases.artes.vis==1 | data$clases.act==1 |
                                     data$clases.danza==1 | data$clases.esc==1 |
                                     data$clases.arte.apr==1)
  


# Recolocando variables:
    # Variable de renta: reducir categorías
    data$renta <- as.factor(ifelse(data$renta < 8, 1, ifelse(data$renta > 13,2,0)))
    # Variable de educación: reducir categorías
    data$univ <- as.numeric(data$educ>41)
    # Variable de empleo: reducir categorías
    data$empleado <- as.numeric(data$est.lab<3)
    # Horas trab. como factor (inital.logit)
    data$horas.trab <- as.factor(data$horas.trab)
    # Educ. como factor (inital.logit)
    data$educ <- as.factor(data$educ)
    # Variable menores: dummy =1 si hay hijos <14 años
    data$hijos <- as.numeric(data$menores >0)
    # Menores como factor
    data$menores <- as.factor(data$menores)
    
    
# Descripción de las variables #####
    library(scales)
    summary(data$asiste)
    summary(data$funciones)
    summary(data[data$asiste==1,]$funciones)
    data %>%
      group_by(asiste) %>%
      summarise(n = n()) %>%
      mutate(totalN = (cumsum(n)),
             percent = round((n / sum(n)), 3),
             cumpercent = round(cumsum(freq = n / sum(n)),3))
    data[data$asiste==1,] %>%
      group_by(funciones) %>%
      summarise(n = n()) %>%
      mutate(totalN = (cumsum(n)),
             percent = round((n / sum(n)), 3),
             cumpercent = round(cumsum(freq = n / sum(n)),3))
    panel1 <- ggplot(data) +
      geom_bar(aes(asiste, 100*(..count..)/sum(..count..))) +
      ylab("%") + labs(title="General") +
      scale_x_continuous("Attended to a live musical stage play", breaks=c(0,1), labels=c("No","Yes")) +
      ylim(0,100)
    panel2 <- ggplot(data[data$renta==2,]) +
      geom_bar(aes(asiste, 100*(..count..)/sum(..count..))) +
      ylab("%") + labs(title="High income") +
      scale_x_continuous("Attended to a live musical stage play", breaks=c(0,1), labels=c("No","Yes")) +
      ylim(0,100)
    panel3 <- ggplot(data[data$renta==0,]) +
      geom_bar(aes(asiste, 100*(..count..)/sum(..count..))) +
      ylab("%") + labs(title="Medium income") +
      scale_x_continuous("Attended to a live musical stage play", breaks=c(0,1), labels=c("No","Yes")) +
      ylim(0,100)
    panel4 <- ggplot(data[data$renta==1,]) +
      geom_bar(aes(asiste, 100*(..count..)/sum(..count..))) +
      ylab("%") + labs(title="Low income") +
      scale_x_continuous("Attended to a live musical stage play", breaks=c(0,1), labels=c("No","Yes")) +
      ylim(0,100)
    png(file="asiste_hist.png", pointsize=22, width=12, height=10, units='in', res=300)
    grid.arrange(panel1, panel2, panel3, panel4, ncol=2, nrow=2)
    dev.off()
    
    panelA <- ggplot(data[data$asiste==1,]) +
      geom_bar(aes(funciones, 100*(..count..)/sum(..count..))) +
      ylab("%") + ylim(0,60) + labs(title="General") +
      scale_x_continuous("Musical live stage plays attended", breaks=c(1:8))
    panelB <- ggplot(data[data$asiste==1 & data$renta==2,]) +
      geom_bar(aes(funciones, 100*(..count..)/sum(..count..))) +
      ylab("%") + ylim(0,60) + labs(title="High income") +
      scale_x_continuous("Musical live stage plays attended", breaks=c(1:8))
    panelC <- ggplot(data[data$asiste==1 & data$renta==0,]) +
      geom_bar(aes(funciones, 100*(..count..)/sum(..count..))) +
      ylab("%") + ylim(0,60) + labs(title="Medium income") +
      scale_x_continuous("Musical live stage plays attended", breaks=c(1:8))
    panelD <- ggplot(data[data$asiste==1 & data$renta==1,]) +
      geom_bar(aes(funciones, 100*(..count..)/sum(..count..))) +
      ylab("%") + ylim(0,60) + labs(title="Low income") +
      scale_x_continuous("Musical live stage plays attended", breaks=c(1:8))
    png(file="funciones_hist.png", pointsize=22, width=16, height=10, units='in', res=300)
    grid.arrange(panelA, panelB, panelC, panelD, ncol=2, nrow=2)
    dev.off()
# Modelo logit #####
  sapply(data,class)
  
  library(stargazer)
  initial.logit <- glm(asiste ~ renta + metropoli + edad + edad2 + hombre + empleado +
                        hijos + clases.cult + p.educ + m.educ + univ,
                      data = data, family = "binomial"(link = "logit"))
  summary(initial.logit)
  stargazer(initial.logit, omit.stat=c("LL","ser","f"), no.space=TRUE, single.row = T
            ,ci=TRUE, ci.level=0.95)

# ANALYSIS OF LOGIT REGRESSIONS #####
# Let's check for problems: heterokedasticity, normality of error term
  par(mfrow=c(2,2))
  jpeg(filename="analysis.jpeg")
  plot(initial.logit)
  dev.off()

   
  # It looks that there is heterokedasticity: BREUSCH PAGAN TEST
  
  library(lmtest)
  bptest(initial.logit)
  # We reject the null hypothesis of homocedasticity: NO PROBLEMO
  # Heterokedasticity happens in logistic regressions.
  
  # As we can also see, the errors are distributed almost normally
  shapiro.test(initial.logit$residuals)
  # The logistic regression does not need to fulfill normality of errors
  
  # THE MOST IMPORTANT ASSUMPTION IN LOGISTIC REGRESSIONS
  # IS THE NON EXISTANCE OF MC.

# ANALYSIS OF LOGIT REGRESSIONS 1)  
  sum(!is.na(data$p.educ))
  sum(!is.na(data$m.educ))
  sum(!is.na(data$horas.trab))
  # TOO MANY NAS: DELETING THIS VARS.
  
# ANALYSIS OF LOGIT REGRESSIONS 2)  
  
  # CORR AND VIF TEST: CHECKING FOR MC
   # THE CORRELATIONS BETWEEN INDEP VAR SHOW THAT THE VAR P.EDUC HAS MANY NAS
   # WE SHOULD DELETE IT

     subset   <- data[,c("renta","metropoli","edad" ,"edad2"  , "horas.trab",
                        "menores" , "clases.cult", "m.educ" , "educ")]  
     cor(subset, method = "pearson")  

    # VIF TEST: EDAD AND EDAD2 CORRELATED
    library(car)
    vif(initial.logit)
    # Checking if all vars are relevant: we eliminate metropoli and worked.hours
    initial.logit <- glm(asiste ~ renta + metropoli + edad + edad2 + hombre + horas.trab +
                           menores + clases.cult + p.educ + m.educ + educ,
                         data = data, family = "binomial"(link = "logit"))
    summary(initial.logit)
    
# FINAL MODEL ######
  final.logit <- glm(asiste ~ renta  + edad + hombre  +
                     hijos + clases.cult  + univ+ empleado,
                     data = data, family = "binomial"(link = "logit"))
  summary(final.logit) 
  stargazer(final.logit, no.space=TRUE, single.row = T)
    
  # ALL VAR ARE RELEVANT AT ALPHA=0.05 
  # MOST RELEVANT EFFECTS SEX,EDUCATION, CLASES CULT.
  # LETS DO A LRTEST TO CHECK IF THE MODEL HAS IMPROVED

    
    a.logit <- glm(asiste ~ renta  + edad + hombre  +
                         hijos + clases.cult +univ+ empleado ,
                       data = data, family = "binomial"(link = "logit"))
    
    b.logit <- glm(asiste ~ renta  + edad + hombre  +
                         hijos + clases.cult ,
                       data = a.logit$model, family = "binomial"(link = "logit"))
    
    stargazer(a.logit, b.logit, title="Regression Results", no.space=TRUE, single.row = T)
    library(lmtest)
    # LR test #
    lrtest.default(a.logit, b.logit)
    # AS WE CAN SEE THE PR(CHI)>0.05: THE SMALLER MODEL IS A SIGNIFICANT IMPROVEMENT
    # OVER THE NEW ONE
    
    
# GRAPHICAL REPRESENTATION: #########
    
    # Plot of the  distribution of probabilities
    prlogit <- final.logit$fitted.values
    summary(final.logit)
    dev.off()
    ggplot(final.logit, aes(x = prlogit)) +geom_dotplot(dotsize = 0.0080, stackdir = "up")
    histogram(prlogit)
    
    ggplot(final.logit, aes(x = prlogit)) +geom_dotplot(dotsize = 0.0090, stackdir = "up", color="darkblue") + ggtitle("Distribution of prob.") + xlab("Logit: Pr(lfp)") + ylab("Frequency") + theme(
      plot.title = element_text(hjust = 0.5),axis.text.y = element_blank(), axis.ticks.y = element_blank()
    )
    # saving as jpeg
    ggsave("distrib_prob.jpeg")
    dev.off()
    # dotplot that showcases the frequency of the predicted probabilities of our sample
    
# CDF : PROBABILITY OF ASSISTANCE GIVEN AGE FOR A WELL OFF INDIVIDUAL
    
    #  CDF

    # Coefficients
    b0          <- final.logit$coef[1] # intercept
    renta       <- final.logit$coef[3] 
    edad        <- final.logit$coef[4]      
    hombre      <- final.logit$coef[5] 
    hijos       <- final.logit$coef[6] 
    clases.cult <- final.logit$coef[7] 
    univ        <- final.logit$coef[8] 
    empleado    <- final.logit$coef[9] 

    
    # Range of the indep. variable
    X_range <- seq(from=min(data$edad), to=max(data$edad), by=1)
    
    # Values (WE CONSIDER DUMMIES=0)
    a_logits = b0 + renta + edad*X_range
               + clases.cult + univ +empleado
        
    
    #Probabilities
    a_probs <- exp(a_logits)/(1 + exp(a_logits))
    
    # Plotting CDF
    plot(X_range, a_probs, 
         ylim=c(0,1),
         type="l", 
         lwd=3, 
         lty=2, 
         col="red", 
         xlab="AGE", ylab="P(outcome)", main="Probability of Assistance: rich individual")  
    abline(h=0.16, col="blue")
    # saving as jpeg
    ggsave("cdf_rich.jpeg")
    dev.off()
  
    
    # Coefficients
    b0          <- final.logit$coef[1] # intercept
    renta       <- final.logit$coef[2] 
    edad        <- final.logit$coef[4]      
    hombre      <- final.logit$coef[5] 
    hijos       <- final.logit$coef[6] 
    clases.cult <- final.logit$coef[7] 
    univ        <- final.logit$coef[8] 
    empleado    <- final.logit$coef[9] 
    
    
    # Range of the indep. variable
    X_range <- seq(from=min(data$edad), to=max(data$edad), by=1)
    
    # Values (WE CONSIDER DUMMIES=0)
    a_logits = b0 + renta + edad*X_range
     
    
    
    
    
    #Probabilities
    a_probs <- exp(a_logits)/(1 + exp(a_logits))
    
    # Plotting CDF
    plot(X_range, a_probs, 
         ylim=c(0,1),
         type="l", 
         lwd=3, 
         lty=2, 
         col="red", 
         xlab="AGE", ylab="P(outcome)", main="Probability of Assistance: poor individual")  
    abline(h=0.16, col="blue")
    # saving as jpeg
    ggsave("cdf_poor.jpeg")
    
  
      
# INTERPRETATIONS ####
# DISCRETE CHANGE IN PROBABILITY: if renta changes for example

    # Benchmark clase media:
    bm <- data.frame(
      renta            <- as.factor(0),
      edad             <- median(data$edad),      
      hombre           <- as.factor(0), 
      hijos            <- 1,
      clases.cult      <- 0,
      univ             <- 0,
      empleado         <- 1
    )
    
    benchmark_prob  <- predict(final.logit, bm,type="response")
  
    
    #renta (pobre)
    
    rp <- data.frame(
      renta            <- as.factor(1),
      edad             <- median(data$edad),      
      hombre           <- as.factor(0), 
      hijos            <- 1,
      clases.cult      <- 0,
      univ             <- 0,
      empleado         <- 1
    )
    
    rp_prob  <- predict(final.logit, rp,type="response")
    
    #renta (rico)
    
    rr <- data.frame(
      renta            <- as.factor(2),
      edad             <- median(data$edad),      
      hombre           <- as.factor(0), 
      hijos            <- 1,
      clases.cult      <- 0,
      univ             <- 0,
      empleado         <- 1
    )
    
    rr_prob  <- predict(final.logit, rr,type="response")
    
    #ser hombre
    
    h  <- data.frame(
      renta            <- as.factor(0),
      edad             <- median(data$edad),      
      hombre           <- as.factor(1), 
      hijos            <- 1,
      clases.cult      <- 0,
      univ             <- 0,
      empleado         <- 1
    )
    
    h_prob  <- predict(final.logit, h,type="response")
    
    #clases.clut
    
    c  <- data.frame(
      renta            <- as.factor(0),
      edad             <- median(data$edad),      
      hombre           <- as.factor(0), 
      hijos            <- 1,
      clases.cult      <- 1,
      univ             <- 0,
      empleado         <- 1
    )
    
    c_prob  <- predict(final.logit, c,type="response")
    
   
    # no empleado
    
    ne  <- data.frame(
      renta            <- as.factor(0),
      edad             <- median(data$edad),      
      hombre           <- as.factor(0), 
      hijos            <- 1,
      clases.cult      <- 0,
      univ             <- 0,
      empleado         <- 0
    )
    
    ne_prob  <- predict(final.logit, ne,type="response")
    
    
    # Changes in probabilities:
    
    # if you are poor
    rp_prob  - benchmark_prob  
    # if you are rich
    rr_prob    - benchmark_prob 
    # if you are a man
    h_prob    - benchmark_prob
    # with lessons
    c_prob - benchmark_prob
    # not employed
    ne_prob - benchmark_prob 
 
    