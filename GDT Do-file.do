********************************************************************
*** Initial Draft Do-file for the Growth Diagnostics Online Tool ***	
********************************************************************
                                
clear all
set more off

** Enter location of main folder below
cd "/Users/josemoralesarilla/Desktop/CID/WDI_csv"

** Enter filename of WDI database saved in the folder
use wdi_data_2013_income_region.dta, clear

** Define country and year of focus
local ctry BRA
local focusyear = 2011

*** Preparing folders and dataset***
capture mkdir `ctry'
cd `ctry'
local countryfolder `c(pwd)'

encode iso, gen(iso_numeric)
tsset iso_numeric year
rename NY_GDP_PCAP_PP_KD gdpvar
levelsof countryname if iso=="`ctry'", local(j) clean 


*** Define first dimension of benchmark countries - Income vecinity ***

gen tempvar1 = gdpvar if iso == "`ctry'" & year== 2012
egen tempvar2 = max(tempvar1)
gen tempvar3 = (gdpvar <= 1.2*tempvar2 & gdpvar >=0.8*tempvar2) & year==2012
egen comparator_income = max(tempvar3), by(iso)
drop tempvar* 

*** Define second dimension of benchmark countries - Same Region ***

encode region, generate(region_num)
gen tempvar1 = region_num if iso == "`ctry'"
egen tempvar2 = max(tempvar1)
gen same_region_temp = (tempvar2==region_num)
egen same_region = max(same_region_temp), by(iso)
drop tempvar* same_region_temp region_num

****************************
*** I. Describing Growth ***
****************************

capture mkdir growth_history
cd growth_history

*** 1) Univariate analysis of GDP per capita and Growth ***

	line gdpvar year if iso=="`ctry'" ///
	, title("Evolution of GDP per Capita") subtitle("`j'") legend(off) ///
	note("Data source:  World Development Indicators, 2013")
graph save univariate_levels, replace

	line NY_GDP_MKTP_KD_ZG year if iso=="`ctry'" ///
	, title("Evolution of GDP per Capita") subtitle("`j'") legend(off) ///
	note("Data source:  World Development Indicators, 2013")
graph save univariate_rate, replace
		
*** 2) Evaluation of GDP per capita vs. benchmark countries ***

	gen temp = gdpvar if year==2000
	egen gdp_index_base = max(temp), by(iso)
	g gdp_index = 100*(gdpvar/gdp_index_base)
	drop gdp_index_base temp
	
	qui levelsof iso_numeric if comparator_income & same_region & iso!="`ctry'", clean local(benchmarks)
	
	local linecmd ""
	local legendcmd ""
	local i=2
	
	foreach c of local benchmarks {
		local linecmd "`linecmd' (line gdp_index year if iso_numeric==`c')"
		qui levelsof countryname if iso_numeric==`c', local(ctryname)
		local legendcmd "`legendcmd' `i' `ctryname'"
		local i = `i'+1  
	}
	
	
	twoway (line gdp_index year if iso=="`ctry'", lwidth(vthick)) `linecmd', legend(order(1 "`j'" `legendcmd') size(vsmall) cols(3)) ///
		title("GDP per capita of `j' and comparator countries") note("Data source:  World Development Indicators, 2013")
graph save univariate_levels_benchmarks, replace

*****************************
*** II. Financial Stories ***
*****************************

cd `countryfolder'
capture mkdir finance
cd finance

*** 1) Interest Rate and GDP per Capita ***
	
	twoway ///
	scatter FR_INR_RINR gdpvar if year==`focusyear' ///
	|| scatter FR_INR_RINR gdpvar if year==`focusyear' & comparator_income==1 & same_region==1 ///
	|| scatter FR_INR_RINR gdpvar if year==`focusyear' & iso=="`ctry'" ///
	, title("Cost of Capital") subtitle("`j', `focusyear'" ) legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source: World Development Indicators, 2013") xscale(log)
graph save rate_by_gdp, replace

*** 2) Interest Rate and Investment (as % of GDP) ***
	
	twoway ///
	scatter FR_INR_RINR NE_GDI_TOTL_ZS if year==`focusyear' ///
	|| scatter FR_INR_RINR NE_GDI_TOTL_ZS if year==`focusyear' & comp==1 & same_region==1 ///
	|| scatter FR_INR_RINR NE_GDI_TOTL_ZS if year==`focusyear' & iso=="`ctry'" ///
	, title("Cost of Capital") subtitle("`j', `focusyear'" ) legend( label (1 "Other Countries") label (2 "Benchmarks") ///
	label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)
graph save rate_by_investment_scatter, replace


*** 3) Sensitivity of Investment to Interest Rate in country of interest ***
	
	twoway /// 
	scatter FR_INR_RINR NE_GDI_TOTL_ZS if iso=="`ctry'", mlabel(year) ///
	|| line FR_INR_RINR NE_GDI_TOTL_ZS if iso=="`ctry'" ///
	|| lfit FR_INR_RINR NE_GDI_TOTL_ZS if iso=="`ctry'" ///
	, title("Sensitivity of Investment to Interest Rate") subtitle("`j'") legend(off) ///
	note("Data source:  World Development Indicators, 2013") 
graph save rate_by_investment_time, replace

*** 4) Net domestic credit ***

	gen NET_DOM_CREDIT_GDP = FM_AST_DOMS_CN / NY_GDP_MKTP_CN * 100
	label variable NET_DOM_CREDIT_GDP "Net Domestic Credit (as % of GDP)"

	twoway ///
	scatter NET_DOM_CREDIT_GDP gdpvar if year==`focusyear' ///
	|| scatter NET_DOM_CREDIT_GDP gdpvar if year==`focusyear' & comp==1 & same_region==1 ///
	|| scatter NET_DOM_CREDIT_GDP gdpvar if year==`focusyear' & iso=="`ctry'" ///
	, title("Net Domestic Credit") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)
graph save credit_gdp_scatter, replace

***************************
*** II.A Saving Stories ***
***************************

capture mkdir savings
cd savings

*** 5) Average interest on new external debt (poor measure of external debt - check EMBI+ and Spreads on Credit Default Swaps) ***

	twoway ///
	scatter DT_INR_DPPG gdpvar if year==`focusyear' ///
	|| scatter DT_INR_DPPG gdpvar if year==`focusyear' & comp==1 & same_region==1 ///
	|| scatter DT_INR_DPPG gdpvar if year==`focusyear' & iso=="`ctry'" ///
	, title("Average interest on new external debt") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)
graph save "Average interest on new external debt", replace

*** 6) Sensitivity of Growth to Average interest on new external debt - Poor indicator of Access to international savings ***
	
	twoway ///
	scatter DT_INR_DPPG NY_GDP_MKTP_KD_ZG if iso== "`ctry'" & year>=2000, mlabel(year) ///
	|| line DT_INR_DPPG NY_GDP_MKTP_KD_ZG if iso== "`ctry'" & year>=2000 ///
	|| lfit DT_INR_DPPG NY_GDP_MKTP_KD_ZG if iso== "`ctry'" & year>=2000 ///
	, title("Sensitivity of Growth to Average interest on new external debt") subtitle("`j'" ) ///
	legend(off) note("Data source:  World Development Indicators, 2013")

graph save "Sensitivity of Growth to Average interest on new external debt", replace

*** 7) External Debt (public and private, as % of GNI)

	
	twoway ///
	scatter DT_DOD_DECT_GN_ZS gdpvar if year == `focusyear' ///
	|| scatter DT_DOD_DECT_GN_ZS gdpvar if year == `focusyear' & comp==1 & same_region==1 ///
	|| scatter DT_DOD_DECT_GN_ZS gdpvar if year == `focusyear' & iso=="`ctry'" ///
	, title("External Debt Stocks") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Same Region and Income Level") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)

graph save "External Debt Stocks", replace
	
*** 8) Evolution of External Debt (public and private, as % of GNI) and Growth ***

	twoway ///
	bar DT_DOD_DECT_GN_ZS year if iso== "`ctry'" ///
	|| line NY_GDP_MKTP_KD_ZG year if iso== "`ctry'", yaxis (2) ///
	, title("Evolution of the External Debt") subtitle("`j'" ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")

graph save "Evolution of the External Debt", replace

*** 9) Total Central Government Debt - Since many countries w/o data, defined "counterfactual" strictly on income neighborhood ***

	twoway ///
	scatter GC_DOD_TOTL_GD_ZS gdpvar if year == `focusyear' ///
	|| scatter GC_DOD_TOTL_GD_ZS gdpvar if year == `focusyear' & comp==1 ///
	|| scatter GC_DOD_TOTL_GD_ZS gdpvar if year == `focusyear' & iso=="`ctry'" ///
	, title("Total Central Government Debt") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks (income only)") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)

graph save "Total Central Government Debt", replace

*** 10) Evolution of the Total Central Government Debt ***

	twoway /// 
	bar GC_DOD_TOTL_GD_ZS year if iso=="`ctry'" ///
	|| line NY_GDP_MKTP_KD_ZG year if iso=="`ctry'", yaxis (2) ///
	, title("Evolution of the Total Central Government Debt") subtitle("`j'" ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")

graph save "Evolution of the Total Central Government Debt", replace

*** 11) Evolution of the Current Account and Growth - Too short a series of CA ***

	twoway ///
	bar BN_CAB_XOKA_GD_ZS year if iso== "`ctry'" ///
	|| line NY_GDP_MKTP_KD_ZG year if iso== "`ctry'", yaxis (2) ///
	, title("Evolution of the Current Account") subtitle("`j'" ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")

graph save "Evolution of the Current Account", replace
	
*** 12) Evolution of the Current Account and the Real Effective Exchange Rate - Many countries do not have PX_REX_REER ***
	*** Alternative source of data - Economist Intelligence Unit ***

	gen DELTA_REER = D.PX_REX_REER/L.PX_REX_REER*100


	twoway ///
	bar BN_CAB_XOKA_GD_ZS year if iso== "`ctry'" ///
	|| line DELTA_REER year if iso== "`ctry'", yaxis (2) ///
	, title("Evolution of the Current Account") subtitle("`j'" ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")
graph save "Evolution of the Current Account_1", replace

*** 13) Real Exchange Rate Volatility and GDP per capita ***
   
	egen VOLAT_REER = sd(DELTA_REER) if year>=2003, by(iso)


	twoway ///
	scatter VOLAT_REER gdpvar if year == `focusyear' & VOLAT_REER<=100 ///
	|| scatter VOLAT_REER gdpvar if year == `focusyear' & comp==1 & same_region==1 & VOLAT_REER<=100 ///
	||scatter VOLAT_REER gdpvar if year == `focusyear' & iso=="`ctry'" & VOLAT_REER<=100 ///
	, title("Volatility of REER") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)

graph save "Volatility of REER", replace

*** 14) Deposit rates

	twoway ///
	scatter FR_INR_DPST gdpvar if year == `focusyear' ///
	|| scatter FR_INR_DPST gdpvar if year == `focusyear' & comp==1 & same_region==1 ///
	||scatter FR_INR_DPST gdpvar if year == `focusyear' & iso=="`ctry'" ///
	, title("Deposit Rates") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)

graph save "deposit_rates", replace

*********************************************
*** II.B Financial Intermediation Stories ***
*********************************************
cd `countryfolder'
cd finance
capture mkdir intermediation
cd intermediation
								
*** 14) Interest rate spread ***

	twoway 
	scatter FR_INR_LNDP gdpvar if year == `focusyear' ///
	|| scatter FR_INR_LNDP gdpvar if year == `focusyear' & comp==1 & same_region==1 ///
	|| scatter FR_INR_LNDP gdpvar if year == `focusyear' & iso=="`ctry'" ///
	, title("Spread between deposit and lending rates") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log)
graph save "spread", replace

*** 15) Non-performing loans ***


	#delimit ;
	twoway 
	(scatter FB_AST_NPER_ZS gdpvar if year == `focusyear')
	(scatter FB_AST_NPER_ZS gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FB_AST_NPER_ZS gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Non-performing Loans") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);
graph save "NPLs", replace;
	
*** 16) Bank Capital to Asset Ratio ***


	#delimit ;
	twoway 
	(scatter FB_BNK_CAPA_ZS gdpvar if year == `focusyear')
	(scatter FB_BNK_CAPA_ZS gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FB_BNK_CAPA_ZS gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Bank's Capital to Asset Ratio") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);
graph save "caital to assets", replace;
	
*** 17) Bank Liquid Reserves ***


	#delimit ;
	twoway 
	(scatter FD_RES_LIQU_AS_ZS  gdpvar if year == `focusyear')
	(scatter FD_RES_LIQU_AS_ZS  gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FD_RES_LIQU_AS_ZS  gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Banks' Liquid Reserves") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);
graph save liquidity, replace;

*** 18) Bank Branches (to assess cost) ***


	#delimit ;
	twoway 
	(scatter FB_CBK_BRCH_P5  gdpvar if year == `focusyear')
	(scatter FB_CBK_BRCH_P5  gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FB_CBK_BRCH_P5  gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Commercial Bank Branches (per 100.000 adults)") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);
graph save numbranches, replace;

*** 18) Depositors with Commercial Banks ***


	#delimit ;
	twoway 
	(scatter FB_CBK_DPTR_P3  gdpvar if year == `focusyear')
	(scatter FB_CBK_DPTR_P3  gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FB_CBK_DPTR_P3  gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Depositors with Commercial Banks (per 1000 adults)") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);

graph save deposits_with_banks, replace;

*** 19) Borrowers from Commercial Banks ***


	#delimit ;
	twoway 
	(scatter FB_CBK_BRWR_P3 gdpvar if year == `focusyear')
	(scatter FB_CBK_BRWR_P3 gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter FB_CBK_BRWR_P3 gdpvar if year == `focusyear' & iso=="`ctry'")
	, title("Borrowers from Commercial Banks (per 1000 adults)") subtitle("`j', `focusyear'" ) legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);

graph save borrowers, replace;
*** 20) Firms using banks to finances investments ***


	#delimit ;
	twoway 
	(scatter IC_FRM_BNKS_ZS  gdpvar if year == `focusyear')
	(scatter IC_FRM_BNKS_ZS  gdpvar if year == `focusyear' & comp==1 & same_region==1)
	(scatter IC_FRM_BNKS_ZS  gdpvar if year == `focusyear' & iso=="`ctry'", mlabel(iso))
	, title("Firms using banks to finance investment") subtitle("`j', `focusyear'") legend( label (1 "Other Countries") ///
	label (2 "Benchmarks") label (3 "`j'")) note("Data source:  World Development Indicators, 2013") xscale(log);
graph save firms_using_banks, replace;
