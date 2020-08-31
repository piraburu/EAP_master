
clear all
set more off
capture log close 
log using log, replace

* Working directoty 
cd C:\Users\pimpeter\Desktop\labormarkets\first_homework

use "Statistical_Capital.dta"

drop if year<2007
 
save "Statistical_Capital.dta", replace
drop if year<2007
append using "Statistical_Growth-Accounts.dta"
drop if year<2007
append using "Statistical_National-Accounts.dta"
drop if year<2007

* Keeping relevant variables.

keep if code=="A" | code=="B" | code=="C" | code=="D_E" | code=="F" | code=="G"| code=="H"| code=="I" ///
| code=="J" | code=="K" | code=="L" | code=="M_N" | code=="O_Q" | code=="P" | code=="R_S"  ///
| code=="T"| code=="TOT" | code=="TOT_IND" | code=="U"


*Save the dataset before start working on it
save capital_GA_NA.dta, replace

use capital_GA_NA.dta, clear

*Now, we destring country and code and give them a number, so we can work easier with the data. 
*We will need "var" as string variable, as you will notice soon.


encode country, gen(country2)
encode code, gen (code2)

order country2, after (country)
tab country2, nolab
order code2, after(code)

drop country code

rename country2 country
rename code2 industry
rename var variable

*Similar choice: order country code2, first

* We are interested in the variable INDUSTRY
* in order to have the analysis: industry country year var1 var2 var3
*														I_CT I_Cult ....

*Choose the years and the countries of interest
*drop if...
*keep if...





* We prepare the varibles to create the panel
help reshape 

reshape wide value, i(industry country year) j(variable) string


order industry country year, first

*Sort the data
sort country industry year

* We have look for the variable/swith the more data as possible.

des

*We rename the variables and delete the word "value" in all of them
rename (value*) (*)


*Before start working with the base, save it! 
save wide.dta, replace


*Now, you start working with the variables:
use wide.dta, clear


*We want to calculate the change in the variables. 
*1) We need to sort the data in the adecuated way
sort country industry year

* keeping vars of interest:
keep industry country year EMP H_EMP VA_Q GO_Q CAP_QI CAPIT_QI ///
CAPNIT_QI LP1TFP_I LP2TFP_I


* --------------------------------------------------

* Differences in capital penetration and employment
bysort country industry: gen EMP_change=(EMP[_n]-EMP[_n-1])/EMP[_n-1]

bysort country industry: gen H_EMP_change=(H_EMP[_n]-H_EMP[_n-1])/H_EMP[_n-1]

bysort country industry: gen VA_Q_change=(VA_Q[_n]-VA_Q[_n-1])/VA_Q[_n-1]

bysort country industry: gen GO_Q_change=(GO_Q[_n]-GO_Q[_n-1])/GO_Q[_n-1]

bysort country industry: gen CAP_QI_change=(CAP_QI[_n]-CAP_QI[_n-1])/CAP_QI[_n-1]

bysort country industry: gen CAPIT_QI_change=(CAPIT_QI[_n]-CAPIT_QI[_n-1])/CAPIT_QI[_n-1]

bysort country industry: gen CAPNIT_QI_change=(CAPNIT_QI[_n]-CAPNIT_QI[_n-1])/CAPNIT_QI[_n-1]

bysort country industry: gen LP1TFP_I_change=(LP1TFP_I[_n]-LP1TFP_I[_n-1])/LP1TFP_I[_n-1]

bysort country industry: gen LP2TFP_I_change=(LP2TFP_I[_n]-LP2TFP_I[_n-1])/LP2TFP_I[_n-1]


*Save the new dataset

save base0.dta, replace

*---------------------------------------------------------------------
clear all
set more off
capture log close 

*Now, you start working with the variables:
use base0.dta, clear

* ----------------SUM STAT
egen country_industry = group(country industry), label


xtset country_industry year
 tabstat *, s(n min p25 p50 p75 max) c(s)

*------------------------


/* 1.	Describe the evolution of ICT capital across industries, 
highlighting differences across countries 
(not necessarily displaying the evolution of ALL countries). */



br industry year CAPIT_QI 
*CAPIT_QI: Capital services, volume indices, 2010=100. Comparable across countries



/*********************** GRAPHS *************************/
tab country, nolabel


*ANALYZING CHOSEN COUNTRIES

************** 1)SPAIN **************

br industry year CAPIT_QI if country==11
twoway (line CAPIT_QI year, sort) if country ==11, by(industry)
*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==11





************** 2) FINLAND **************

br industry year CAPIT_QI if country==34
twoway (line CAPIT_QI year, sort) if country ==34, by(industry)

*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==34





************** 3) BELGIUM **************
br industry year CAPIT_QI if country==2
twoway (line CAPIT_QI year, sort) if country ==2, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==2




************** 4) GERMANY DE 6 **************
br industry year CAPIT_QI if country==6
twoway (line CAPIT_QI year, sort) if country ==6, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==6


************** 5) AUSTRIA AT 1 **************
br industry year CAPIT_QI if country==1
twoway (line CAPIT_QI year, xlabel(2007(1)2017) sort) if country ==1, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==1


************** 6) UK 37 **************
br industry year CAPIT_QI if country==37
twoway (line CAPIT_QI year, sort) if country ==37, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==37


************** 7) NETHERLANDS NL 30 **************
br industry year CAPIT_QI if country==30
twoway (line CAPIT_QI year, sort) if country ==30, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==30


************** 8) ITALY IT 24 **************
br industry year CAPIT_QI if country==24
twoway (line CAPIT_QI year, sort) if country ==24, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==24


************** 9) FRANCE FR 20 **************
br industry year CAPIT_QI if country==20
twoway (line CAPIT_QI year, sort) if country ==20, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==20


************** 10) DENMARK DK 7 **************
br industry year CAPIT_QI if country==7
twoway (line CAPIT_QI year, sort) if country ==7, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==7


************** 11) FINLAND FL 19 **************
br industry year CAPIT_QI if country==19
twoway (line CAPIT_QI year, sort) if country ==19, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==19


************** 12) CZEK REP. CZ 5 **************
br industry year CAPIT_QI if country==5
twoway (line CAPIT_QI year, sort) if country ==5, by(industry)


*Select some industries of interest: 
twoway (line CAPIT_QI year if industry==1,xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==5, xlabel(2007(1)2017) sort) ///
(line CAPIT_QI year if industry==7, xlabel(2007(1)2017) sort) (line CAPIT_QI year if industry==12, xlabel(2007(1)2017) sort) if country==5




/*########################   2.
Describe the evolution of employment 
(number of employees and number of hours worked) 
across industries, highlighting differences across countries. */
* Declining industries, homogeneity between countries, three, four countries

br industry year EMP H_EMP 

************** 1) SPAIN **************

/* summary table*/
tabstat EMP H_EMP if  country==11 & year==2007, by(industry)

tabstat EMP H_EMP if country==11 & year==2014, by(industry)

tabstat EMP H_EMP if country==11, by(industry)

* EMP
twoway (line EMP year if industry==1, xlabel(2007(1)2017) sort) (line EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line EMP year if industry==7, xlabel(2007(1)2017) sort) (line EMP year if industry==12, xlabel(2007(1)2017) sort) if country==11
*H_EMP
twoway (line H_EMP year if industry==1, xlabel(2007(1)2017) sort) (line H_EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line H_EMP year if industry==7, xlabel(2007(1)2017) sort) (line H_EMP year if industry==12, xlabel(2007(1)2017) sort) if country==11


************** 2) GERMANY **************

/* summary table*/
tabstat EMP H_EMP if  country==6 & year==2007, by(industry)

tabstat EMP H_EMP if country==6 & year==2014, by(industry)

tabstat EMP H_EMP if country==6, by(industry)


* EMP
twoway (line EMP year if industry==1, xlabel(2007(1)2017) sort) (line EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line EMP year if industry==7, xlabel(2007(1)2017) sort) (line EMP year if industry==12, xlabel(2007(1)2017) sort) if country==6
*H_EMP
twoway (line H_EMP year if industry==1, xlabel(2007(1)2017) sort) (line H_EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line H_EMP year if industry==7, xlabel(2007(1)2017) sort) (line H_EMP year if industry==12, xlabel(2007(1)2017) sort) if country==6


************** 3) ITALY **************

/* summary table*/
tabstat EMP H_EMP if  country==24 & year==2007, by(industry)

tabstat EMP H_EMP if country==24 & year==2014, by(industry)

tabstat EMP H_EMP if country==24, by(industry)


* EMP
twoway (line EMP year if industry==1, xlabel(2007(1)2017) sort) (line EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line EMP year if industry==7, xlabel(2007(1)2017) sort) (line EMP year if industry==12, xlabel(2007(1)2017) sort) if country==24
*H_EMP
twoway (line H_EMP year if industry==1, xlabel(2007(1)2017) sort) (line H_EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line H_EMP year if industry==7, xlabel(2007(1)2017) sort) (line H_EMP year if industry==12, xlabel(2007(1)2017) sort) if country==24

************** 4) EU14 **************

/* summary table*/
tabstat EMP H_EMP if  country==14 & year==2007, by(industry)

tabstat EMP H_EMP if country==14 & year==2014, by(industry)

tabstat EMP H_EMP if country==14, by(industry)


* EMP
twoway (line EMP year if industry==1, xlabel(2007(1)2017) sort) (line EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line EMP year if industry==7, xlabel(2007(1)2017) sort) (line EMP year if industry==12, xlabel(2007(1)2017) sort) if country==14
*H_EMP
twoway (line H_EMP year if industry==1, xlabel(2007(1)2017) sort) (line H_EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line H_EMP year if industry==7, xlabel(2007(1)2017) sort) (line H_EMP year if industry==12, xlabel(2007(1)2017) sort) if country==14

************** 5) EU28 **************

/* summary table*/
tabstat EMP H_EMP if  country==18 & year==2007, by(industry)

tabstat EMP H_EMP if country==18 & year==2014, by(industry)

tabstat EMP H_EMP if country==18, by(industry)


* EMP
twoway (line EMP year if industry==1, xlabel(2007(1)2017) sort) (line EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line EMP year if industry==7, xlabel(2007(1)2017) sort) (line EMP year if industry==12, xlabel(2007(1)2017) sort) if country==18
*H_EMP
twoway (line H_EMP year if industry==1, xlabel(2007(1)2017) sort) (line H_EMP year if industry==5, xlabel(2007(1)2017) sort) ///
(line H_EMP year if industry==7, xlabel(2007(1)2017) sort) (line H_EMP year if industry==12, xlabel(2007(1)2017) sort) if country==18








/* 3.	Display the observed correlation between ICT and other 
 related variables (such as non-ict capital) at industry level,
 as well as with other income related variables and try to explain such correlations. 
 Estimate  ICT levels on other technological and income variables 
 to see the extent to which each of them help predict ICT. */


************** 1) SPAIN **************


corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I  ///
if industry==1 & country==11

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I  ///
if industry==5 & country==11

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I  ///
if industry==7 & country==11

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I  ///
if industry==12 & country==11

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I  ///
if industry==16 & country==11


************** 2) ITALY **************
 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==1 & country==24

 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==5 & country==24

 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==7 & country==24

 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q ///
if industry==12 & country==24

 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==16 & country==24

 
 ************** 3) GERMANY **************
 
corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==1 & country==6

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==5 & country==6

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==7 & country==6

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==12 & country==6

corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q  ///
if industry==16 & country==6

 
 ********* REGRESSIONS*********
 corr CAPIT_QI CAPNIT_QI CAP_QI EMP  H_EMP LP1TFP_I  LP2TFP_I VA_Q GO_Q
 quiet regress CAPIT_QI CAPNIT_QI CAP_QI 
 vif 
 * Very high MC for both CAPIT vars.
 * lets use the other variables that do not show that high correlation, we can use
 *one of those two. We choose one variable for each pair of correlated ones:
 * except the labor variables. VAQ GOQ are not significant either

 
 *** 1) FOR EACH INDUSTRY
 eststo clear
eststo: regress CAPIT_QI CAPNIT_QI  LP1TFP_I if industry==1 
vif
eststo: regress CAPIT_QI    CAPNIT_QI  LP1TFP_I  GO_Q if industry==5 
vif
eststo: regress CAPIT_QI CAPNIT_QI  LP1TFP_I if industry==7 
vif
eststo: regress CAPIT_QI  CAPNIT_QI LP1TFP_I if industry==12 
vif

esttab using industry.tex, ar2 label  ///
  title(ICT OLS for each industry)
  


  *** 1) FOR EACH INDUSTRY AND COUNTRY
  * ITALY
  
   eststo clear
eststo: regress CAPIT_QI VA_Q H_EMP LP1TFP_I if industry==1  & country==24
eststo: regress CAPIT_QI CAPNIT_QI LP1TFP_I if industry==5  & country==24
eststo: regress CAPIT_QI CAPNIT_QI EMP  LP1TFP_I if industry==7  & country==24
eststo: regress CAPIT_QI EMP  LP1TFP_I if industry==12  & country==24

esttab using italy.tex, ar2 label  ///
  title(ITALY: ICT OLS for each industry)

 * GERMANY
   eststo clear
eststo: regress CAPIT_QI VA_Q  LP1TFP_I if industry==1  & country==6
eststo: regress CAPIT_QI   EMP LP1TFP_I if industry==5  & country==6
eststo: regress CAPIT_QI VA_Q EMP  LP1TFP_I if industry==7  & country==6
eststo: regress CAPIT_QI  EMP LP1TFP_I if industry==12  & country==6

esttab using ger.tex, ar2 label  ///
  title(GERMNAY: ICT OLS for each industry)
 
 * SPAIN
   eststo clear
eststo: regress CAPIT_QI   LP1TFP_I if industry==1  & country==11
eststo: regress CAPIT_QI   LP1TFP_I if industry==5  & country==11
eststo: regress CAPIT_QI   LP1TFP_I if industry==7  & country==11
eststo: regress CAPIT_QI  EMP LP1TFP_I if industry==12  & country==11

esttab using spain.tex, ar2 label  ///
  title(SPAIN: ICT OLS for each industry)
 
 
/*4.	Display the correlation between 
the evolution of Employment across industries 
and other technology and income related variables. */ 

br country industry year EMP EMP_change


*Now, get the correlation:
corr EMP_change CAPIT_QI_change CAPNIT_QI_change CAP_QI_change H_EMP_change ///
LP1TFP_I_change  LP2TFP_I_change GO_Q_change VA_Q_change 


************** 1) SPAIN **************


corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
if industry==1 & country==11

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
if industry==5 & country==11

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
if industry==7 & country==11

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
if industry==12 & country==11

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
if industry==16 & country==11


************** 2) ITALY **************
corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q if industry==1 & country==24

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q if industry==5 & country==24

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
GO_Q VA_Q if industry==7 & country==24

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
GO_Q VA_Q if industry==12 & country==24

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q if industry==16 & country==24

 
 ************** 3) GERMANY **************
 
corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q  if industry==1 & country==6

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q  if industry==5 & country==6

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
GO_Q VA_Q  if industry==7 & country==6

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I ///
GO_Q VA_Q  if industry==12 & country==6

corr EMP_change H_EMP CAPIT_QI CAPNIT_QI CAP_QI LP1TFP_I  LP2TFP_I  ///
GO_Q VA_Q  if industry==16 & country==6




/*5.Deep into the relation between 
Employment and ICT capital across industries 
(either number of employees or hours or both). */


clear all 
use base0.dta
gen lnEMP=ln(EMP)
egen country_industry = group(country industry), label
global var_list CAPIT_QI  LP1TFP_I

xtset country_industry year
tabstat *, s(n min p25 p50 p75 max) c(s)


/*A.	Estimate the level of Employment on the level of ICT  without adding any other variable. */
eststo clear
eststo: regress lnEMP CAPIT_QI
esttab using regols.tex, ar2 label  ///
  title(Regressing lnEMP)


/*B.	Estimate the former equation by adding fixed effects (time and country fixed effects). 
Discuss the estimated coefficients and interpret it with respect to the coefficients found in A. */
/*https://www.stata.com/features/overview/linear-fixed-and-random-effects-models */

eststo clear
eststo: xtreg lnEMP CAPIT_QI i.year if country==11, fe 
eststo:xtreg lnEMP CAPIT_QI i.year if country==6, fe 
eststo: xtreg lnEMP CAPIT_QI i.year if country==24, fe
eststo: xtreg lnEMP CAPIT_QI i.year if country==7, fe 
eststo: xtreg lnEMP CAPIT_QI i.year if country==20, fe

esttab using fe.tex, ar2 label  ///
  title(Regressing lnEMP on FE: time and country)


/* C.Add other covariates available in the dataset that you think may affect employment. 
Discuss the changes observed in the coefficient of ICT.*/

/*
D.	Select 5 countries and run estimation C for each of the 5 selected countries (year fixed effects). 
Discuss what you observed in the relation between ICT penetration and Employment. 
*/


eststo clear
eststo: xtreg lnEMP $var_list i.year if country==11, fe 
eststo:xtreg lnEMP $var_list VA_Q i.year if country==6, fe 
eststo: xtreg lnEMP $var_list VA_Q i.year if country==24, fe
eststo: xtreg lnEMP $var_list VA_Q i.year if country==7, fe 
eststo: xtreg lnEMP $var_list VA_Q i.year if country==20, fe

esttab using fe2.tex, ar2 label  ///
  title(Regressing lnEMP on FE: time and country)


log close



