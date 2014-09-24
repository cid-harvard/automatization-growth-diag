                               
*** Growth Diagnostics Tool ***	
                                
clear all
set more off


** Enter location of main folder below
cd "C:\Users\Luis Miguel\Dropbox\CID Research Assistantship\Automatization Growth Diagnostics"

** Enter filename of WDI database saved in the folder
use indicators_WDI.dta, clear
 
** Define country and year of focus
local ctrygd MAR
local focusyeargd 2010

*** Preparing folders and dataset***
capture mkdir `ctrygd'
cd `ctrygd'
local countryfolder `c(pwd)'

capture encode iso, gen(cc)
xtset cc year


** I. Generate indicators of potential constraints and specify the functional relationship to outcome variable. GDP per capita in logs is the outcome variable unless otherwise specified.
gen container_cost = log10(IS_SHP_GOOD_TU)
gen electcity_consumption = log10(EG_USE_ELEC_KH_PC )
gen homicides =  log(VC_IHR_PSRC_P5) 
gen primarycompletion = SE_PRM_CMPT_ZS 
gen secondary_enrollment = SE_SEC_ENRR
gen tertiary_enrollment = SE_TER_ENRR

* generating  road density indicator and correcting for population density
cap gen logroaddensity = log(IS_ROD_DNST_K2)
cap gen logpopdensity = log(EN_POP_DNST )
reg logroaddensity logpopdensity if year == `focusyeargd'
predict road_density_bypopdens, resid


** II. Generate scatterplots and GDP associated with a country's performance on each indicator 

*insert loop to repeat for every year in dataset
foreach x of varlist road_density_bypopdens primarycompletion container_cost electcity_consumption homicides secondary_enrollment tertiary_enrollment {

twoway lfitci loggdppercap `x' if year == `focusyeargd' , legend(off) ///
|| scatter loggdppercap `x' if year == `focusyeargd' & iso !="`ctrygd'", mlabel(iso) ytitle("GDP per capita, log") legend(off) /// 
|| scatter loggdppercap `x' if year == `focusyeargd' & iso =="`ctrygd'", mlabel(iso) legend(off) 
graph save `ctrygd'_`x'_`focusyeargd', replace

reg loggdppercap `x' if year == `focusyeargd', r
predict `x'_prgdp if year == `focusyeargd'
predict `x'_se if year == `focusyeargd', stdp
predict `x'_res if year == `focusyeargd', residual
gen `x'_norm = `x'_res/`x'_se
}


browse year iso *_prgdp *_norm if iso == "`ctrygd'" & year == `focusyeargd'

* Once loop written, the next line will look at how constraints changed, would be interesting to look at around time frame of growth accelerations/episodes
*xtline  *_prgdp loggdppc if year>1995 & iso == "`ctrygd'"
