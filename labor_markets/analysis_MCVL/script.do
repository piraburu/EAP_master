********************************************************************************
********************************************************************************
*                                     PART I                                   *
*                                                                              *
********************************************************************************
********************************************************************************



********************************************************************************
* EXERCISE 1
* 
* Report (i) % and absolute number of individuals included in Personal but
* not In Afiliados, (ii) % and absolute number of individuals included in 
* both files.Can you explain the reason for having disparities in 
* the number of observations of each file?

log using log, replace

clear all
set more off


cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA"
use "personal16.dta",clear

sort IDENTPERS 

merge IDENTPERS using "afiliados16_1.dta"
tab _merge

* The value of 1 means that they belong only to the master file (Personal)
* 922,925 
* And a value of 3 if they are in both of them
* 6,047,437

sort IDENTPERS FALTA FBAJA
br IDENTPERS dbirth SEXO FALTA FBAJA _merge if _merge==1
* Those who are not matched have no data in FALTA FBAJA

* We loose information because we do not have information for those
* individuals that are not present in the afiliacion database.
* How many individuals are in both databases? We can check this:

tab indiv _merge

********************************************************************************
* EXERCISE 2
*
*
*
*


clear all
set more off

cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use afiliacion_personal16_2.dta, replace

tab indiv
* We have 285,207 individuals same as n==N


* Labor Market situation
* 2016
tab situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
* 2006
tab situlab if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 


* By Gender 
tab situlab SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), co 
tab situlab SEXO if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006), co 
*
label define sexo 1"Men" 2"Women"
label values SEXO sexo 
tab situlab SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), co

splitvallabels situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)  
catplot SEXO situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
percent(SEXO) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\hist_gender.png", as(png) replace


* By Age Groups
gen y_end_panel=mdy(10,1,2016)
format y_end_panel %td
gen ageOct16=y_end_panel-dbirth
replace ageOct16=int(ageOct16/365)
gen age_group=.
replace age_group=1 if ageOct16<30 
replace age_group=2 if ageOct16>=30 & ageOct16<44 
replace age_group=3 if ageOct16>=44

histogram ageOct16

tab situlab age_group if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006),co 
tab situlab age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co


tab situlab age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), co

splitvallabels situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)  
catplot age_group situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
percent(age_group) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\hist_age.png", as(png) replace



* By Nationalities and by inmigrant status:
gen inmigrants=.
replace inmigrants=1 if PAISNAC!="N00"
replace inmigrants=0 if PAISNAC=="N00"

gen nationality=.
replace nationality=1 if PAISNAC=="N01" | PAISNAC=="N10" | ///
PAISNAC=="N11" | PAISNAC=="N15" | PAISNAC=="N16" | PAISNAC=="N19"
replace nationality=2 if PAISNAC=="N12" | PAISNAC=="N23" 
replace nationality=3 if PAISNAC=="N06" | PAISNAC=="N03" | PAISNAC=="N07" | ///
PAISNAC=="N08" | PAISNAC=="N09" | PAISNAC=="N13" | PAISNAC=="N22" | ///
PAISNAC=="N26" | PAISNAC=="N27"
tab nationality, miss
replace nationality=4 if nationality==. & PAISNAC!="N00"
replace nationality=5 if PAISNAC=="N00"

tab situlab nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co 
tab situlab nationality if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006),co

tab situlab inmigrants if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co 
tab situlab inmigrants if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006),co 



label define natgroups 1"EU12" 2"Africa" 3"South America" 4"Others" 5 "Spanish", replace
label values nationality natgroups
tab situlab nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), co

splitvallabels situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)  
catplot nationality situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
percent(nationality) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\hist_nation.png", as(png) replace







* Overall
graph bar if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
over(SEXO) over(situlab) blabel(bar)

* by inmigrants
graph bar if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
over(inmigrants) over (situlab) blabel(bar)


save "ex2.dta", replace

********************************************************************************
* EXERCISE 3:
*
clear all
set more off

cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use ex2.dta, replace

gen hworked2=(COEFPARC/1000)*8
replace hworked2=8 if COEFPARC==0
drop hworked
rename hworked2 hworked


* Employed individuals only: contract type

* All
tab tipo if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
* By gender
tab tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co 
* AGE 
tab tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co 
* NATIONALITY
tab tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016),co 


* Employed individuals only: worked hours

* All
tab tipo if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
* By gender
tab tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
* AGE 
tab tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
* NATIONALITY
tab tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
*****************


* BY GENDER
tab tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)
catplot tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
	percent(SEXO) asyvars stack bar(1, bcolor(lime)) bar(2, bcolor(dkgreen)) ///
	bar(3, bcolor(sienna)) bar(4, bcolor(brown))
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\h_gender_t.png", as(png) replace


* BY AGE
tab tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)
catplot tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
	percent(age_group) asyvars stack bar(1, bcolor(lime)) bar(2, bcolor(dkgreen)) ///
	bar(3, bcolor(sienna)) bar(4, bcolor(brown))
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\h_age_t.png", as(png) replace


* BY NATIONALITY
tab tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016)
catplot tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
	percent(nationality) asyvars stack bar(1, bcolor(lime)) bar(2, bcolor(green)) ///
	bar(3, bcolor(sienna)) bar(4, bcolor(nrown))
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\h_nation_t.png", as(png) replace




********************************************************************************
clear all
set more off



cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA"
use "data.dta",clear

label var age_oct16 "Age of the individual at October 2016"
label var age_cycle "Age of the individual at that cycle"
label var age_cycle "Age of the individual at that cycle"
label var minFALTAwm "Labor experience-Starting working day"

save, replace
* 108,564 individuals


* We have to include data from residence.
use SDFMCVL2016PERSONAL.dta, clear
keep IDENTPERS DOMICILIO PROVPRIAF

sort IDENTPERS
save provinces_info.dta, replace


use data.dta, clear
sort IDENTPERS
rename _merge merge
merge m:1 IDENTPERS using provinces_info.dta


save data_2.dta, replace

eststo clear
eststo: regress hworked i.age_group
esttab using regols.tex, ar2 label  ///
  title("Regressing Worked Hours by Age groups")
  

********************************************************************************
* EXER. 4
clear all
set more off



cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA"
use "data_2.dta",clear

label var FALTA "Staring date of afiliation episode on the Social Security"
label var FBAJA "Ending date of afiliation episode on the Social Security"

*Compute total time as employed, self-employed and unemployed at each t 
*with using current_empdur current_selfempdur current_unempdur

label var wage "Proxy of wages for each cycle"
label var year "Year"
label var nindef_t "Number of indefinite contracts in each cycle per individual"
label var ntemp_t "Number of temporary contracts in each cycle per individual"
label var time_emp "Number of temporary contracts in each cycle per individual"

save, replace

* I have 108564 individuals after I dropped out 6713 (so, we had 115,277)

drop if indiv==.

* Number of total observations
display 108564*22

des

********************************************************************************
* EXERCISE 5: 
*
* MERGING CONVIVIENTES FOR NEXT PART
clear all
set more off



cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA"
use "data_2.dta",clear

drop _merge
sort IDENTPERS 
merge IDENTPERS using "convivientes16.dta"

tab _merge

*rename DOMICILIO residence

save, replace

********************************************************************************

bysort IDENTPERS: gen hworked2=8 if hworked==8
bysort IDENTPERS: replace hworked2=8-hworked
bysort IDENTPERS: replace hworked2=8 if hworked2==0
drop hworked
rename hworked2 hworked

save, replace


********************************************************************************

********************************************************************************
********************************************************************************
*                                     PART II                                  *
*                                                                              *
********************************************************************************
********************************************************************************
	
	
********************************************************************************
* EXERCISE 1: 	
* A) 
	
* Exercise 1a)
tab gender if indiv==1

* Age at the start of the time period:

gen year2006=mdy(1,1,2006)
format year2006 %td
gen agejan06=year2006-dbirth
replace agejan06=int(agejan06/365)
drop year2006
histogram ageOct16 if indiv==1, ///
percent fcolor(mint) barwidth(1) gap(7) addlabel 

*RESIDENCE 
replace residence=int(residence/1000)
tab residence

gen inmigrant=1 if paisnac!="N00"
replace inmigrant=0 if paisnac=="N00"

* NATIONALITY

gen nationality=.
replace nationality=1 if paisnac=="N01" | paisnac=="N10" | ///
paisnac=="N11" | paisnac=="N15" | paisnac=="N16" | paisnac=="N19"
replace nationality=2 if paisnac=="N12" | paisnac=="N23" 
replace nationality=3 if paisnac=="N06" | paisnac=="N03" | paisnac=="N07" | ///
paisnac=="N08" | paisnac=="N09" | paisnac=="N13" | paisnac=="N22" | ///
paisnac=="N26" | paisnac=="N27"
replace nationality=4 if nationality==. & paisnac!="N00"
replace nationality=5 if paisnac=="N00"

tab nationality if indiv==1
********************************************************************************
* EXERCISE 1: 	
* B) 
* CREATING VARIABLES


* SITLAB: LABOR SITUATION

* TYPE OF CONTRACT: TIPO

* HOURS WORKED:
bysort t: egen avg_hworked=mean(hworked)


* MONTHLY WAGES:
bysort t: egen monthly_wages=mean(wage) 
bysort t: egen monthly_wages_eu12=mean(wage) if nationality==1
bysort t: egen monthly_wages_africa=mean(wage) if nationality==2
bysort t: egen monthly_wages_latinos=mean(wage) if nationality==3
bysort t: egen monthly_wages_others=mean(wage) if nationality==4
bysort t: egen monthly_wages_spain=mean(wage) if nationality==5
* HOURLY WAGES:

bysort IDENTPERS: gen wage_day=(wage/22) if situlab==1
bysort IDENTPERS: gen hourly_wage=(wage_day/hworked) if situlab==1
drop wage_day 
bysort t: egen hourly_wages_eu12=mean(hourly_wage) if nationality==1
bysort t: egen hourly_wages_africa=mean(hourly_wage) if nationality==2
bysort t: egen hourly_wages_latinos=mean(hourly_wage) if nationality==3
bysort t: egen hourly_wages_others=mean(hourly_wage) if nationality==4
bysort t: egen hourly_wages_spain=mean(hourly_wage) if nationality==5

*----------

* LABOR SITUATION BY NATIONALITY

tab situlab nationality if t==1 & indiv==1,co
tab situlab nationality if t==22,co

tab situlab age_group if t==1

label define natgroups 1 "EU12" 2"Africa" 3"South America" 4"Others" 5 "Spain", replace
label values nationality natgroups

splitvallabels situlab if t==1  
catplot nationality situlab if t==1, ///
percent(nationality) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\1.png", as(png) replace

splitvallabels situlab if t==22 
catplot nationality situlab if t==22, ///
percent(nationality) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\2.png", as(png) replace


* TYPE OF CONTRACT
tab tipo nationality if t==1 & indiv==1,co
tab tipo nationality if  t==22,co 


splitvallabels tipo if t==1  
catplot nationality tipo if t==1, ///
percent(nationality) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\3.png", as(png) replace

splitvallabels tipo if t==22 
catplot nationality tipo if t==22, ///
percent(nationality) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("%", size(small)) ///
blabel(bar, format(%4.1f)) ///
intensity(25) ///
asyvars
graph export "C:\Users\pimpeter\Desktop\LABOR_2\figures\4.png", as(png) replace



* HOURS WORKED
tab nationality if t==1, sum (hworked)
tab nationality if t==22, sum (hworked)



* MONTHLY WAGES

sum monthly_wages_eu12 monthly_wages_africa monthly_wages_latinos ///
    monthly_wages_others monthly_wages_spain if t==1

sum monthly_wages_eu12 monthly_wages_africa monthly_wages_latinos ///
    monthly_wages_others monthly_wages_spain if t==22


	
	
	
* HOURLY WAGES
sum hourly_wages_eu12 hourly_wages_africa hourly_wages_latinos ///
    hourly_wages_others hourly_wages_spain if t==1

sum hourly_wages_eu12 hourly_wages_africa hourly_wages_latinos ///
    hourly_wages_others hourly_wages_spain if t==22

	
* OTHERS
*latinosvsus spanish monthly wages
twoway (line monthly_wages_spain cycle, sort) ///
(line monthly_wages_latinos cycle, sort)

graph set window fontface "LM Roman 10"

*latinos vsus spanish hourly wages
twoway (line hourly_wages_spain cycle, sort) ///
(line hourly_wages_latinos cycle, sort)

graph set window fontface "LM Roman 10"


*regression
  eststo clear
eststo: reg hourly_wage ib5.nationality i.tipo hworked
esttab using rege.tex, ar2 label  ///
  title("Regressing Hourly Wages")


********************************************************************************
* EXERCISE 2: 	

* INMIGRANTS

gen inmigrants=.
replace inmigrants=1 if paisnac!="N00"
replace inmigrants=0 if paisnac=="N00"

bysort t: egen hourly_wages_inmigrant=mean(hourly_wage) if inmigrants==1
bysort t: egen hourly_wages_spanish=mean(hourly_wage) if inmigrants==0

bysort t: egen monthly_wages_inmigrant=mean(monthly_wages) if inmigrants==1
bysort t: egen monthly_wages_spanish=mean(monthly_wages) if inmigrants==0

* hourly graph
twoway (connected hourly_wages_inmigrant cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hourly_wages_spanish cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))

* monthly graph

twoway (connected monthly_wages_eu12 cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_spanish cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_africa cycle, sort lcolor(black) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_latinos cycle, sort lcolor(brown) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_others cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))

* 4 TYPES OF INMIGRANTS

* hourly graph
twoway (connected hourly_wages_eu12 cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hourly_wages_africa cycle, sort lcolor(black) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hourly_wages_latinos cycle, sort lcolor(brown) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hourly_wages_others cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))


* monthly graph
twoway (connected monthly_wages_eu12 cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_africa cycle, sort lcolor(black) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_latinos cycle, sort lcolor(brown) lwidth(medium) lpattern(solid) msize(small)) ///
(connected monthly_wages_others cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))


********************************************************************************
* EXERCISE 3: 
	
* INMIGRANTS
bysort t: egen hworked_inmigrant=mean(hworked) if inmigrants==1
bysort t: egen hworked_spanish=mean(hworked) if inmigrants==0

* hworked graph
twoway (connected hworked_inmigrant cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hworked_spanish cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))

* % unemployment
tab situlab if inmigrants==1
tab situlab if inmigrants==0

* 4 TYPES OF INMIGRANTS
* monthly graph
bysort t: egen hworked_eu=mean(hworked) if nationality==1
bysort t: egen hworked_africa=mean(hworked) if nationality==2
bysort t: egen hworked_latinos=mean(hworked) if nationality==3
bysort t: egen hworked_others=mean(hworked) if nationality==4

twoway (connected hworked_eu cycle, sort lcolor(green) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hworked_africa cycle, sort lcolor(black) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hworked_latinos cycle, sort lcolor(brown) lwidth(medium) lpattern(solid) msize(small)) ///
(connected hworked_others cycle, sort lcolor(red) lwidth(medium) lpattern(solid) msize(small))



********************************************************************************
* EXERCISE 4: 
********************************************************************************
********************************************************************************
************ REGRESIONS
********************************************************************************
********************************************************************************

* A) HOURLY WAGE CHANGE


tabstat hourly_wage, statistics(mean median sd p25 p50 p75)

* Creating LN wage
bysort IDENTPERS: gen ln_h_wage=log(hourly_wage)
bysort IDENTPERS: gen ln_hourly_wage_rate =ln_h_wage[_n]-ln_h_wage[_n-1] 
bysort IDENTPERS: gen hourly_wage_change =hourly_wage[_n]-hourly_wage[_n-1] 
bysort IDENTPERS: gen l_hourly_wage_change =log(hourly_wage_change)

replace l_hourly_wage_change=. if l_hourly_wage_change<0

*regresiones
eststo clear
eststo: xtreg l_hourly_wage_change inmigrant, i(cycle) fe
esttab using r1.tex, ar2 label  ///
title("Regressing log(hourly_wage_change)")

 eststo clear
eststo: xtreg ln_h_wage inmigrant, i(cycle) fe
esttab using r2.tex, ar2 label  ///
title("Regressing log(hourly_wage)")




* B) HOURLY WAGE CHANGE
*
gen level_inmigrants= nationality
replace level_inmigrants=. if nationality==5

 eststo clear
eststo: xtreg ln_h_wage ib4.level_inmigrants, i(cycle) fe
esttab using r3.tex, ar2 label  ///
  title("Regressing log(hourly_wage)")

  
 eststo clear
eststo: xtreg l_hourly_wage_change ib4.level_inmigrants, i(cycle) fe
esttab using r4.tex, ar2 label  ///
  title("Regressing log(hourly_wage)")








*___________________________________


* C) INCLUDING HOURS WORKED IN REGRESSIONS A & B
*
	* a
eststo clear
eststo: xtreg ln_h_wage inmigrant hworked, i(cycle) fe
esttab using r5.tex, ar2 label  ///
  title("Regressing log(hourly_wage)")
  
eststo clear
eststo: xtreg l_hourly_wage_change inmigrant hworked, i(cycle) fe
esttab using r6.tex, ar2 label  ///
  title("Regressing log(hourly_wage_change)")
  
	* b
	
	eststo clear
eststo: xtreg ln_h_wage ib4.level_inmigrants hworked, i(cycle) fe
esttab using r7.tex, ar2 label  ///
  title("Regressing log(hourly_wage)")
  
eststo clear
eststo: xtreg l_hourly_wage_change ib4.level_inmigrants hworked, i(cycle) fe
esttab using r8.tex, ar2 label  ///
  title("Regressing log(hourly_wage_change)")
	
	
	
	
	
	



* D) LABOUR EXPERIENCE CATEGORIES
	* Removing negative experience
	*Negative values in experience
bysort IDENTPERS: gen experience=labor_experience
forval x=1/22{
set more off
bysort IDENTPERS: replace experience=experience[_n-`x'] if experience<0
}


* Generating variable with experience categories
gen exp_cat =.
replace exp_cat = 1 if labor_experience <= 182
replace exp_cat = 2 if labor_experience > 182 & labor_experience <= 365
replace exp_cat = 3 if labor_experience > 365 & labor_experience <= 730
replace exp_cat = 4 if labor_experience > 730 & labor_experience <= 1095
replace exp_cat = 5 if labor_experience > 1095 & labor_experience <= 1040
replace exp_cat = 6 if labor_experience > 1040
* Regression
gen y_end_panel=mdy(10,1,2016)
format y_end_panel %td
gen ageOct16=y_end_panel-dbirth
replace ageOct16=int(ageOct16/365)

eststo clear
eststo: xtreg ln_h_wage hworked ib4.level_inmigrants gender i.exp_cat ageOct16, i(cycle) fe
esttab using r9.tex, ar2 label  ///
title("Regressing log(hourly_wage)")
  
  eststo clear
eststo: xtreg l_hourly_wage_change hworked ib4.level_inmigrants gender i.exp_cat ageOct16, i(cycle) fe
esttab using r10.tex, ar2 label  ///
 title("Regressing log(hourly_wage_change)")
	
	
xtreg ln_h_wage hworked ib4.level_inmigrants gender i.exp_cat ageOct16, i(cycle) fe
xtreg ln_hourly_wage_rate hworked ib4.level_inmigrants gender i.exp_cat ageOct16, i(cycle) fe

log close





