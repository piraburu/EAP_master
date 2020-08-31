* Homework 2
* Odra Quesada Campos
********************************************************************************
* EXERCISE 2
clear all
set more off
capture log close
cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data" 
use afiliacion_personal16_2.dta, replace

br IDENTPERS dbirth FALTA FBAJA situ tipo COEFPARC

tab indiv
* We have 285,207 individuals same as n==N


* LABOR MARKET SITUATION AT FIRST OF OCTOBER 2016
* Overall
tab situlab if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
* pre-crisis 
tab situlab if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 


* By Gender 
tab situlab SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
tab situlab SEXO if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 

* By AGE GROUPS

*Try the histogram
histogram ageOct16

gen y_end_panel=mdy(10,1,2016)
format y_end_panel %td
gen ageOct16=y_end_panel-dbirth
replace ageOct16=int(ageOct16/365)
gen age_group=.
replace age_group=1 if ageOct16<30 
replace age_group=2 if ageOct16>=30 & ageOct16<44 
replace age_group=3 if ageOct16>=44

tab situlab age_group if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 
tab situlab age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 

* By Nationality
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

tab situlab nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
tab situlab nationality if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 

tab situlab inmigrants if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
tab situlab inmigrants if FALTA<=mdy(10,1,2006) & FBAJA>=mdy(10,1,2006) 

* Overall
graph bar if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
over(situlab) blabel(bar)

* by gender
graph bar if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), ///
over(SEXO) over (situlab) blabel(bar)


save "afi_pers16_ex2_3.dta", replace
********************************************************************************
* EXERCISE 3:
clear all
set more off
capture log close
cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data" 
use afi_pers16_ex2_3.dta, replace

gen hworked2=(COEFPARC/1000)*8
replace hworked2=8 if COEFPARC==0
drop hworked
rename hworked2 hworked


* ONLY FOR EMPLOYED INDIVIDUALS
tab tipo if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
br IDENTPERS dbirth situlab tipo if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 

tab tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 

tab tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 
tab tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 


tab tipo inmigrants if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 

* Employed individuals and hours worked
tab tipo if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)

tab tipo SEXO if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
tab tipo age_group if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)

tab tipo inmigrants if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)
tab tipo nationality if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016), sum (hworked)

********************************************************************************
clear all
set more off
capture log close


cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "panel_odrius.dta",clear

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


use panel_odrius.dta, clear
sort IDENTPERS
rename _merge merge
merge m:1 IDENTPERS using provinces_info.dta


save panel_odrius_2.dta, replace


********************************************************************************
********************************************************************************
* EXERCISE 1
* Personal data 
clear all
set more off
capture log close

cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "personal16.dta",clear

sort IDENTPERS 

merge IDENTPERS using "afiliados16_1.dta"
tab _merge
* When it takes value 1: it belongs to the master file, which is the
* first we open so, in our case, 922,925 
* came from "personal16.dta" 3: from both

sort IDENTPERS FALTA FBAJA
br IDENTPERS dbirth SEXO FALTA FBAJA _merge if _merge==1
* Those who are not matched have no data in FALTA FBAJA

* keep if _merge==3
*(922,925 observations deleted)
* We dropped out of the analysis those individuals that own personal16.

gen indiv_personal=1 if _merge==1
gen indiv_afiliados=1 if _merge==3
* We have people older than 45 years old
tab indiv _merge


egen indivp = tag(IDENTPERS)
tab indiv


********************************************************************************
* EXERCICE 4
clear all
set more off
capture log close


cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "panel_odrius_2.dta",clear

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
* We have been following these individuals since do file 3.

br * if indiv==.
drop if indiv==.

* Number of total observations
display 108564*22

des



********************************************************************************
* EXERCISE 5: TRYING TO MERGE CONVIVIENTS
clear all
set more off
capture log close


cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "panel_odrius_thursday.dta",clear

drop _merge
sort IDENTPERS 
merge IDENTPERS using "conv16.dta"

tab _merge

* After the merge 107652 individuals with convivients data
* We had 108,564 (we loose less than 1000)????
rename DOMICILIO residence

save, replace


********************************************************************************
bysort IDENTPERS: gen hworked2=8 if hworked==8
bysort IDENTPERS: replace hworked2=8-hworked
bysort IDENTPERS: replace hworked2=8 if hworked2==0
drop hworked
rename hworked2 hworked

save, replace

********************************************************************************
clear all
set more off
capture log close


cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "panel_odrius_thursday.dta",clear


* Exercise 1a)
tab gender if indiv==1

*AGE at 2006
gen year2006=mdy(1,1,2006)
format year2006 %td

gen agejan06=year2006-dbirth
replace agejan06=int(agejan06/365)
drop year2006

histogram agejan06 if indiv==1, ///
percent fcolor(olive_teal) barwidth(1) gap(7) addlabel scheme(sj)

*RESIDENCE (use somewhere?)
replace residence=int(residence/1000)
tab residence

sort IDENTPERS t FALTA FBAJA
save, replace

gen byte andal=1 if  residence==4 |  residence==11 |  residence==14 |  residence==18 |  residence==21 |  residence==23 |  residence==29 |  residence==41 
replace andal=0 if andal==.
gen byte aragon=1 if  residence==22 |  residence==44 |  residence==50
replace aragon=0 if aragon==.
gen byte astur=1 if  residence==33
replace astur=0 if astur==.
gen byte balear=1 if  residence==7
replace balear=0 if balear==.
gen byte canar=1 if  residence==35 |  residence==38
replace canar=0 if canar==.
gen byte cantab=1 if  residence==39
replace cantab=0 if cantab==.
gen byte castman=1 if  residence==2 |  residence==13 |  residence==16 |  residence==19 |  residence==45
replace castman=0 if castman==.
gen byte castleon=1 if  residence==5 |  residence==9 |  residence==24 |  residence==34 |  residence==37 |  residence==40 |  residence==42 |  residence==47 |  residence==49
replace castleon=0 if castleon==.
gen byte catal=1 if  residence==8 |  residence==17 |  residence==25 |  residence==43
replace catal=0 if catal==.
gen byte valenc=1 if  residence==3 |  residence==12 |  residence==46
replace valenc=0 if valenc==.
gen byte extrem=1 if  residence==6 |  residence==10
replace extrem=0 if extrem==.
gen byte galic=1 if  residence==15 |  residence==27 |  residence==32 |  residence==36
replace galic=0 if galic==.
gen byte madrid=1 if  residence==28
replace madrid=0 if madrid==.
gen byte murcia=1 if  residence==30
replace murcia=0 if murcia==.
gen byte navarr=1 if  residence==31
replace navarr=0 if navarr==.
gen byte vasco=1 if  residence==1 |  residence==20 |  residence==48
replace vasco=0 if vasco==.
gen byte rioja=1 if  residence==26
replace rioja=0 if rioja==.
gen ceumel=1 if  residence==51 |  residence==52
replace ceumel=0 if ceumel==.
gen no_residence=1 if residence==0
replace no_residence=0 if no_residence==.


save, replace

gen inmigrant=1 if paisnac!="N00"
replace inmigrant=0 if paisnac=="N00"


* Exercise 1b)
tab gender if indiv==1


* TYPE OF CONTRACT
tab tipo gender if FALTA<=mdy(10,1,2016) & FBAJA>=mdy(10,1,2016) 


* HOURS WORKED
bysort t: egen avg_hworked=mean(hworked)
bysort t: egen avg_hworked_male=mean(hworked) if gender==1
bysort t: egen avg_hworked_female=mean(hworked) if gender==2
sort IDENTPERS t

twoway (line avg_hworked_male cycle, sort) ///
(line avg_hworked_female cycle, sort)

graph set window fontface "LM Roman 10"


save "panel_friday.dta", replace


tab situlab gender if t==1
tab situlab gender if t==22

tab tipo gender if t==1
tab tipo gender if t==22

tab gender if t==1, sum (hworked)
tab gender if t==22, sum (hworked)

tab hworked gender if t==1

* MONTHLY WAGES
bysort t: egen avg_hworked=mean(hworked)
bysort t: egen avg_hworked_male=mean(hworked) if gender==1
bysort t: egen avg_hworked_female=mean(hworked) if gender==2


br IDENTPERS t gender wage monthly_wages	
tab gender if t==1, sum (wage)
sum monthly_wages
tab gender if t==22, sum (wage)

bysort IDENTPERS: gen wage_day=(wage/22) if situlab==1
bysort IDENTPERS: gen hourly_wage=(wage_day/hworked) if situlab==1
drop wage_day 
br IDENTPERS t gender wage monthly_wages 

sum hourly_wages

tab gender if t==1, sum (hourly_wage)
tab gender if t==22, sum (hourly_wage)

corr age_oct16 monthly_wages

qui compress
save, replace

********************************************************************************
*EXERCISE 2
clear all
set more off
capture log close


cd "C:\Users\ENCARNA\Desktop\Labor_Markets\Data"
use "panel_friday.dta",clear

*inmigrants
gen inmigrants=.
replace inmigrants=1 if paisnac!="N00"
replace inmigrants=0 if paisnac=="N00"
bysort t: egen hourly_wages_inm=mean(hourly_wage) if inmigrants==1
bysort t: egen hourly_wages_nat=mean(hourly_wage) if inmigrants==0

tab inmigrants if inmigrants==0, sum (hourly_wage)



twoway (connected avg_hworked_male cycle, sort lcolor(blue) lwidth(medium) lpattern(solid) msize(small)) ///
(connected avg_hworked_female cycle, sort lcolor(pink) lwidth(medium) lpattern(solid) msize(small))


bysort t: egen hourly_wages_male=mean(hourly_wage) if gender==1
bysort t: egen hourly_wages_female=mean(hourly_wage) if gender==2

bysort t: egen monthly_wages_male=mean(wage) if gender==1
bysort t: egen monthly_wages_female=mean(wage) if gender==2



bysort IDENTPERS: gen cduration=FBAJA - FALTA if situlab==1
label var cduration "Contract duration"

* Cantidad de días que has estado empleado hasta el inicio del contrato
bysort IDENTPERS: gen before_curr= current_empdur - cduration if situlab==1
bysort IDENTPERS: gen ternure=cycle-FALTA if situlab==1 
bysort IDENTPERS: gen labor_experience=before_curr+ternure if situlab==1

* As the last spell
bysort IDENTPERS: gen experience=labor_experience
forval x=1/22{
set more off
bysort IDENTPERS: replace experience=labor_experience[_n-`x'] if experience==.
}
*
* Now we can drop experience
drop labor_experience
rename experience labor_experience
label var labor_experience "Labor life experience"


* Until de starting day of the cycle

*NEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEW
*Negative values in experience
bysort IDENTPERS: gen experience=labor_experience
forval x=1/22{
set more off
bysort IDENTPERS: replace experience=esperience[_n-`x'] if experience<0
}
*
rename ternure tenure
save "panel_friday_v2", replace




























