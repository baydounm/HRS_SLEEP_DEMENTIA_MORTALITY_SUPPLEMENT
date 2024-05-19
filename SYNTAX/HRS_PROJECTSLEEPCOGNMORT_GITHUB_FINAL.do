set maxvar 100000, permanently


capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\DATA_MANAGEMENT.smcl", replace

**STEP 0: OPEN FILES AND CREATE HHIDPN VARIABLE, SORT BY THIS VARIABLE**

cd "E:\HRS_MANUSCRIPT\FINAL_DATA"

use randhrs1992_2018v2,clear


capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

use trk2020tr_r,clear
capture rename HHID-VERSION,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

**STEP 1: REDUCE RAND FILE TO RESPONDENT VARIABLE FILE****

use randhrs1992_2018v2,clear
 
keep HHIDPN r* inw* h*

save randhrs1992_2018v2_resp, replace



**STEP 2: MERGE REDUCED RAND FILE WITH TRACKER FILE****

use randhrs1992_2018v2_resp,clear
capture drop _merge
merge HHIDPN using trk2020tr_r
tab _merge
capture drop _merge
sort HHIDPN
save randhrs1992_2018v2_resp_tracker, replace




**STEP 3: DESCRIBE AND SUMMARIZE THE FILE****

describe 

su 

**STEP 4: IDENTIFY THE REQUIRED VARIABLES USING RAND AND TRACKER FILE DOCUMENTATION AND LIST THEM ****
use randhrs1992_2018v2_resp_tracker,clear


**DEPRESSIVE SYMPTOMS IN 2006:

**2006 is r8: r8cesd

su r8cesd 

**LIST OF AGE VARIABLES (2006-2018):
**2006 is r8: r8agey_e
**2008 is r9: r9agey_e
**2010 is r10: r10agey_e
**2012 is r11: r11agey_e
**2014 is r12: r12agey_e
**2016 is r13: r13agey_e
**2018 is r14: r14agey_e

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e


**LIST OF VARIABLES NEEDED TO CREATE THE RACE/ETHNICITY (fixed):

**RACE:\ need to impute, n=5 missing**

capture drop RACE
gen RACE=rarace

tab RACE 

**Ethnicity: 1=Hispanic, 0=Non-Hispanic: n=1 missing

capture drop ETHNICITY
gen ETHNICITY=rahispan

tab ETHNICITY 

**RACE/ETHNICITY: 

capture drop RACE_ETHN
gen RACE_ETHN=.
replace RACE_ETHN=1 if RACE==1 & ETHNICITY==0
replace RACE_ETHN=2 if RACE==2 & ETHNICITY==0
replace RACE_ETHN=3 if ETHNICITY==1 & RACE~=.
replace RACE_ETHN=4 if RACE==3 & ETHNICITY==0

tab RACE_ETHN,missing
tab RACE_ETHN 


**GENDER (fixed):

capture drop SEX
gen SEX=ragender

tab SEX 


**EDUCATION (fixed):

tab raeduc, missing 

capture drop education
gen education = .
replace education = 1 if raeduc == 1 /*< HS*/
replace education = 2 if raeduc == 2 /*GED*/
replace education = 3 if raeduc == 3 /*HS GRADUATE*/
replace education = 4 if raeduc == 4 /*SOME COLLEGE*/
replace education = 5 if raeduc == 5 /*COLLEGE AND ABOVE*/

tab education , missing
tab education 


**INCOME VARIABLE (2006):

tab h8itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2006
gen totwealth_2006 = .
replace totwealth_2006 = 1 if h8itot < 25000
replace totwealth_2006 = 2 if h8itot >= 25000 & h8itot < 125000
replace totwealth_2006 = 3 if h8itot >= 125000 & h8itot < 300000
replace totwealth_2006 = 4 if h8itot >= 300000 & h8itot < 650000
replace totwealth_2006 = 5 if h8itot >= 650000 & h8itot ~= .


tab totwealth_2006 , missing
tab totwealth_2006 

save, replace

**MARITAL STATUS (2006)**

tab r8mstat, missing

capture drop marital_2006
gen marital_2006 = .
replace marital_2006 = 1 if r8mstat == 8 /*never married*/
replace marital_2006 = 2 if (r8mstat == 1 | r8mstat == 2 | r8mstat == 3) /*married / partnered*/
replace marital_2006 = 3 if (r8mstat == 4 | r8mstat == 5 | r8mstat == 6) /*separated / divorced*/
replace marital_2006 = 4 if (r8mstat == 7) /*widowed*/

tab marital_2006, missing
tab marital_2006

**EMPLOYMENT (2006):

tab r8work, missing

capture drop work_st_2006
gen work_st_2006 = .
replace work_st_2006 = 0 if r8work == 0
replace work_st_2006 = 1 if r8work == 1

tab work_st_2006, missing
tab work_st_2006


**CIGARETTE SMOKING (2006): 
tab r8smokev, missing
tab r8smoken, missing

capture drop smoking_2006
gen smoking_2006 = .
replace smoking_2006 = 1 if r8smokev == 0
replace smoking_2006 = 2 if r8smokev == 1 & r8smoken == 0
replace smoking_2006 = 3 if r8smokev == 1 & r8smoken == 1

tab smoking_2006, missing
tab smoking_2006 

save, replace


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2006* n=173 missing/


tab r8drink, missing
tab r8drinkd, missing


capture drop alcohol_2006
gen alcohol_2006 = .
replace alcohol_2006 = 1 if r8drink == 0
replace alcohol_2006 = 2 if r8drink == 1 & r8drinkd == 0
replace alcohol_2006 = 3 if r8drink == 1 & (r8drinkd == 1 | r8drinkd == 2)
replace alcohol_2006 = 4 if r8drink == 1 & (r8drinkd > 3 & r8drinkd ~= . & r8drinkd ~= .d & r8drinkd ~= .m & r8drinkd ~= .r)

tab alcohol_2006, missing



**PHYSICAL ACTIVITY (2006):
tab r8vgactx, missing
tab r8mdactx, missing

capture drop physic_act_2006
gen physic_act_2006 = .
replace physic_act_2006 = 1 if (r8vgactx ==  5 & r8mdactx == 5)
replace physic_act_2006 = 2 if (r8vgactx ==  3 | r8mdactx == 3 | r8vgactx ==  4 | r8mdactx == 4)
replace physic_act_2006 = 3 if (r8vgactx ==  1 | r8mdactx == 1 | r8vgactx ==  2 | r8mdactx == 2)

tab physic_act_2006, missing
tab physic_act_2006


**SELF-RATED HEALTH (2006):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r10shlt, missing

capture drop srh_2006
gen srh_2006 = .
replace srh_2006 = 1 if (r8shlt == 1 | r8shlt == 2 | r8shlt == 3)
replace srh_2006 = 2 if (r8shlt == 4 | r8shlt == 5)

tab srh_2006, missing
tab srh_2006 

save, replace


**WEIGTH STATUS, 2006**
/*body mass index*/

/*2006*/

*<25 
**  25-29.9
**  ≥30


tab r8pmbmi, missing
tab r8bmi, missing
tab r8bmi , missing
tab r8bmi 
su r8bmi ,det


capture drop bmi_2006
gen bmi_2006 = r8pmbmi if r8pmbmi < 100
else replace bmi_2006 = r8bmi if r8bmi < 100

tab bmi_2006, missing
tab bmi_2006 , missing
tab bmi_2006 
su bmi_2006 , det



capture drop bmibr_2006
gen bmibr_2006 = 1 if bmi_2006 < 25
replace bmibr_2006 = 2 if bmi_2006 >= 25 & bmi_2006 < 30
replace bmibr_2006 = 3 if bmi_2006 >= 30 & bmi_2006 ~= .

tab bmibr_2006, missing


/*cardiometabolic risk factors and chronic conditions, 2006*/

/*HYPERTENSION*/

tab r8hibpe, missing

capture drop hbp_ever_2006
gen hbp_ever_2006 = .
replace hbp_ever_2006 = 0 if r8hibpe == 0
replace hbp_ever_2006 = 1 if r8hibpe == 1

tab hbp_ever_2006, missing
tab hbp_ever_2006 


/*DIABETES*/

tab r8diabe, missing

capture drop diab_ever_2006
gen diab_ever_2006 = .
replace diab_ever_2006 = 0 if r8diabe == 0
replace diab_ever_2006 = 1 if r8diabe == 1

tab diab_ever_2006, missing
tab diab_ever_2006 


/*HEART PROBLEMS*/

tab r8hearte, missing

capture drop heart_ever_2006
gen heart_ever_2006 = .
replace heart_ever_2006 = 0 if r8hearte == 0
replace heart_ever_2006 = 1 if r8hearte == 1

tab heart_ever_2006, missing
tab heart_ever_2006 


/*STROKE*/

tab r8stroke, missing

capture drop stroke_ever_2006
gen stroke_ever_2006 = .
replace stroke_ever_2006 = 0 if r8stroke == 0
replace stroke_ever_2006 = 1 if r8stroke == 1

tab stroke_ever_2006, missing
tab stroke_ever_2006 , missing
tab stroke_ever_2006 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2006
gen cardiometcond_2006 = .
replace cardiometcond_2006 = hbp_ever_2006 + diab_ever_2006 + heart_ever_2006 + stroke_ever_2006

tab cardiometcond_2006, missing
tab cardiometcond_2006 , missing
tab cardiometcond_2006 


capture drop cardiometcondbr_2006
gen cardiometcondbr_2006 = .
replace cardiometcondbr_2006 = 1 if cardiometcond_2006 ==0
replace cardiometcondbr_2006 = 2 if (cardiometcond_2006 == 1 | cardiometcond_2006 == 2)
replace cardiometcondbr_2006 = 3 if (cardiometcond_2006 == 3 | cardiometcond_2006 == 4)

tab cardiometcondbr_2006, missing
tab cardiometcondbr_2006 

**2006 CESD**
capture drop cesd_2006
gen cesd_2006=r8cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2006-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum kwgtr

**STEP 5: GENERATE THE MAIN VARIABLES NEEDED FOR THE ANALYSIS, CHANGE THEIR NAMES FOR EASE OF USE**



**AGE VARIABLES**

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e 


**REMAINING COVARIATES**

tab1 SEX RACE_ETHN education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006

save, replace

**STEP 6: SLEEP DATA, 2006**

use H06C_R,clear

tab1 KC083 KC084 KC085 KC086 KC232U2 

capture rename HHID-KVERSION, lower

save H06C_R_fin, replace


capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

******************************Create a poorsleep variable**********************************************************

**Trouble fall asleep: 1: most of the time; 2:sometimes; 3:rarely or never (reverse code); 8/9 change to missing**
capture drop kc083r
gen kc083r=.
replace kc083r=3 if kc083==1
replace kc083r=2 if kc083==2
replace kc083r=1 if kc083==3
replace kc083r=. if kc083==8 | kc083==9


**Trouble waking up during the night: 1: most of the time; 2:sometimes; 3:rarely or never (reverse code); 8/9 change to missing**

capture drop kc084r
gen kc084r=.
replace kc084r=3 if kc084==1
replace kc084r=2 if kc084==2
replace kc084r=1 if kc084==3
replace kc084r=. if kc084==8 | kc084==9

**Trouble waking up too early: 1: most of the time; 2:sometimes; 3:rarely or never (reverse code); 8/9 change to missing**
capture drop kc085r
gen kc085r=.
replace kc085r=3 if kc085==1
replace kc085r=2 if kc085==2
replace kc085r=1 if kc085==3
replace kc085r=. if kc085==8 | kc085==9


**Feel rested in the morning: 1: most of the time; 2:sometimes; 3:rarely or never;  8/9 change to missing**

capture drop kc086r
gen kc086r=.
replace kc086r=3 if kc086==3
replace kc086r=2 if kc086==2
replace kc086r=1 if kc086==1
replace kc086r=. if kc086==8 | kc086==9


**Medications to sleep: 1: yes; 5:no; 8/9 change to missing**

capture drop kc232u2r
gen kc232u2r=.
replace kc232u2r=1 if kc232u2==1
replace kc232u2r=0 if kc232u2==5
replace kc232u2r=. if kc232u2==8 | kc232u2==9


**Poor sleep score, re-scaled to range from 0 to 9**
capture drop poorsleep_2006
gen poorsleep_2006=.
replace poorsleep_2006=(kc083r+kc084r+kc085r+kc086r+kc232u2r)-4

su poorsleep_2006,detail
histogram poorsleep_2006

save, replace

sort HHIDPN
save, replace

**Alternative poor sleep score excluding medication use, re-scaled 0 to 8**
capture drop poorsleepalt_2006
gen poorsleepalt_2006=.
replace poorsleepalt_2006=(kc083r+kc084r+kc085r+kc086r)-4

su poorsleepalt_2006,detail
histogram poorsleepalt_2006

save, replace

sort HHIDPN
save, replace


merge HHIDPN using  randhrs1992_2018v2_resp_tracker

save HRS_PROJECTSLEEPCONGMORT_fin, replace




**STEP 7: DEMENTIA PROBABILITY DATA 2006 THROUGH 2010**
use HRS_PROJECTSLEEPCONGMORT_fin,clear

sort HHIDPN
capture drop _merge

use Dementia_prob2000_2016,clear

destring HHID, replace
destring PN, replace

capture rename HHID-HRS_year,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN



sort HHIDPN
save, replace

**HRS year 2006**
keep if hrs_year==2006

save Dementia_prob2006, replace


use HRS_PROJECTSLEEPCONGMORT_fin,clear
sort HHIDPN
capture drop _merge
save, replace


merge HHIDPN using Dementia_prob2006

save HRS_PROJECTSLEEPCONGMORT_finLONG, replace

capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\FIGURE1.smcl",replace


**STEP 8: DETERMINE SAMPLE WITH COMPLETE DATA ON SLEEP TOTAL SCORE IN 2006, DEMENTIA PROBABILITY DATA AT 2006, AND WHERE RESPONDENT'S AGE IS >50 IN 2006**

use HRS_PROJECTSLEEPCONGMORT_finLONG,clear


**AGE >50 in 2006**

capture drop sample50plus2006
gen sample50plus2006=.
replace sample50plus2006=1 if r8agey_e>50 & r8agey_e~=.
replace sample50plus2006=0 if sample50plus2006~=1 & r8agey_e~=.

tab sample50plus2006

capture drop samplealivein2006
gen samplealivein2006=.
replace samplealivein2006=1 if inw8==1
replace samplealivein2006=0 if samplealivein2006~=1

tab samplealivein2006

capture drop samplepoorsleep2006
gen samplepoorsleep2006=.
replace samplepoorsleep2006=1 if poorsleep_2006~=. 
replace samplepoorsleep2006=0 if samplepoorsleep2006~=1

tab samplepoorsleep2006 

capture drop sampledementia
gen sampledementia=.
replace sampledementia=1 if hrs_year==2006 & hurd_p!=. & expert_p!=. & lasso_p!=. 
replace sampledementia=0 if sampledementia~=1

tab sampledementia

save, replace

capture drop sample_final
gen sample_final=.
replace sample_final=1 if sample50plus2006==1 & samplealivein2006==1 & samplepoorsleep2006==1 & sampledementia==1 & kwgtr~=. 
replace sample_final=0 if sample_final~=1

tab sample_final

save HRS_PROJECTSLEEPCONGMORT_finWIDE, replace



**STEP 9: MORTALITY VARIABLES FROM 2008 THROUGH 2020: TRACKER FILE INW**

**dead vs. alivE:\ 2008-2020

capture drop died
gen died=.
replace died=1 if (sample_final==1 & knowndeceasedyr~=. & knowndeceasedmo~=.)
replace died=0 if died!=1 & sample_final==1

tab died if sample_final==1


**Date of death: dod**

su knowndeceasedmo knowndeceasedyr if sample_final==1
tab1 knowndeceasedmo knowndeceasedyr if sample_final==1

capture drop deathmonth
gen deathmonth=knowndeceasedmo if knowndeceasedmo~=98

capture drop deathyear
gen deathyear=knowndeceasedyr

capture drop deathday
gen deathday=14

capture drop dod
gen dod=mdy(deathmonth, deathday, deathyear)

**Date of entry: doenter**
capture drop doenter
gen doenter=mdy(01,01,2006)

**Date of exit if still alivE:\ doexit**
capture drop doexit
gen doexit=mdy(12,31,2020) 

**Date of exit for censor or dead**
capture drop doevent
gen doevent=.
replace doevent=dod if died==1 & sample_final==1
replace doevent=doexit if died==0 & sample_final==1

su doevent

***Estimated birth date**

capture drop dob
gen dob=mdy(birthmo,14,birthyr)



capture drop ageevent
gen ageevent=(doevent-dob)/365.5

capture drop ageenter
gen ageenter=r8agey_e

save, replace

**STEP 10: STSET FOR MORTALITY OUTCOME***

capture drop AGE2006
gen AGE2006=ageenter

save, replace

stset ageevent if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) scale(1)


stdescribe if sample_final==1
stsum if sample_final==1
strate if sample_final==1

save, replace

capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\IMPUTATION.smcl",replace


**STEP 12: MULTIPLE IMPUTATION FOR COVARIATES: MARCH 14TH: USE THE AD PGS PAPER********************** 

**//RUN IMPUTATIONS FOR 2006 COVARIATE DATA: 


**DESIGN VARIABLES**
**svyset secu [pweight=kwgtr], strata(stratum) 

**SAMPLING VARIABLES**
**sample*

**OUTCOME AND OTHER RELATED VARIABLES**
**died  doexit doevent doenter dob _t _st _d _t0 

**EXPOSURE AND MEDIATOR VARIABLES**
**poorsleep_2006  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem 

**Year variable and age variables**
**hrs_year r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e 


**COVARIATES USED FOR OR REQUIRING IMPUTATION:
**marital_2006 education work_st_2006 totwealth_2006 smoking_2006 alcohol_2006 physic_act_2006 bmi_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 srh_2006 cesd_2006

**OTHER COVARIATES:
**AGE2006 SEX RACE ETHNICITY RACE_ETHN

**--> re-compute categorical BMI and cardiometabolic risk variables after imputation

use HRS_PROJECTSLEEPCONGMORT_finWIDE,clear

capture drop AGE2006
gen AGE2006=r8agey_e

save, replace

keep HHIDPN HHID hhid pn kwgtr stratum secu sample* died  doexit doevent doenter dob _t _st _d _t0 poorsleep_2006  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year AGE2006 SEX RACE ETHNICITY RACE_ETHN marital_2006 education work_st_2006 totwealth_2006 smoking_2006 physic_act_2006 bmi_2006 bmibr_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 cardiometcond_2006 cardiometcondbr_2006 srh_2006 cesd_2006 r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e ageevent ageenter alcohol_2006 poorsleepalt_2006 kc083r kc084r kc085r kc086r kc232u2r


save finaldata_unimputed, replace

sort HHIDPN 

save, replace

set matsize 11000

capture mi set, clear

mi set flong

capture mi svyset, clear

mi svyset secu [pweight=kwgtr], strata(stratum) vce(linearized) singleunit(missing)

mi stset ageevent if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) scale(1)


mi unregister HHIDPN HHID hhid pn kwgtr stratum secu sample* died  doexit doevent doenter dob _t _st _d _t0 poorsleep_2006  hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year AGE2006 SEX RACE ETHNICITY RACE_ETHN marital_2006 education work_st_2006 totwealth_2006 smoking_2006 physic_act_2006 bmi_2006 bmibr_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 cardiometcond_2006 cardiometcondbr_2006 srh_2006 cesd_2006 r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e ageevent ageenter alcohol_2006 poorsleepalt_2006


mi register imputed  marital_2006 education work_st_2006 totwealth_2006 smoking_2006 physic_act_2006 bmi_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 srh_2006 cesd_2006

mi register passive poorsleep_2006  poorsleepalt_2006 hurd_p hurd_dem expert_p expert_dem lasso_p lasso_dem hrs_year alcohol_2006

tab1 marital_2006 education work_st_2006 totwealth_2006 smoking_2006 physic_act_2006 bmi_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 srh_2006

mi impute chained (mlogit) marital_2006 education work_st_2006  totwealth_2006 smoking_2006 physic_act_2006 hbp_ever_2006 diab_ever_2006 heart_ever_2006 stroke_ever_2006 srh_2006 (regress) bmi_2006 cesd_2006 = AGE2006 SEX i.RACE_ETHN  if AGE2006>=50 , force augment noisily  add(5) rseed(1234) savetrace(tracefile, replace) 



save finaldata_imputed, replace

sort HHIDPN


capture drop male
mi passivE:\ gen male=.
mi passivE:\ replace male=1 if SEX==1 & sample_final==1
mi passivE:\ replace male=0 if SEX==2 & sample_final==1

capture drop female
mi passivE:\ gen female=.
mi passivE:\ replace female=1 if SEX==2 & sample_final==1
mi passivE:\ replace female=0 if SEX==1 & sample_final==1


capture drop cardiometcond_2006
mi passivE:\ gen cardiometcond_2006 = .
mi passivE:\ replace cardiometcond_2006 = hbp_ever_2006 + diab_ever_2006 + heart_ever_2006 + stroke_ever_2006


capture drop bmibr_2006
mi passivE:\ gen bmibr_2006 = 1 if bmi_2006 < 25
mi passivE:\ replace bmibr_2006 = 2 if bmi_2006 >= 25 & bmi_2006 < 30
mi passivE:\ replace bmibr_2006 = 3 if bmi_2006 >= 30 & bmi_2006 ~= .

capture drop NonWhite
mi passivE:\ gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save finaldata_imputed_FINAL, replace

capture log close 
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\SINGLEITEM_SENSITIVITY.smcl",replace

use finaldata_imputed_FINAL,clear


**Trouble fall asleep: kc083r
**Trouble waking up during the night: kc084r
**Trouble waking up too early: kc085r
**Feel rested in the morning: kc086r
**Medications to sleep:kc232u2r 

**Single items of sleep relationship with dementia and mortality**

foreach x of varlist kc083r kc084r kc085r kc086r kc232u2r {
	mi estimatE:\ stcox i.`x' if sample_final==1
	
}

foreach x of varlist kc083r kc084r kc085r kc086r kc232u2r {
	foreach y of varlist hurd_dem expert_dem lasso_dem {
	mi estimatE:\ mlogit `y'  i.`x' if sample_final==1
	
}
}


**Cox model PH assumption**
mi extract 0

save finaldata_imputed_FINAL_ZERO,replace


stcox poorsleep_2006 if sample_final==1
estat phtest, rank detail




capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE1.smcl",replace


**STEP 13: DESCRIPTIVE TABLE BY SEX AND RACE/ETHNICITY, WITHOUT TAKING INTO ACCOUNT SAMPLING DESIGN COMPLEXITY, ON UNIMPUTED DATA***

use finaldata_imputed_FINAL,clear

***********UNIMPUTED DATA ANALYSIS***************************************
mi extract 0

save finaldata_unimputed_FINAL, replace

su AGE2006 if sample_final==1 

tab1 SEX RACE_ETHN education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 if sample_final==1 

reg AGE2006 i.SEX if sample_final==1 
tab SEX RACE_ETHN if sample_final==1 , row col chi
tab SEX education if sample_final==1 , row col chi
tab SEX totwealth_2006 if sample_final==1 , row col chi
tab SEX marital_2006 if sample_final==1 , row col chi
tab SEX work_st_2006 if sample_final==1 , row col chi
tab SEX smoking_2006 if sample_final==1 , row col chi
tab SEX physic_act_2006 if sample_final==1 , row col chi
tab SEX srh_2006 if sample_final==1, row col chi
tab SEX bmibr_2006 if sample_final==1, row col chi
tab SEX cardiometcondbr_2006 if sample_final==1, row col chi

reg AGE2006 i.RACE_ETHN if sample_final==1
reg cesd_2006 i.RACE_ETHN if sample_final==1
tab RACE_ETHN SEX if sample_final==1, row col chi


**TAKE INTO ACCOUNT SAMPLING DESIGN COMPLEXITY, ON IMPUTED DATA*** 
use finaldata_imputed_FINAL,clear

mi svyset secu [pweight=kwgtr], strata(stratum)
 
foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem  alcohol_2006 {
	mi estimatE:\ svy, subpop(sample_final): prop `x1'
}
 

foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p  {
	mi estimatE:\ svy, subpop(sample_final): mean `x2'
}


mi xeq 0: strate if sample_final==1  

capture drop Men
mi passivE:\ gen Men=1 if SEX==1 & sample_final==1
mi passivE:\ replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passivE:\ gen Women=1 if SEX==2 & sample_final==1
mi passivE:\ replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passivE:\ gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passivE:\ gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passivE:\ replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passivE:\ gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passivE:\ replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passivE:\ gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passivE:\ replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passivE:\ gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1


save, replace

**************STRATIFIED ANALYSIS***************************

**Men**

foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem alcohol_2006 {
	mi estimatE:\ svy, subpop(Men): prop `x1' 
}
 

foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(Men): mean `x2'
}


mi xeq 0: strate if Men==1  

**Women**


foreach x1 of varlist SEX RACE_ETHN NonWhite education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem alcohol_2006 {
	mi estimatE:\ svy, subpop(Women): prop `x1' 
}
 

foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(Women): mean `x2'
}


mi xeq 0: strate  if Women==1


**NHW**

foreach x1 of varlist SEX education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem  alcohol_2006 {
	mi estimatE:\ svy, subpop(NHW): prop `x1' 
}
 

foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(NHW): mean `x2'
}


mi xeq 0: strate if NHW==1 


**NonWhite**

foreach x1 of varlist SEX  education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem alcohol_2006 {
	mi estimatE:\ svy, subpop(NonWhite): prop `x1' 
}
 

foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(NonWhite): mean `x2'
}


mi xeq 0: strate  if NonWhite==1


save, replace


************************DIFFERENCES BY SEX AND BY RACE**************************

foreach x1 of varlist RACE_ETHN NonWhite education  totwealth_2006 marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem   alcohol_2006 {
	mi estimatE:\ svy, subpop(sample_final): mlogit `x1' SEX
}

 
foreach x1 of varlist SEX education   marital_2006 work_st_2006 smoking_2006 physic_act_2006 srh_2006  bmibr_2006 cardiometcondbr_2006 hurd_dem expert_dem lasso_dem alcohol_2006 {
	mi estimatE:\ svy, subpop(sample_final): mlogit `x1' NonWhite
}


foreach x2 of varlist AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(sample_final): reg `x2' SEX
}


foreach x2 of varlist totwealth_2006 AGE2006 cesd_2006 poorsleep_2006  hurd_p expert_p  lasso_p {
	mi estimatE:\ svy, subpop(sample_final): reg `x2' NonWhite
}


save, replace


capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\FIGURE2.smcl",replace

use finaldata_imputed_FINAL,clear


**STEP 14: FIGURE 2: COMPARE SURVIVAL PROBABILITIES ACROSS EXPOSURE (poorsleep_2006, create tertiles) AND MEDIATOR LEVELS (hurd_dem expert_dem lasso_dem)**

mi extract 0

save finaldata_unimputed_FINAL, replace


stset ageevent if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) scale(1)


stdescribe if sample_final==1
stsum if sample_final==1
strate if sample_final==1

save, replace


capture drop poorsleep_2006tert
xtile poorsleep_2006tert=poorsleep_2006 if sample_final==1,nq(3)

bysort poorsleep_2006tert: su poorsleep_2006 if sample_final==1,detail

save, replace

sts test poorsleep_2006tert if sample_final==1, logrank
sts graph if sample_final==1, by(poorsleep_2006tert) 

graph save "FIGURE2A.gph", replace

sts test hurd_dem if sample_final==1, logrank
sts graph if sample_final==1, by(hurd_dem) 


graph save "FIGURE2B.gph", replace


sts test expert_dem if sample_final==1, logrank
sts graph if sample_final==1, by(expert_dem) 


graph save "FIGURE2C.gph", replace


sts test lasso_dem if sample_final==1, logrank
sts graph if sample_final==1, by(lasso_dem) 


graph save "FIGURE2D.gph", replace

graph combine "FIGURE2A.gph" "FIGURE2B.gph" "FIGURE2C.gph" "FIGURE2D.gph"
graph save "FIGURE2.gph", replace

capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\FIGURE3.smcl",replace

use finaldata_imputed_FINAL,clear


**STEP 14: FIGURE 2: COMPARE SURVIVAL PROBABILITIES ACROSS EXPOSURE (poorsleep_2006, create tertiles) AND MEDIATOR LEVELS (hurd_dem expert_dem lasso_dem)**

mi extract 0

save finaldata_unimputed_FINAL, replace


stset ageevent if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) scale(1)


stdescribe if sample_final==1
stsum if sample_final==1
strate if sample_final==1

save, replace


capture drop poorsleep_2006tert
xtile poorsleep_2006tert=poorsleep_2006 if sample_final==1,nq(3)

bysort poorsleep_2006tert: su poorsleep_2006 if sample_final==1,detail

save, replace

*************LOWEST TERTILE OF POOR SLEEP QUALITY***********************

sts test hurd_dem if sample_final==1 & poorsleep_2006tert==1, logrank
sts graph if sample_final==1 & poorsleep_2006tert==1, by(hurd_dem) 

graph save "FIGURE3A1.gph", replace



sts test expert_dem if sample_final==1 & poorsleep_2006tert==1, logrank
sts graph if sample_final==1 & poorsleep_2006tert==1, by(expert_dem) 

graph save "FIGURE3A2.gph", replace


sts test lasso_dem if sample_final==1 & poorsleep_2006tert==1, logrank
sts graph if sample_final==1 & poorsleep_2006tert==1, by(lasso_dem) 

graph save "FIGURE3A3.gph", replace

graph combine "FIGURE3A1.gph" "FIGURE3A2.gph" "FIGURE3A3.gph"
graph save "FIGURE3A.gph", replace



*************MIDDLE TERTILE OF POOR SLEEP QUALITY***********************

sts test hurd_dem if sample_final==1 & poorsleep_2006tert==2, logrank
sts graph if sample_final==1 & poorsleep_2006tert==2, by(hurd_dem) 

graph save "FIGURE3B1.gph", replace



sts test expert_dem if sample_final==1 & poorsleep_2006tert==2, logrank
sts graph if sample_final==1 & poorsleep_2006tert==2, by(expert_dem) 

graph save "FIGURE3B2.gph", replace


sts test lasso_dem if sample_final==1 & poorsleep_2006tert==2, logrank
sts graph if sample_final==1 & poorsleep_2006tert==2, by(lasso_dem) 

graph save "FIGURE3B3.gph", replace

graph combine "FIGURE3B1.gph" "FIGURE3B2.gph" "FIGURE3B3.gph"
graph save "FIGURE3B.gph", replace


*******************UPPERMOST TERTILE OF POOR SLEEP QUALITY*********************

sts test hurd_dem if sample_final==1 & poorsleep_2006tert==3, logrank
sts graph if sample_final==1 & poorsleep_2006tert==3, by(hurd_dem) 

graph save "FIGURE3C1.gph", replace



sts test expert_dem if sample_final==1 & poorsleep_2006tert==3, logrank
sts graph if sample_final==1 & poorsleep_2006tert==3, by(expert_dem) 

graph save "FIGURE3C2.gph", replace


sts test lasso_dem if sample_final==1 & poorsleep_2006tert==3, logrank
sts graph if sample_final==1 & poorsleep_2006tert==3, by(lasso_dem) 

graph save "FIGURE3C3.gph", replace

graph combine "FIGURE3C1.gph" "FIGURE3C2.gph" "FIGURE3C3.gph"
graph save "FIGURE3C.gph", replace


capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE2.smcl",replace

use finaldata_imputed_FINAL,clear


capture drop poorsleep_2006tert
xtile poorsleep_2006tert=poorsleep_2006 if sample_final==1,nq(3)

bysort poorsleep_2006tert: su poorsleep_2006 if sample_final==1,detail

save finaldata_imputed_FINAL, replace



**STEP 15: TABLE 2: COX PH MODELS FOR EXPOSURE (POORSLEEP and dementia probabilities, loge transformed) VS. OUTCOME AND MEDIATOR VS. OUTCOME, OVERALL AND STRATIFIED BY SEX AND RACE:\ REDUCE AND FULL MODELS; INTERACTION BY SEX AND BY RACE*******


capture drop lnhurd_odds
mi passivE:\ gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passivE:\ gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passivE:\ gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passivE:\ gen Men=1 if SEX==1 & sample_final==1
mi passivE:\ replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passivE:\ gen Women=1 if SEX==2 & sample_final==1
mi passivE:\ replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passivE:\ gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passivE:\ gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passivE:\ replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passivE:\ gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passivE:\ replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passivE:\ gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passivE:\ replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passivE:\ gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace




****************OVERALL*********************

***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite
	
}


***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}



***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

**MODELS 4A-4X: BACKWARD ELIMINATION***

**FULL MODEL 2**
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}



**REMOVE CESD**
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006  
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006  
	
}

**REMOVE CARDIOMETABOLIC FACTORS**


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006  cesd_2006 
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006  cesd_2006 
	
}


**REMOVE BMI***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006   cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  cardiometcondbr_2006 cesd_2006
	
}

**REMOVE SRH***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE PA***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE SMOKING***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006  physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006  physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE WORK STATUS***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006  i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE MARITAL STATUS***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006  work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE INCOME***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

**REMOVE EDUCATION***

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

*****************MEN************************


***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite
	
}


***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****

foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Men): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}



*****************WOMEN**********************

***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006

	
}

***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(Women): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}


****************NHW*************************


***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHW): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}



****************NHB*************************


***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite
	
}



foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NHB): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}


****************HISP************************



***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(HISP): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}



**************NonWhite*************************

***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite
	
}

***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}



foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(NonWhite): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}




****************INTERACTION BY SEX*********

***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite
	
}



***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}


***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.SEX AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}





****************INTERACTION BY RACE*********


***MODEL 1****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2006 SEX 
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2006 SEX 
	
}



***MODEL 2****
foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2006 SEX  i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}



foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##NonWhite AGE2006 SEX  i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}



***MODEL 3: MODEL 2 + ALCOHOL (SENSITIVITY ANALYSIS)****


foreach x of varlist poorsleep_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.NonWhite AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}

foreach x of varlist poorsleep_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.NonWhite AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 alcohol_2006
	
}



save, replace


capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE3.smcl",replace


**STEP 16: COX PH MODEL OF DEMENTIA STATUS VS. MORTALITY BY SLEEP TERTILE****

capture drop poorsleep_2006tert
xtile poorsleep_2006tert=poorsleep_2006 if sample_final==1,nq(3)

save, replace

************************FIRST POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==1
	
}

foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==1
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==1
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==1
	
}



************************SECOND POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==2
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==2
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==2
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==2
	
}


************************THIRD POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==3
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleep_2006tert==3
	
}

***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==3
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleep_2006tert==3
	
}

**************************************INTERACTION WITH POOR SLEEP QUALITY TERTILE**********************************


***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleep_2006tert AGE2006 SEX NonWhite 
	
}


***MODEL 1****
foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleep_2006tert AGE2006 SEX NonWhite 
	
}

***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleep_2006tert AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 
	
}



foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleep_2006tert AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 
	
}

capture log close



capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE3B.smcl",replace


**STEP 16: COX PH MODEL OF DEMENTIA STATUS VS. MORTALITY BY SLEEP TERTILE****

capture drop poorsleepalt_2006tert
xtile poorsleepalt_2006tert=poorsleepalt_2006 if sample_final==1,nq(3)

save, replace


****************OVERALL*********************

***MODEL 1****
foreach x of varlist poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite
	
}

foreach x of varlist poorsleepalt_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite
	
}


***MODEL 2****
foreach x of varlist poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}

foreach x of varlist poorsleepalt_2006tert hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006
	
}




************************FIRST POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==1
	
}

foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==1
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==1
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==1
	
}



************************SECOND POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==2
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==2
	
}


***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==2
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==2
	
}


************************THIRD POOR SLEEP QUALITY TERTILE***************************************

***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==3
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite if poorsleepalt_2006tert==3
	
}

***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==3
	
}


foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox `x' AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 if poorsleepalt_2006tert==3
	
}

**************************************INTERACTION WITH POOR SLEEP QUALITY TERTILE**********************************


***MODEL 1****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleepalt_2006tert AGE2006 SEX NonWhite 
	
}


***MODEL 1****
foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleepalt_2006tert AGE2006 SEX NonWhite 
	
}

***MODEL 2****
foreach x of varlist  lnhurd_odds lnexpert_odds lnlasso_odds {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleepalt_2006tert AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 
	
}



foreach x of varlist  hurd_dem expert_dem lasso_dem {
mi estimatE:\ svy, subpop(sample_final): stcox c.`x'##c.poorsleepalt_2006tert AGE2006 SEX NonWhite i.education  i.totwealth_2006 i.marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006 cesd_2006 
	
}

capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE4.smcl",replace


**STEP 17: TABLE 3: MED4WAY FOR POOR SLEEP AS EXPOSURE, DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME:\ FULL MODEL; OVERALL AND STRATIFIED BY SEX AND BY RACE/ETHNICITY***

**COVARIATES: NonWhite AGE2006 SEX  i.education  i.totwealth_2006 marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006

use finaldata_imputed_FINAL,clear



capture drop lnhurd_odds
mi passivE:\ gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passivE:\ gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passivE:\ gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passivE:\ gen Men=1 if SEX==1 & sample_final==1
mi passivE:\ replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passivE:\ gen Women=1 if SEX==2 & sample_final==1
mi passivE:\ replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passivE:\ gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passivE:\ gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passivE:\ replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passivE:\ gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passivE:\ replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passivE:\ gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passivE:\ replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passivE:\ gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace

capture mi stset ageevent [pweight = kwgtr] if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) id(HHIDPN) scale(1)

capture drop educationg* totalwealth_2006g* marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g*

tab education,generate(educationg)

tab totwealth_2006, generate(totalwealth_2006g)

tab marital_2006, generate(marital_2006g)

tab smoking_2006, generate(smoking_2006g)

tab physic_act_2006, generate(physic_act_2006g)

tab srh_2006, generate(srh_2006g)

tab bmibr_2006, generate(bmibr_2006g)
 
tab cardiometcondbr_2006, generate(cardiometcondbr_2006g)



***************************TABLE 4: MODEL 2*********************************

*****************************OVERALL*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

mi passivE:\ egen zcesd_2006=std(cesd_2006) if sample_final==1

save, replace




foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****SENSITIVITY ANALYSIS, OVERALL*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************MEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****SENSITIVITY ANALYSIS, MEN*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************WOMEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace



save, replace


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****SENSITIVITY ANALYSIS, WOMEN*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************NHW*****************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****SENSITIVITY ANALYSIS,  NHW*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***************************Non-White*************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

*****SENSITIVITY ANALYSIS,  Non-White*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save finaldata_imputed_FINAL, replace




capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLE5.smcl",replace


**STEP 17: TABLE 5: MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS EXPOSURE, POOR SLEEP AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME:\ FULL MODEL BY SEX AND BY RACE/ETHNICITY***


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***************SENSITIVITY ANALYSIS, OVERALL******************


foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************MEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************WOMEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************NHW*****************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************Non-White*************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  educationg* totwealth_2006 marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g* zcesd_2006 if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save, replace

capture log close


********************************************************SENSITIVITY ANALYSIS: REDUCED MODELS***********************************************

capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLES3.smcl",replace


**STEP 17: TABLE S3: MED4WAY FOR POOR SLEEP AS EXPOSURE, DIFFERENT PROBABILITIES OF DEMENTIA AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME:\ FULL MODEL; OVERALL AND STRATIFIED BY SEX AND BY RACE/ETHNICITY***

**COVARIATES: NonWhite AGE2006 SEX  i.education  i.totwealth_2006 marital_2006 work_st_2006 i.smoking_2006 physic_act_2006 i.srh_2006  i.bmibr_2006 cardiometcondbr_2006

use finaldata_imputed_FINAL,clear



capture drop lnhurd_odds
mi passivE:\ gen lnhurd_odds=ln((hurd_p)/(1-hurd_p))

capture drop lnexpert_odds
mi passivE:\ gen lnexpert_odds=ln((expert_p)/(1-expert_p))


capture drop lnlasso_odds
mi passivE:\ gen lnlasso_odds=ln((lasso_p)/(1-lasso_p))


capture drop Men
mi passivE:\ gen Men=1 if SEX==1 & sample_final==1
mi passivE:\ replace Men=0 if Men~=1 & SEX~=. & sample_final==1

capture drop Women
mi passivE:\ gen Women=1 if SEX==2 & sample_final==1
mi passivE:\ replace Women=0 if Women~=1 & SEX~=. & sample_final==1

capture drop NHW
mi passivE:\ gen NHW=1 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NHW=0 if NHW~=1 & RACE_ETHN~=. & sample_final==1

capture drop NHB
mi passivE:\ gen NHB=1 if RACE_ETHN==2 & sample_final==1
mi passivE:\ replace NHB=0 if NHB~=1 & RACE_ETHN~=. & sample_final==1


capture drop HISP
mi passivE:\ gen HISP=1 if RACE_ETHN==3 & sample_final==1
mi passivE:\ replace HISP=0 if HISP~=1 & RACE_ETHN~=. & sample_final==1 


capture drop OTHER
mi passivE:\ gen OTHER=1 if RACE_ETHN==4 & sample_final==1
mi passivE:\ replace OTHER=0 if OTHER~=1 & RACE_ETHN~=. & sample_final==1


capture drop NonWhite
mi passivE:\ gen NonWhite=0 if RACE_ETHN==1 & sample_final==1
mi passivE:\ replace NonWhite=1 if RACE_ETHN!=1 & RACE_ETHN!=. & sample_final==1

save, replace

capture mi stset ageevent [pweight = kwgtr] if sample_final==1, failure(died==1) enter(AGE2006) origin(AGE2006) id(HHIDPN) scale(1)

capture drop educationg* totalwealth_2006g* marital_2006g* smoking_2006g* physic_act_2006g* srh_2006g* bmibr_2006g*  cardiometcondbr_2006g*

tab education,generate(educationg)

tab totwealth_2006, generate(totalwealth_2006g)

tab marital_2006, generate(marital_2006g)

tab smoking_2006, generate(smoking_2006g)

tab physic_act_2006, generate(physic_act_2006g)

tab srh_2006, generate(srh_2006g)

tab bmibr_2006, generate(bmibr_2006g)
 
tab cardiometcondbr_2006, generate(cardiometcondbr_2006g)


*****************************OVERALL*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****SENSITIVITY ANALYSIS, OVERALL*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************MEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace



save, replace


foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****SENSITIVITY ANALYSIS, MEN*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************WOMEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace



foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****SENSITIVITY ANALYSIS, WOMEN*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************NHW*****************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace



foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****SENSITIVITY ANALYSIS,  NHW*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***************************Non-White*************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleep_2006 `m' AGE2006 SEX NonWhite if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

*****SENSITIVITY ANALYSIS,  Non-White*******

foreach m of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way zpoorsleepalt_2006 `m' AGE2006 SEX NonWhite if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save finaldata_imputed_FINAL, replace




capture log close
capture log using "E:\HRS_MANUSCRIPT\OUTPUT\TABLES4.smcl",replace


**STEP 17: TABLE 5: MED4WAY FOR DIFFERENT PROBABILITIES OF DEMENTIA AS EXPOSURE, POOR SLEEP AS MEDIATORS, AND ALL-CAUSE DEATH AS OUTCOME:\ FULL MODEL BY SEX AND BY RACE/ETHNICITY***


use finaldata_imputed_FINAL,clear

*****************************OVERALL*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}

***************SENSITIVITY ANALYSIS, OVERALL******************


foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite if sample_final==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


*****************************MEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite  if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite if SEX==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



*****************************WOMEN*******************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite if SEX==2 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************************NHW*****************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace





foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite if NonWhite==0 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


***************************Non-White*************************************
capture drop zpoorsleep_2006 
capture drop zpoorsleepalt_2006
capture drop zlnhurd_odds 
capture drop zlnexpert_odds 
capture drop zlnlasso_odds
foreach x of varlist poorsleep_2006 poorsleepalt_2006 lnhurd_odds lnexpert_odds lnlasso_odds {
	mi passivE:\ egen z`x'=std(`x') if sample_final==1
}

save, replace




foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleep_2006  AGE2006 SEX NonWhite if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}



***************SENSITIVITY ANALYSIS******************

foreach x of varlist zlnhurd_odds zlnexpert_odds zlnlasso_odds {
mi estimate, cmdok esampvaryok: med4way `x' zpoorsleepalt_2006  AGE2006 SEX NonWhite  if NonWhite==1 , a0(0) a1(1) m(0) yreg(cox) mreg(linear) 
}


save, replace

capture log close



