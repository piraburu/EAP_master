
clear all
set more off
capture log close
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use "afiliacion_personal16.dta",clear


gen yend=year(FBAJA)
gen ystart=year(FALTA)

gen age=ystart-year(dbirth)
label var age "Age at the beginning of the episode"
br IDENTPERS dbirth FNACIM FALTA FBAJA yend ystart age


/*Labor Situation*/
destring REGCOT, replace

*Employed*
generate situlab = 1 if REGCOT<.

*Self-employed*
replace situlab =  2 if (REGCOT == 0521 | REGCOT == 0522 | ///
REGCOT==0531| REGCOT == 0721 | REGCOT == 0825 |REGCOT==0831)

* unemployed *
replace situlab = 3 if (TRL >= 751 & TRL <= 756) 

* Special agreement and others*
replace situlab = 4 if (REGCOT == 0140 | REGCOT == 0540 | REGCOT == 0640 | REGCOT == 0740 | REGCOT == 0840 | REGCOT == 0940 | REGCOT == 1240) 

replace situlab = 4 if situlab == 1 & (REGCOT==161 | REGCOT == 163 | REGCOT == 831 | REGCOT == 899 | TRL==980 | TRL==983 ) 

*Label the variable and the values: 
label var situlab "Labor status"

label define situlab 1"Employed" 2"Self-employed" 3"Unemployed" 4"Special agreement and others"
label values situlab situlab 

tab situlab, miss
* Unemployed people: 1,360,042



/*Type of contract */
/*Permanent or temporal*/
gen indef_temp=2 

*Permanent
replace indef_temp=1 if (TIPCONT==001 | TIPCONT==003| TIPCONT==009| TIPCONT==011 | TIPCONT==018 | TIPCONT==020 | TIPCONT==023| TIPCONT==028|/*
*/ TIPCONT==029 | TIPCONT==032 | TIPCONT==033 | TIPCONT==035| TIPCONT==038| TIPCONT==040| TIPCONT==041| TIPCONT==042| TIPCONT==043| TIPCONT==044| TIPCONT==045| TIPCONT==046| TIPCONT==047| TIPCONT==048| TIPCONT==049/*
*/| TIPCONT==059| TIPCONT==060| TIPCONT==061|TIPCONT==062| TIPCONT==063| TIPCONT==065| TIPCONT==069| TIPCONT==070| TIPCONT==071| TIPCONT==080| TIPCONT==081|TIPCONT==086|TIPCONT==088|TIPCONT==089|/*
*/ TIPCONT==098| TIPCONT==100| TIPCONT==101| TIPCONT==102| TIPCONT==109| TIPCONT==130| /*
*/TIPCONT==131| TIPCONT==139| TIPCONT==141| TIPCONT==150| TIPCONT==151| TIPCONT==152| TIPCONT==153| TIPCONT==154| TIPCONT==155| TIPCONT==156| TIPCONT==157|/*
*/ TIPCONT==181| TIPCONT==182| TIPCONT==183| TIPCONT==184| TIPCONT==185| TIPCONT==186| TIPCONT==189| TIPCONT==200/*
*/| TIPCONT==209| TIPCONT==230| TIPCONT==231| TIPCONT==239| TIPCONT==241| TIPCONT==250| TIPCONT==251| TIPCONT==252| TIPCONT==253| TIPCONT==254| TIPCONT==255| TIPCONT==256| TIPCONT==257|TIPCONT==289/*
*/| TIPCONT==300| TIPCONT==309| TIPCONT==330| TIPCONT==331| TIPCONT==339| TIPCONT==350| TIPCONT==351| TIPCONT==352| TIPCONT==353| TIPCONT==354| TIPCONT==355| TIPCONT==356| TIPCONT==357|TIPCONT==389) 

*Unknown
replace indef_temp=3 if TIPCONT==000 

replace indef_temp=. if situlab!=1

* So, we have 3 types of contracts and those unknown are unemployed.
tab indef_temp, miss

label var indef_temp "Type of contract"
label define indef_temp 1"Permanent" 2"Temporal" 3"Unknown"
label values indef_temp indef_temp

tab indef_temp, miss


/*Full-Time or Part-Time*/

gen FTPT=1 
replace FTPT=2 if (TIPCONT==003 | TIPCONT==004 |TIPCONT==006 | TIPCONT==023 |TIPCONT==024 | TIPCONT==025 |TIPCONT==026 | TIPCONT==027 |/*
*/TIPCONT==034 | TIPCONT==063 | TIPCONT==081 | TIPCONT==089 | TIPCONT==095 | TIPCONT==098 | TIPCONT==200 | TIPCONT==209 | TIPCONT==230/*
*/ | TIPCONT==231 | TIPCONT==239 | TIPCONT==241 | TIPCONT>=250 & TIPCONT<=257 | TIPCONT==289 | TIPCONT>=500 & TIPCONT<558  ) 

tab FTPT, miss

replace FTPT=. if situlab!=1
*Label the values! 
label define FTPT 1"Full-Time" 2"Part-time"
label values FTPT FTPT
tab FTPT, miss


*Generate a new variable 
gen tipo=.
replace tipo=1 if indef_temp==1 & FTPT==1
replace tipo=2 if indef_temp==1 & FTPT==2
replace tipo=3 if indef_temp==2 & FTPT==1
replace tipo=4 if indef_temp==2 & FTPT==2
replace tipo=5 if TIPCONT==000 

tab tipo, miss
*It only makes sense for employed individuals and self employed
replace tipo=. if situlab!=1 
* (1,540,022 real changes made, 1,540,022 to missing)
codebook situlab
*Labelling 
label var tipo "Type of contract"
label define tipo 1"Indef FT" 2"Indef PT" 3"Temp FT" 4"Temp PT" 5"Unknown"
label values tipo tipo

/*Generate hours worked 
(it is explained in the video 3.2. however it is better 
if you construct it here)*/



save, replace

qui compress
sort IDENTPERS FALTA FBAJA 
save afiliacion_personal16_2.dta, replace

********************************************************************************
********************************************************************************

clear all
set more off
capture log close
cd "C:\Users\pimpeter\Desktop\LABOR_2\DATA" 
use "afiliacion_personal16.dta",clear

*Be sure you understand the data:
use afiliacion_personal16_2.dta, replace

br IDENTPERS dbirth FALTA FBAJA situ tipo COEFPARC
* Old contracts
tab ystart if tipo==5

* Important!!
tab tipo situlab, miss

gen hworked=.
* That are all the unemployed people

br IDENTPERS COEFPARC situ hworked

gen hworked=.
replace hworked=(1000-COEFPARC)*0.008 if situlab==1

histogram COEFPARC if situlab==1
histogram COEFPARC if tipo==2
histogram hworked if tipo==2



*Focusing at certain day:
tab tipo if FALTA<=mdy(1,1,2015) & FBAJA>=mdy(1,1,2015)
*Problem solved! :D
*Up to now, you can answer questions 1, 2 and 3 (Part I) of the homework. 

save, replace

