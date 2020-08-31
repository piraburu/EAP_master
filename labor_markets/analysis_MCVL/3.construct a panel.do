
clear all
set more off
cd "C:\Users\Usuario\Documents\Máster\Labour\Tarea2" 

use "afiliacion_personal16_2.dta",clear


*STEP 1: create the list of individuals we want to focus on.
br IDENTPERS dbirth age FALTA FBAJA situ tipo hworked

*We need individuals with info since 2006
bysort IDENTPERS: egen maxFBAJA=max(FBAJA)
format maxFBAJA %td 
drop if maxFBAJA<mdy(5,1,2006)
*Please, do not simply copy it! Try to understand it!!!!

*Drop all those older than 45 in October 2016
gen ageOct16= 2016 - year(dbirth) - (month(dbirth) >= 10)
keep if ageOct16<45


*How many individuals do you have in your dataset? 
*I recomend you to generate n and N again
drop n N
bysort IDENTPERS: gen N=_N
bysort IDENTPERS: gen n=_n


...

sort IDENTPERS FALTA FBAJA 
save pre_panel0.dta,replace

***************************************************************************



*STEP 2: Prepare the variables before generating the panel.

use pre_panel0.dta, clear


*Does the observation belong to each cycle?
*We have 11 years * 2 obs/year = 22 cycles: from 1/5/2006 to  1/10/2016
*br IDENTPERS dbirth FALTA FBAJA 

*1) Let's generate the cycles: 
gen cycle1=0
replace cycle1=1 if FALTA<= mdy(5,1,2006) & FBAJA> mdy(5,1,2006)
gen cycle2=0
replace cycle2=1 if FALTA<= mdy(10,1,2006) & FBAJA> mdy(10,1,2006)
gen cycle3=0
replace cycle3=1 if FALTA<= mdy(5, 1,2007) & FBAJA> mdy(5,1,2007)
gen cycle4=0 
replace cycle4=1 if FALTA<= mdy(10,1,2007) & FBAJA> mdy(10,1,2007)
gen cycle5=0
replace cycle5=1 if FALTA<= mdy(5, 1,2008) & FBAJA> mdy(5,1,2008)
gen cycle6=0 
replace cycle6=1 if FALTA<= mdy(10,1,2008) & FBAJA> mdy(10,1,2008)
gen cycle7=0
replace cycle7=1 if FALTA<= mdy(5, 1,2009) & FBAJA> mdy(5,1,2009)
gen cycle8=0 
replace cycle8=1 if FALTA<= mdy(10,1,2009) & FBAJA> mdy(10,1,2009)
gen cycle9=0
replace cycle9=1 if FALTA<= mdy(5, 1,2010) & FBAJA> mdy(5,1,2010)
gen cycle10=0 
replace cycle10=1 if FALTA<= mdy(10,1,2010) & FBAJA> mdy(10,1,2010)
gen cycle11=0
replace cycle11=1 if FALTA<= mdy(5, 1,2011) & FBAJA> mdy(5,1,2011)
gen cycle12=0 
replace cycle12=1 if FALTA<= mdy(10,1,2011) & FBAJA> mdy(10,1,2011)
gen cycle13=0
replace cycle13=1 if FALTA<= mdy(5, 1,2012) & FBAJA> mdy(5,1,2012)
gen cycle14=0 
replace cycle14=1 if FALTA<= mdy(10,1,2012) & FBAJA> mdy(10,1,2012)
gen cycle15=0
replace cycle15=1 if FALTA<= mdy(5, 1,2013) & FBAJA> mdy(5,1,2013)
gen cycle16=0 
replace cycle16=1 if FALTA<= mdy(10,1,2013) & FBAJA> mdy(10,1,2013)
gen cycle17=0
replace cycle17=1 if FALTA<= mdy(5, 1,2014) & FBAJA> mdy(5,1,2014)
gen cycle18=0 
replace cycle18=1 if FALTA<= mdy(10,1,2014) & FBAJA> mdy(10,1,2014)
gen cycle19=0
replace cycle19=1 if FALTA<= mdy(5, 1,2015) & FBAJA> mdy(5,1,2015)
gen cycle20=0 
replace cycle20=1 if FALTA<= mdy(10,1,2015) & FBAJA> mdy(10,1,2015)
gen cycle21=0
replace cycle21=1 if FALTA<= mdy(5, 1,2016) & FBAJA> mdy(5,1,2016)
gen cycle22=0 
replace cycle22=1 if FALTA<= mdy(10,1,2016) & FBAJA> mdy(10,1,2016)

*Check if it worked!!!!!





*Create some variables you will need for the estimations:

*2)You will need to know the labour experience, therefore you need to know the starting working day: 
*br IDENTPERS dbirth FALTA FBAJA 
gen FALTAemp=FALTA if situlab<3
format FALTAemp %td
bysort IDENTPERS: egen minFALTA = min(FALTAemp)
format minFALTA %td
drop FALTAemp

*Drop all auxiliar variables you create. The dataset is quiet big, so you better keep only important variables.



*3)Total time as employed, self-employed and unemployed until current contract
gen empdur=duration if situlab==1
*bysort IDENTPERS: egen current_empdur=sum(empdur)
bysort IDENTPERS: gen current_empdur=sum(empdur) 
*Notice these two command compute different things, which one do you need?
drop empdur

*Do the same with the self-employment and unemployment time.
/* SELF-EMPLOYMENT */
gen sempdur=duration if situlab==2
bysort IDENTPERS: gen current_sempdur=sum(sempdur) 
drop sempdur
/* UNEMPLOYMENT */
gen unempdur=duration if situlab==3
bysort IDENTPERS: gen current_unempdur=sum(unempdur)
drop unempdur

*4)Nº of indefinite and temporary contract until current contract: 
gen temp=1 if tipo==3|tipo==4
bysort IDENTPERS: gen ntemp=sum(temp)
drop temp 

gen indef=1 if tipo==1|tipo==2
bysort IDENTPERS: gen nindef=sum(indef)
drop indef


sort IDENTPERS FALTA FBAJA 
save pre_panel1.dta, replace





**************

*STEP 3: Prepare the variables in WIDE format .


/*
In order to generate the panel, we are using reshape from wide to long. 

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
*/

clear all
set more off
cd "C:\Users\Usuario\Documents\Máster\Labour\Tarea2" 
use pre_panel1.dta,replace



* Now you have to generate 22 variables of each variable of interest regarding each of the 22 periods:

*You can do it for example with the following loops (there might be other ways). *(The loop might take some time)

br IDENTPERS dbirth FALTA FBAJA situlab cycle* 

*Situlab
qui forval x=1/22{
	*(I have only generate 10 cycles, you need to create 22)
set more off
gen situlab`x'=situlab if cycle`x'==1
bysort IDENTPERS: egen Situlab`x'=min(situlab`x')
drop situlab`x'
rename Situlab`x' situlab`x'
}
****Try to understand the loop!!!!!!
br IDENTPERS dbirth situlab1
*Do the same with all the variables you need: 

*Tipo
qui forval x=1/22{
set more off
gen tipo`x'=tipo if cycle`x'==1
bysort IDENTPERS: egen Tipo`x'=min(tipo`x')
drop tipo`x'
rename Tipo`x' tipo`x'
}

*GRUPCOT
qui forval x=1/22{
set more off
gen grupcot`x'=GRUPCOT if cycle`x'==1
bysort IDENTPERS: egen Grupcot`x'=min(grupcot`x')
drop grupcot`x'
rename Grupcot`x' grupcot`x'
}

*FALTA
qui forval x=1/22{
set more off
gen FALTA`x'=FALTA if cycle`x'==1
bysort IDENTPERS: egen FALTA_`x'=min(FALTA`x')
drop FALTA`x'
rename FALTA_`x' FALTA`x'
}

*FBAJA
qui forval x=1/22{
set more off
gen FBAJA`x'=FBAJA if cycle`x'==1
bysort IDENTPERS: egen FBAJA_`x'=min(FBAJA`x')
drop FBAJA`x'
rename FBAJA_`x' FBAJA`x'
}

format FALTA* FBAJA* %td


*Some other variables you might want to include in your panel: 
*Worked related: minFALTA current_empdur current_selfempdur current_unempdur ntemp nindef hworked tipo situlab CNAE09 GRUPCOT
*Personal info: dbirth or age SEXO NACIONALIDAD PROVNAC 

*Do you need to do the same with worked and personal variables? Personal variables do not change over time.


forval x=1/22{
set more off
gen gender`x'=SEXO
}
drop SEXO
drop empdur1 sempdur1 unempdur1

* Tiempo trabajado / parado hasta el primer ciclo:
	* Solo se suman contratos acabados antes del primer ciclo
	bysort IDENTPERS: egen empdur_2006_1 = sum(duration) if situlab==1 & FBAJA<mdy(5,1,2006)
	bysort IDENTPERS: egen sempdur_2006_1 = sum(duration) if situlab==2 & FBAJA<mdy(5,1,2006)
	bysort IDENTPERS: egen unempdur_2006_1 = sum(duration) if situlab==3 & FBAJA<mdy(5,1,2006)
	* Sumar contratos empezados antes del primer ciclo pero acabados después
	bysort IDENTPERS: egen empdur_2006_2 = sum(mdy(5,1,2006)-FALTA) if situlab==1 & FBAJA>mdy(5,1,2006) & FALTA<mdy(5,1,2006)
	bysort IDENTPERS: egen sempdur_2006_2 = sum(mdy(5,1,2006)-FALTA) if situlab==2 & FBAJA>mdy(5,1,2006) & FALTA<mdy(5,1,2006)
	bysort IDENTPERS: egen unempdur_2006_2 = sum(mdy(5,1,2006)-FALTA) if situlab==3 & FBAJA>mdy(5,1,2006) & FALTA<mdy(5,1,2006)
	* Convertir missings en 0
	replace empdur_2006_1 = 0 if empdur_2006_1==.
	replace empdur_2006_2 = 0 if empdur_2006_2==.
	replace sempdur_2006_1 = 0 if sempdur_2006_1==.
	replace sempdur_2006_2 = 0 if sempdur_2006_2==.
	replace unempdur_2006_1 = 0 if unempdur_2006_1==.
	replace unempdur_2006_2 = 0 if unempdur_2006_2==.
	* Suma de las dos anteriores
	bysort IDENTPERS: egen empdur1 = sum(empdur_2006_1 + empdur_2006_2)
	bysort IDENTPERS: egen sempdur1 = sum(sempdur_2006_1 + sempdur_2006_2)
	bysort IDENTPERS: egen unempdur1 = sum(unempdur_2006_1 + unempdur_2006_2)
	* Desechar auxiliares
	drop empdur_2006_1 empdur_2006_2 sempdur_2006_1 sempdur_2006_2 unempdur_2006_1 unempdur_2006_2
	
* Tiempo empleado en cada ciclo (x empieza en 2 porque el 1 lo acabamos de calcular
qui forval x=2/3 {
	set more off
	* No hace falta incluir la condición (cycle`x'==1) porque ya estamos condicionando con FALTA y FBAJA
	if (mod(`x', 2)==1) {
		/* If in an odd cycle (1, 3, 5, ...) then we are in May, year: 2015 + trunc(x/2) */
		* Ciclos impares: terminan en mayo del año: 2006 + trunc(x/2), empiezan en octubre del año anterior (2005+trunc(x/2))
		* Multiplicando por cycle`x' nos aseguramos de que no se consideren los ciclos en los que no se ha trabajado.
		* Contratos empezados y acabados durante el ciclo: podemos utilizar duration porque todos los días trabajados se corresponden con el ciclo
		gen empdur`x'_1 = cycle`x' * duration if situlab==1 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		gen sempdur`x'_1 = cycle`x' * duration if situlab==2 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		gen unempdur`x'_1 = cycle`x' * duration if situlab==3 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		* Contratos empezados en el ciclo pero acabados después
		gen empdur`x'_2 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - FALTA) if situlab==1 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		gen sempdur`x'_2 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - FALTA) if situlab==2 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		gen unempdur`x'_2 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - FALTA) if situlab==3 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA>mdy(10,1,2005+trunc(`x'/2))
		* Contratos acabados en el ciclo pero empezados antes
		gen empdur`x'_3 = cycle`x' * (FBAJA - mdy(10,1,2005+trunc(`x'/2))) if situlab==1 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
		gen sempdur`x'_3 = cycle`x' * (FBAJA - mdy(10,1,2005+trunc(`x'/2))) if situlab==2 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
		gen unempdur`x'_3 = cycle`x' * (FBAJA - mdy(10,1,2005+trunc(`x'/2))) if situlab==3 & FBAJA<mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
		* Contratos acabados después del ciclo y empezados antes
		gen empdur`x'_4 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - mdy(10,1,2005+trunc(`x'/2))) if situlab==1 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
		gen sempdur`x'_4 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - mdy(10,1,2005+trunc(`x'/2))) if situlab==2 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
		gen unempdur`x'_4 = cycle`x' * (mdy(5,1,2006+trunc(`x'/2)) - mdy(10,1,2005+trunc(`x'/2))) if situlab==3 & FBAJA>mdy(5,1,2006+trunc(`x'/2)) & FALTA<mdy(10,1,2005+trunc(`x'/2))
	}
	if (mod(`x', 2)==0) { /* con else no me funciona */
		/* Then it is an even cycle (2, 4, 6, ...) */
		* Ciclos impares: terminan en octubre del año: 2005 + trunc(x/2), empiezan en mayo del mismo año
		* Multiplicando por cycle`x' nos aseguramos de que no se consideren los ciclos en los que no se ha trabajado.
		* Contratos empezados y acabados durante el ciclo: podemos utilizar duration porque todos los días trabajados se corresponden con el ciclo
		gen empdur`x'_1 = cycle`x' * duration if situlab==1 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		gen sempdur`x'_1 = cycle`x' * duration if situlab==2 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		gen unempdur`x'_1 = cycle`x' * duration if situlab==3 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		* Contratos empezados en el ciclo pero acabados después
		gen empdur`x'_2 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - FALTA) if situlab==1 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		gen sempdur`x'_2 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - FALTA) if situlab==2 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		gen unempdur`x'_2 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - FALTA) if situlab==3 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA>mdy(5,1,2005+trunc(`x'/2))
		* Contratos acabados en el ciclo pero empezados antes
		gen empdur`x'_3 = cycle`x' * (FBAJA - mdy(5,1,2005+trunc(`x'/2))) if situlab==1 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
		gen sempdur`x'_3 = cycle`x' * (FBAJA - mdy(5,1,2005+trunc(`x'/2))) if situlab==2 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
		gen unempdur`x'_3 = cycle`x' * (FBAJA - mdy(5,1,2005+trunc(`x'/2))) if situlab==3 & FBAJA<mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
		* Contratos acabados después del ciclo y empezados antes
		gen empdur`x'_4 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - mdy(5,1,2005+trunc(`x'/2))) if situlab==1 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
		gen sempdur`x'_4 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - mdy(5,1,2005+trunc(`x'/2))) if situlab==2 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
		gen unempdur`x'_4 = cycle`x' * (mdy(10,1,2005+trunc(`x'/2)) - mdy(5,1,2005+trunc(`x'/2))) if situlab==3 & FBAJA>mdy(10,1,2005+trunc(`x'/2)) & FALTA<mdy(5,1,2005+trunc(`x'/2))
	}
	* Sustituir missings por 0
	replace empdur`x'_1 = 0 if empdur`x'_1 == .
	replace empdur`x'_2 = 0 if empdur`x'_2 == .
	replace empdur`x'_3 = 0 if empdur`x'_3 == .
	replace empdur`x'_4 = 0 if empdur`x'_4 == .
	replace sempdur`x'_1 = 0 if sempdur`x'_1 == .
	replace sempdur`x'_2 = 0 if sempdur`x'_2 == .
	replace sempdur`x'_3 = 0 if sempdur`x'_3 == .
	replace sempdur`x'_4 = 0 if sempdur`x'_4 == .
	replace unempdur`x'_1 = 0 if unempdur`x'_1 == .
	replace unempdur`x'_2 = 0 if unempdur`x'_2 == .
	replace unempdur`x'_3 = 0 if unempdur`x'_3 == .
	replace unempdur`x'_4 = 0 if unempdur`x'_4 == .
	* Sumar todos al acumulado del periodo anterior
	by IDENTPERS: egen empdur`x' = sum(empdur`x'_1 + empdur`x'_2 + empdur`x'_3 + empdur`x'_4)
	by IDENTPERS: egen sempdur`x' = sum(sempdur`x'_1 + sempdur`x'_2 + sempdur`x'_3 + sempdur`x'_4)
	by IDENTPERS: egen unempdur`x' = sum(unempdur`x'_1 + unempdur`x'_2 + unempdur`x'_3 + unempdur`x'_4)
	* Drop auxiliary variables
	*drop empdur`x'_1 empdur`x'_2 empdur`x'_3 empdur`x'_4
	*drop sempdur`x'_1 sempdur`x'_2 sempdur`x'_3 sempdur`x'_4
	*drop unempdur`x'_1 unempdur`x'_2 unempdur`x'_3 unempdur`x'_4
}

save pre_panel2.dta, replace

use pre_panel2.dta,replace

gen FBAJA`x'=FBAJA if cycle`x'==1
bysort IDENTPERS: egen FBAJA_`x'=min(FBAJA`x')
drop FBAJA`x'
rename FBAJA_`x' FBAJA`x'
}


gen cycle1=0
replace cycle1=1 if FALTA<= mdy(5,1,2006) & FBAJA> mdy(5,1,2006)
gen cycle2=0
replace cycle2=1 if FALTA<= mdy(10,1,2006) & FBAJA> mdy(10,1,2006)

gen sempdur`x'=duration if situlab==2
bysort IDENTPERS: gen current_sempdur=sum(sempdur) 
drop sempdur


format dbirth* %td


sort IDENTPERS FALTA FBAJA

save pre_panel2_wide.dta, replace

**************




*3.3 Let's do the reshape the dataset: 

use pre_panel2_wide.dta, replace

*Drop the variables you do not need for the reshape: all variables different from var1 var2....var22 (except IDENTPERS)


drop FNACIM SEXO NACIONALIDAD PROVNAC PROVPRIAF DOMICILIO FFALLEC PAISNAC EDUCACION dbirth FALTA FBAJA REGCOT GRUPCOT TIPCONT COEFPARC IDENTCCC2 CNAE09 NUMTRAB FANTIGEMP TRL IDENTEMPRESA PROVCCC1 duration _merge yend ystart age situlab indef_temp FTPT tipo hworked maxFBAJA ageOct16 N n minFALTA current_empdur ntemp nindef


*Check that all variables of interest are the same for each individual
br
bysort IDENTPERS: gen p=_n

*We keep only the first one
keep if p==1
drop  p
*How many observations do we have now? Have you ever seen this figure before?


*(Save it just in case you need more chances)
save pre_panel3_wide.dta, replace




/*  
To go from wide to long:

                reshape long stub, i(i) j(j)
                                           \
                                            j new variable

*/

use pre_panel3_wide.dta,clear

*I just include some example variables
reshape long  situlab dbirth tipo grupcot FALTA FBAJA gender nac provnac , i(IDENTPERS) j(t)


/*Check your panel: 
-how many observations do you have? Is it what you expected? 
-How many individuals? How many times each individual?
*/

br

*Clean and order you panel:
drop cycle*

sort IDENTPERS t 

*Order the variables:
order IDENTPERS t dbirth provnac nac gender FALTA FBAJA situlab tipo grupcot,first

*You might want to use the labels you generate before (situlab, tipo...)



*For those witout information, we assume they are not-employed, and therefore, unemployed
replace situlab = 3 if situlab==.

replace grupcot=. if situlab>1
*This regards previous employemnd grupcot, so we drop it. 


*Compute labour experience at each t with minFALTA 
gen cycle=mdy(5,1,2006) if t==1
format cycle %td
replace cycle=mdy(10,1,2006) if t==2
replace cycle=mdy(5,1,2006) if t==3
*Find a loop for doing it.

*Compute total time as employed, self-employed and unemployed at each t with using current_empdur current_selfempdur current_unempdur
*Compute nÂº of indefinite and temporary contract at each t with ntemp nindef 


*Summarazing: do all the change you need in order to have a clean panel with your variables of interest. 
gen age=int((dbirth-cycle)/365)
...


save panel1.dta,replace



***************************************************************************

*STEP 4: Add now the BASECOT the information and adapt it to the panel.

use "SDFMCVL2016COTIZA1.dta",clear

forval x=2/12{
	append using "SDFMCVL2016COTIZA`x'.dta"
}
/*If you computer cannot run this loop, split it:
For each COTIZA file keep only variables and observations you need. 
Save them separately and append them at the end */

drop if ANOCOT<2006
keep IDENTPERS ANOCOT BASE5CCOM BASE10CCOM



bysort IDENTPERS ANOCOT: gen n=_n
*Some individuals have several wages for one month. Let's keep the biggest amount

bysort IDENTPERS ANOCOT: egen BASE5=max(BASE5CCOM)
bysort IDENTPERS ANOCOT: egen BASE10=max(BASE10CCOM)
drop if n>1
drop n
drop BASE5CCOM BASE10CCOM

sort IDENTPERS ANOCOT
save pre_basecot1.dta, replace

*This structure is different from the panel's. Let's transform it. 



use pre_basecot1.dta, clear


keep if ANOCOT==2006
drop ANOCOT
reshape long BASE, i(IDENTPERS) j(t)
gen year=2006
replace t=5 if t==5 & year==2008
replace t=4 if t==10 & year==2007
save base2006.dta,replace

*Instead of doing it for each year, compute it with a loop for the 11 years:

forval x=2006/2016{
use pre_basecot1.dta, clear
....

replace t=(`x'-2006)*2+1 if t==5 
replace t=.... if t==10 
save base`x'.dta, replace
 }

use base2006.dta
forval x=2007/2016{
	append using base`x'.dta
}

sort IDENTPERS t
br 
tab year
tab t 
*Does it make sense?

save base_panel.dta, replace


*Once you have the base_panel.dta, you can delete all the auxiliar dataset you needed (Check it in your working directory)
forval x=2006/2016{
	erase base`x'.dta
}


***************************************************************************

*Let's add the wages to our panel: 
use panel1.dta, clear
merge 1:1 IDENTPERS t using base_panel.dta

tab _merge

drop if _merge==2

br IDENTPERS t gender situlab BASE _merge

gen wage=BASE/100
replace wage=. if situlab>1
*Only for employed and self-employed 



sort IDENTPERS t
qui compress
save panel.dta, replace


*Congrats!!!! You got it!!!!







*Up to now, you can finished Part I of the homework.

*In order to develop Part II, create a new dofile where you create the new variables you need. 
*If you were able to get here (and you did Homework 1), Part II will be very easy for you, I promisse! 

*Now, I leave you alone. Good luck!!!!!

*And do not heasitate to write me if you get stuck.




