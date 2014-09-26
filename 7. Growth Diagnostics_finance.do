clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* ORIGINAL DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\WDI"
* ORIGINAL DATABASES
use "wdi2013.dta", clear
* OTHER DATABASES:
	* MACRO VARIABLES (SOME)
	global macrovar "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\International Debt Statistics (World Bank)\IDS2013.dta"
	* REAL EXCHANGE RATE
	global exchange "C:\Users\Luis Miguel\Documents\Bases de Datos\The Economist Intelligence Unit\exchangerate.dta"
	* FINANCIAL STRUCTURE
	global financial "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\Financial Development and Structure (World Bank)\Fin_Struc_2013.dta"
	* ENTERPRISE SURVEYS: FINANCE
	global es_finance "C:\Users\Luis Miguel\Documents\Bases de Datos\World Bank\Enterprise Surveys\finance.dta"
	* UNIDO
	global unido "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_2&4.dta"
* COUNTRY TO BE ANALYZED
local ctry PER
levelsof country if wbcode=="`ctry'", local(j) clean
* RESULTS
cd "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results"
capture mkdir "`ctry'"
global dir "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results\\`ctry'"
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata"
****************************************************************************************************************************************

* Elimination of non-countries: 38
* Arab World, Caribbean Small States, East Asia & Pacific (all income levels), East Asia & Pacific (developing only), East Asia & Pacific (IFC classification),
* Euro Area, Euope & Central Asia (all income levels), Europe & Central Asia (developing only), Europe & Central Asia (IFC classification), European Union,
* Heavily indebted poor countries (HIPC), High Income, High Income: OECD, High Income: nonOECD, Latin America & Caribbean (all income levels),
* Latin America & Caribbean (developing only), Latin America and the Caribbean (IFC classification), Least developed countries: UN classification,
* Low & middle income, Low income, Lower middle income, Middle East & North Africa (all income levels), Middle East & North Africa (developing only),
* Middle East and North Africa (IFC classification), Middle income, North America, Not classified, OECD members, Other small states, 
* Pacific island small states, Small states, South Asia, South Asia (IFC classification), Sub-Saharian Africa (IFC classification), 
* Sub-Saharian Africa (all income levels), Sub-Saharian Africa (developing only), Upper middle income, World
drop if wbcode=="ARB" | wbcode=="CSS" | wbcode=="EAS" | wbcode=="EAP" | wbcode=="CEA" | wbcode=="EMU" | wbcode=="ECS" | wbcode=="ECA" | wbcode=="CEU" /*
*/ | wbcode=="EUU" | wbcode=="HPC" | wbcode=="HIC" | wbcode=="OEC" | wbcode=="NOC"| wbcode=="LCN" | wbcode=="LAC" | wbcode=="CLA" | wbcode=="LDC" /*
*/ | wbcode=="LMY" | wbcode=="LIC" | wbcode=="LMC" | wbcode=="MEA" | wbcode=="MNA" | wbcode=="CME" | wbcode=="MIC" | wbcode=="NAC" | wbcode=="INX" /*
*/ | wbcode=="OED" | wbcode=="OSS" | wbcode=="PSS" | wbcode=="SST" | wbcode=="SAS" | wbcode=="CSA" | wbcode=="CAA" | wbcode=="SSF" | wbcode=="SSA" /*
*/ | wbcode=="UMC" | wbcode=="WLD"

* Elimination of small countries
gen n=0
replace n=1 if year==2012 & SP_POP_TOTL<1000000
bys wbcode: egen m=max(n)
drop if m==1
drop n m
sort country year

* Elimination of oil countries
drop if wbcode=="QAT" | wbcode=="KWT" | wbcode=="ARE" | wbcode=="OMN" | wbcode=="SAU" | wbcode=="BHR"

* WARNING: ELIMINATION OF BELARUS BECAUSE IT HAS A "TOO NEGATIVE" REAL INTEREST RATE
drop if wbcode=="BLR"
* WARNING: ELIMINATION OF ZIMBABWE BECAUSE IT HAS A "TOO VOLATILE" EXCHANGE RATE
drop if wbcode=="ZWE"

* Region
gen region=.
* South America
	* Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Guyana, Paraguay, Peru, Uruguay, Venezuela
foreach x in ARG BOL BRA CHL COL ECU GUY PRY PER URY VEN {
	replace region=1 if wbcode=="`x'"
}
* Central America & Caribbean
	* Antigua y Barbuda, Aruba, Bahamas, Barbados, Belize, Cayman Islands, Costa Rica, Cuba, Curacao, Dominica, 
	* Dominican Rep., El Salvador, Grenada, Guatemala, Haiti, Honduras, Jamaica, Mexico, Nicaragua, Panama, Puerto Rico,
	* Sint Maarten (Dutch part), St. Kitts and Nevis, St. Lucia, St. Martin (French part), St. Vincent and the Grenadines, Suriname, Trinidad and Tobago, 
	* Turks and Caicos Islands, Virgin Islands (U.S.)
foreach x in ATG ABW BHS BRB BLZ CYM CRI CUB CUW DMA DOM SLV GRD GTM HTI HND JAM MEX NIC PAN PRI SXM KNA LCA MAF VCT SUR /*
*/ TTO TCA VIR {
	replace region=2 if wbcode=="`x'"
}
* North-America: Bermuda, Canada, United States
foreach x in BMU CAN USA {
	replace region=2 if wbcode=="`x'"
}
* Central Europe (former non-communist): Austria, Germany, Liechtenstein, Luxemburg, Switzerland
foreach x in AUT DEU LIE LUX CHE {
		replace region=3 if wbcode=="`x'"
}
* Central Europe (former Communist): Croatia, Czech Rep., Hungary, Poland, Slovak Rep., Slovenia
foreach x in HRV CZE HUN POL SVK SVN {
		replace region=4 if wbcode=="`x'"
}
* North Europe: Denmark, Faeroe Islands, Finland, Greenland, Iceland, Norway, Sweden
foreach x in DNK FIN FRO GRL ISL NOR SWE {
	replace region=3 if wbcode=="`x'"
}
* South Europe: Andorra, Italy, Malta, Portugal, San Marino, Spain
foreach x in ADO ITA MLT PRT SMR ESP {
	replace region=3 if wbcode=="`x'"
}
* West Europe: Belgium, Channel Islands, France, Isle of Man, Ireland, Monaco, Netherlands, United Kingdom
foreach x in BEL CHI FRA IMY IRL MCO NLD GBR {
	replace region=3 if wbcode=="`x'"
}
* Southeast Europe (former non-Communist): Cyprus, Greece
foreach x in CYP GRC  {
	replace region=3 if wbcode=="`x'"
}
* Southeast Europe (former Communist): Albania, Bosnia and Herzegovina, Bulgaria, Kosovo, Macedonia, Moldova, Montenegro, Romania, Serbia
foreach x in ALB BIH BGR KSV MKD MDA MNE ROM SRB {
	replace region=4 if wbcode=="`x'"
}
* Post-Soviet States: Armenia, Azerbaijan, Belarus, Estonia, Georgia, Kazakhstan, Kyrgyzstan, Latvia, Lithuania, Moldova, Russia, Tajikistan, Turkmenistan, 
*					  Ukraine, Uzbekistan
foreach x in ARM AZE BLR EST GEO KAZ KGZ LVA LTU MDA RUS TJK TKM UKR UZB {
	replace region=4 if wbcode=="`x'"
}
* Middle East & North Africa: Algeria, Bahrain, Djibouti, Egypt, Israel, Iran, Iraq, Jordan, Kuwait, Lebanon, Libya, Morocco, Oman, Qatar, Saudi Arabia, Syria, 
*							  Tunisia, Turkey, United Arab Emirates, West Bank and Gaza, Yemen
foreach x in DZA BHR DJI EGY ISR IRN IRQ JOR KWT LBN LBY MAR OMN QAT SAU SYR TUN TUR ARE WBG YEM {
	replace region=5 if wbcode=="`x'"
}
* East and South East Asia: China, Hong Kong, Japan, Macau, Mongolia, North Korea, South Korea
* 							Brunei, Cambodia, Indonesia, Laos, Malaysia, Myanmar(Burma), Philippines, Singapore, Thailand, Vietnam
foreach x in CHN HKG JPN MAC MNG PRK KOR BRN KHM IDN LAO MYS MMR PHL SGP THA VNM {
	replace region=6 if wbcode=="`x'"
}
* South Asia: Afghanistan, Bangladesh, Bhutan, India, Maldives, Nepal, Pakistan, Sri Lanka
foreach x in AFG BGD BTN IND MDV NPL PAK LKA {
	replace region=7 if wbcode=="`x'"
}
* Sub-Saharian Africa: Angola, Benin, Botswana, Burkina Faso, Burundi, Cape Verde, Cameroon, Central African Rep., Chad, Comoros, Dem. Rep. Congo, Rep. Congo,
* 					   Cote d'Ivoire, Equatorial Guinea, Eritrea, Ethiopia, Gabon, Gambia, Ghana, Guinea, Guinea-Bissau, Kenya, Lesotho, Liberia, Madagascar,
*					   Malawi, Mali, Mauritania, Mauritius, Mozambique, Namibia, Niger, Nigeria, Rwanda, Sao Tome and Principe, Senegal, Seychelles, 
*					   Sierra Leone, Somalia, South Africa, South Sudan, Sudan, Swaziland, Tanzania, Togo, Uganda, Zambia, Zimbabwe
foreach x in AGO BEN BWA BFA BDI CPV CMR CAF TCD COM COD ZAR COG CIV GNQ ERI ETH GAB GMB GHA GIN GNB KEN LSO LBR MDG MWI MLI MRT MUS MOZ NAM NER NGA RWA STP SEN /*
*/ SYC SLE SOM ZAF SSD SDN SWZ TZA TGO UGA ZMB ZWE {
	replace region=8 if wbcode=="`x'"
}
* South Pacific: American Samoa, Australia, Fiji, French Polynesia, Guam, Kiribati, Marshall Islands, Micronesia, New Caledonia, New Zealand, 
*				 Northern Mariana Islands, Palau, Papua New Guinea, Samoa, Solomon Islands, Timor-Leste, Tonga, Tuvalu, Vanuatu
foreach x in ASM AUS FJI PYF GUM KIR MHL FSM NCL NZL MNP PLW PNG WSM SLB TMP TON TUV VUT {
	replace region=9 if wbcode=="`x'"
}
label def region 1"South America" 2"North and Central America & the Caribbean" 3"Former Non-Communist Europe" 4"Former-Communist Europe" /*
*/ 5"Middle East & North Africa" 6"East & Southeast Asia" 7"South Asia" 8"Sub-Saharian Africa" 9"South Pacific"
label val region region

* In which region the country is?
summ region if wbcode=="`ctry'"
scalar region`ctry'=r(mean)

* Renaming and labeling
rename NY_GDP_PCAP_KD gdppc			/* GDP per capita (constant 2005 US$) <-- FOR TIME SERIES */
gen loggdppc=log(gdppc)
label var loggdppc "Log(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2		/* GDP per capita, PPP (constant 2005 international $) <-- FOR CROSS-SECTION */
gen loggdppc2=log(gdppc2)
label var loggdppc "GDP per capita (constant 2005 US$), log"
label var loggdppc2 "GDP per capita, PPP (constant 2005 international $), log"
label var year "Years"

* Identification of growth collapses and accelerations
	summ year if wbcode=="`ctry'" & gdppc!=.
	* Minimum
	scalar minyear=r(min)
	local minyear: display %9.0fc minyear
	*Maximum
	scalar maxyear=r(max)
	local maxyear: display %9.0fc maxyear
	* 8 year growth rate (forward)
	sort wbcode year
	gen g4=100*(((gdppc[_n+7]/gdppc[_n])^(1/7))-1) if wbcode[_n+7]==wbcode[_n]
	* Change in growth rate
	gen delta=g4[_n]-g4[_n-7] if wbcode[_n+7]==wbcode[_n]
	* Aceleration
	gen accel=0
	replace accel=1 if g4>=3.5 & delta>=2.0 & gdppc[_n+7]>=max(gdppc[_n],gdppc[_n+1],gdppc[_n+2],gdppc[_n+3],gdppc[_n+4],gdppc[_n+5],gdppc[_n+6]) /*
	*/ & gdppc[_n+7]!=. & gdppc[_n]!=.
	* Selecting the acceleration
	gen accel2=1 if accel[_n]==1 & gdppc[_n]>gdppc[_n-1] & gdppc[_n]<gdppc[_n+1]
	gen accel3=1 if accel2==1 & accel2[_n-1]!=1 & accel2[_n-2]!=1 & accel2[_n-3]!=1 & accel2[_n-4]!=1 & accel2[_n-5]!=1 & accel2[_n-6]!=1 & accel2[_n-7]!=1
	drop accel2
	rename accel3 accel2
	* Deacceleration
	gen deaccel=0
	replace deaccel=1 if g4<=1.0 & delta<=-2.0
	* Selecting the deacceleration
	gen deaccel2=1 if deaccel==1 & deaccel[_n-1]!=1 & deaccel[_n-2]!=1 & deaccel[_n-3]!=1 & deaccel[_n-4]!=1 & deaccel[_n-5]!=1 & deaccel[_n-6]!=1 & deaccel[_n-7]!=1
	* Defining and counting the thresholds
	gen milestone=1 if (deaccel2==1 | accel2==1) & wbcode=="`ctry'"
	count if milestone==1
	scalar number_milestones=r(N)
	if `=number_milestones'>0 {
		* Capturing the thresholds
		tab year if milestone==1, matrow(milestone)
		forval x=1/`=number_milestones' {
			scalar milestone`x'=milestone[`x',1]
		}

		* Length of periods (and halves)
		scalar length1=`=milestone1'-`=minyear'
		scalar half1=`=`=length1'/2'
		forval x=2/`=number_milestones' {
			scalar length`x'=`=milestone`x''-`=milestone`=`x'-1''
			scalar half`x'=`=`=length`x''/2'
		}
		scalar length`=`=number_milestones'+1'=`=maxyear'-`=milestone`=number_milestones''
		scalar half`=`=number_milestones'+1'=`=`=length`=`=number_milestones'+1''/2'
	}
	else {
		* Capturing the thresholds
		scalar milestone1=`=maxyear'
		* Length of periods (and halves)
		scalar length1=`=milestone1'-`=minyear'
		scalar half1=`=`=length1'/2'
	}



****************************************************************************************************
*************************************** HIGH COST OF FINANCE ***************************************
****************************************************************************************************

********************************************
* FINANCIAL DEPTH VS GDPpc (CROSS SECTION) *
********************************************
rename FS_AST_PRVT_GD_ZS credit
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & credit!=.
	scalar maxyear1=r(max)
	bys year: count if loggdppc2!=. & credit!=.
	if r(N)>=30 {
		keep if year==`=maxyear1'
	}
	continue, break
}
scalar drop maxyear1
summ year if wbcode=="`ctry'" & loggdppc2!=. & credit!=.
scalar maxyear1=r(max)
local maxyear1: display %9.0f maxyear1

drop if year!=`=maxyear1'

if `=maxyear1'!=. {
	* Statistics for Figure 1
	* Deciles
	foreach x in credit loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in credit loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 1
	lpoly credit loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Financial depth vs. GDP per capita, `=maxyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Domestic credit to private sector (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter credit loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter credit loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter credit loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure1`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure1`ctry'_4.png") replace
	
	* How many s.d. is the country from the fitted value?
	gen diff=(credit-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_credit=r(mean)
	drop pred se diff
}
restore

*******************************************************
* REAL LENDING INTEREST RATE VS GDPpc (CROSS SECTION) *
*******************************************************
rename FR_INR_RINR real_i
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & real_i!=.
	scalar maxyear2=r(max)
	bys year: count if loggdppc2!=. & real_i!=.
	if r(N)>=30 {
		keep if year==`=maxyear2'
	}
	continue, break
}
scalar drop maxyear2
summ year if wbcode=="`ctry'" & loggdppc2!=. & real_i!=.
scalar maxyear2=r(max)
local maxyear2: display %9.0f maxyear2

drop if year!=`=maxyear2'

if `=maxyear2'!=. {
	* Statistics for Figure 2
	* Deciles
	foreach x in real_i loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in real_i loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 2
	lpoly real_i loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Real lending interest rate vs. GDP per capita, `=maxyear2'") subtitle("`j'") /*
	*/ note("Note: Real lending interest rate is the lending interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators") /*
	*/ ytitle("Real lending interest rate (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter real_i loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter real_i loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter real_i loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure2`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure2`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(real_i-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_real_i=r(mean)
	drop pred se diff
}
restore

******************************************************************
* REAL LENDING INTEREST RATE VS INVESTMENT RATIO (CROSS SECTION) *
******************************************************************
sort wbcode year
gen invest_m=.
replace invest_m=(NE_GDI_FTOT_ZS[_n]+NE_GDI_FTOT_ZS[_n-1]+NE_GDI_FTOT_ZS[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
gen real_i_m=(real_i[_n]+real_i[_n-1]+real_i[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if real_i_m!=. & invest_m!=.
	scalar maxyear3=r(max)
	bys year: count if real_i_m!=. & invest_m!=.
	if r(N)>=30 {
		keep if year==`=maxyear3'
	}
	continue, break
}
scalar drop maxyear3
summ year if wbcode=="`ctry'" & real_i_m!=. & invest_m!=.
scalar maxyear3=r(max)
local maxyear3: display %9.0f maxyear3

drop if year!=`=maxyear3'

if `=maxyear3'!=. {
	* Statistics for Figure 3
	* Deciles
	foreach x in real_i_m invest_m {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in real_i_m invest_m {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 3
	lpoly real_i_m invest_m, ci at(invest_m) gen(pred) se(se) legend(off) /*
	*/ title("Real lending interest rate vs. Investment ratio, `=`=maxyear3'-2'-`=maxyear3'") subtitle("`j'") /*
	*/ note("Note: Real lending interest rate is the lending interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators") /*
	*/ ytitle("Real lending interest rate (%), 3-year average") xtitle("Gross fixed capital formation (% of GDP), 3-year average") /*
	*/ addplot(scatter real_i_m invest_m, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter real_i_m invest_m if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter real_i_m invest_m if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure3`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure3`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(real_i_m-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_real_i_m=r(mean)
	drop pred se diff
}
restore

*******************************************************************
** REAL LENDING INTEREST RATE VS INVESTMENT RATIO (TIME SCATTER) **
*******************************************************************
rename NE_GDI_FTOT_ZS invest
preserve

* Statistics for Figure 4
summ year if wbcode=="`ctry'" & real_i!=. & invest!=.
* Minimum
scalar minyear4=r(min)
local minyear4: display %9.0fc minyear4
*Maximum
scalar maxyear4=r(max)
local maxyear4: display %9.0fc maxyear4

* Figure 4
if `=minyear4'<`=`=maxyear4'-10' {
	twoway connect real_i invest if wbcode=="`ctry'" & year>=`=`=maxyear4'-10', mlabel(year) lcolor(cranberry) lwidth(medthick) || /*
	*/ scatter real_i invest if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear4'-10', mcolor(red) legend(off) /*
	*/ xtitle("Gross fixed capital formation (% of GDP)") /*
	*/ ytitle("Real lending interest rate (%)") /*
	*/ title("Real lending interest rate vs. Investment ratio, `=`=maxyear4'-10'-`=maxyear4'") subtitle("`j'") /*
	*/ note("Note: Real lending interest rate is the lending interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators")
}
else {
	twoway connect real_i invest if wbcode=="`ctry'" & year>=`minyear4', mlabel(year) lcolor(cranberry) lwidth(medthick) || /*
	*/ scatter real_i invest if wbcode=="`ctry'" & milestone==1 & year>=`=minyear4', mcolor(red) legend(off) /*
	*/ xtitle("Gross fixed capital formation (% of GDP)") /*
	*/ ytitle("Real lending interest rate (%)") /*
	*/ title("Real lending interest rate vs. Investment ratio, `=minyear4'-`=maxyear4'") subtitle("`j'") /*
	*/ note("Note: Real lending interest rate is the lending interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure4`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure4`ctry'_4.png") append

restore

*************************************************************
** INVESTMENTS FINANCED BY BANKS OR EQUITY (CROSS-SECTION) **
*************************************************************
preserve
save "temp.dta", replace
use "$es_finance", clear		/* Entreprise Surveys */
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
gen invest_bank_equity=invest_bank+invest_equity
label var invest_bank_equity "Proportion of investments financed by banks or equity"

* Years
summ year if loggdppc2!=. & invest_bank_equity!=.
scalar minyear5=r(min)
scalar maxyear5=r(max)
summ year if wbcode=="`ctry'" & loggdppc2!=. & invest_bank_equity!=.
scalar year5=r(mean)

* Statistics for Figure 5
* Deciles
foreach x in loggdppc2 invest_bank_equity {
	xtile pct=`x' if `x'!=., nq(10)
	summ pct if wbcode=="`ctry'"
	scalar pct_`x'=r(mean)
	local pct_`x': display %9.1fc pct_`x'
	drop pct
	}
* Ranks
foreach x in loggdppc2 invest_bank_equity {
	count if `x'!=.
	scalar n_`x'=r(N)
	xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
	summ rank if wbcode=="`ctry'"
	scalar rank_`x'=r(mean)
	drop rank
	}
	
* Figure 5
lpoly invest_bank_equity loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
*/ title("Investments financed by banks or equity vs. GDP per capita," "`=minyear5'-`=maxyear5'") subtitle("`j', `=year5'") /*
*/ note("Data source: Enterprise Surveys and World Development Indicators") /*
*/ ytitle("Proportion of investments financed by banks or equity") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
*/ addplot(scatter invest_bank_equity loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
*/ scatter invest_bank_equity loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
*/ scatter invest_bank_equity loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

* Exporting results into word document
gr export "$dir\figure5`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure5`ctry'_4.png") append

* How many s.d. is the country from the fitted value?
gen diff=(invest_bank_equity-pred)/se
summ diff if wbcode=="`ctry'"
scalar diff_invest_bank_equity=r(mean)
drop pred se diff

restore

****************************************************
** WORK CAPITAL FINANCED BY BANKS (CROSS-SECTION) **
****************************************************
preserve
save "temp.dta", replace
use "$es_finance", clear		/* Entreprise Surveys */
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge

* Years
summ year if loggdppc2!=. & workingk_bank!=. 
scalar minyear6=r(min)
scalar maxyear6=r(max)
summ year if wbcode=="`ctry'" & loggdppc2!=. & workingk_bank!=. 
scalar year6=r(mean)

* Statistics for Figure 6
* Deciles
foreach x in loggdppc2 workingk_bank {
	xtile pct=`x' if `x'!=., nq(10)
	summ pct if wbcode=="`ctry'"
	scalar pct_`x'=r(mean)
	local pct_`x': display %9.1fc pct_`x'
	drop pct
	}
* Ranks
foreach x in loggdppc2 workingk_bank {
	count if `x'!=.
	scalar n_`x'=r(N)
	xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
	summ rank if wbcode=="`ctry'"
	scalar rank_`x'=r(mean)
	drop rank
	}
	
* Figure 6
lpoly workingk_bank loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
*/ title("Working capital financed by banks vs. GDP per capita," "`=minyear6'-`=maxyear6'") subtitle("`j', `=year6'") /*
*/ note("Data source: Enterprise Surveys and World Development Indicators") /*
*/ ytitle("Proportion of working capital financed by banks (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
*/ addplot(scatter workingk_bank loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
*/ scatter workingk_bank loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
*/ scatter workingk_bank loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

* Exporting results into word document
gr export "$dir\figure6`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure6`ctry'_4.png") append

* How many s.d. is the country from the fitted value?
gen diff=(workingk_bank-pred)/se
summ diff if wbcode=="`ctry'"
scalar diff_workingk_bank=r(mean)
drop pred se diff

restore

***************************************************
** FINANCE AS BINDING CONSTRAINT (CROSS-SECTION) **
***************************************************
preserve
save "temp.dta", replace
use "$es_finance", clear		/* Entreprise Surveys */
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge

* Years
summ year if loggdppc2!=. & finance_constraint!=. 
scalar minyear7=r(min)
scalar maxyear7=r(max)
summ year if wbcode=="`ctry'" & loggdppc2!=. & finance_constraint!=. 
scalar year7=r(mean)

* Statistics for Figure 7
* Deciles
foreach x in loggdppc2 finance_constraint {
	xtile pct=`x' if `x'!=., nq(10)
	summ pct if wbcode=="`ctry'"
	scalar pct_`x'=r(mean)
	local pct_`x': display %9.1fc pct_`x'
	drop pct
	}
* Ranks
foreach x in loggdppc2 finance_constraint {
	count if `x'!=.
	scalar n_`x'=r(N)
	xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
	summ rank if wbcode=="`ctry'"
	scalar rank_`x'=r(mean)
	drop rank
	}
	
* Figure 7
lpoly finance_constraint loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
*/ title("Finance as a major constraint vs. GDP per capita," "`=minyear7'-`=maxyear7'") subtitle("`j', `=year7'") /*
*/ note("Data source: Enterprise Surveys and World Development Indicators") /*
*/ ytitle("Proportion of firms identifying access to finance" "as a major constraint (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
*/ addplot(scatter finance_constraint loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
*/ scatter finance_constraint loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
*/ scatter finance_constraint loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

* Exporting results into word document
gr export "$dir\figure7`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure7`ctry'_4.png") append

* How many s.d. is the country from the fitted value?
gen diff=(finance_constraint-pred)/se
summ diff if wbcode=="`ctry'"
scalar diff_finance_constraint=r(mean)
drop pred se diff

restore
/*
***********************
** CAMELS AND HIPPOS **
***********************
*preserve
keep country wbcode year gdppc gdppc2 loggdppc loggdppc2
merge 1:m wbcode year using "$unido" /* UNIDO */
drop if _merge!=3
drop _merge
sort wbcode year isic

* Industries
drop if value==.
keep if isic==15 | isic==155 | isic==16 | isic==17 | isic==1711 | isic==1810 | isic==191 | isic==1920 | isic==20 | isic==21 | isic==2101 | isic==22 | /*
*/ isic==2310 | isic==2320 | isic==2411 | isic==2413 | isic==242 | isic==2423 | isic==2430 | isic==251 | isic==2520 | isic==2691 | isic==2610 | isic==269 | /*
*/ isic==2710 | isic==2731 | isic==2720 | isic==2732 | isic==281 | isic==291 | isic==292 | isic==3000 | isic==31 | isic==32 | isic==33 | isic==34 | /*
*/ isic==35 | isic==351 | isic==36 | isic==99
replace isic=1 if isic==15
replace isic=2 if isic==155
replace isic=3 if isic==16
replace isic=4 if isic==17
replace isic=5 if isic==1711
replace isic=6 if isic==1810
replace isic=7 if isic==191
replace isic=8 if isic==1920
replace isic=9 if isic==20
replace isic=10 if isic==21
replace isic=11 if isic==2101
replace isic=12 if isic==22
replace isic=13 if isic==2310
replace isic=14 if isic==2320
replace isic=15 if isic==2411
replace isic=16 if isic==2413
replace isic=17 if isic==242
replace isic=18 if isic==2423
replace isic=19 if isic==251
replace isic=20 if isic==2520
replace isic=21 if isic==2691
replace isic=22 if isic==2610
replace isic=23 if isic==269
replace isic=24 if isic==2710
replace isic=25 if isic==2720
replace isic=26 if isic==281
replace isic=27 if isic==291
replace isic=28 if isic==3000
replace isic=29 if isic==31
replace isic=30 if isic==32
replace isic=31 if isic==33
replace isic=32 if isic==34
replace isic=33 if isic==35
replace isic=34 if isic==351
replace isic=35 if isic==36
label def isic 1"Food products" 2"Beverages" 3"Tobacco products" 4"Textiles" 5"Spinning" 6"Apparel" 7"Leather" 8"Footwear" /*
*/ 9"Wood products" 10"Paper and paper products" 11"Pulp, paper" 12"Printing and publishing" 13"Coke oven products" 14"Refined petroleum products" /*
*/ 15"Basic chemicals exclud. fertilizers" 16"Synthetic resins" 17"Other chemicals" 18"Drugs" 19"Rubber products" 20"Plastic products" /*
*/ 21"Pottery, china" 22"Glass" 23"Non metal products" 24"Iron and steel" 25"Non-ferrous metal" 26"Metal products" 27"Machinery" /*
*/ 28"Office, computing" 29"Elect. Machinery" 30"Radio, TV and communication equip." 31"Medical, precision and optical instruments" 32"Motor vehicle" /*
*/ 33"Transp. Equip." 351"Ship and boats" 36"Furniture"
	* Food products = 1 - 2
	gen va=value if isic==2
	bys wbcode year: egen va2=max(va)
	replace value=value-va2 if isic==1
	drop va va2
	* Synthetic resins = 16 + 2430
	gen va=value if isic==2430
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==16
	drop va va2
	drop if isic==2430
	* Non metal products = 23 - 21
	gen va=value if isic==21
	bys wbcode year: egen va2=max(va)
	replace value=value-va2 if isic==23
	drop va va2
	* Iron and steel = 24 + 2731
	gen va=value if isic==2731
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==24
	drop va va2
	drop if isic==2731
	* Non-ferrous metal = 25 + 2732
	gen va=value if isic==2732
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==25
	drop va va2
	drop if isic==2732
	* Machinery = 27 + 292
	gen va=value if isic==292
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==27
	drop va va2
	drop if isic==292
	* Electronic machinery = 29 + 30
	gen va=value if isic==30
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==29
	drop va va2
	* Transp. Equip. = 33 + 32
	gen va=value if isic==32
	bys wbcode year: egen va2=max(va)
	replace value=value+va2 if isic==33
	drop va va2
drop if value==.

* Dependency on external finance
gen fin=.
replace fin=0.14 if isic==1
replace fin=0.08 if isic==2
replace fin=-0.45 if isic==3
replace fin=0.40 if isic==4
replace fin=-0.09 if isic==5
replace fin=0.03 if isic==6
replace fin=-0.14 if isic==7
replace fin=-0.08 if isic==8
replace fin=0.28 if isic==9
replace fin=0.18 if isic==10
replace fin=0.15 if isic==11
replace fin=0.20 if isic==12
replace fin=0.33 if isic==13
replace fin=0.04 if isic==14
replace fin=0.25 if isic==15
replace fin=0.16 if isic==16
replace fin=0.22 if isic==17
replace fin=1.49 if isic==18
replace fin=0.23 if isic==19
replace fin=1.14 if isic==20
replace fin=-0.15 if isic==21
replace fin=0.53 if isic==22
replace fin=0.06 if isic==23
replace fin=0.09 if isic==24
replace fin=0.01 if isic==25
replace fin=0.24 if isic==26
replace fin=0.45 if isic==27
replace fin=1.06 if isic==28
replace fin=0.77 if isic==29
replace fin=1.04 if isic==30
replace fin=0.96 if isic==31
replace fin=0.39 if isic==32
replace fin=0.31 if isic==33
replace fin=0.46 if isic==34
replace fin=0.24 if isic==35

* Calculation of VA as % of total VA
gen va_ind=value if isic==99
bys wbcode year: egen va_ind2=max(va_ind)
drop if isic==99
gen va_per=value/va_ind2
drop value va_ind va_ind2

* Industry dummies
forval x=1/35 {
	gen isic`x'=1 if isic==`x'
	replace isic`x'=0 if isic!=`x'
}
* Local for dummies
local ind "isic2 isic3 isic4 isic5 isic6 isic7 isic8 isic9 isic10 isic11 isic12 isic13 isic14 isic15 isic16 isic17 isic18 isic19 isic20 isic21 isic22 isic23 isic24 isic25 isic26 isic27 isic28 isic29 isic30 isic31 isic32 isic33 isic34 isic35"

* Industry dummies*GDP
forval x=1/35 {
	gen isic`x'_gdp=isic`x'*gdppc2 if isic==`x'
	replace isic`x'_gdp=0 if isic`x'_gdp==.
	}
local ind_gdp "isic1_gdp isic2_gdp isic3_gdp isic4_gdp isic5_gdp isic6_gdp isic7_gdp isic8_gdp isic9_gdp isic10_gdp isic11_gdp isic12_gdp isic13_gdp isic14_gdp isic15_gdp isic16_gdp isic17_gdp isic18_gdp isic19_gdp isic20_gdp isic21_gdp isic22_gdp isic23_gdp isic24_gdp isic25_gdp isic26_gdp isic27_gdp isic28_gdp isic29_gdp isic30_gdp isic31_gdp isic32_gdp isic33_gdp isic34_gdp isic35_gdp"
	
* Country dummies
encode wbcode, gen(wbcode2)
forval x=1/127 {
	gen country`x'=1 if wbcode2==`x'
	replace country`x'=0 if wbcode2!=`x'
}

* Country dummies * dependency
forval x=1/127 {
	gen country`x'_fin=country`x'*fin if wbcode2==`x'
	replace country`x'_fin=0 if country`x'_fin==.
	drop country`x'
	}
local country_fin "country1_fin country2_fin country3_fin country4_fin country5_fin country6_fin country7_fin country8_fin country9_fin country10_fin country11_fin country12_fin country13_fin country14_fin country15_fin country16_fin country17_fin country18_fin country19_fin country20_fin country21_fin country22_fin country23_fin country24_fin country25_fin country26_fin country27_fin country28_fin country29_fin country30_fin country31_fin country32_fin country33_fin country34_fin country35_fin country36_fin country37_fin country38_fin country39_fin country40_fin country41_fin country42_fin country43_fin country44_fin country45_fin country46_fin country47_fin country48_fin country49_fin country50_fin country51_fin country52_fin country53_fin country54_fin country55_fin country56_fin country57_fin country58_fin country59_fin country60_fin country61_fin country62_fin country63_fin country64_fin country65_fin country66_fin country67_fin country68_fin country69_fin country70_fin country71_fin country72_fin country73_fin country74_fin country75_fin country76_fin country77_fin country78_fin country79_fin country80_fin country81_fin country82_fin country83_fin country84_fin country85_fin country86_fin country87_fin country88_fin country89_fin country90_fin country91_fin country92_fin country93_fin country94_fin country95_fin country96_fin country97_fin country98_fin country99_fin country100_fin country101_fin country102_fin country103_fin country104_fin country105_fin country106_fin country107_fin country108_fin country109_fin country110_fin country111_fin country112_fin country113_fin country114_fin country115_fin country116_fin country117_fin country118_fin country119_fin country120_fin country121_fin country122_fin country123_fin country124_fin country125_fin country126_fin country127_fin"

* Regression
reg va_per `ind' `ind_gdp' `country_fin', r
gen bheta=.
matrix bheta=e(b)
forval x=66/127 {
	scalar b`x'=bheta[1,`x']
*	replace bheta=`b`x''
}

*8
*/
*********************************************
** NET CASH FLOWS FROM BANKS (TIME SERIES) **
*********************************************
preserve
sort wbcode year
gen net_cash=(credit[_n]*NY_GDP_MKTP_KN[_n]-(1+FR_INR_LEND[_n])*credit[_n-1]*NY_GDP_MKTP_KN[_n-1])/(credit[_n-1]*NY_GDP_MKTP_KN[_n-1]) if wbcode[_n]==wbcode[_n-1]	/*I use constant GDP in LCU*/

* Statistics for Figure 9
summ year if wbcode=="`ctry'" & net_cash!=.
* Minimum
scalar minyear9=r(min)
local minyear9: display %9.0fc minyear9
*Maximum
scalar maxyear9=r(max)
local maxyear9: display %9.0fc maxyear9
* Max/Min variable
summ net_cash if wbcode=="`ctry'" & year>=`=`=maxyear9'-15'
scalar max_net_cash=r(max)
gen max_net_cash=`=max_net_cash' if wbcode=="`ctry'"
scalar min_net_cash=r(min)
gen min_net_cash=`=min_net_cash' if wbcode=="`ctry'"

* Figure 9
if `=minyear9'<`=`=maxyear9'-15' {
	twoway connect net_cash year if wbcode=="`ctry'" & year>=`=`=maxyear9'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_net_cash year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear9'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_net_cash year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear9'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Net cash flow from banks") /*
	*/ title("Net cash flow from banks, `=`=maxyear9'-15'-`=maxyear9'") subtitle("`j'") /*
	*/ note("Note: net cash flows from banks are the percentage change in credit to the private sector minus" /*
	*/ "the lending interest rate" "Data source: World Development Indicators")
}
else {
	twoway connect net_cash year if wbcode=="`ctry'" & year>=`minyear9', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_net_cash year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear9', lcolor(gs8) legend(off) || /*
	*/ spike min_net_cash year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear9', lcolor(gs8) legend(off) /*
	*/ ytitle("Net cash flow from banks") /*
	*/ title("Net cash flow from banks, `=minyear9'-`=maxyear9'") subtitle("`j'") /*
	*/ note("Note: Net cash flows from banks are the percentage change in credit to the private sector minus" /*
	*/ "the (lending) interest rate" "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure9`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure9`ctry'_4.png") append

restore

***********************************************
** NET CASH FLOWS FROM BANKS (CROSS-SECTION) **
***********************************************
sort wbcode year
gen net_cash2=(credit[_n]*NY_GDP_MKTP_PP_CD[_n]-(1+FR_INR_LEND[_n])*credit[_n-1]*NY_GDP_MKTP_PP_CD[_n-1])/(credit[_n-1]*NY_GDP_MKTP_PP_CD[_n-1]) if wbcode[_n]==wbcode[_n-1]	 /*I use current GDP in US$*/
gen net_cash2_m=(net_cash2[_n]+net_cash2[_n-1]+net_cash2[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
gen loggdppc2_m=(loggdppc2[_n]+loggdppc2[_n-1]+loggdppc2[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2_m!=. & net_cash2_m!=.
	scalar maxyear10=r(max)
	bys year: count if loggdppc2_m!=. & net_cash2_m!=.
	if r(N)>=30 {
		keep if year==`=maxyear10'
	}
	continue, break
}
scalar drop maxyear10
summ year if wbcode=="`ctry'" & loggdppc2_m!=. & net_cash2_m!=.
scalar maxyear10=r(max)
local maxyear10: display %9.0f maxyear10

drop if year!=`=maxyear10'

if `=maxyear10'!=. {
	* Statistics for Figure 10
	* Deciles
	foreach x in net_cash2_m loggdppc2_m {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in net_cash2_m loggdppc2_m {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 10
	lpoly net_cash2_m loggdppc2_m, ci at(loggdppc2_m) gen(pred) se(se) legend(off) /*
	*/ title("Net cash flow from banks vs. GDP per capita, `=maxyear10'") subtitle("`j'") /*
	*/ note("Note: Net cash flows from banks are the percentage change in credit to the private sector minus" /*
	*/ "the lending interest rate" "Data source: World Development Indicators") /*
	*/ ytitle("Net cash flow from banks, , 3-year average") xtitle("GDP per capita, PPP (constant 2005 international $), 3-year average log") /*
	*/ addplot(scatter net_cash2_m loggdppc2_m, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter net_cash2_m loggdppc2_m if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter net_cash2_m loggdppc2_m if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure10`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure10`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(net_cash2_m-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_net_cash2_m=r(mean)
	drop pred se diff
}
restore

****************************************************************************************************
************************* LOW DOMESTIC SAVINGS + BAD INTERNATIONAL FINANCE *************************
****************************************************************************************************

*******************************************************
* REAL SAVINGS INTEREST RATE VS GDPpc (CROSS SECTION) *
*******************************************************
gen real_i2=FR_INR_DPST-NY_GDP_DEFL_KD_ZG
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & real_i2!=.
	scalar maxyear11=r(max)
	bys year: count if loggdppc2!=. & real_i2!=.
	if r(N)>=30 {
		keep if year==`=maxyear11'
	}
	continue, break
}
scalar drop maxyear11
summ year if wbcode=="`ctry'" & loggdppc2!=. & real_i2!=.
scalar maxyear11=r(max)
local maxyear11: display %9.0f maxyear11

drop if year!=`=maxyear11'

if `=maxyear11'!=. {
	* Statistics for Figure 11
	* Deciles
	foreach x in real_i2 loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in real_i2 loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 11
	lpoly real_i2 loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Real savings interest rate vs. GDP per capita, `=maxyear11'") subtitle("`j'") /*
	*/ note("Note: Real savings interest rate is the deposit interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators") /*
	*/ ytitle("Real deposit interest rate (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter real_i2 loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter real_i2 loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter real_i2 loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure11`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure11`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(real_i2-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_real_i2=r(mean)
	drop pred se diff
}
restore

**************************************************************
* REAL SAVINGS INTEREST RATE VS SAVINGS RATIO (CROSS SECTION) *
**************************************************************
sort wbcode year
gen saving_m=.
replace saving_m=(NY_GDS_TOTL_ZS[_n]+NY_GDS_TOTL_ZS[_n-1]+NY_GDS_TOTL_ZS[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
gen real_i2_m=.
replace real_i2_m=(real_i2[_n]+real_i2[_n-1]+real_i2[_n-2])/3 if wbcode[_n]==wbcode[_n-1] & wbcode[_n]==wbcode[_n-2]
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if real_i2_m!=. & saving_m!=.
	scalar maxyear12=r(max)
	bys year: count if real_i2_m!=. & saving_m!=.
	if r(N)>=30 {
		keep if year==`=maxyear12'
	}
	continue, break
}
scalar drop maxyear12
summ year if wbcode=="`ctry'" & real_i2_m!=. & saving_m!=.
scalar maxyear12=r(max)
local maxyear12: display %9.0f maxyear12

drop if year!=`=maxyear12'

if `=maxyear12'!=. {
	* Statistics for Figure 12
	* Deciles
	foreach x in real_i2_m saving_m {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in real_i2_m saving_m {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 12
	lpoly real_i2_m saving_m, ci at(saving_m) gen(pred) se(se) legend(off) /*
	*/ title("Real savings interest rate vs. Savings ratio, `=`=maxyear12'-2'-`=maxyear12'") subtitle("`j'") /*
	*/ note("Note: Real savings interest rate is the deposit interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators") /*
	*/ ytitle("Real deposit interest rate (%), 3-year average") xtitle("Gross domestic savings (% of GDP), 3-year average") /*
	*/ addplot(scatter real_i2_m saving_m, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter real_i2_m saving_m if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter real_i2_m saving_m if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure12`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure12`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(real_i2_m-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_real_i2_m=r(mean)
	drop pred se diff
}
restore

***************************************************************
** REAL DEPOSIT INTEREST RATE VS SAVINGS RATIO(TIME SCATTER) **
***************************************************************
rename NY_GDS_TOTL_ZS saving
preserve

* Statistics for Figure 13
summ year if wbcode=="`ctry'" & real_i2!=. & saving!=.
* Minimum
scalar minyear13=r(min)
local minyear13: display %9.0fc minyear13
*Maximum
scalar maxyear13=r(max)
local maxyear13: display %9.0fc maxyear13

* Figure 13
if `=minyear13'<`=`=maxyear13'-10' {
	twoway connect real_i2 saving if wbcode=="`ctry'" & year>=`=`=maxyear13'-10', mlabel(year) lcolor(cranberry) lwidth(medthick) || /*
	*/ scatter real_i2 saving if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear13'-10', mcolor(red) legend(off) /*
	*/ xtitle("Gross domestic savings (% of GDP)") /*
	*/ ytitle("Real deposit interest rate (%)") /*
	*/ title("Real savings interest rate vs. Savings ratio, `=`=maxyear13'-10'-`=maxyear13'") subtitle("`j'") /*
	*/ note("Note: Real savings interest rate is the deposit interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators")
}
else {
	twoway connect real_i2 saving if wbcode=="`ctry'" & year>=`minyear13', mlabel(year) lcolor(cranberry) lwidth(medthick) || /*
	*/ scatter real_i2 saving if wbcode=="`ctry'" & milestone==1 & year>=`=minyear13', mcolor(red) legend(off) /*
	*/ xtitle("Gross domestic savings (% of GDP)") /*
	*/ ytitle("Real deposit interest rate (%)") /*
	*/ title("Real savings interest rate vs. Savings ratio, `=minyear13'-`=maxyear13'") subtitle("`j'") /*
	*/ note("Note: Real savings interest rate is the deposit interest rate adjusted for inflation as measured" /*
	*/ "by the GDP deflator." "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure13`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure13`ctry'_4.png") append

restore

******************************************
** SOVEREIGN RISK: SPREAD (TIME SERIES) **
******************************************
*preserve
*14

********************************************
** SOVEREIGN RISK: SPREAD (CROSS-SECTION) **
********************************************
*preserve
*15

*************************************************
** SOVEREIGN RISK: CREDIT RATING (TIME SERIES) **
*************************************************
*preserve
*16

***************************************************
** SOVEREIGN RISK: CREDIT RATING (CROSS-SECTION) **
***************************************************
*preserve
*17

*****************************************
** FOREIGN DEBT AS % GDP (TIME SERIES) **
*****************************************
rename DT_DOD_DECT_GN_ZS debt_y
preserve

* Statistics for Figure 18
summ year if wbcode=="`ctry'" & debt_y!=.
* Minimum
scalar minyear18=r(min)
local minyear18: display %9.0fc minyear18
*Maximum
scalar maxyear18=r(max)
local maxyear18: display %9.0fc maxyear18
* Max/Min variable
summ debt_y if wbcode=="`ctry'" & year>=`=`=maxyear18'-20'
scalar max_debt_y=r(max)
gen max_debt_y=`=max_debt_y' if wbcode=="`ctry'"
scalar min_debt_y=r(min)
gen min_debt_y=`=min_debt_y' if wbcode=="`ctry'"

* Figure 18
if `=minyear18'<`=`=maxyear18'-20' {
	twoway connect debt_y year if wbcode=="`ctry'" & year>=`=`=maxyear18'-20', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_debt_y year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear18'-20', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_y year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear18'-20', lcolor(gs8) legend(off) /*
	*/ ytitle("External debt stocks (% of GNI)") /*
	*/ title("External Debt (% of GNI), `=`=maxyear18'-20'-`=maxyear18'") subtitle("`j'") /*
	*/ note("Note: GNI is GDP plus net receipts of primary income (compensation of employees and property" /*
	*/ "income) from abroad." "Data source: World Development Indicators")
}
else {
	twoway connect debt_y year if wbcode=="`ctry'" & year>=`=minyear18', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_debt_y year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear18', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_y year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear18', lcolor(gs8) legend(off) /*
	*/ ytitle("External debt stocks (% of GNI)") /*
	*/ title("External Debt (% of GNI), `=minyear18'-`=maxyear18'") subtitle("`j'") /*
	*/ note("Note: GNI is GDP plus net receipts of primary income (compensation of employees and property" /*
	*/ "income) from abroad." "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure18`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure18`ctry'_4.png") append

restore

*******************************************
** FOREIGN DEBT AS % GDP (CROSS-SECTION) **
*******************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & debt_y!=.
	scalar maxyear19=r(max)
	bys year: count if loggdppc2!=. & debt_y!=.
	if r(N)>=30 {
		keep if year==`=maxyear19'
	}
	continue, break
}
scalar drop maxyear19
summ year if wbcode=="`ctry'" & loggdppc2!=. & debt_y!=.
scalar maxyear19=r(max)
local maxyear19: display %9.0f maxyear19

drop if year!=`=maxyear19'

if `=maxyear19'!=. {
	* Statistics for Figure 19
	* Deciles
	foreach x in debt_y loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in debt_y loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 19
	lpoly debt_y loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("External Debt (% of GNI) vs. GDP per capita, `=maxyear19'") subtitle("`j'") /*
	*/ note("Note: GNI is GDP plus net receipts of primary income (compensation of employees and property" /*
	*/ "income) from abroad." "Data source: World Development Indicators") /*
	*/ ytitle("External debt stocks (% of GNI)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter debt_y loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter debt_y loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter debt_y loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure19`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure19`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(debt_y-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_debt_y=r(mean)
	drop pred se diff
}
restore

*********************************************
** FOREIGN DEBT AS % EXPORTS (TIME SERIES) **
*********************************************
rename DT_DOD_DECT_EX_ZS debt_x
preserve

* Statistics for Figure 20
summ year if wbcode=="`ctry'" & debt_x!=.
* Minimum
scalar minyear20=r(min)
local minyear20: display %9.0fc minyear20
*Maximum
scalar maxyear20=r(max)
local maxyear20: display %9.0fc maxyear20
* Max/Min variable
summ debt_x if wbcode=="`ctry'" & year>=`=`=maxyear20'-20'
scalar max_debt_x=r(max)
gen max_debt_x=`=max_debt_x' if wbcode=="`ctry'"
scalar min_debt_x=r(min)
gen min_debt_x=`=min_debt_x' if wbcode=="`ctry'"

* Figure 20
if `=minyear20'<`=`=maxyear20'-20' {
	twoway connect debt_x year if wbcode=="`ctry'" & year>=`=`=maxyear20'-20', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_debt_x year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear20'-20', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_x year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear20'-20', lcolor(gs8) legend(off) /*
	*/ ytitle("External debt stocks (% of exports of goods," "services and primary income)") /*
	*/ title("External Debt (% of exports), `=`=maxyear20'-20'-`=maxyear20'") subtitle("`j'") /*
	*/ note("Note: Primary income is the compensation of employees and property income) from abroad." "Data source: World Development Indicators")
}
else {
	twoway connect debt_x year if wbcode=="`ctry'" & year>=`=minyear20', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_debt_x year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear20', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_x year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear20', lcolor(gs8) legend(off) /*
	*/ ytitle("External debt stocks (% of exports of goods," "services and primary income)") /*
	*/ title("External Debt (% of exports), `=minyear20'-`=maxyear20'") subtitle("`j'") /*
	*/ note("Note: Primary income is the compensation of employees and property income) from abroad." "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure20`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure20`ctry'_4.png") append

restore

***********************************************
** FOREIGN DEBT AS % EXPORTS (CROSS-SECTION) **
***********************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & debt_x!=.
	scalar maxyear21=r(max)
	bys year: count if loggdppc2!=. & debt_x!=.
	if r(N)>=30 {
		keep if year==`=maxyear21'
	}
	continue, break
}
scalar drop maxyear21
summ year if wbcode=="`ctry'" & loggdppc2!=. & debt_x!=.
scalar maxyear21=r(max)
local maxyear21: display %9.0f maxyear21

drop if year!=`=maxyear21'

if `=maxyear21'!=. {
	* Statistics for Figure 21
	* Deciles
	foreach x in debt_x loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in debt_x loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 21
	lpoly debt_x loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("External Debt (% of exports), `=maxyear21'") subtitle("`j'") /*
	*/ note("Note: Primary income is the compensation of employees and property income) from abroad." "Data source: World Development Indicators") /*
	*/ ytitle("External debt stocks (% of exports of goods," "services and primary income)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter debt_x loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter debt_x loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter debt_x loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure21`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure21`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(debt_x-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_debt_x=r(mean)
	drop pred se diff
}
restore

***********************************
** SHORT-TERM DEBT (TIME SERIES) **
***********************************
rename DT_DOD_DSTC_ZS s_debt
preserve

* Statistics for Figure 22
summ year if wbcode=="`ctry'" & s_debt!=.
* Minimum
scalar minyear22=r(min)
local minyear22: display %9.0fc minyear22
*Maximum
scalar maxyear22=r(max)
local maxyear22: display %9.0fc maxyear22
* Max/Min variable
summ s_debt if wbcode=="`ctry'" & year>=`=`=maxyear22'-20'
scalar max_s_debt=r(max)
gen max_s_debt=`=max_s_debt' if wbcode=="`ctry'"
scalar min_s_debt=r(min)
gen min_s_debt=`=min_s_debt' if wbcode=="`ctry'"

* Figure 22
if `=minyear22'<`=`=maxyear22'-20' {
	twoway connect s_debt year if wbcode=="`ctry'" & year>=`=`=maxyear22'-20', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_s_debt year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear22'-20', lcolor(gs8) legend(off) || /*
	*/ spike min_s_debt year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear22'-20', lcolor(gs8) legend(off) /*
	*/ ytitle("Short-term debt (% of total external debt)") /*
	*/ title("Short-term external debt, `=`=maxyear22'-20'-`=maxyear22'") subtitle("`j'") /*
	*/ note("Note: Short-term debt includes all debt having an original maturity of one year or less and interest" /*
	*/ "in arrears on long-term debt." "Data source: World Development Indicators")
}
else {
	twoway connect s_debt year if wbcode=="`ctry'" & year>=`=minyear22', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_s_debt year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear22', lcolor(gs8) legend(off) || /*
	*/ spike min_s_debt year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear22', lcolor(gs8) legend(off) /*
	*/ ytitle("Short-term debt (% of total external debt)") /*
	*/ title("Short-term external debt, `=minyear22'-`=maxyear22'") subtitle("`j'") /*
	*/ note("Note: Short-term debt includes all debt having an original maturity of one year or less and interest" /*
	*/ "in arrears on long-term debt." "Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure22`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure22`ctry'_4.png") append

restore

*************************************
** SHORT-TERM DEBT (CROSS-SECTION) **
*************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & s_debt!=.
	scalar maxyear23=r(max)
	bys year: count if loggdppc2!=. & s_debt!=.
	if r(N)>=30 {
		keep if year==`=maxyear23'
	}
	continue, break
}
scalar drop maxyear23
summ year if wbcode=="`ctry'" & loggdppc2!=. & s_debt!=.
scalar maxyear23=r(max)
local maxyear23: display %9.0f maxyear23

drop if year!=`=maxyear23'

if `=maxyear23'!=. {
	* Statistics for Figure 23
	* Deciles
	foreach x in s_debt loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in s_debt loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 23
	lpoly s_debt loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Short-term debt vs. GDP per capita, `=maxyear23'") subtitle("`j'") /*
	*/ note("Note: Short-term debt includes all debt having an original maturity of one year or less and interest" /*
	*/ "in arrears on long-term debt." "Data source: World Development Indicators") /*
	*/ ytitle("Short-term debt (% of total external debt)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter s_debt loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter s_debt loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter s_debt loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure23`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure23`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(s_debt-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_s_debt=r(mean)
	drop pred se diff
}
restore

***********************************
** EXTERNAL DEBT/TOTAL (TIME SERIES) **
***********************************
* 24

***********************************
** EXTERNAL DEBT/TOTAL (CROSS-SECTION) **
***********************************
* 25

*********************************************************
** AVERAGE MATURITY OF NEW EXTERNAL DEBT (TIME SERIES) **
*********************************************************
rename DT_MAT_DPPG debt_mat
preserve

* Statistics for Figure 26
summ year if wbcode=="`ctry'" & debt_mat!=.
* Minimum
scalar minyear26=r(min)
local minyear26: display %9.0fc minyear26
*Maximum
scalar maxyear26=r(max)
local maxyear26: display %9.0fc maxyear26
* Max/Min variable
summ debt_mat if wbcode=="`ctry'" & year>=`=`=maxyear26'-20'
scalar max_debt_mat=r(max)
gen max_debt_mat=`=max_debt_mat' if wbcode=="`ctry'"
scalar min_debt_mat=r(min)
gen min_debt_mat=`=min_debt_mat' if wbcode=="`ctry'"

* Figure 26
if `=minyear26'<`=`=maxyear26'-20' {
	twoway connect debt_mat year if wbcode=="`ctry'" & year>=`=`=maxyear26'-20', lcolor(cranberry) lwidth(medthick) ||/*
	*/ spike max_debt_mat year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear26'-20', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_mat year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear26'-20', lcolor(gs8) legend(off) /*
	*/ ytitle("Average maturity on new external debt commitments (years)") /*
	*/ title("Average maturity on new external debt, `=`=maxyear26'-20'-`=maxyear26'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}
else {
	twoway connect debt_mat year if wbcode=="`ctry'" & year>=`=minyear26', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_debt_mat year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear26', lcolor(gs8) legend(off) || /*
	*/ spike min_debt_mat year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear26', lcolor(gs8) legend(off) /*
	*/ ytitle("Average maturity on new external debt commitments (years)") /*
	*/ title("Average maturity on new external debt, `=minyear26'-`=maxyear26'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure26`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure26`ctry'_4.png") append

restore

***********************************************************
** AVERAGE MATURITY OF NEW EXTERNAL DEBT (CROSS SECTION) **
***********************************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & debt_mat!=.
	scalar maxyear27=r(max)
	bys year: count if loggdppc2!=. & debt_mat!=.
	if r(N)>=30 {
		keep if year==`=maxyear27'
	}
	continue, break
}
scalar drop maxyear27
summ year if wbcode=="`ctry'" & loggdppc2!=. & debt_mat!=.
scalar maxyear27=r(max)
local maxyear27: display %9.0f maxyear27

drop if year!=`=maxyear27'

if `=maxyear27'!=. {
	* Statistics for Figure 27
	* Deciles
	foreach x in debt_mat loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in debt_mat loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 27
	lpoly debt_mat loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Average maturity on new external debt vs. GDP per capita") subtitle("`=maxyear27', `j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Average maturity on new external debt" "commitments (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter debt_mat loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter debt_mat loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter debt_mat loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure27`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure27`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(debt_mat-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_debt_mat=r(mean)
	drop pred se diff
}
restore

*******************************************
** CURRENT ACCOUNT BALANCE (TIME SERIES) **
*******************************************
save "temp.dta", replace
use "$macrovar", clear		/* International Debt Statistics */
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
gen c_a=(BN_CAB_XOKA_CD*100)/NY_GDP_MKTP_CD
label var c_a "CA balance (% of GDP)"
preserve

* Statistics for Figure 28
summ year if wbcode=="`ctry'" & c_a!=.
* Minimum
scalar minyear28=r(min)
local minyear28: display %9.0fc minyear28
*Maximum
scalar maxyear28=r(max)
local maxyear28: display %9.0fc maxyear28
* Max/Min variable
summ c_a if wbcode=="`ctry'" & year>=`=`=maxyear28'-20'
scalar max_c_a=r(max)
gen max_c_a=`=max_c_a' if wbcode=="`ctry'"
scalar min_c_a=r(min)
gen min_c_a=`=min_c_a' if wbcode=="`ctry'"

* Figure 28
if `=minyear28'<`=`=maxyear28'-20' {
	twoway area c_a year if wbcode=="`ctry'" & year>=`=`=maxyear28'-20', lwidth(medthick) || /*
	*/ spike max_c_a year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear28'-20', lcolor(gs8) legend(off) || /*
	*/ spike min_c_a year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear28'-20', lcolor(gs8) legend(off) /*
	*/ ytitle("Current account balance (% of GDP)") /*
	*/ title("Current account balance, `=`=maxyear28'-20'-`=maxyear28'") subtitle("`j'") /*
	*/ note("Data source: International Debt Statistics and World Development Indicators")
}
else {
	twoway area c_a year if wbcode=="`ctry'" & year>=`=minyear28', lwidth(medthick) || /*
	*/ spike max_c_a year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear28', lcolor(gs8) legend(off) || /*
	*/ spike min_c_a year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear28', lcolor(gs8) legend(off) /*
	*/ ytitle("Current account balance (% of GDP)") /*
	*/ title("Current account balance, `=minyear28'-`=maxyear28'") subtitle("`j'") /*
	*/ note("Data source: International Debt Statistics and World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure28`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure25`ctry'_4.png") append

restore

*********************************************
** CURRENT ACCOUNT BALANCE (CROSS SECTION) **
*********************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & c_a!=.
	scalar maxyear29=r(max)
	bys year: count if loggdppc2!=. & c_a!=.
	if r(N)>=30 {
		keep if year==`=maxyear29'
	}
	continue, break
}
scalar drop maxyear29
summ year if wbcode=="`ctry'" & loggdppc2!=. & c_a!=.
scalar maxyear29=r(max)
local maxyear29: display %9.0f maxyear29

drop if year!=`=maxyear29'

if `=maxyear29'!=. {
	* Statistics for Figure 29
	* Deciles
	foreach x in c_a loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in c_a loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 29
	lpoly c_a loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Current account balance vs. GDP per capita, `=maxyear29'") subtitle("`j'") /*
	*/ note("Data source: International Debt Statistics and World Development Indicators") /*
	*/ ytitle("Current account balance (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter c_a loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter c_a loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter c_a loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure29`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure29`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(c_a-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_c_a=r(mean)
	drop pred se diff
}
restore

**********************************************************
** CURRENT ACCOUNT BALANCE VS GDPpc GROWTH(TIME SERIES) **
**********************************************************
rename NY_GDP_PCAP_KD_ZG growth
preserve

* Statistics for Figure 30
summ year if wbcode=="`ctry'" & c_a!=. & growth!=.
* Minimum
scalar minyear30=r(min)
local minyear30: display %9.0fc minyear30
*Maximum
scalar maxyear30=r(max)
local maxyear30: display %9.0fc maxyear30
* Max/Min variable
summ growth if wbcode=="`ctry'" & year>=`=`=maxyear30'-20'
scalar max_growth=r(max)
gen max_growth=`=max_growth' if wbcode=="`ctry'"
gen max_30=max(max_growth,max_c_a) if wbcode=="`ctry'"
scalar min_growth=r(min)
gen min_growth=`=min_growth' if wbcode=="`ctry'"
gen min_30=min(min_growth,min_c_a) if wbcode=="`ctry'"

* Figure 30
if `=minyear30'<`=`=maxyear30'-20' {
	twoway connect c_a year if wbcode=="`ctry'" & year>=`=`=maxyear30'-20', lwidth(medthick) || /*
	*/ connect growth year if wbcode=="`ctry'" & year>=`=`=maxyear30'-20', lwidth(medthick) || /*
	*/ spike max_30 year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear30'-20', lcolor(gs8) || /*
	*/ spike min_30 year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear30'-20', lcolor(gs8) /*
	*/ legend(order(1 "CA balance (% of GDP)" 2 "GDP per capita growth (annual %)")) /*
	*/ ytitle("Percentage") /*
	*/ title("Current account balance vs. Economic growth, `=`=maxyear30'-20'-`=maxyear30'") subtitle("`j'") /*
	*/ note("Note: Annual percentage growth rate of GDP per capita based on constant local currency" /*
	*/ "Data source: International Debt Statistics and World Development Indicators")
}
else {
	twoway connect c_a year if wbcode=="`ctry'" & year>=`=minyear30', lwidth(medthick) || /*
	*/ connect growth year if wbcode=="`ctry'" & year>=`=minyear30', lwidth(medthick) || /*
	*/ spike max_30 year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear30', lcolor(gs8) || /*
	*/ spike min_30 year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear30', lcolor(gs8) /*
	*/ legend(order(1 "CA balance (% of GDP)" 2 "GDP per capita growth (annual %)")) /*
	*/ ytitle("Percentage") /*
	*/ title("Current account balance vs. Economic growth, `=`=maxyear30'-20'-`=maxyear30'") subtitle("`j'") /*
	*/ note("Note: Annual percentage growth rate of GDP per capita based on constant local currency" /*
	*/ "Data source: International Debt Statistics and World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure30`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure30`ctry'_4.png") append

restore

***************************************************
** REAL EXCHANGE RATE VOLATILITY (CROSS SECTION) **
***************************************************
save "temp.dta", replace
use "$exchange", clear /*EIU*/
merge 1:1 wbcode year using "temp.dta"
keep if _merge==3
drop _merge
sort wbcode year
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & rex!=.
	scalar maxyear31=r(max)
	bys year: count if loggdppc2!=. & rex!=.
	if r(N)<30 {
		drop if year==`=maxyear31'
	}
	continue, break
}
scalar drop maxyear31
summ year if wbcode=="`ctry'" & loggdppc2!=. & rex!=.
scalar maxyear31=r(max)
local maxyear31: display %9.0f maxyear31

drop if year<`=`=maxyear31'-10'
bys wbcode: egen rex_sd=sd(rex)
bys wbcode: egen rex_mean=mean(rex)
drop if year!=`=maxyear31'
gen rex_vol=rex_sd/rex_mean

if `=maxyear31'!=. {
	* Statistics for Figure 31
	* Deciles
	foreach x in rex_vol loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in rex_vol loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}

	* Figure 31
	lpoly rex_vol loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Real exchange rate volatility vs. GDP per capita, `=maxyear31'") subtitle("`j'") /*
	*/ note("Data source: Economist Intelligence Unit and World Development Indicators") /*
	*/ ytitle("Coefficient of variation of" "the real exchange rate), `=`=maxyear31'-10'-`=maxyear31'") /*
	*/ xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter rex_vol loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter rex_vol loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter rex_vol loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure31`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure31`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(rex_vol-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_rex_vol=r(mean)
	drop pred se diff
}
restore

****************************************************************************
************************* FINANCIAL INTERMEDIATION *************************
****************************************************************************

********************************************
** SPREAD OF INTEREST RATES (TIME SERIES) **
********************************************
rename FR_INR_LNDP spread
preserve

* Statistics for Figure 32
summ year if wbcode=="`ctry'" & spread!=.
* Minimum
scalar minyear32=r(min)
local minyear32: display %9.0fc minyear32
*Maximum
scalar maxyear32=r(max)
local maxyear32: display %9.0fc maxyear32
* Max/Min variable
summ spread if wbcode=="`ctry'" & year>=`=`=maxyear32'-15'
scalar max_spread=r(max)
gen max_spread=`=max_spread' if wbcode=="`ctry'"
scalar min_spread=r(min)
gen min_spread=`=min_spread' if wbcode=="`ctry'"

* Figure 32
if `=minyear32'<`=`=maxyear32'-15' {
	twoway connect spread year if wbcode=="`ctry'" & year>=`=`=maxyear32'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_spread year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear32'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_spread year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear32'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Interest rate spread (lending rate minus deposit rate, %)") /*
	*/ title("Interest rate spread, `=`=maxyear32'-15'-`=maxyear32'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}
else {
	twoway connect spread year if wbcode=="`ctry'" & year>=`=minyear32', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike spread year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear32', lcolor(gs8) legend(off) || /*
	*/ spike spread year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear32', lcolor(gs8) legend(off) /*
	*/ ytitle("Interest rate spread (lending rate minus deposit rate, %)") /*
	*/ title("Interest rate spread, `=minyear32'-`=maxyear32'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure32`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure32`ctry'_4.png") append

restore

**********************************************
** SPREAD OF INTEREST RATES (CROSS-SECTION) **
**********************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & spread!=.
	scalar maxyear33=r(max)
	bys year: count if loggdppc2!=. & spread!=.
	if r(N)>=33 {
		keep if year==`=maxyear33'
	}
	continue, break
}
scalar drop maxyear33
summ year if wbcode=="`ctry'" & loggdppc2!=. & spread!=.
scalar maxyear33=r(max)
local maxyear33: display %9.0f maxyear33

drop if year!=`=maxyear33'

if `=maxyear33'!=. {
	* Statistics for Figure 33
	* Deciles
	foreach x in spread loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in spread loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 33
	lpoly spread loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Interest rate spread vs. GDP per capita, `=maxyear33'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Interest rate spread (lending rate minus deposit rate, %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter spread loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter spread loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter spread loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure33`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure33`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(spread-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_spread=r(mean)
	drop pred se diff
}
restore

******************************************
** BANK'S OPERATING COSTS (TIME SERIES) **
******************************************
save "temp.dta", replace
use "$financial", clear
keep wbcode year overhead concentration roa roe
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
label var year "Year"
preserve

* Statistics for Figure 34
summ year if wbcode=="`ctry'" & overhead!=.
* Minimum
scalar minyear34=r(min)
local minyear34: display %9.0fc minyear34
*Maximum
scalar maxyear34=r(max)
local maxyear34: display %9.0fc maxyear34
* Max/Min variable
summ overhead if wbcode=="`ctry'" & year>=`=`=maxyear34'-15'
scalar max_overhead=r(max)
gen max_overhead=`=max_overhead' if wbcode=="`ctry'"
scalar min_overhead=r(min)
gen min_overhead=`=min_overhead' if wbcode=="`ctry'"

* Figure 34
if `=minyear34'<`=`=maxyear34'-15' {
	twoway connect overhead year if wbcode=="`ctry'" & year>=`=`=maxyear34'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_overhead year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear34'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_overhead year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear34'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Bank overhead costs to total assets (%)") /*
	*/ title("Overhad costs of banks, `=`=maxyear34'-15'-`=maxyear34'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}
else {
	twoway connect overhead year if wbcode=="`ctry'" & year>=`=minyear34', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike overhead year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear34', lcolor(gs8) legend(off) || /*
	*/ spike overhead year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear34', lcolor(gs8) legend(off) /*
	*/ ytitle("Bank overhead costs to total assets (%)") /*
	*/ title("Overhad costs of banks, `=minyear34'-`=maxyear34'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}

* Exporting results into word document
gr export "$dir\figure34`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure34`ctry'_4.png") append

restore

********************************************
** BANK'S OPERATING COSTS (CROSS-SECTION) **
********************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & overhead!=.
	scalar maxyear35=r(max)
	bys year: count if loggdppc2!=. & overhead!=.
	if r(N)>=30 {
		keep if year==`=maxyear35'
	}
	continue, break
}
scalar drop maxyear35
summ year if wbcode=="`ctry'" & loggdppc2!=. & overhead!=.
scalar maxyear35=r(max)
local maxyear35: display %9.0f maxyear35

drop if year!=`=maxyear35'

if `=maxyear35'!=. {
	* Statistics for Figure 35
	* Deciles
	foreach x in overhead loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in overhead loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 35
	lpoly overhead loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Overhad costs of banks vs. GDP per capita, `=maxyear35'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank) and World" "Development Indicators") /*
	*/ ytitle("Bank overhead costs to total assets (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter overhead loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter overhead loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter overhead loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure35`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure35`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(overhead-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_overhead=r(mean)
	drop pred se diff
}
restore

*********************************
** BANK RESERVES (TIME SERIES) **
*********************************
rename FD_RES_LIQU_AS_ZS reserve
preserve

* Statistics for Figure 36
summ year if wbcode=="`ctry'" & reserve!=.
* Minimum
scalar minyear36=r(min)
local minyear36: display %9.0fc minyear36
*Maximum
scalar maxyear36=r(max)
local maxyear36: display %9.0fc maxyear36
* Max/Min variable
summ reserve if wbcode=="`ctry'" & year>=`=`=maxyear36'-15'
scalar max_reserve=r(max)
gen max_reserve=`=max_reserve' if wbcode=="`ctry'"
scalar min_reserve=r(min)
gen min_reserve=`=min_reserve' if wbcode=="`ctry'"

* Figure 36
if `=minyear36'<`=`=maxyear36'-15' {
	twoway connect reserve year if wbcode=="`ctry'" & year>=`=`=maxyear36'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_reserve year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear36'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_reserve year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear36'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Bank liquid reserves to bank assets ratio (%)") /*
	*/ title("Bank reserves, `=`=maxyear36'-15'-`=maxyear36'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}
else {
	twoway connect reserve year if wbcode=="`ctry'" & year>=`=minyear36', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_reserve year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear36', lcolor(gs8) legend(off) || /*
	*/ spike min_reserve year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear36', lcolor(gs8) legend(off) /*
	*/ ytitle("Bank liquid reserves to bank assets ratio (%)") /*
	*/ title("Bank reserves, `=minyear36'-`=maxyear36'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure36`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure36`ctry'_4.png") append

restore

***********************************
** BANK RESERVES (CROSS-SECTION) **
***********************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & reserve!=.
	scalar maxyear37=r(max)
	bys year: count if loggdppc2!=. & reserve!=.
	if r(N)<30 {
		drop if year==`=maxyear37'
	}
	continue, break
}
scalar drop maxyear37
summ year if wbcode=="`ctry'" & loggdppc2!=. & reserve!=.
scalar maxyear37=r(max)
local maxyear37: display %9.0f maxyear37

drop if year!=`=maxyear37'

if `=maxyear37'!=. {
	* Statistics for Figure 37
	* Deciles
	foreach x in reserve loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in reserve loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 37
	lpoly reserve loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Bank reserves vs. GDP per capita, `=maxyear37'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Bank liquid reserves to bank assets ratio (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter reserve loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter reserve loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter reserve loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure37`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure37`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(reserve-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_reserve=r(mean)
	drop pred se diff
}
restore


**************************************
** BANK CONCENTRATION (TIME SERIES) **
**************************************
preserve

* Statistics for Figure 38
summ year if wbcode=="`ctry'" & concentration!=.
* Minimum
scalar minyear38=r(min)
local minyear38: display %9.0fc minyear38
*Maximum
scalar maxyear38=r(max)
local maxyear38: display %9.0fc maxyear38
* Max/Min variable
summ concentration if wbcode=="`ctry'" & year>=`=`=maxyear38'-15'
scalar max_concentration=r(max)
gen max_concentration=`=max_concentration' if wbcode=="`ctry'"
scalar min_concentration=r(min)
gen min_concentration=`=min_concentration' if wbcode=="`ctry'"

* Figure 38
if `=minyear38'<`=`=maxyear38'-15' {
	twoway connect concentration year if wbcode=="`ctry'" & year>=`=`=maxyear38'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_concentration year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear38'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_concentration year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear38'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Assets of 3 largest banks as % of assets of" "all commercial banks") /*
	*/ title("Bank concentration, `=`=maxyear38'-15'-`=maxyear38'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}
else {
	twoway connect concentration year if wbcode=="`ctry'" & year>=`=minyear38', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_concentration year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear38', lcolor(gs8) legend(off) || /*
	*/ spike min_concentration year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear38', lcolor(gs8) legend(off) /*
	*/ ytitle("Assets of 3 largest banks as % of assets of" "all commercial banks") /*
	*/ title("Bank concentration, `=minyear38'-`=maxyear38'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}

* Exporting results into word document
gr export "$dir\figure38`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure38`ctry'_4.png") append

restore

****************************************
** BANK CONCENTRATION (CROSS-SECTION) **
****************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & concentration!=.
	scalar maxyear39=r(max)
	bys year: count if loggdppc2!=. & concentration!=.
	if r(N)<30 {
		drop if year==`=maxyear39'
	}
	continue, break
}
scalar drop maxyear39
summ year if wbcode=="`ctry'" & loggdppc2!=. & concentration!=.
scalar maxyear39=r(max)
local maxyear39: display %9.0f maxyear39

drop if year!=`=maxyear39'

if `=maxyear39'!=. {
	* Statistics for Figure 39
	* Deciles
	foreach x in concentration loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in concentration loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 39
	lpoly concentration loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Bank concentration vs. GDP per capita, `=maxyear39'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank) and World" "Development Indicators") /*
	*/ ytitle("Assets of 3 largest banks as % of assets of" "all commercial banks") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter concentration loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter concentration loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter concentration loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure39`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure39`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(concentration-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_concentration=r(mean)
	drop pred se diff
}
restore

********************************************
** BANK's RETURNS ON ASSETS (TIME SERIES) **
********************************************
preserve

* Statistics for Figure 40
summ year if wbcode=="`ctry'" & roa!=.
* Minimum
scalar minyear40=r(min)
local minyear40: display %9.0fc minyear40
*Maximum
scalar maxyear40=r(max)
local maxyear40: display %9.0fc maxyear40
* Max/Min variable
summ roa if wbcode=="`ctry'" & year>=`=`=maxyear40'-15'
scalar max_roa=r(max)
gen max_roa=`=max_roa' if wbcode=="`ctry'"
scalar min_roa=r(min)
gen min_roa=`=min_roa' if wbcode=="`ctry'"

* Figure 40
if `=minyear40'<`=`=maxyear40'-15' {
	twoway connect roa year if wbcode=="`ctry'" & year>=`=`=maxyear40'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_roa year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear40'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_roa year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear40'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Average Return on Assets (Net Income/Total Assets)") /*
	*/ title("Banks ROA, `=`=maxyear40'-15'-`=maxyear40'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}
else {
	twoway connect roa year if wbcode=="`ctry'" & year>=`=minyear40', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_roa year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear40', lcolor(gs8) legend(off) || /*
	*/ spike min_roa year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear40', lcolor(gs8) legend(off) /*
	*/ ytitle("Average Return on Assets (Net Income/Total Assets)") /*
	*/ title("Banks ROA, `=minyear40'-`=maxyear40'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank)")
}

* Exporting results into word document
gr export "$dir\figure40`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure40`ctry'_4.png") append

restore

**********************************************
** BANK's RETURNS ON ASSETS (CROSS-SECTION) **
**********************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & roa!=.
	scalar maxyear41=r(max)
	bys year: count if loggdppc2!=. & roa!=.
	if r(N)>=30 {
		keep if year==`=maxyear41'
	}
	continue, break
}
scalar drop maxyear41
summ year if wbcode=="`ctry'" & loggdppc2!=. & roa!=.
scalar maxyear41=r(max)
local maxyear41: display %9.0f maxyear41

drop if year!=`=maxyear41'

if `=maxyear41'!=. {
	* Statistics for Figure 41
	* Deciles
	foreach x in roa loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in roa loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 41
	lpoly roa loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Banks ROA vs. GDP per capita, `=maxyear41'") subtitle("`j'") /*
	*/ note("Data source: Financial Development and Structure Dataset (World Bank) and World" "Development Indicators") /*
	*/ ytitle("Average Return on Assets (Net Income/Total Assets)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter roa loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter roa loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter roa loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure41`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure41`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(roa-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_roa=r(mean)
	drop pred se diff
}
restore

*************************************
** FIRMS USING BANKS (TIME SERIES) **
*************************************
rename IC_FRM_BNKS_ZS firms_banks
preserve

* Statistics for Figure 42
summ year if wbcode=="`ctry'" & firms_banks!=.
* Minimum
scalar minyear42=r(min)
local minyear42: display %9.0fc minyear42
*Maximum
scalar maxyear42=r(max)
local maxyear42: display %9.0fc maxyear42
* Max/Min variable
summ firms_banks if wbcode=="`ctry'" & year>=`=`=maxyear42'-15'
scalar max_firms_banks=r(max)
gen max_firms_banks=`=max_firms_banks' if wbcode=="`ctry'"
scalar min_firms_banks=r(min)
gen min_firms_banks=`=min_firms_banks' if wbcode=="`ctry'"

* Figure 42
if `=minyear42'<`=`=maxyear42'-15' {
	twoway connect firms_banks year if wbcode=="`ctry'" & year>=`=`=maxyear42'-15', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_firms_banks year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear42'-15', lcolor(gs8) legend(off) || /*
	*/ spike min_firms_banks year if wbcode=="`ctry'" & milestone==1 & year>=`=`=maxyear42'-15', lcolor(gs8) legend(off) /*
	*/ ytitle("Firms using banks to finance investment (% of firms)") /*
	*/ title("Firms using banks, `=`=maxyear42'-15'-`=maxyear42'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}
else {
	twoway connect firms_banks year if wbcode=="`ctry'" & year>=`=minyear42', lcolor(cranberry) lwidth(medthick) || /*
	*/ spike max_firms_banks year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear42', lcolor(gs8) legend(off) || /*
	*/ spike min_firms_banks year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear42', lcolor(gs8) legend(off) /*
	*/ ytitle("Firms using banks to finance investment (% of firms)") /*
	*/ title("Firms using banks, `=minyear42'-`=maxyear42'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators")
}

* Exporting results into word document
gr export "$dir\figure42`ctry'_4.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure42`ctry'_4.png") append

restore

***************************************
** FIRMS USING BANKS (CROSS-SECTION) **
***************************************
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & firms_banks!=.
	scalar maxyear43=r(max)
	bys year: count if loggdppc2!=. & firms_banks!=.
	if r(N)>=30 {
		keep if year==`=maxyear43'
	}
	continue, break
}
scalar drop maxyear43
summ year if wbcode=="`ctry'" & loggdppc2!=. & firms_banks!=.
scalar maxyear43=r(max)
local maxyear43: display %9.0f maxyear43

drop if year!=`=maxyear43'

if `=maxyear43'!=. {
	* Statistics for Figure 43
	* Deciles
	foreach x in firms_banks loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in firms_banks loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Figure 43
	lpoly firms_banks loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) /*
	*/ title("Firms using banks vs. GDP per capita, `=maxyear43'") subtitle("`j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Firms using banks to finance investment (% of firms)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter firms_banks loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter firms_banks loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter firms_banks loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure43`ctry'_4.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_4.doc", g("$dir\figure43`ctry'_4.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(firms_banks-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_firms_banks=r(mean)
	drop pred se diff
}
restore
********************************************************************************************************************************************************
********************************************************************************************************************************************************

***************************************************
** RANKINGS, DECILES AND ERROR IN S.E. UNITS **
***************************************************

foreach var in credit real_i real_i_m invest_bank_equity workingk_bank finance_constraint net_cash2_m real_i2 real_i2_m debt_y debt_x  s_debt debt_mat c_a /*
*/ rex_vol spread overhead concentration roa firms_banks {
	capture noisily gen rank_`var'=`=rank_`var''
	capture noisily gen n_`var'=`=n_`var''
	capture noisily gen pct_`var'=`=pct_`var''
	capture noisily gen diff_`var'=`=diff_`var''
}

forval x=1/43 {
	capture noisily gen maxyear`x'=`=maxyear`x''
}

preserve
collapse maxyear1 rank_credit n_credit pct_credit diff_credit
rename maxyear1 year
rename rank_credit rank
rename n_credit n
rename pct_credit decile
rename diff_credit deviation
gen variable=1
save "temp1.dta", replace
restore

preserve
collapse maxyear2 rank_real_i n_real_i pct_real_i diff_real_i
rename maxyear2 year
rename rank_real_i rank
rename n_real_i n
rename pct_real_i decile
rename diff_real_i deviation
gen variable=2
save "temp2.dta", replace
restore

preserve
collapse maxyear3 rank_real_i_m n_real_i_m pct_real_i_m diff_real_i_m
rename maxyear3 year
rename rank_real_i_m rank
rename n_real_i_m n
rename pct_real_i_m decile
rename diff_real_i_m deviation
gen variable=3
save "temp3.dta", replace
restore

preserve
collapse maxyear5 rank_invest_bank_equity n_invest_bank_equity pct_invest_bank_equity diff_invest_bank_equity
rename maxyear5 year
rename rank_invest_bank_equity rank
rename n_invest_bank_equity n
rename pct_invest_bank_equity decile
rename diff_invest_bank_equity deviation
gen variable=5
save "temp5.dta", replace
restore

preserve
collapse maxyear6 rank_workingk_bank n_workingk_bank pct_workingk_bank diff_workingk_bank
rename maxyear6 year
rename rank_workingk_bank rank
rename n_workingk_bank n
rename pct_workingk_bank decile
rename diff_workingk_bank deviation
gen variable=6
save "temp6.dta", replace
restore

preserve
collapse maxyear7 rank_finance_constraint n_finance_constraint pct_finance_constraint diff_finance_constraint
rename maxyear7 year
rename rank_finance_constraint rank
rename n_finance_constraint n
rename pct_finance_constraint decile
rename diff_finance_constraint deviation
gen variable=7
save "temp7.dta", replace
restore

preserve
collapse maxyear10 rank_net_cash2_m n_net_cash2_m pct_net_cash2_m diff_net_cash2_m
rename maxyear10 year
rename rank_net_cash2_m rank
rename n_net_cash2_m n
rename pct_net_cash2_m decile
rename diff_net_cash2_m deviation
gen variable=10
save "temp10.dta", replace
restore

preserve
collapse maxyear11 rank_real_i2 n_real_i2 pct_real_i2 diff_real_i2
rename maxyear11 year
rename rank_real_i2 rank
rename n_real_i2 n
rename pct_real_i2 decile
rename diff_real_i2 deviation
gen variable=11
save "temp11.dta", replace
restore

preserve
collapse maxyear12 rank_real_i2_m n_real_i2_m pct_real_i2_m diff_real_i2_m
rename maxyear12 year
rename rank_real_i2_m rank
rename n_real_i2_m n
rename pct_real_i2_m decile
rename diff_real_i2_m deviation
gen variable=12
save "temp12.dta", replace
restore

preserve
collapse maxyear19 rank_debt_y n_debt_y pct_debt_y diff_debt_y
rename maxyear19 year
rename rank_debt_y rank
rename n_debt_y n
rename pct_debt_y decile
rename diff_debt_y deviation
gen variable=19
save "temp19.dta", replace
restore

preserve
collapse maxyear21 rank_debt_x n_debt_x pct_debt_x diff_debt_x
rename maxyear21 year
rename rank_debt_x rank
rename n_debt_x n
rename pct_debt_x decile
rename diff_debt_x deviation
gen variable=21
save "temp21.dta", replace
restore

preserve
collapse maxyear23 rank_s_debt n_s_debt pct_s_debt diff_s_debt
rename maxyear23 year
rename rank_s_debt rank
rename n_s_debt n
rename pct_s_debt decile
rename diff_s_debt deviation
gen variable=23
save "temp23.dta", replace
restore

preserve
collapse maxyear27 rank_debt_mat n_debt_mat pct_debt_mat diff_debt_mat
rename maxyear27 year
rename rank_debt_mat rank
rename n_debt_mat n
rename pct_debt_mat decile
rename diff_debt_mat deviation
gen variable=27
save "temp27.dta", replace
restore

preserve
collapse maxyear29 rank_c_a n_c_a pct_c_a diff_c_a
rename maxyear29 year
rename rank_c_a rank
rename n_c_a n
rename pct_c_a decile
rename diff_c_a deviation
gen variable=29
save "temp29.dta", replace
restore

preserve
collapse maxyear31 rank_rex_vol n_rex_vol pct_rex_vol diff_rex_vol
rename maxyear31 year
rename rank_rex_vol rank
rename n_rex_vol n
rename pct_rex_vol decile
rename diff_rex_vol deviation
gen variable=31
save "temp31.dta", replace
restore

preserve
collapse maxyear33 rank_spread n_spread pct_spread diff_spread
rename maxyear33 year
rename rank_spread rank
rename n_spread n
rename pct_spread decile
rename diff_spread deviation
gen variable=33
save "temp33.dta", replace
restore

preserve
collapse maxyear35 rank_overhead n_overhead pct_overhead diff_overhead
rename maxyear35 year
rename rank_overhead rank
rename n_overhead n
rename pct_overhead decile
rename diff_overhead deviation
gen variable=35
save "temp35.dta", replace
restore

if maxyear37!=. {
preserve
collapse maxyear37 rank_reserve n_reserve pct_reserve diff_reserve
rename maxyear37 year
rename rank_reserve rank
rename n_reserve n
rename pct_reserve decile
rename diff_reserve deviation
gen variable=37
save "temp37.dta", replace
restore
}

preserve
collapse maxyear39 rank_concentration n_concentration pct_concentration diff_concentration
rename maxyear39 year
rename rank_concentration rank
rename n_concentration n
rename pct_concentration decile
rename diff_concentration deviation
gen variable=39
save "temp39.dta", replace
restore

preserve
collapse maxyear41 rank_roa n_roa pct_roa diff_roa
rename maxyear41 year
rename rank_roa rank
rename n_roa n
rename pct_roa decile
rename diff_roa deviation
gen variable=41
save "temp41.dta", replace
restore

preserve
collapse maxyear43 rank_firms_banks n_firms_banks pct_firms_banks diff_firms_banks
rename maxyear43 year
rename rank_firms_banks rank
rename n_firms_banks n
rename pct_firms_banks decile
rename diff_firms_banks deviation
gen variable=43
save "temp43.dta", replace
restore

use "temp1.dta", clear
forval x=2/43 {
	capture noisily append using "temp`x'.dta"
}

label def variable 1"Financial depth" 2"Real lending interest rate" 3"Real lending interest rate, 3-year average" 5"Investments financed by banks or equity" /*
*/ 6"Working capital financed by banks" 7"Finance as a major constraint" 10"Net cash flow from banks" 11"Real savings interest rate" /*
*/ 12"Real savings interest rate, 3-year average" 19"External Debt (% of GNI)" 21"External Debt (% of exports)" 23"Short-term debt" /*
*/ 27"Average maturity on new external debt" 29"Current account balance" 31"Real exchange rate volatility" 33"Interest rate spread" /*
*/ 35"Overhead costs of banks" 37"Bank reserves" 39"Bank concentration" 41"Banks ROA" 43"Firms using banks"
label val variable variable
order variable year
gen significant=0
replace significant=1 if deviation>1.0 | deviation<-1.0
label def significant 0"" 1"*"
label val significant significant
export excel using "$dir\table`ctry'4", firstrow(var) sheetreplace
*************************************************************************************
scalar drop _all
macro drop _all
erase "temp.dta"
forval x=1/43 {
	capture noisily erase "temp`x'.dta"
}
