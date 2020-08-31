
clear all
set more off
capture log close
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 

********************************************************************************
********************************************************************************

* 1) PERSONAL 
*    INDIVIDUAL CHARACTERISTICS
use "SDFMCVL2016PERSONAL.dta",clear


*How many individuals are there in the sample? 
codebook IDENTPERS
* 1,208,132 individuals

* How many time each individual appears
bysort IDENTPERS: gen N=_N

*As we do not know the day of a birhtday, we can use 1st with the  MDY (month-day-year) format. 
* We have the first 4 digits to the year and 2 more for the month

*FNACIM
* int is to truncate the numbers
gen ybirth=int(FNACIM/100)
gen mbirth=FNACIM-ybirth*100
gen dbirth=mdy(mbirth,1,ybirth)
format dbirth %td
drop mbirth ybirth


*Date of death FFALLEC
br FFALLEC
gen ydeath=int(FFALLEC/100)
gen mdeath=FFALLEC-(ydeath*100)
gen ddeath=mdy(mdeath,1,ydeath)
format ddeath %td
drop ydeath mdeath


*In order to compress the data, use the following command:
qui compress


*Save it with a different name. NEVER replace the original database
save personal16.dta, replace

********************************************************************************
********************************************************************************

clear all
set more off
capture log close

*2) AFILIATION
* This is the difficult one
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use "SDFMCVL2016AFILIADOS1.dta", clear


* We can check information in the page 25 of the GUIDE

*How many observations have the data base?
des
* 6,047,437 of obsevations

*How big is it?
* We can check it with a describe
des 
* 804,309,121 SIZE
* She refers to the CAPACITY of the data base in megas

*As this file is heavy, keep only the variables we are not going to use:
* She recommends us to be EFFICIENT 
keep IDENTPERS FALTA FBAJA IDENTCCC2 IDENTEMPRESA ///
REGCOT GRUPCOT TIPCONT COEFPARC PROVCCC1 CNAE09 NUMTRAB FANTIGEMP TRL

*Check again the size of the database.
*Let's understan the structure of this file
sort IDENTPERS FALTA FBAJA
br 

* We need to them at the beginning because they are the important ones
* MAIN VARIABLES
order IDENTPERS FALTA FBAJA, first

*Make some checks:
* ALTA: staring date of all the working/enployment episodes
*Change the format of the FALTA and FBAJA as we did with the date of birth

* IDENTCCC2: Code of the firm

* TRANSFORMING FALTA FBAJA in a date format for Stata
/*
global varas FALTA FBAJA FANTIGEMP
foreach x of varlist $varas {
gen var1`x'=string(`x',"%10.0g")
gen var2`x'=date(var1`x', "YMD") 
replace `x'=var2`x'
format `x' %td
}
drop var1* var2* */

* Another way to do that MDY:
br FALTA FBAJA FANTIGEMP

gen yA=int(FALTA/100)
gen yearA=int(yA/100)
gen dA=FALTA-(yA*100)
gen mA=yA-(yearA*100)
gen dFALTA=mdy(mA,dA,yearA)
format dFALTA %td
drop yA yearA dA mA


gen yB=int(FBAJA/100)
gen yearB=int(yB/100)
gen dB=FBAJA-(yB*100)
gen mB=yB-(yearB*100)
gen dFBAJA=mdy(mB,dB,yearB)
format dFBAJA %td
drop yB yearB dB mB


gen yAN=int(FANTIGEMP/100)
gen yearAN=int(yAN/100)
gen dAN=FANTIGEMP-(yAN*100)
gen mAN=yAN-(yearAN*100)
gen dFANTIGEMP=mdy(mAN,dAN,yearAN)
format dFANTIGEMP %td
drop yAN yearAN dAN mAN

replace FALTA = dFALTA
format FALTA %td
replace FBAJA = dFBAJA
format FBAJA %td
replace FANTIGEMP = dFANTIGEMP
format FANTIGEMP %td
drop dFALTA dFBAJA dFANTIGEMP

br FALTA FBAJA FANTIGEMP


* On average, how many observations are there per individual? 
bysort IDENTPERS: gen N=_N
sum N

* For numerate the observations it is important to sort before apply it
sort IDENTPERS FALTA FBAJA
bysort IDENTPERS: gen n=_n

br IDENTPERS FALTA FBAJA FANTIGEMP N n
sum N n

egen mean_obs=mean(N) if indiv==1
*21

* Number of individuals
egen indiv = tag(IDENTPERS)
tab indiv
* 285,207


*How long take on average each episode?
gen duration=FBAJA-FALTA
br IDENTPERS FALTA FBAJA duration
sum duration
count if duration<0
label var duration "Duration of each labor episode"

* We have negative numbers on duration
* There are some errors in the database, so we fix them: 

br IDENTPERS FALTA FBAJA duration if duration<0

gen FALTA_v2=FBAJA if duration<0
format FALTA_v2 %td

gen FBAJA_v2=FALTA if duration<0
format FBAJA_v2 %td

br IDENTPERS FALTA FALTA_v2 FBAJA FBAJA_v2 duration

replace FALTA=FALTA_v2 if duration<0
* (3,008 real changes made)

replace FBAJA=FBAJA_v2 if duration<0
* (3,008 real changes made)

drop FALTA_v2 FBAJA_v2 duration

gen duration=FBAJA-FALTA
sum duration

br IDENTPERS FALTA FBAJA if duration<0
* 363.6003 takes on average each episode

qui compress 

*FANTIGEMP: Starting date of the firm

save afiliados16_1.dta, replace 


********************************************************************************
********************************************************************************

clear all
set more off
capture log close


*3) CONVIVIENTES
* Information about people living with the reference person
* Census registration
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use "SDFMCVL2016CONVIVI.dta",clear

br
* 1==male 2==female

*I add day 1 to the dates. 

global varas FECHA*
foreach x of varlist $varas {
gen y`x'=int(`x'/100)
gen m`x'=`x'-y`x'*100
replace `x'=mdy(m`x',1,y`x')
format `x' %td
drop m`x' y`x'
}
*
sort IDENTPERS

*How many individuals do you have?
egen hnonmiss = rownonmiss(FECHA* SEXO*)
gen i_perHH=hnonmiss/2
drop hnonmiss

sum i_perHH
* Min of 1; max of 10 individuals pero HH
* The mean is 2.859
tab i_perHH


qui compress 
save convivientes16.dta, replace


********************************************************************************
********************************************************************************
clear all
set more off
capture log close


*4) COTIZACIÓN = CONTRIBUTION BASIS (wages proxy)
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use "SDFMCVL2016COTIZA1.dta",clear


* Monthly contribution in cents
sort IDENTPERS ANOCOT IDENTCCC2
br


*Which is the monthly average contribution of January 2015? and annual?
sum BASE1CCOM BASETOTALCCOM
* 76634.86 cents so, 766.3486€
* 935103.3 cents so, 935.1033€


*Self-employment:
use SDFMCVL2016COTIZA13.dta, clear

*Append all cotization dtas with a loop

/*This step might required powerful computers. 
If yours is not able to do it, don't worry, you can do it later on in a different way. 
Don't forget to save the do file before starting trying this step (Stata can collapse),
so you do not lose you work!
 */

clear all
set more off
capture log close
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 

use SDFMCVL2016COTIZA1.dta, clear
save data16.dta, replace

forvalues i = 2/12 {
use data16.dta, clear
    append using "SDFMCVL2016COTIZA`i'.dta"
save data16.dta, replace	
}

use "data16.dta", clear


*Sort the data, compress it and save it!
sort IDENTPERS ANOCOT IDENTCCC2 
qui compress

save "cotizacion16.dta", replace

********************************************************************************
********************************************************************************
clear all
set more off
capture log close
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 


*FINAL STEP: Merge the files you need. 
*In order to do the merge, both datasets need to be sorted in the same way.

use "afiliados16_1.dta",clear

*Just in case you did't do it before, sort the dataset now.
sort IDENTPERS FALTA FBAJA
save, replace


*Since I did not give you all afiliation files, just keep the individuals 
*available in the files I gave you (afiliacion1)

*How many individuals do you have? 
*(keep this figure in mind, so you can make some checks at the end)
*egen indiv = tag(IDENTPERS)
*tab indiv
* 285,207 individuals


* Another way to know how much individuals we have in the sample
* The accumulative sum (only because it is a sum of 1 and zero)
* egen total_indiv=sum(indiv)

save, replace


use "personal16.dta",clear
sort IDENTPERS 

merge IDENTPERS using "afiliados16_1.dta"
tab _merge

* When it takes value 1: it belongs to the master file, which is the
* first we open so, in our case, 922,925 came from "personal16.dta"
* 3: from both

sort IDENTPERS FALTA FBAJA
br IDENTPERS dbirth SEXO FALTA FBAJA _merge

keep if _merge==3
* (922,925 observations deleted)
qui compress
drop _merge
save "afiliacion_personal16.dta", replace
