clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* ORIGINAL DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\WDI"
* ORIGINAL DATABASES
use "wdi2013.dta", clear
* OTHER DATABASES:
	* EDUCATION
	global education "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\Educational Attainment (Barro & Lee)\BL2013_MF2599_v1.3.dta"
	* PHYSICAL CAPITAL
	global capital "C:\Users\Luis Miguel\Documents\Bases de Datos\Penn World Tables\pwt80\pwt80.dta"
	* TAX REVENUE
	global revenue "C:\Users\Luis Miguel\Documents\Bases de Datos\IMF\taxrevenue.dta"
	* INSTITUTIONS
	global institutions "C:\Users\Luis Miguel\Documents\Bases de Datos\The Quality of Government Institute\Standard data\qog_std_ts_20dec13.dta"
	* COMPLEXITY
	global complexity "C:\Users\Luis Miguel\Documents\Bases de Datos\CID - Harvard\complexity_y_c.dta"
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
rename NY_GDP_PCAP_KD gdppc
gen loggdppc=log10(gdppc)
label var loggdppc "Log(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2
gen loggdppc2=log10(gdppc2)
label var loggdppc "GDP per capita (constant 2005 US$), log"
label var loggdppc2 "GDP per capita, PPP (constant 2005 international $), log"
label var year "Years"

* Elimination of oil countries
drop if wbcode=="QAT" | wbcode=="KWT" | wbcode=="ARE" | wbcode=="OMN" | wbcode=="SAU" | wbcode=="BHR"

*********************************************
** STRUCTURAL TRANSFORMATION: URBANIZATION **
*********************************************
rename SP_URB_TOTL_IN_ZS urban_pop
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & urban_pop!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & urban_pop!=.
scalar minyear1=r(min)
local minyear1: display %9.0f minyear1

drop if year!=`=minyear1'

if `=minyear1'!=. {
	* Statistics for Figure 1
	* Deciles
	foreach x in urban_pop loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in urban_pop loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | urban_pop==.
	summ loggdppc2
	scalar min_y1=r(min)
	scalar max_y1=r(max)
	summ urban_pop
	scalar min_x1=r(min)
	scalar max_x1=r(max)

	* Figure 1: Urban population as % of total (vs World)
	lpoly urban_pop loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y1'(1)`=max_y1')) ysc(range(`=min_x1'(1)`=max_x1')) /*
	*/ title("Urbanization, `=minyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Urban population (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter urban_pop loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter urban_pop loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter urban_pop loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure1`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure1`ctry'_2A2.png") replace
	
	* How many s.d. is the country from the fitted value?
	gen diff=(urban_pop-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_urban_pop=r(mean)
	drop pred se diff
}
restore

*********************************************************
** STRUCTURAL TRANSFORMATION: AGRICULTURE SHARE OF GDP **
*********************************************************
rename NV_AGR_TOTL_ZS agr_gdp
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & agr_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & agr_gdp!=.
scalar minyear2=r(min)
local minyear2: display %9.0f minyear2

drop if year!=`=minyear2'

if `=minyear2'!=. {
	* Statistics for Figure 2
	* Deciles
	foreach x in agr_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in agr_gdp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | agr_gdp==.
	summ loggdppc2
	scalar min_y2=r(min)
	scalar max_y2=r(max)
	summ agr_gdp
	scalar min_x2=r(min)
	scalar max_x2=r(max)

	* Figure 2: Agriculture as % of GDP (vs World)
	lpoly agr_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y2'(1)`=max_y2')) ysc(range(`=min_x2'(1)`=max_x2')) /*
	*/ title("Share of agriculture in GDP, `=minyear2'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Agriculture, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter agr_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter agr_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter agr_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure2`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure2`ctry'_2A2.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(agr_gdp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_agr_gdp=r(mean)
	drop pred se diff
}
restore

***********************************************************
** STRUCTURAL TRANSFORMATION: MANUFACTURING SHARE OF GDP **
***********************************************************
rename NV_IND_MANF_ZS mnf_gdp
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & mnf_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & mnf_gdp!=.
scalar minyear3=r(min)
local minyear3: display %9.0f minyear3

drop if year!=`=minyear3'

if `=minyear3'!=. {
	* Statistics for Figure 3
	* Deciles
	foreach x in mnf_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in mnf_gdp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | mnf_gdp==.
	summ loggdppc2
	scalar min_y3=r(min)
	scalar max_y3=r(max)
	summ mnf_gdp
	scalar min_x3=r(min)
	scalar max_x3=r(max)

	* Figure 3: Manufacturing as % of GDP (vs World)
	lpoly mnf_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y3'(1)`=max_y3')) ysc(range(`=min_x3'(1)`=max_x3')) /*
	*/ title("Share of manufacturing in GDP, `=minyear3'") subtitle("`j'") note("Note: Manufacturing corresponds to ISIC Rev.3 divisions 15-37" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Manufacturing, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter mnf_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter mnf_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter mnf_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure3`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure3`ctry'_2A2.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(mnf_gdp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_mnf_gdp=r(mean)
	drop pred se diff
}
restore

******************************************************
** STRUCTURAL TRANSFORMATION: INDUSTRY SHARE OF GDP **
******************************************************
rename NV_IND_TOTL_ZS ind_gdp
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ind_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ind_gdp!=.
scalar minyear4=r(min)
local minyear4: display %9.0f minyear4

drop if year!=`=minyear4'

if `=minyear4'!=. {
	* Statistics for Figure 4
	* Deciles
	foreach x in ind_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in ind_gdp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | ind_gdp==.
	summ loggdppc2
	scalar min_y4=r(min)
	scalar max_y4=r(max)
	summ ind_gdp
	scalar min_x4=r(min)
	scalar max_x4=r(max)

	* Figure 4: Industry as % of GDP (vs World)
	lpoly ind_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y4'(1)`=max_y4')) ysc(range(`=min_x4'(1)`=max_x4')) /*
	*/ title("Share of industry in GDP, `=minyear4'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Industry, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ind_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ind_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ind_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure4`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure4`ctry'_2A2.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(ind_gdp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_ind_gdp=r(mean)
	drop pred se diff
}
restore

******************************************************
** STRUCTURAL TRANSFORMATION: SERVICES SHARE OF GDP **
******************************************************
rename NV_SRV_TETC_ZS ss_gdp
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ss_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ss_gdp!=.
scalar minyear5=r(min)
local minyear5: display %9.0f minyear5

drop if year!=`=minyear5'

if `=minyear5'!=. {
	* Statistics for Figure 5
	* Deciles
	foreach x in ss_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in ss_gdp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | ss_gdp==.
	summ loggdppc2
	scalar min_y5=r(min)
	scalar max_y5=r(max)
	summ ss_gdp
	scalar min_x5=r(min)
	scalar max_x5=r(max)

	* Figure 5: Industry as % of GDP (vs World)
	lpoly ss_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y5'(1)`=max_y5')) ysc(range(`=min_x5'(1)`=max_x5')) /*
	*/ title("Share of industry in GDP, `=minyear5'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Industry, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ss_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ss_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ss_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure5`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure5`ctry'_2A2.png") append
	
	* How many s.d. is the country from the fitted value?
	gen diff=(ss_gdp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_ss_gdp=r(mean)
	drop pred se diff
}
restore

**********************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN AGRICULTURE **
**********************************************************
rename SL_AGR_EMPL_ZS emp_agr
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_agr!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_agr!=.
scalar minyear6=r(min)
local minyear6: display %9.0f minyear6

drop if year!=`=minyear6'

if `=minyear6'!=. {
	* Statistics for Figure 6
	* Deciles
	foreach x in emp_agr loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in emp_agr loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | emp_agr==.
	summ loggdppc2
	scalar min_y6=r(min)
	scalar max_y6=r(max)
	summ emp_agr
	scalar min_x6=r(min)
	scalar max_x6=r(max)

	* Figure 6: Employment in agriculture (vs World)
	lpoly emp_agr loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y6'(1)`=max_y6')) ysc(range(`=min_x6'(1)`=max_x6')) /*
	*/ title("Agriculture employment, `=minyear6'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in agriculture (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_agr loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_agr loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_agr loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure6`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure6`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(emp_agr-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_emp_agr=r(mean)
	drop pred se diff
}
restore


*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN INDUSTRY **
*******************************************************
rename SL_IND_EMPL_ZS emp_ind
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_ind!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ind!=.
scalar minyear7=r(min)
local minyear7: display %9.0f minyear7

drop if year!=`=minyear7'

if `=minyear7'!=. {
	* Statistics for Figure 7
	* Deciles
	foreach x in emp_ind loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in emp_ind loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | emp_ind==.
	summ loggdppc2
	scalar min_y7=r(min)
	scalar max_y7=r(max)
	summ emp_ind
	scalar min_x7=r(min)
	scalar max_x7=r(max)

	* Figure 7: Employment in industry (vs World)
	lpoly emp_ind loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y7'(1)`=max_y7')) ysc(range(`=min_x7'(1)`=max_x7')) /*
	*/ title("Industry employment, `=minyear7'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in industry (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ind loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ind loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ind loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure7`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure7`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(emp_ind-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_emp_ind=r(mean)
	drop pred se diff
}
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN SERVICES **
*******************************************************
rename SL_SRV_EMPL_ZS emp_ss
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_ss!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ss!=.
scalar minyear8=r(min)
local minyear8: display %9.0f minyear8

drop if year!=`=minyear8'

if `=minyear8'!=. {
	* Statistics for Figure 8
	* Deciles
	foreach x in emp_ss loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in emp_ss loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | emp_ss==.
	summ loggdppc2
	scalar min_y8=r(min)
	scalar max_y8=r(max)
	summ emp_ss
	scalar min_x8=r(min)
	scalar max_x8=r(max)

	* Figure 8: Employment in services (vs World)
	lpoly emp_ss loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y8'(1)`=max_y8')) ysc(range(`=min_x8'(1)`=max_x8')) /*
	*/ title("Services employment, `=minyear8'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in services (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ss loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ss loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ss loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure8`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure8`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(emp_ss-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_emp_ss=r(mean)
	drop pred se diff
}
restore

********************************************************************************************************************************************************

*****************************************************
** PHYSICAL CAPITAL: ENERGY CONSUMPTION PER CAPITA **
*****************************************************
rename EG_USE_PCAP_KG_OE energypc
gen logenergypc=log10(energypc)
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & logenergypc!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & logenergypc!=.
scalar minyear9=r(min)
local minyear9: display %9.0f minyear9

drop if year!=`=minyear9'

if `=minyear9'!=. {
	* Statistics for Figure 9
	* Deciles
	foreach x in logenergypc loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in logenergypc loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | logenergypc==.
	summ loggdppc2
	scalar min_y9=r(min)
	scalar max_y9=r(max)
	summ logenergypc
	scalar min_x9=r(min)
	scalar max_x9=r(max)

	* Figure 9: Energy consumption per capita (vs World)
	lpoly logenergypc loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y9'(1)`=max_y9')) ysc(range(`=min_x9'(1)`=max_x9')) /*
	*/ title("Energy consumption per capita, `=minyear9'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Energy use (kg of oil equivalent per capita), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter logenergypc loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter logenergypc loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter logenergypc loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure9`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure9`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(logenergypc-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_logenergypc=r(mean)
	drop pred se diff
}
restore

*******************************************
** PHYSICAL CAPITAL: CAPITAL PER WORKER **
*******************************************
preserve
save "temp.dta", replace
use "$capital", clear /*Penn World Tables*/
rename countrycode wbcode
replace wbcode="ZAR" if wbcode=="COD"
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
gen kpw=log10(ck/SL_TLF_TOTL_IN)

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & kpw!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & kpw!=.
scalar minyear10=r(min)
local minyear10: display %9.0f minyear10

drop if year!=`=minyear10'

if `=minyear10'!=. {
	* Statistics for Figure 10
	* Deciles
	foreach x in kpw loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in kpw loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | kpw==.
	summ loggdppc2
	scalar min_y10=r(min)
	scalar max_y10=r(max)
	summ kpw
	scalar min_x10=r(min)
	scalar max_x10=r(max)

	* Figure 10: Capital per worker (vs World)
	lpoly kpw loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y10'(1)`=max_y10')) ysc(range(`=min_x10'(1)`=max_x10')) /*
	*/ title("Capital per worker, `=minyear10'") subtitle("`j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("Capital stock/labor force" "(at current PPP mil. 2005 US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter kpw loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter kpw loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter kpw loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure10`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure10`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(kpw-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_kpw=r(mean)
	drop pred se diff
}
restore
********************************************************************************************************************************************************

***************************************************************
** HUMAN CAPITAL: YEARS OF SCHOOLING (OF POPULATION OVER 25) **
***************************************************************
preserve
merge 1:1 wbcode year using "$education" /*Barro and Lee only have data for every 5 years*/
drop if _merge!=3
drop _merge
rename yr_sch school

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & school!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & school!=.
scalar minyear11=r(min)
local minyear11: display %9.0f minyear11

drop if year!=`=minyear11'

if `=minyear11'!=. {
	* Statistics for Figure 11
	* Deciles
	foreach x in school loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in school loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | school==.
	summ loggdppc2
	scalar min_y11=r(min)
	scalar max_y11=r(max)
	summ school
	scalar min_x11=r(min)
	scalar max_x11=r(max)

	* Figure 11: Years of schooling (vs World)
	lpoly school loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.0fc)) xsc(range(`=min_y11'(1)`=max_y11')) ysc(range(`=min_x11'(1)`=max_x11')) /*
	*/ title("Years of schooling, `=minyear11'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Years of schooling") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter school loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter school loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter school loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure11`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure11`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(school-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_school=r(mean)
	drop pred se diff
}
restore

**************************************
** HUMAN CAPITAL: PRIMARY SCHOOLING **
**************************************
preserve
merge 1:1 wbcode year using "$education" /*Barro and Lee only have data for every 5 years*/
drop if _merge!=3
drop _merge
rename lp prim

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & prim!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & prim!=.
scalar minyear12=r(min)
local minyear12: display %9.0f minyear12

drop if year!=`=minyear12'

if `=minyear12'!=. {
	* Statistics for Figure 12
	* Deciles
	foreach x in prim loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in prim loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | prim==.
	summ loggdppc2
	scalar min_y12=r(min)
	scalar max_y12=r(max)
	summ prim
	scalar min_x12=r(min)
	scalar max_x12=r(max)

	* Figure 12: Primary schooling (vs World)
	lpoly prim loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.0fc)) xsc(range(`=min_y12'(1)`=max_y12')) ysc(range(`=min_x12'(1)`=max_x12')) /*
	*/ title("Primary schooling, `=minyear12'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Primary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter prim loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter prim loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter prim loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure12`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure12`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(prim-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_prim=r(mean)
	drop pred se diff
}
restore

****************************************
** HUMAN CAPITAL: SECONDARY SCHOOLING **
****************************************
preserve
merge 1:1 wbcode year using "$education" /*Barro and Lee only have data for every 5 years*/
drop if _merge!=3
drop _merge
rename ls sec

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & sec!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & sec!=.
scalar minyear13=r(min)
local minyear13: display %9.0f minyear13

drop if year!=`=minyear13'

if `=minyear13'!=. {
	* Statistics for Figure 13
	* Deciles
	foreach x in sec loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in sec loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | sec==.
	summ loggdppc2
	scalar min_y13=r(min)
	scalar max_y13=r(max)
	summ sec
	scalar min_x13=r(min)
	scalar max_x13=r(max)

	* Figure 13: Secondary enrollment (vs World)
	lpoly sec loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.0fc)) xsc(range(`=min_y13'(1)`=max_y13')) ysc(range(`=min_x13'(1)`=max_x13')) /*
	*/ title("Secondary schooling, `=minyear13'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Secondary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter sec loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter sec loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter sec loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure13`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure13`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(sec-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_sec=r(mean)
	drop pred se diff
}
restore

***************************************
** HUMAN CAPITAL: TERTIARY SCHOOLING **
***************************************
preserve
merge 1:1 wbcode year using "$education" /*Barro and Lee only have data for every 5 years*/
drop if _merge!=3
drop _merge
rename lh univ

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & univ!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & univ!=.
scalar minyear14=r(min)
local minyear14: display %9.0f minyear14

drop if year!=`=minyear14'

if `=minyear14'!=. {
	* Statistics for Figure 14
	* Deciles
	foreach x in univ loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in univ loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | univ==.
	summ loggdppc2
	scalar min_y14=r(min)
	scalar max_y14=r(max)
	summ univ
	scalar min_x14=r(min)
	scalar max_x14=r(max)

	* Figure 14: Tertiary schooling (vs World)
	lpoly univ loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.0fc)) xsc(range(`=min_y14'(1)`=max_y14')) ysc(range(`=min_x14'(1)`=max_x14')) /*
	*/ title("Tertiary schooling, `=minyear14'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Tertiary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter univ loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter univ loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter univ loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure14`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure14`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(univ-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_univ=r(mean)
	drop pred se diff
}
restore

**************************************************************
** HUMAN CAPITAL: SCIENTIFIC AND TECHNICAL JOURNAL ARTICLES **
**************************************************************
gen journal=IP_JRN_ARTC_SC*1000/SP_POP_TOTL
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & journal!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & journal!=.
scalar minyear15=r(min)
local minyear15: display %9.0f minyear15

drop if year!=`=minyear15'

if `=minyear15'!=. {
	* Statistics for Figure 15
	* Deciles
	foreach x in journal loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in journal loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | journal==.
	summ loggdppc2
	scalar min_y15=r(min)
	scalar max_y15=r(max)
	summ journal
	scalar min_x15=r(min)
	scalar max_x15=r(max)

	* Figure 15: Journals (vs World)
	lpoly journal loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.1fc)) xsc(range(`=min_y15'(1)`=max_y15')) ysc(range(`=min_x15'(1)`=max_x15')) /*
	*/ title("Scientific and Technical Journal Articles, `=minyear15'") subtitle("Per 1,000 people, `j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Scientific and technical journal articles per 1,000 people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter journal loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter journal loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter journal loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure15`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure15`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(journal-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_journal=r(mean)
	drop pred se diff
}
restore

***************************************
** HUMAN CAPITAL: RESEARCHERS IN R&D **
***************************************
rename SP_POP_SCIE_RD_P6 research
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & research!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & research!=.
scalar minyear16=r(min)
local minyear16: display %9.0f minyear16

drop if year!=`=minyear16'

if `=minyear16'!=. {
	* Statistics for Figure 16
	* Deciles
	foreach x in research loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in research loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | research==.
	summ loggdppc2
	scalar min_y16=r(min)
	scalar max_y16=r(max)
	summ research
	scalar min_x16=r(min)
	scalar max_x16=r(max)

	* Figure 16: Researchers in R&D (vs World)
	lpoly research loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.1fc)) xsc(range(`=min_y16'(1)`=max_y16')) ysc(range(`=min_x16'(1)`=max_x16')) /*
	*/ title("Researchers in R&D, `=minyear16'") subtitle("Per million people, `j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Researchers in R&D per million people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter research loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter research loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter research loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure16`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure16`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(research-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_research=r(mean)
	drop pred se diff
}
restore
********************************************************************************************************************************************************

**********************************
** POPULATION: INFANT MORTALITY **
**********************************
rename SP_DYN_IMRT_IN infant
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & infant!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & infant!=.
scalar minyear17=r(min)
local minyear17: display %9.0f minyear17

drop if year!=`=minyear17'

if `=minyear17'!=. {
	* Statistics for Figure 17
	* Deciles
	foreach x in infant loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in infant loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | infant==.
	summ loggdppc2
	scalar min_y17=r(min)
	scalar max_y17=r(max)
	summ infant
	scalar min_x17=r(min)
	scalar max_x17=r(max)

	* Figure 17: Infant mortality (vs World)
	lpoly infant loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y17'(1)`=max_y17')) ysc(range(`=min_x17'(50)`=max_x17')) /*
	*/ title("Infant mortality, `=minyear17'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Mortality rate, infant (per 1,000 live births)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter infant loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter infant loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter infant loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure17`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure17`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(infant-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_infant=r(mean)
	drop pred se diff
}
restore

********************************
** POPULATION: FERTILITY RATE **
********************************
rename SP_DYN_TFRT_IN fertil
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & fertil!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & fertil!=.
scalar minyear18=r(min)
local minyear18: display %9.0f minyear18

drop if year!=`=minyear18'

if `=minyear18'!=. {
	* Statistics for Figure 18
	* Deciles
	foreach x in fertil loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in fertil loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | fertil==.
	summ loggdppc2
	scalar min_y18=r(min)
	scalar max_y18=r(max)
	summ fertil
	scalar min_x18=r(min)
	scalar max_x18=r(max)

	* Figure 18: Fertility rate (vs World)
	lpoly fertil loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y18'(1)`=max_y18')) ysc(range(`=min_x18'(1)`=max_x18')) /*
	*/ title("Fertility rate, `=minyear18'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Fertility rate, total (births per woman)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter fertil loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter fertil loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter fertil loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure18`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure18`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(fertil-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_fertil=r(mean)
	drop pred se diff
}
restore

*********************************
** POPULATION: LIFE EXPECTANCY **
*********************************
rename SP_DYN_LE00_IN life
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & life!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & life!=.
scalar minyear19=r(min)
local minyear19: display %9.0f minyear19

drop if year!=`=minyear19'

if `=minyear19'!=. {
	* Statistics for Figure 19
	* Deciles
	foreach x in life loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in life loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | life==.
	summ loggdppc2
	scalar min_y19=r(min)
	scalar max_y19=r(max)
	summ life
	scalar min_x19=r(min)
	scalar max_x19=r(max)

	* Figure 19: Life Expectancy (vs World)
	lpoly life loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y19'(1)`=max_y19')) ysc(range(`=min_x19'(1)`=max_x19')) /*
	*/ title("Life expectancy, `=minyear19'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Life expectancy at birth, total (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter life loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter life loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter life loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure19`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure19`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(life-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_life=r(mean)
	drop pred se diff
}
restore

***********************************
** POPULATION: POPULATION GROWTH **
***********************************
rename SP_POP_GROW pop_g
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & pop_g!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & pop_g!=.
scalar minyear20=r(min)
local minyear20: display %9.0f minyear20

drop if year!=`=minyear20'

if `=minyear20'!=. {
	* Statistics for Figure 20
	* Deciles
	foreach x in pop_g loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in pop_g loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | pop_g==.
	summ loggdppc2
	scalar min_y20=r(min)
	scalar max_y20=r(max)
	summ pop_g
	scalar min_x20=r(min)
	scalar max_x20=r(max)

	* Figure 20: Population growth (vs World)
	lpoly pop_g loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y20'(1)`=max_y20')) ysc(range(`=min_x20'(1)`=max_x20')) /*
	*/ title("Population growth, `=minyear20'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Population growth (annual %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter pop_g loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter pop_g loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter pop_g loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure20`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure20`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(pop_g-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_pop_g=r(mean)
	drop pred se diff
}
restore

**************************************
** POPULATION: DEMOGRAPHIC DIVIDEND **
**************************************
rename SP_POP_DPND depend
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & depend!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & depend!=.
scalar minyear21=r(min)
local minyear21: display %9.0f minyear21

drop if year!=`=minyear21'

if `=minyear21'!=. {
	* Statistics for Figure 21
	* Deciles
	foreach x in depend loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in depend loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | depend==.
	summ loggdppc2
	scalar min_y21=r(min)
	scalar max_y21=r(max)
	summ depend
	scalar min_x21=r(min)
	scalar max_x21=r(max)

	* Figure 21: Demographic Dividend (vs World)
	lpoly depend loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y21'(1)`=max_y21')) ysc(range(`=min_x21'(1)`=max_x21')) /*
	*/ title("Demographic dividend, `=minyear21'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Age dependency ratio (% of working-age population)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter depend loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter depend loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter depend loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure21`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure21`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(depend-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_depend=r(mean)
	drop pred se diff
}
restore
save "temp.dta", replace
********************************************************************************************************************************************************

**************************
** PRODUCTIVITY AND TFP **
**************************
preserve
use "$capital", clear /*Penn World Tables*/
rename countrycode wbcode
replace wbcode="ZAR" if wbcode=="COD"
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ctfp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ctfp!=.
scalar minyear22=r(min)
local minyear22: display %9.0f minyear22

drop if year!=`=minyear22'

if `=minyear22'!=. {
	* Statistics for Figure 22
	* Deciles
	foreach x in ctfp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in ctfp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | ctfp==.
	summ loggdppc2
	scalar min_y22=r(min)
	scalar max_y22=r(max)
	summ ctfp
	scalar min_x22=r(min)
	scalar max_x22=r(max)

	* Figure 22: Total Factor Productivity  (vs World)
	lpoly ctfp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y22'(1)`=max_y22')) ysc(range(`=min_x22'(1)`=max_x22')) /*
	*/ title("Total Factor Productivity, `=minyear22'") subtitle("Relative to USA, `j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("TFP level at current PPPs (USA=1)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ctfp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ctfp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ctfp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure22`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure22`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(ctfp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_ctfp=r(mean)
	drop pred se diff
}
restore
save "temp2.dta", replace
********************************************************************************************************************************************************

********************************************
** POLICY AND INSTITUTIONS: TAXES REVENUE **
********************************************
preserve
use "$revenue", clear /*World Economic Outlook*/
reshape long y, i(iso) j(year)
drop weocountrycode weosubjectcode subjectdescriptor units scale
drop if year>=estimatesstartafter
drop estimatesstartafter
rename iso wbcode
replace wbcode="KSV" if wbcode=="UVK"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
merge 1:1 wbcode year using "temp2.dta"
drop if _merge!=3
drop _merge
rename y tax_gdp
label var tax_gdp "General government revenue (% of GDP)"

* Minimum years
forval x=2012(-1)1980 {
	count if loggdppc2!=. & year==`x' & tax_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & tax_gdp!=.
scalar minyear23=r(min)
local minyear23: display %9.0f minyear23

drop if year!=`=minyear23'

if `=minyear23'!=. {
	* Statistics for Figure 23
	* Deciles
	foreach x in tax_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in tax_gdp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | tax_gdp==.
	summ loggdppc2
	scalar min_y23=r(min)
	scalar max_y23=r(max)
	summ tax_gdp
	scalar min_x23=r(min)
	scalar max_x23=r(max)

	* Figure 23: Tax revenue (% of GDP) (vs World)
	lpoly tax_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y23'(1)`=max_y23')) ysc(range(`=min_x23'(1)`=max_x23')) /*
	*/ title("Government revenue, `=minyear23'") subtitle("`j'") note("Data source: World Economic Outlook and World Development Indicators") /*
	*/ ytitle("General government revenue (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tax_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tax_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tax_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure23`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure23`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(tax_gdp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_tax_gdp=r(mean)
	drop pred se diff
}
restore

***************************************
** POLICY AND INSTITUTIONS: OPENNESS **
***************************************
gen open=NE_EXP_GNFS_ZS+NE_IMP_GNFS_ZS
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & open!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & open!=.
scalar minyear24=r(min)
local minyear24: display %9.0f minyear24

drop if year!=`=minyear24'

if `=minyear24'!=. {
	* Statistics for Figure 24
	* Deciles
	foreach x in open loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in open loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | open==.
	summ loggdppc2
	scalar min_y24=r(min)
	scalar max_y24=r(max)
	summ open
	scalar min_x24=r(min)
	scalar max_x24=r(max)

	* Figure 24: Openness (% of GDP) (vs World)
	lpoly open loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y24'(1)`=max_y24')) ysc(range(`=min_x24'(100)`=max_x24'))  /*
	*/ title("Openness, `=minyear24'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Exports + Imports of goods and services (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter open loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter open loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter open loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure24`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure24`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(open-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_open=r(mean)
	drop pred se diff
}
restore
save "temp3.dta", replace

****************************************
** POLICY AND INSTITUTIONS: DEMOCRACY **
****************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if fh_ipolity2==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge n2 n3
rename fh_ipolity2 demo

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & demo!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & demo!=.
scalar minyear25=r(min)
local minyear25: display %9.0f minyear25

drop if year!=`=minyear25'

if `=minyear25'!=. {
	* Statistics for Figure 25
	* Deciles
	foreach x in demo loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in demo loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | demo==.
	summ loggdppc2
	scalar min_y25=r(min)
	scalar max_y25=r(max)
	summ demo
	scalar min_x25=r(min)
	scalar max_x25=r(max)

	* Figure 25: Democracy (vs World)
	lpoly demo loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y25'(1)`=max_y25')) ysc(range(`=min_x25'(1)`=max_x25'))  /*
	*/ title("Democracy, `=minyear25'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House/Polity) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Democracy (Freedom House/Imputed Polity)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter demo loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter demo loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter demo loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure25`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure25`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(demo-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_demo=r(mean)
	drop pred se diff
}
restore
save "temp3.dta", replace

******************************************
** POLICY AND INSTITUTIONS: RULE OF LAW **
******************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if fh_rol==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename fh_rol rule

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & rule!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & rule!=.
scalar minyear26=r(min)
local minyear26: display %9.0f minyear26

drop if year!=`=minyear26'

if `=minyear26'!=. {
	* Statistics for Figure 26
	* Deciles
	foreach x in rule loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in rule loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | rule==.
	summ loggdppc2
	scalar min_y26=r(min)
	scalar max_y26=r(max)
	summ rule
	scalar min_x26=r(min)
	scalar max_x26=r(max)

	* Figure 26: Rule of Law (vs World)
	lpoly rule loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y26'(1)`=max_y26')) ysc(range(`=min_x26'(1)`=max_x26'))  /*
	*/ title("Rule of Law, `=minyear26'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Rule of Law") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter rule loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter rule loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter rule loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure26`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure26`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(rule-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_rule=r(mean)
	drop pred se diff
}
restore
save "temp3.dta", replace

***********************************************
** POLICY AND INSTITUTIONS: ECONOMIC FREEDOM **
***********************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if hf_efiscore==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename hf_efiscore econ_freedom

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=.  & year==`x' & econ_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & econ_freedom!=.
scalar minyear27=r(min)
local minyear27: display %9.0f minyear27

drop if year!=`=minyear27'

if `=minyear27'!=. {
	* Statistics for Figure 27
	* Deciles
	foreach x in econ_freedom loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in econ_freedom loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | econ_freedom==.
	summ loggdppc2
	scalar min_y27=r(min)
	scalar max_y27=r(max)
	summ econ_freedom
	scalar min_x27=r(min)
	scalar max_x27=r(max)

	* Figure 27: Economic Freedom (vs World)
	lpoly econ_freedom loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y27'(10)`=max_y27')) ysc(range(`=min_x27'(1)`=max_x27'))  /*
	*/ title("Economic Freedom, `=minyear27'") subtitle("`j'") note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
	*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Economic Freedom Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter econ_freedom loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter econ_freedom loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter econ_freedom loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure27`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure27`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(econ_freedom-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_econ_freedom=r(mean)
	drop pred se diff
}
restore
save "temp3.dta", replace

***********************************************
** POLICY AND INSTITUTIONS: BUSINESS FREEDOM **
***********************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if hf_business==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename hf_business bus_freedom

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & bus_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & bus_freedom!=.
scalar minyear28=r(min)
local minyear28: display %9.0f minyear28

drop if year!=`=minyear28'

if `=minyear28'!=. {
	* Statistics for Figure 28
	* Deciles
	foreach x in bus_freedom loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in bus_freedom loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | bus_freedom==.
	summ loggdppc2
	scalar min_y28=r(min)
	scalar max_y28=r(max)
	summ bus_freedom
	scalar min_x28=r(min)
	scalar max_x28=r(max)

	* Figure 28: Business Freedom (vs World)
	lpoly bus_freedom loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y28'(10)`=max_y28')) ysc(range(`=min_x28'(1)`=max_x28'))  /*
	*/ title("Business Freedom, `=minyear28'") subtitle("`j'") note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
	*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
	*/ "and closing a business (time, cost, and recovery rate)" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Business Freedom score") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter bus_freedom loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter bus_freedom loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter bus_freedom loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure28`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure28`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(bus_freedom-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_bus_freedom=r(mean)
	drop pred se diff
}
restore

********************************************************************************************************************************************************

****************************************************************
** COMPOSITION OF EXPORTS: HIGH-TECHNOLOGY EXPORTS PER CAPITA **
****************************************************************
gen tech_exp=log10(TX_VAL_TECH_CD/SP_POP_TOTL)
preserve

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & tech_exp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & tech_exp!=.
scalar minyear29=r(min)
local minyear29: display %9.0f minyear29

drop if year!=`=minyear29'

if `=minyear29'!=. {
	* Statistics for Figure 29
	* Deciles
	foreach x in tech_exp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in tech_exp loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | tech_exp==.
	summ loggdppc2
	scalar min_y29=r(min)
	scalar max_y29=r(max)
	summ tech_exp
	scalar min_x29=r(min)
	scalar max_x29=r(max)

	* Figure 29: High-technology exports per capita (vs World)
	lpoly tech_exp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y29'(1)`=max_y29')) ysc(range(`=min_x29'(1)`=max_x29')) /*
	*/ title("High-technology exports per capita, `=minyear29'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("High-technology exports per capita (current US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tech_exp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tech_exp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tech_exp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure29`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure29`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(tech_exp-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_tech_exp=r(mean)
	drop pred se diff
}
restore
save "temp4.dta", replace

***************************************
** COMPOSITION OF EXPORTS: DIVERSITY **
***************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & diversity_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & diversity_rca!=.
scalar minyear30=r(min)
local minyear30: display %9.0f minyear30

drop if year!=`=minyear30'

if `=minyear30'!=. {
	* Statistics for Figure 30
	* Deciles
	foreach x in diversity_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in diversity_rca loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | diversity_rca==.
	summ loggdppc2
	scalar min_y30=r(min)
	scalar max_y30=r(max)
	summ diversity_rca
	scalar min_x30=r(min)
	scalar max_x30=r(max)

	* Figure 30: Diverisity of exports (vs World)
	lpoly diversity_rca loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y30'(1)`=max_y30')) ysc(range(`=min_x30'(100)`=max_x30')) /*
	*/ title("Diversity of exports, `=minyear30'") subtitle("`j'") note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
	*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database") /*
	*/ ytitle("Number of products exported with RCA") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter diversity_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter diversity_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter diversity_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure30`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure30`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(diversity_rca-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_diversity_rca=r(mean)
	drop pred se diff
}
restore
save "temp4.dta", replace

*************************************************
** COMPOSITION OF EXPORTS: ECONOMIC COMPLEXITY **
*************************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge
format eci_rca %9.1fc

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & eci_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & eci_rca!=.
scalar minyear31=r(min)
local minyear31: display %9.0f minyear31

drop if year!=`=minyear31'

if `=minyear31'!=. {
	* Statistics for Figure 31
	* Deciles
	foreach x in eci_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in eci_rca loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | eci_rca==.
	summ loggdppc2
	scalar min_y31=r(min)
	scalar max_y31=r(max)
	summ eci_rca
	scalar min_x31=r(min)
	scalar max_x31=r(max)

	* Figure 31: Economic Complexity Index (vs World)
	lpoly eci_rca loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y31'(1)`=max_y31')) ysc(range(`=min_x31'(1)`=max_x31')) /*
	*/ title("Economic Complexity, `=minyear31'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Economic Complexity Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter eci_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter eci_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter eci_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure31`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure31`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(eci_rca-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_eci_rca=r(mean)
	drop pred se diff
}
restore
save "temp4.dta", replace

************************************************
** COMPOSITION OF EXPORTS: COMPLEXITY OUTLOOK **
************************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge
rename oppvalue_rca coi_rca
format coi_rca %9.1fc

* Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & coi_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & coi_rca!=.
scalar minyear32=r(min)
local minyear32: display %9.0f minyear32

drop if year!=`=minyear32'

if `=minyear32'!=. {
	* Statistics for Figure 32
	* Deciles
	foreach x in coi_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(10)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in coi_rca loggdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if loggdppc2==. | coi_rca==.
	summ loggdppc2
	scalar min_y32=r(min)
	scalar max_y32=r(max)
	summ coi_rca
	scalar min_x32=r(min)
	scalar max_x32=r(max)

	* Figure 32: Economic Complexity Index (vs World)
	lpoly coi_rca loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y32'(1)`=max_y32')) ysc(range(`=min_x32'(1)`=max_x32')) /*
	*/ title("Complexity Outlook, `=minyear32'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Complexity Outlook Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter coi_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter coi_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter coi_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure32`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure32`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(coi_rca-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_coi_rca=r(mean)
	drop pred se diff
}
restore
********************************************************************************************************************************************************

***************************************************
** RANKINGS, PERCENTILES AND ERROR IN S.E. UNITS **
***************************************************

foreach var in urban_pop agr_gdp mnf_gdp ind_gdp ss_gdp emp_agr emp_ind emp_ss logenergypc kpw school prim sec univ journal research infant fertil life /*
*/ pop_g depend ctfp tax_gdp open demo rule econ_freedom bus_freedom tech_exp diversity_rca eci_rca coi_rca {
	capture noisily gen rank_`var'=`=rank_`var''
	capture noisily gen n_`var'=`=n_`var''
	capture noisily gen pct_`var'=`=pct_`var''
	capture noisily gen diff_`var'=`=diff_`var''
	}

forval x=1/32 {
	capture noisily gen minyear`x'=`=minyear`x''
}

preserve
collapse minyear1 rank_urban_pop n_urban_pop pct_urban_pop diff_urban_pop
rename minyear1 year
rename rank_urban_pop rank
rename n_urban_pop n
rename pct_urban_pop decile
rename diff_urban_pop deviation
gen variable=1
save "temp1.dta", replace
restore

preserve
collapse minyear2 rank_agr_gdp n_agr_gdp pct_agr_gdp diff_agr_gdp
rename minyear2 year
rename rank_agr_gdp rank
rename n_agr_gdp n
rename pct_agr_gdp decile
rename diff_agr_gdp deviation
gen variable=2
save "temp2.dta", replace
restore

preserve
collapse minyear3 rank_mnf_gdp n_mnf_gdp pct_mnf_gdp diff_mnf_gdp
rename minyear3 year
rename rank_mnf_gdp rank
rename n_mnf_gdp n
rename pct_mnf_gdp decile
rename diff_mnf_gdp deviation
gen variable=3
save "temp3.dta", replace
restore

preserve
collapse minyear4 rank_ind_gdp n_ind_gdp pct_ind_gdp diff_ind_gdp
rename minyear4 year
rename rank_ind_gdp rank
rename n_ind_gdp n
rename pct_ind_gdp decile
rename diff_ind_gdp deviation
gen variable=4
save "temp4.dta", replace
restore

preserve
collapse minyear5 rank_ss_gdp n_ss_gdp pct_ss_gdp diff_ss_gdp
rename minyear5 year
rename rank_ss_gdp rank
rename n_ss_gdp n
rename pct_ss_gdp decile
rename diff_ss_gdp deviation
gen variable=5
save "temp5.dta", replace
restore

preserve
collapse minyear6 rank_emp_agr n_emp_agr pct_emp_agr diff_emp_agr
rename minyear6 year
rename rank_emp_agr rank
rename n_emp_agr n
rename pct_emp_agr decile
rename diff_emp_agr deviation
gen variable=6
save "temp6.dta", replace
restore

preserve
collapse minyear7 rank_emp_ind n_emp_ind pct_emp_ind diff_emp_ind
rename minyear7 year
rename rank_emp_ind rank
rename n_emp_ind n
rename pct_emp_ind decile
rename diff_emp_ind deviation
gen variable=7
save "temp7.dta", replace
restore

preserve
collapse minyear8 rank_emp_ss n_emp_ss pct_emp_ss diff_emp_ss
rename minyear8 year
rename rank_emp_ss rank
rename n_emp_s n
rename pct_emp_ss decile
rename diff_emp_ss deviation
gen variable=8
save "temp8.dta", replace
restore

preserve
collapse minyear9 rank_logenergypc n_logenergypc pct_logenergypc diff_logenergypc
rename minyear9 year
rename rank_logenergypc rank
rename n_logenergypc n
rename pct_logenergypc decile
rename diff_logenergypc deviation
gen variable=9
save "temp9.dta", replace
restore

preserve
collapse minyear10 rank_kpw n_kpw pct_kpw diff_kpw
rename minyear10 year
rename rank_kpw rank
rename n_kpw n
rename pct_kpw decile
rename diff_kpw deviation
gen variable=10
save "temp10.dta", replace
restore

preserve
collapse minyear11 rank_school n_school pct_school diff_school
rename minyear11 year
rename rank_school rank
rename n_school n
rename pct_school decile
rename diff_school deviation
gen variable=11
save "temp11.dta", replace
restore

preserve
collapse minyear12 rank_prim n_prim pct_prim diff_prim
rename minyear12 year
rename rank_prim rank
rename n_prim n
rename pct_prim decile
rename diff_prim deviation
gen variable=12
save "temp12.dta", replace
restore

preserve
collapse minyear13 rank_sec n_sec pct_sec diff_sec
rename minyear13 year
rename rank_sec rank
rename n_sec n
rename pct_sec decile
rename diff_sec deviation
gen variable=13
save "temp13.dta", replace
restore

preserve
collapse minyear14 rank_univ n_univ pct_univ diff_univ
rename minyear14 year
rename rank_univ rank
rename n_univ n
rename pct_univ decile
rename diff_univ deviation
gen variable=14
save "temp14.dta", replace
restore

preserve
collapse minyear15 rank_journal n_journal pct_journal diff_journal
rename minyear15 year
rename rank_journal rank
rename n_journal n
rename pct_journal decile
rename diff_journal deviation
gen variable=15
save "temp15.dta", replace
restore

preserve
capture noisily {
collapse minyear16 rank_research n_research pct_research diff_research
rename minyear16 year
rename rank_research rank
rename n_research n
rename pct_research decile
rename diff_research deviation
gen variable=16
save "temp16.dta", replace
}
restore

preserve
collapse minyear17 rank_infant n_infant pct_infant diff_infant
rename minyear17 year
rename rank_infant rank
rename n_infant n
rename pct_infant decile
rename diff_infant deviation
gen variable=17
save "temp17.dta", replace
restore

preserve
collapse minyear18 rank_fertil n_fertil pct_fertil diff_fertil
rename minyear18 year
rename rank_fertil rank
rename n_fertil n
rename pct_fertil decile
rename diff_fertil deviation
gen variable=18
save "temp18.dta", replace
restore

preserve
collapse minyear19 rank_life n_life pct_life diff_life
rename minyear19 year
rename rank_life rank
rename n_life n
rename pct_life decile
rename diff_life deviation
gen variable=19
save "temp19.dta", replace
restore

preserve
collapse minyear20 rank_pop_g n_pop_g pct_pop_g diff_pop_g
rename minyear20 year
rename rank_pop_g rank
rename n_pop_g n
rename pct_pop_g decile
rename diff_pop_g deviation
gen variable=20
save "temp20.dta", replace
restore

preserve
collapse minyear21 rank_depend n_depend pct_depend diff_depend
rename minyear21 year
rename rank_depend rank
rename n_depend n
rename pct_depend decile
rename diff_depend deviation
gen variable=21
save "temp21.dta", replace
restore

preserve
collapse minyear22 rank_ctfp n_ctfp pct_ctfp diff_ctfp
rename minyear22 year
rename rank_ctfp rank
rename n_ctfp n
rename pct_ctfp decile
rename diff_ctfp deviation
gen variable=22
save "temp22.dta", replace
restore

preserve
collapse minyear23 rank_tax_gdp n_tax_gdp pct_tax_gdp diff_tax_gdp
rename minyear23 year
rename rank_tax_gdp rank
rename n_tax_gdp n
rename pct_tax_gdp decile
rename diff_tax_gdp deviation
gen variable=23
save "temp23.dta", replace
restore

preserve
collapse minyear24 rank_open n_open pct_open diff_open
rename minyear24 year
rename rank_open rank
rename n_open n
rename pct_open decile
rename diff_open deviation
gen variable=24
save "temp24.dta", replace
restore

preserve
collapse minyear25 rank_demo n_demo pct_demo diff_demo
rename minyear25 year
rename rank_demo rank
rename n_demo n
rename pct_demo decile
rename diff_demo deviation
gen variable=25
save "temp25.dta", replace
restore

preserve
collapse minyear26 rank_rule n_rule pct_rule diff_rule
rename minyear26 year
rename rank_rule rank
rename n_rule n
rename pct_rule decile
rename diff_rule deviation
gen variable=26
save "temp26.dta", replace
restore

preserve
collapse minyear27 rank_econ_freedom n_econ_freedom pct_econ_freedom diff_econ_freedom
rename minyear27 year
rename rank_econ_freedom rank
rename n_econ_freedom n
rename pct_econ_freedom decile
rename diff_econ_freedom deviation
gen variable=27
save "temp27.dta", replace
restore

preserve
collapse minyear28 rank_bus_freedom n_bus_freedom pct_bus_freedom diff_bus_freedom
rename minyear28 year
rename rank_bus_freedom rank
rename n_bus_freedom n
rename pct_bus_freedom decile
rename diff_bus_freedom deviation
gen variable=28
save "temp28.dta", replace
restore

preserve
collapse minyear29 rank_tech_exp n_tech_exp pct_tech_exp diff_tech_exp
rename minyear29 year
rename rank_tech_exp rank
rename n_tech_exp n
rename pct_tech_exp decile
rename diff_tech_exp deviation
gen variable=29
save "temp29.dta", replace
restore

preserve
collapse minyear30 rank_diversity_rca n_diversity_rca pct_diversity_rca diff_diversity_rca
rename minyear30 year
rename rank_diversity_rca rank
rename n_diversity_rca n
rename pct_diversity_rca decile
rename diff_diversity_rca deviation
gen variable=30
save "temp30.dta", replace
restore

preserve
collapse minyear31 rank_eci_rca n_eci_rca pct_eci_rca diff_eci_rca
rename minyear31 year
rename rank_eci_rca rank
rename n_eci_rca n
rename pct_eci_rca decile
rename diff_eci_rca deviation
gen variable=31
save "temp31.dta", replace
restore

preserve
collapse minyear32 rank_coi_rca n_coi_rca pct_coi_rca diff_coi_rca
rename minyear32 year
rename rank_coi_rca rank
rename n_coi_rca n
rename pct_coi_rca decile
rename diff_coi_rca deviation
gen variable=32
save "temp32.dta", replace
restore

use "temp1.dta", clear
forval x=2/32 {
	capture noisily append using "temp`x'.dta"
}

label def variable 1"Urbanization" 2"Share of agriculture in GDP" 3"Share of manufacturing in GDP" 4"Share of industry in GDP" 5"Share of services in GDP" /*
*/ 6"Agriculture employment" 7"Industry employment" 8"Services employment" 9"Energy consumption per capita" 10"Capital per worker" 11"Years of schooling" /*
*/ 12"Primary schooling" 13"Secondary schooling" 14"Tertiary schooling" 15"Scientific and Technical Journal Articles" 16"Researchers in R&D" /*
*/ 17"Infant mortality" 18"Fertility rate" 19"Life expectancy" 20"Population growth" 21"Demographic dividend" 22"Total Factor Productivity" /*
*/ 23"Government revenue" 24"Openness" 25"Democracy" 26"Rule of Law" 27"Economic Freedom" 28"Business Freedom" 29"High-technology exports per capita" /*
*/ 30"Diversity of exports" 31"Economic Complexity" 32"Complexity Outlook"
label val variable variable
order variable year
gen significant=0
replace significant=1 if deviation>1.0 | deviation<-1.0
label def significant 0"" 1"*"
label val significant significant
export excel using "$dir\table`ctry'2", firstrow(var) sheetreplace

*************************************************************************************
scalar drop _all
macro drop _all
erase "temp.dta"
forval x=1/32 {
	capture noisily erase "temp`x'.dta"
}
