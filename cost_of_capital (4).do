cd C:\Users\Brad\Desktop\IndicatorProject\diagnostics

** Enter name of WDI database saved in the folder
use wdi_data_2013_income_region_st10.dta, clear	

encode iso, gen(iso_numeric)
tsset iso_numeric year

local ctry ALB
local focusyear = 2012

												*** Describing Growth ***
												
*** I) Univariate analysis of GDP per capita and Growth ***

	preserve
	
	keep if iso == "`ctry'"
	qui levelsof countryname, local(j) clean

	*#delimit;
	twoway (line NY_GDP_PCAP_KD year) ///
	, title("Evolution of GDP per Capita") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")

	*#delimit;
	twoway (line NY_GDP_MKTP_KD_ZG year) ///
	, title("Evolution of GDP per Capita") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013")

	restore
		
*** II) Evaluation of GDP per capita vs. benchmark countries ***

	preserve

	local gdpvar NY_GDP_PCAP_PP_KD
		
	gen temp = `gdpvar' if year==2000
	egen gdp1985 = max(temp), by(iso)
	g gdp_index = 100*(`gdpvar'/gdp1985)
	drop gdp1985 temp

	gen tempvar1 = `gdpvar' if iso == "$ctry" & year==2012
	egen tempvar2 = max(tempvar1)
	g comparator_income_temp = (`gdpvar' <= 1.2*tempvar2 & `gdpvar' >=0.8*tempvar2) & year==2012
	egen comparator_income = max(comparator_income_temp), by(iso)
	drop tempvar* comparator_income_temp

	encode region, generate(region_num)
	gen tempvar1 = region_num if iso == "$ctry"
	egen tempvar2 = max(tempvar1)
	g same_region_temp = (tempvar2==region_num)
	egen same_region = max(same_region_temp), by(iso)
	drop tempvar* same_region_temp
	
	qui levelsof iso_numeric if comparator_income & same_region & iso!="$ctry", clean local(compctrs)
	
	global linecmd ""
	global legendcmd ""
	local i=2
	
	foreach c of local compctrs {
		global linecmd "$linecmd (line gdp_index year if iso_numeric==`c')"
		qui levelsof countryname if iso_numeric==`c', local(ctryname)
		global legendcmd "$legendcmd `i' `ctryname'"
		local i = `i'+1  
	}
	
	qui levelsof countryname if iso=="$ctry", local(j) clean
	
	twoway (line gdp_index year if iso=="$ctry", lwidth(vthick)) $linecmd, legend(order(1 "`j'" $legendcmd) size(vsmall) cols(3)) ///
		title("GDP per capita of `j' and comparator countries") note("Data source:  World Development Indicators, 2013")

	restore
								
												*** First Decision Node ***

*** 1) Interest Rate and GDP per Capita ***

	** What country?
	local y BRA

	** What year?
	local t 2012

	** Calculating comparator countries
	preserve
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region
	
	levelsof countryname if iso=="`y'", local(j) clean
	
	#delimit ;
	twoway 
	(scatter FR_INR_RINR NY_GDP_PCAP_KD )
	(scatter FR_INR_RINR NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FR_INR_RINR NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Cost of Capital") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013") xscale(log);

	restore

*** 2) Interest Rate and Investment (as % of GDP) ***

	** What country?
	local y BRA

	** What year?
	local t 2012

	** Calculating comparator countries
	preserve
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region
	
	levelsof countryname if iso=="`y'", local(j) clean
	
	#delimit ;
	twoway 
	(scatter FR_INR_RINR NE_GDI_TOTL_ZS )
	(scatter FR_INR_RINR NE_GDI_TOTL_ZS if comp==1 & same_region==1)
	(scatter FR_INR_RINR NE_GDI_TOTL_ZS if iso=="`y'", mlabel(iso))
	, title("Cost of Capital") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 3) Sensativity of Investment to Interest Rate in country of interest ***
	
	** What country?
	local y BRA
	
	preserve
	keep if iso== "`y'"
	
	levelsof countryname, local(j) clean
	
	#delimit ;
	twoway 
	(scatter FR_INR_RINR NE_GDI_TOTL_ZS, mlabel(year))
	(line FR_INR_RINR NE_GDI_TOTL_ZS)
	(lfit FR_INR_RINR NE_GDI_TOTL_ZS)
	, title("Sensibility of Investment to Interest Rate") subtitle(`"`j'"')
	ytitle("Real Interest Rate") xtitle("Gross Capital Formation") legend(off) note("Data source:  World Development Indicators, 2013");

	restore

*** 4) Net domestic credit ***

	** What country?
	local y BRA

	** What year?
	local t 2012

	preserve
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	gen NET_DOM_CREDIT_GDP = FM_AST_DOMS_CN / NY_GDP_MKTP_CN * 100
	label variable NET_DOM_CREDIT_GDP "Net Domestic Credit (als % of GDP)


	#delimit ;
	twoway 
	(scatter NET_DOM_CREDIT_GDP NY_GDP_PCAP_KD)
	(scatter NET_DOM_CREDIT_GDP NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter NET_DOM_CREDIT_GDP NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Net Domestic Credit") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore


								*** Savings Stories? ***

*** 5) Average interest on new external debt (poor measure of external debt - check EMBI+ and Spreads on Credit Default Swaps) ***

	** What country?
	local y BRA

	** What year?
	local t 2011

	preserve
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter DT_INR_DPPG NY_GDP_PCAP_KD)
	(scatter DT_INR_DPPG NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter DT_INR_DPPG NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Average interest on new external debt") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 6) Sensativity of Growth to Average interest on new external debt - Poor indicator of Access to international savings ***

	** What country?
	local y BRA
	
	preserve
	keep if iso== "`y'"
	
	levelsof countryname, local(j) clean
	
	#delimit ;
	twoway 
	(scatter DT_INR_DPPG NY_GDP_MKTP_KD_ZG, mlabel(year))
	(line DT_INR_DPPG NY_GDP_MKTP_KD_ZG)
	(lfit DT_INR_DPPG NY_GDP_MKTP_KD_ZG)
	, title("Sensibility of Growth to Average interest on new external debt") subtitle(`"`j'"' )
	legend(off) note("Data source:  World Development Indicators, 2013");

	restore

*** 7) External Debt (public and private, as % of GNI)

	** What country?
	local y BRA

	** What year?
	local t 2011

	preserve
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter DT_DOD_DECT_GN_ZS NY_GDP_PCAP_KD)
	(scatter DT_DOD_DECT_GN_ZS NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter DT_DOD_DECT_GN_ZS NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("External Debt Stocks") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore


*** 8) Evolution of External Debt (public and private, as % of GNI)

	** What country?
	local y BRA

	preserve
	
	keep if iso== "`y'"
	levelsof countryname, local(j) clean

	#delimit ;
	twoway 
	(bar DT_DOD_DECT_GN_ZS year)
	(line NY_GDP_MKTP_KD_ZG year, yaxis (2))
	, title("Evolution of the External Debt") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013");

	restore

*** 9) Total Central Government Debt - Since many countries w/o data, defined "counterfactual" strictly on income neighborhood ***

	** What country?
	local y BRA

	** What year?
	local t 2011

	preserve
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter GC_DOD_TOTL_GD_ZS NY_GDP_PCAP_KD)
	(scatter GC_DOD_TOTL_GD_ZS NY_GDP_PCAP_KD if comp==1)
	(scatter GC_DOD_TOTL_GD_ZS NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Total Central Government Debt") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 10) Evolution of the Total Central Government Debt ***

	** What country?
	local y BRA

	preserve
	
	keep if iso== "`y'"
	levelsof countryname, local(j) clean

	#delimit ;
	twoway 
	(bar GC_DOD_TOTL_GD_ZS year)
	(line NY_GDP_MKTP_KD_ZG year, yaxis (2))
	, title("Evolution of the Total Central Government Debt") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013");

	restore

*** 11) Evolution of the Current Account and Growth - Too short a series of CA ***

	** What country?
	local y BRA

	preserve
	
	keep if iso== "`y'"
	levelsof countryname, local(j) clean

	#delimit ;
	twoway 
	(bar BN_CAB_XOKA_GD_ZS year)
	(line NY_GDP_MKTP_KD_ZG year, yaxis (2))
	, title("Evolution of the Current Account") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013");

	restore
	
*** 12) Evolution of the Current Account and the Real Effective Exchange Rate - Many countries do not have PX_REX_REER ***
	*** Alternative source of data - Economist Intelligence Unit ***

gen DELTA_REER = D.PX_REX_REER/L.PX_REX_REER*100

	** What country?
	
	local y BDI

	preserve
	
	keep if iso== "`y'"
	levelsof countryname, local(j) clean

	#delimit ;
	twoway 
	(bar BN_CAB_XOKA_GD_ZS year)
	(line DELTA_REER year, yaxis (2))
	, title("Evolution of the Current Account") subtitle(`"`j'"' ) legend(off) ///
	note("Data source:  World Development Indicators, 2013");

	restore

*** 13) Real Exchange Rate Volatility and GDP per capita ***

	preserve
	gen LOG_GDP_PC = log(NY_GDP_PCAP_KD)
	egen VOLAT_REER= sd(DELTA_REER) if year>=2003, by(iso) 
	
	** What country?
	local y MYS

	** What year?
	local t 2011
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter VOLAT_REER LOG_GDP_PC if VOLAT_REER<=100)
	(scatter VOLAT_REER LOG_GDP_PC if comp==1 & same_region==1 & VOLAT_REER<=100)
	(scatter VOLAT_REER LOG_GDP_PC if iso=="`y'" & VOLAT_REER<=100, mlabel(iso))
	, title("Volatility of REER") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore
	
								*** Financial Intermediation Stories ***
*** 14) Interest rate spread ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2012
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FR_INR_LNDP NY_GDP_PCAP_KD)
	(scatter FR_INR_LNDP NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FR_INR_LNDP NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Spread between deposit and lending rates") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 15) Non-performing loans ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2012
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FB_AST_NPER_ZS NY_GDP_PCAP_KD)
	(scatter FB_AST_NPER_ZS NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FB_AST_NPER_ZS NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Non-performing Loans") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore
	
*** 16) Bank Capital to Asset Ratio ***

	preserve
	
	** What country?
	local y VEN

	** What year?
	local t 2012
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FB_BNK_CAPA_ZS  NY_GDP_PCAP_KD)
	(scatter FB_BNK_CAPA_ZS  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FB_BNK_CAPA_ZS  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Bank's Capital to Asset Ratio") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore	
	
*** 17) Bank Liquid Reserves ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2012
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FD_RES_LIQU_AS_ZS  NY_GDP_PCAP_KD)
	(scatter FD_RES_LIQU_AS_ZS  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FD_RES_LIQU_AS_ZS  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Banks' Liquid Reserves") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 18) Bank Branches (to assess cost) ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2011
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FB_CBK_BRCH_P5  NY_GDP_PCAP_KD)
	(scatter FB_CBK_BRCH_P5  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FB_CBK_BRCH_P5  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Commercial Bank Branches (per 100.000 adults)") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore
	
*** 18) Depositors with Commercial Banks ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2011
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FB_CBK_DPTR_P3  NY_GDP_PCAP_KD)
	(scatter FB_CBK_DPTR_P3  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FB_CBK_DPTR_P3  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Depositors with Commercial Banks (per 1000 adults)") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 19) Borrowers from Commercial Banks ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2011
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter FB_CBK_BRWR_P3  NY_GDP_PCAP_KD)
	(scatter FB_CBK_BRWR_P3  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter FB_CBK_BRWR_P3  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Borrowers from Commercial Banks (per 1000 adults)") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore

*** 20) Firms using banks to finances investments ***

	preserve
	
	** What country?
	local y BRA

	** What year?
	local t 2009
	
	keep if year == `t'
	gen tempvar1 = NY_GDP_PCAP_KD if iso == "`y'"
	egen tempvar2 = mean(tempvar1)
	gen comparator_income = 0
	replace comp = 1 if NY_GDP_PCAP_KD >= .8*tempvar2
	replace comp = 0 if NY_GDP_PCAP_KD > 1.2*tempvar2

	encode region, generate(region_numeric)
	drop region
	gen tempvar3 = region if iso == "`y'"
	egen tempvar4 = mean(tempvar3)
	gen same_region = 0
	replace same = 1 if tempvar4 == region

	levelsof countryname if iso=="`y'", local(j) clean

	#delimit ;
	twoway 
	(scatter IC_FRM_BNKS_ZS  NY_GDP_PCAP_KD)
	(scatter IC_FRM_BNKS_ZS  NY_GDP_PCAP_KD if comp==1 & same_region==1)
	(scatter IC_FRM_BNKS_ZS  NY_GDP_PCAP_KD if iso=="`y'", mlabel(iso))
	, title("Firms using banks to finance investment") subtitle(`"`j', `t'"' ) legend( label (1 "Other Countries") label (2 "Same Region and Income Level") ///
	label (3 `"`j'"')) note("Data source:  World Development Indicators, 2013");

	restore



