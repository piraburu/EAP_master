**2008**
**H file**
*Open the folder:
cd "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment"
*Open a csv file esudb08h:
insheet using esudb08h.csv, clear
*Keep the chosen variables variables:
 keep hb010   hb030   hx040   hx240   hh010   vhrentaa hx060
*Rename the  variables:
rename hb010 year
rename hb030 id
rename hx040 nind
rename hx240 eq
rename hh010 housetype
rename vhrentaa income
rename hx060 hometype
*Save the Stata file 2008H:
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008h.dta", replace 
**D file**
*Open the folder:
cd "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment"
*Open a csv file esudb17h:
insheet using esudb08d.csv, clear
*Keep the chosen variables variables:
keep db010 db030 db040 db090 db100
*Rename the variables:
rename db010  year
rename db030  id
rename db040  region
rename db090 weight
rename db100 area

*Save the Stata file 2017D:
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008d.dta", replace 

 **MERGE **
use 2008d  
merge 1:1 id using 2008h 
*Save in a new file
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008.dta", replace 

**Create new variables**
gen eqincome=income/eq
gen tweight=nind*weight
**Delete negative values**
*Delete missing values:
drop if eqincome>= .
*Delete negative income values:
drop if eqincome < 0
*Solve
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008.dta", replace 
*Change hometype name
gen var="2 Adults with >= 3 children" if hometype=="13"
replace var="2 Adults with one child" if hometype=="11"
replace var="2 Adults (1,>75)" if hometype=="7"
replace var="Adult with one child" if hometype=="10"




*Generate a similar numerical variables
encode region, gen(ngregion)
encode housetype, gen(nhousetype)
encode var, gen(nhometype)
drop if nhometype>= .
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008.dta", replace 

* Inequality(Gini)----------------------------------------------------
*By hometype
igini eqincome, hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(0) hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(1) hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(2) hsize(tweight) hgroup(nhometype)


*Curves
clorenz eqincome, hsize(tweight) hgroup(nhometype)
clorenz eqincome, hsize(tweight) hgroup(nhometype) type(gen)




* Poverty(FGT)
*By hometype
ifgt eqincome, alpha(0) hsize(tweight) hgroup(nhometype) opl(median) prop(60)
ifgt eqincome, alpha(1) hsize(tweight) hgroup(nhometype) opl(median) prop(60)
ifgt eqincome, alpha(2) hsize(tweight) hgroup(nhometype) opl(median) prop(60)

sum eqincome, detail
*Curves (TIP)
sum eqincome, detail  /*median=12589; median*0.6=7552.76*/
cpoverty eqincome, hsize(tweight) hgroup(nhometype) curve(cpg) pline(7552.76) min(0) max(1)













**2012------------------------------------------------------------------**
**H file**
*Open the folder:
 cd "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\"
*Open a csv file esudb15h:
insheet using esudb12h.csv, clear
*Keep the chosen variables variables:
 keep hb010   hb030   hx040   hx240   hh010   vhrentaa   hx060
*Rename the  variables:
rename hb010 year
rename hb030 id
rename hx040 nind
rename hx240 eq
rename hh010 housetype
rename vhrentaa income
rename hx060 hometype
*Save the Stata file 2015H:
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2012h.dta", replace 
 
**D file**
*Open the folder:
 cd "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\"
*Open a csv file esudb15h:
insheet using esudb12d.csv, clear
*Keep the chosen variables variables:
keep db010 db030 db040 db090 db100
*Rename the variables:
rename db010  year
rename db030  id
rename db040  region
rename db090 weight
rename db100 area

*Save the Stata file 2017D:
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2012d.dta", replace 

 **MERGE **
use 2012d  
merge 1:1 id using 2012h 
*Save in a new file
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2012.dta", replace 

**Create new variables**
gen eqincome=income/eq
gen tweight=nind*weight
**Delete negative values**
*Delete missing values:
drop if eqincome>= .
*Delete negative income values:
drop if eqincome < 0
*Solve
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2012.dta", replace 

*Change hometype name
gen var="2 Adults with >= 3 children" if hometype=="13"
replace var="2 Adults with one child" if hometype=="11"
replace var="2 Adults (1,>75)" if hometype=="7"
replace var="Adult with one child" if hometype=="10"


*Generate a similar numerical variables
encode region, gen(ngregion)
encode housetype, gen(nhousetype)
encode var, gen(nhometype)
drop if nhometype>= .
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2012.dta", replace 

* Inequality(Gini) ------------------------------------------
*By hometype
igini eqincome, hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(0) hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(1) hsize(tweight) hgroup(nhometype)
ientropy eqincome, theta(2) hsize(tweight) hgroup(nhometype)


*Curves
clorenz eqincome, hsize(tweight) hgroup(nhometype)
clorenz eqincome, hsize(tweight) hgroup(nhometype) type(gen)

* Poverty(FGT)--------------------------------------------
*By hometype
ifgt eqincome, alpha(0) hsize(tweight) hgroup(nhometype) opl(median) prop(60)
ifgt eqincome, alpha(1) hsize(tweight) hgroup(nhometype) opl(median) prop(60)
ifgt eqincome, alpha(2) hsize(tweight) hgroup(nhometype) opl(median) prop(60)

sum eqincome, detail /*median:*/ 
*Curves (TIP)
cpoverty eqincome, hsize(tweight) hgroup(nhometype) curve(cpg) pline(8278) min(0) max(1)


**CURVES FOR TWO YEAR**

**The two files must be in the same folder**
**For example, folder 2017**

cd "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment"
use 2008.dta
append using 2012.dta
save "C:\Users\pimpeter\Desktop\Soc_welfare_stata\stata_assignment\2008-12.dta", replace

**CURVES FOR TWO YEAR AND A CLASSIFICATION**

**The two files must be in the same folder**
**For example, folder 2017**

use 2008-12
sum eqincome, detail /*median:*/ 
cpoverty eqincome, hsize(tweight) hgroup(nyearhome) curve(cpg) pline(7906.8) min(0) max(1)





gen yearhome="2 Adults with >= 3 children,'08" if year==2008 & hometype=="13"
replace yearhome="2 Adults with one child,'08" if year==2008 & hometype=="11"
replace yearhome="2 Adults (1,>75),'08" if year==2008 & hometype=="7"
replace yearhome="Adult with one child,'08" if year==2008 &  hometype=="10"
replace yearhome="2 Adults with >= 3 children'12" if year==2012 &hometype=="13" 
replace yearhome="2 Adults with one child,'12" if year==2012 & hometype=="11"
replace yearhome="2 Adults (1,>75),'12" if year==2012 & hometype=="7"
replace yearhome="Adult with one child, '12" if year==2012 &  hometype=="10"


encode yearhome, gen(nyearhome)
clorenz eqincome, hsize(tweight) hgroup(nyearhome)


