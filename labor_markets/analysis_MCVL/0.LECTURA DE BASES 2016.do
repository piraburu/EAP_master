

*****CARGA DE DATOS NO FISCALES 2016******** 



***FICHERO DATOS PERSONALES***

*cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"
cd "/Volumes/Fedea Datos/Lucia/MCVL/MCVL2016"
insheet using "MCVL2016PERSONAL.TXT", delimiter(";") 


rename v1 IDENTPERS
rename v2 FNACIM
rename v3 SEXO
rename v4 NACIONALIDAD
rename v5 PROVNAC
rename v6 PROVPRIAF
rename v7 DOMICILIO
rename v8 FFALLEC
rename v9 PAISNAC
rename v10 EDUCACION



label var IDENTPERS "Identificador de la persona"
label var FNACIM "Fecha de nacimiento: aaaa/mm"
label var SEXO "Sexo"
label var NACIONALIDAD "Nacionalidad"
label var PROVNAC "Provincia de nacimiento (Padrón)"
label var PROVPRIAF "Provincia de la primera afiliación"
label var DOMICILIO "Domicilio de residencia habitual (Padrón)"
label var FFALLEC "Fecha de fallecimiento: aaaa/mm"
label var PAISNAC "Pais de nacimiento (Padrón)"
label var EDUCACION "Nivel educativo (Padrón)"

destring FNACIM, replace

qui compress
save "SDFMCVL2016PERSONAL.dta", replace


***FICHERO AFILIADOS****


forval a=1/4{
clear
set more off
*cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"

insheet using "MCVL2016AFILIAD`a'.TXT", delimiter(";") 

rename v1 IDENTPERS
rename v2 REGCOT
rename v3 GRUPCOT
rename v4 TIPCONT
rename v5 COEFPARC
rename v6 FALTA
rename v7 FBAJA
rename v8 CAUSABAJA
rename v9 MINUSV
rename v10 IDENTCCC2
rename v11 DOMCCC2
rename v12 CNAE09
rename v13 NUMTRAB
rename v14 FANTIGEMP
rename v15 TRL
rename v16 COLECTTRABAJ
rename v17 TIPEMPLEADOR
rename v18 TIPEMPRESA
rename v19 IDENTEMPRESA
rename v20 PROVCCC1
rename v21 FMODCONT1
rename v22 TIPCONMOD1
rename v23 CPARCMOD1
rename v24 FMODCONT2
rename v25 TIPCONMOD2
rename v26 CPARCMOD2
rename v27 FMODGRUP1
rename v28 GRUPCOTMOD1
rename v29 CNAE93
rename v30 INDSETAAGRARIA
rename v31 TRLOTRAS
rename v32 FALTAEFECTO
rename v33 FBAJAEFECTO

label var IDENTPERS "Identificador de la persona"
label var REGCOT "Régimen de cotización"
label var GRUPCOT "Grupo de cotización"
label var TIPCONT "Tipo de contrato de trabajo"
label var COEFPARC "Coeficiente de tiempo parcial"
label var FALTA "Fecha real de alta en afiliación"
label var FBAJA "Fecha real de baja en afiliación"
label var CAUSABAJA "Causa de baja en afiliación"
label var MINUSV "Minusvalía según alta en afiliación"
label var IDENTCCC2 "Código de cuenta de cotización"
label var DOMCCC2 "Domicilio de actividad de la cuenta de cotización"
label var CNAE09 "Actividad económica según CNAE 2009 de la cuenta de cotización"
label var NUMTRAB "Número de trabajadores en la cuenta de cotización"
label var FANTIGEMP "Fecha de alta del primer trabajador de la cuenta de cotización" 
label var TRL "Tipo de relación laboral de la cuenta de cotización"
label var COLECTTRABAJ "colectivo especial de la cuenta de cotización"
label var TIPEMPLEADOR "Empleador tipo de identificador"
label var TIPEMPRESA "Empleador (forma jurídica) letra NIF de la entidad pagadora"
label var IDENTEMPRESA "Código de cuenta de cotización principal"
label var PROVCCC1 "Provincia del domicilio de la cuenta de cotización principal"
label var FMODCONT1 "Fecha modificación del tipo de contrato inicial o coeficiente de tiempo parcial inicial"
label var TIPCONMOD1  "Tipo de contrato inicial"
label var CPARCMOD1 "Coeficiente de tiempo parcial inicial"
label var FMODCONT2 "Fecha modificación tipo contrato segundo o coeficiente tiempo parcial segundo" 
label var TIPCONMOD2 "Tipo de contrato segundo"
label var CPARCMOD2 "Coeficiente de tiempo parcial segundo"
label var FMODGRUP1 "Fecha de modificación del grupo de cotización inicial" 
label var GRUPCOTMOD1 "Grupo de cotización inicial"
label var CNAE93 "Actividad económica según CNAE 1993 de la cuenta de cotización"
label var INDSETAAGRARIA "Sistema especial de trabajadores agrarios (SETA)"
label var TRLOTRAS "Tipo de relación con otras entidades o autónomos"
label var FALTAEFECTO "Fecha de efecto de alta en la afiliación"
label var FBAJAEFECTO "Fecha de efecta de baja en la afiliación"

qui compress
save SDFMCVL2016AFILIADOS`a'.dta, replace
}

******

* FICHERO CONVIVIENTES

*cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"
clear
set more off
insheet using "MCVL2016CONVIVIR.TXT", delimiter(";") 

rename v1 IDENTPERS
rename v2 FECHA1
rename v3 SEXO1
rename v4 FECHA2
rename v5 SEXO2
rename v6 FECHA3
rename v7 SEXO3
rename v8 FECHA4
rename v9 SEXO4
rename v10 FECHA5
rename v11 SEXO5
rename v12 FECHA6
rename v13 SEXO6
rename v14 FECHA7
rename v15 SEXO7
rename v16 FECHA8
rename v17 SEXO8
rename v18 FECHA9
rename v19 SEXO9
rename v20 FECHA10
rename v21 SEXO10

label var IDENTPERS "Identificador de la persona"
label var FECHA1 "Fecha del primer conviviente"
label var SEXO1 "Sexo del primer conviviente"
label var FECHA2 "Fecha del segundo conviviente"
label var SEXO2 "Sexo del segundo conviviente"
label var FECHA3 "Fecha del tercer conviviente"
label var SEXO3 "Sexo del tercer conviviente"
label var FECHA4 "Fecha del cuarto conviviente"
label var SEXO4 "Sexo del cuarto conviviente"
label var FECHA5 "Fecha del quinto conviviente"
label var SEXO5 "Sexo del quinto conviviente"
label var FECHA6 "Fecha del sexto conviviente"
label var SEXO6 "Sexo del sexto conviviente"
label var FECHA7 "Fecha del séptimo conviviente"
label var SEXO7 "Sexo del séptimo conviviente"
label var FECHA8 "Fecha del octavo conviviente"
label var SEXO8 "Sexo del octavo conviviente"
label var FECHA9 "Fecha del noveno conviviente"
label var SEXO9 "Sexo del noveno conviviente"
label var FECHA10 "Fecha del décimo conviviente"
label var SEXO10 "Sexo del décimo conviviente"

destring FECHA*, replace
destring SEXO*,replace

qui compress

save "SDFMCVL2016CONVIVI.dta", replace



*FICHEROS DE COTIZACIONES POR CUENTA AJENA
forval a=1/12{
clear
set more off
insheet using "MCVL2016COTIZA`a'.TXT", delimiter(";") 

rename v1 IDENTPERS
rename v2 IDENTCCC2
rename v3 ANOCOT
rename v4 BASE1CCOM
rename v5 BASE2CCOM
rename v6 BASE3CCOM
rename v7 BASE4CCOM
rename v8 BASE5CCOM
rename v9 BASE6CCOM
rename v10 BASE7CCOM
rename v11 BASE8CCOM
rename v12 BASE9CCOM
rename v13 BASE10CCOM
rename v14 BASE11CCOM
rename v15 BASE12CCOM
rename v16 BASETOTALCCOM


label var IDENTPERS "Identificador de la persona"
label var IDENTCCC2 "Código de cuenta de cotización"
label var ANOCOT "Año de cotización"

qui compress

save "SDFMCVL2016COTIZA`a'.dta", replace

 }
**

 *FICHEROS DE COTIZACIONES POR CUENTA PROPIA
 
**cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"

clear
insheet using "MCVL2016COTIZA13.TXT", delimiter(";") 

rename v1 IDENTPERS
rename v2 IDENTCCC2
rename v3 ANOCOT
rename v4 BASE1
rename v5 BASE2
rename v6 BASE3
rename v7 BASE4
rename v8 BASE5
rename v9 BASE6
rename v10 BASE7
rename v11 BASE8
rename v12 BASE9
rename v13 BASE10
rename v14 BASE11
rename v15 BASE12
rename v16 BASETOTAL

label var IDENTPERS "Identificador de la persona"
label var IDENTCCC2 "Código de cuenta de cotización"
label var ANOCOT "Año de cotización"

qui compress

save "SDFMCVL2016COTIZA13.dta", replace

****FICHERO DIVISION***

*cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"

insheet using "MCVL2016DIVISION.TXT", delimiter(" ")  

rename v1 IDENTPERS
rename v2 CAMPO1
rename v3 CAMPO2

label var IDENTPERS "Identificador de la persona"

qui compress

save "SDFMCVL2016DIVISION.dta", replace


***FICHERO PRESTACIONES****

**cd "/Volumes/BBDD/MCVL/MCVL2016/SDF"


clear
insheet using "MCVL2016PRESTAC.TXT", delimiter(";")  

rename v1 IDENTPERS
rename v2 ANOPREST
rename v3 PSIK
rename v4 CLASEPRES
rename v5 SITUSUJETO
rename v6 GRADOINCAP
rename v7 FMINUSV
rename v8 SOVI
rename v9 CLASEMIN
rename v10 REGPRES
rename v11 FEFECTECON
rename v12 BASEREG
rename v13 PORCENTBASEREG
rename v14 ANOBONIF
rename v15 ANOSCOTIZ
rename v16 IMPORTE_PENSEFECT
rename v17 IMPORTE_REVALORIZACION
rename v18 IMPORTE_GARMIN
rename v19 IMPORTE_COMPLEMENT
rename v20 IMPORTETOTAL
rename v21 SITUPRES
rename v22 FSITUPRES
rename v23 PROVINCIA_PRES
rename v24 TITULARES_CAUSANTE
rename v25 PRORRATA_CONVENIOINT
rename v26 PRORRATA_DIVORCIO
rename v27 COEF_RED_TOTAL
rename v28 TIPOJUBILACION
rename v29 COEFPARC_JUBILACION
rename v30 ORFANDAD_PRES
rename v31 PRESAJENA
rename v32 IMPORTE_PAGASEXTRA
rename v33 IMPORTE_ANUALDESVIPC
rename v34 IMPORTE_ANUALTOTAL
rename v35 ANONACIMSUPERVI
rename v36 PENSIONLIMIT
rename v37 COEF_REDUCT_LIMMAX
rename v38 COMPATIBIL_JUBYTRABAJO
rename v39 FORDINJUB
rename v40 PERCOTEDADOJUB
rename v41 PERCOT
rename v42 PORCENT_ANOSCOT

label var IDENTPERS "Identificador de la persona"
label var ANOPREST "Año del dato"
label var PSIK "Identificador de la prestación"
label var CLASEPRES "Clase de la prestación"
label var SITUSUJETO "Situación del sujeto causante"
label var GRADOINCAP "Grado de incapacidad"
label var FMINUSV "Fecha de minusvalía"
label var SOVI "Norma SOVI"
label var CLASEMIN "Clase de mínimo"
label var REGPRES "Régimen de la pensión"
label var FEFECTECON "Fecha de efectos económicos de la pensión"
label var BASEREG "Base reguladora"
label var PORCENTBASEREG "Porcentaje aplicado a la base reguladora"
label var ANOBONIF "Años bonificados"
label var ANOSCOTIZ "Años considerados cotizados para la jubilación"
label var IMPORTE_PENSEFECT "Importe mensual de la pensión efectiva"
label var IMPORTE_REVALORIZACION "Importe mensual de revalorización"
label var IMPORTE_GARMIN "Importe mensual de complementos garantía mínimos"
label var IMPORTE_COMPLEMENT "Importe mensual de otros complementos"
label var IMPORTETOTAL "Importe mensual total de la prestación"
label var SITUPRES "Situación de la prestación (causa de baja)"
label var FSITUPRES "Fecha de situación de la prestación"
label var PROVINCIA_PRES "Provincia de gestión de la prestación"
label var TITULARES_CAUSANTE "Número de titulares de un mismo sujeto causante"
label var PRORRATA_CONVENIOINT "Prorrata de convenio internacional"
label var PRORRATA_DIVORCIO "Prorrata de divorcio"
label var COEF_RED_TOTAL "Coeficiente reductor total"
label var TIPOJUBILACION "Tipo de situación de jubilación"
label var COEFPARC_JUBILACION "Coeficiente de parcialidad (jubilación)"
label var ORFANDAD_PRES "Prestación vitalicia (orfandad y viudedad"
label var PRESAJENA "Concurrencia con prestación ajena"
label var IMPORTE_PAGASEXTRA "Importe anual pagas extras"
label var IMPORTE_ANUALDESVIPC "Importe paga desviación IPC"
label var IMPORTE_ANUALTOTAL "Importe anual total de la prestación"
label var ANONACIMSUPERVI "Año de nacimiento del causante de pensión de supervivencia"
label var PENSIONLIMIT "Pensión limitada"
label var COEF_REDUCT_LIMMAX "Coeficiente reductor del límite máximo"
label var COMPATIBIL_JUBYTRABAJO "Compatibilidad de jubilación y trabajo"
label var FORDINJUB "Fecha ordinaria de jubilación"
label var PERCOTEDADOJUB "Periodo cotizado en edad ordinaria de jubilación"
label var PERCOT "Periodo de cotización"
label var PORCENT_ANOSCOT "Porcentaje por años cotizados"


qui compress

save "SDFMCVL2016PRESTACION.dta", replace

/*
****Pasar a string/destring fichero afiliados**
 
gen va1=string(REGCOT)

gen va2=string(GRUPCOT)

gen va3=string(CNAE09)

gen va4=string(CNAE93)

drop REGCOT GRUPCOT CNAE09 CNAE93

rename va1 REGCOT

rename va2 GRUPCOT

rename va3 CNAE09

rename va4 CNAE93

label var REGCOT "Régimen de cotización"
label var GRUPCOT "Grupo de cotización"
label var CNAE09 "Actividad económica según CNAE 2009 de la cuenta de cotización"
label var CNAE93 "Actividad económica según CNAE 1993 de la cuenta de cotización"

rename TIPCONMOD2 TIPCONTMOD2
rename  COLECTTRABAJ ETT




****Transformar string a variables numéricas*****

destring FMODCONT1 TIPCONMOD1 CPARCMOD1 FMODCONT2 TIPCONTMOD2  CPARCMOD2 FMODGRUP1 GRUPCOTMOD1, replace 


tab TIPEMPLEADOR

***Reemplazar las letras por ceros****

gen TIPEMPLEADORnuevo=0 if TIPEMPLEADOR=="0"
replace TIPEMPLEADORnuevo=1 if TIPEMPLEADOR=="1"
replace TIPEMPLEADORnuevo=2 if TIPEMPLEADOR=="2"
replace TIPEMPLEADORnuevo=5 if TIPEMPLEADOR=="5"
replace TIPEMPLEADORnuevo=6 if TIPEMPLEADOR=="6"
replace TIPEMPLEADORnuevo=7 if TIPEMPLEADOR=="7"
replace TIPEMPLEADORnuevo=8 if TIPEMPLEADOR=="8"
replace TIPEMPLEADORnuevo=9 if TIPEMPLEADOR=="9"
replace TIPEMPLEADORnuevo=0 if TIPEMPLEADOR=="D"

replace TIPEMPLEADORnuevo=0 if TIPEMPLEADOR=="M"

drop TIPEMPLEADOR
rename TIPEMPLEADORnuevo TIPEMPLEADOR

label var TIPEMPLEADOR "Empleador tipo de identificador"


