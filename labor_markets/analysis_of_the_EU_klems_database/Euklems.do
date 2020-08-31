
clear all
set more off
capture log close 


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
/* In order to generate the panel, we are using reshape from wide to long. 

Therefore, we prepare the dataset accordingly. 


           long
        +------------+                  wide
        | i  j  stub |                 +----------------+
        |------------|                 | i  stub1 stub2 |
        | 1  1   4.1 |     reshape     |----------------|
        | 1  2   4.5 |   <--------->   | 1    4.1   4.5 |
        | 2  1   3.3 |                 | 2    3.3   3.0 |
        | 2  2   3.0 |                 +----------------+
        +------------+


From wide to long:

                reshape long stub, i(i) j(j)
                                           \
                                            j new variable
											
From long to wide:

                                            j existing variable
                                           /
                reshape wide stub, i(i) j(j)


*/


*How would you do it?
-------------





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


