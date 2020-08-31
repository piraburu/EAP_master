clear all
set more off
import excel "Germany-Austria.xlsx", ///
sheet("Hoja1") firstrow

***** EXERCISE 1*******************************************************
* Converting from string to int
destring smpphelix, gen(prices)
tabstat prices, statistics(mean median sd skewness kurtosis min max)

* J-B test (sktest in stata) and qnorm to check if it has a normal dist.
sktest prices
qnorm prices

*J-B dice que asimetria=0, kurtsis=3, vemos que no, por el test
* por la distrib, y por los valores de asimetría y kurtosis.

* Checking for neg values
count if prices < 0


gen lprices = log(prices + (prices^2)+1)
tabstat lprices, statistics(mean median sd skewness kurtosis min max)

sktest lprices
qnorm lprices


***** EXERCISE 2*******************************************************

* Preliminaries: setting the data
		bysort year month day : egen avgp=mean(prices)
		bysort year month day : egen lavgp=mean(lprices)

		egen monthday = group(month day)
		
		duplicates drop monthday, force

		tsset monthday

******* ADF TEST:  **********************************
*
varsoc avgp, maxlag(31)
varsoc lavgp, maxlag(31)

* Opt for avginc is 43
* Opt for lavginc is 29
dfuller avgp, lags(29) drift regress
dfuller avgp, lags(29) trend regress
dfuller lavgp, lags(29) drift regress
dfuller lavgp, lags(29) trend regress



* Taking diffs.
gen davgp = d.avgp
gen dlavgp = d.lavgp
*
varsoc davgp, maxlag(31)
varsoc dlavgp, maxlag(31)
*
dfuller davgp, lags(28) drift regress
dfuller davgp, lags(28) trend regress
dfuller dlavgp, lags(28) drift regress
dfuller dlavgp, lags(28) trend regress
		 	 
******* PP TEST:  **********************************	 
* 
pperron avgp, regress
pperron avgp, trend regress
pperron lavgp, regress
pperron lavgp, trend regress

* In diffs.
pperron davgp, regress
pperron davgp, trend regress
pperron dlavgp, regress
pperron dlavgp, trend regress

******* VAR ESTIMATION:  ***************************
* 
varsoc davgp, maxlag(31) 
varsoc dlavgp, maxlag(31)
*
var davgp, lags(1/28)
outreg2 using var1, tex replace
var dlavgp, lags(1/28)
outreg2 using var2, tex replace









		 