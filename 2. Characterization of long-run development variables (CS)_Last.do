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
local ctry ESP
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
gen loggdppc=log(gdppc)
label var loggdppc "Log(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2
gen loggdppc2=log(gdppc2)
label var loggdppc "GDP per capita (constant 2005 US$), log"
label var loggdppc2 "GDP per capita, PPP (constant 2005 international $), log"
label var year "Years"

* Elimination of oil countries
/*
gen oilpc=(TX_VAL_FUEL_ZS_UN)*(TX_VAL_MRCH_CD_WT)/(100*SP_POP_TOTL)
rename TX_VAL_FUEL_ZS_UN oilexp
xtile rich=loggdppc2, n(100)
xtile oil=oilpc, n(100)
xtile oil2=oilexp, n(100)
gsort -year -loggdppc2 -oilpc -oilexp
tab country if rich>90 & oil>90 & oil2>90 & rich!=. & oil!=. & oil2!=.
br country wbcode year loggdppc2 oilpc oilexp rich oil oil2 if rich>90 & oil>90 & oil2>90 & rich!=. & oil!=. & oil2!=.
*/
drop if wbcode=="QAT" | wbcode=="KWT" | wbcode=="ARE" | wbcode=="OMN" | wbcode=="SAU" | wbcode=="BHR"

*********************************************
** STRUCTURAL TRANSFORMATION: URBANIZATION **
*********************************************
rename SP_URB_TOTL_IN_ZS urban_pop
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & urban_pop!=.
	scalar maxyear1=r(max)
	bys year: count if loggdppc2!=. & urban_pop!=.
	if r(N)>=100 {
		keep if year==`=maxyear1'
	}
	continue, break
}
scalar drop maxyear1
summ year if wbcode=="`ctry'" & loggdppc2!=. & urban_pop!=.
scalar maxyear1=r(max)
local maxyear1: display %9.0f maxyear1

drop if year!=`=maxyear1'

if `=maxyear1'!=. {
	* Statistics for Figure 1
	* Percentiles
	foreach x in urban_pop loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Urbanization, `=maxyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Urban population (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter urban_pop loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter urban_pop loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter urban_pop loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure1`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure1`ctry'_2A1.png") replace
	
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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & agr_gdp!=.
	scalar maxyear2=r(max)
	bys year: count if loggdppc2!=. & agr_gdp!=.
	if r(N)<100 {
		drop if year==`=maxyear2'
	}
	continue, break
}
scalar drop maxyear2
summ year if wbcode=="`ctry'" & loggdppc2!=. & agr_gdp!=.
scalar maxyear2=r(max)
local maxyear2: display %9.0f maxyear2

drop if year!=`=maxyear2'

if `=maxyear2'!=. {
	* Statistics for Figure 2
	* Percentiles
	foreach x in agr_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Share of agriculture in GDP, `=maxyear2'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Agriculture, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter agr_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter agr_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter agr_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure2`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure2`ctry'_2A1.png") append
	
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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & mnf_gdp!=.
	scalar maxyear3=r(max)
	bys year: count if loggdppc2!=. & mnf_gdp!=.
	if r(N)<100 {
		drop if year==`=maxyear3'
	}
	continue, break
}
scalar drop maxyear3
summ year if wbcode=="`ctry'" & loggdppc2!=. & mnf_gdp!=.
scalar maxyear3=r(max)
local maxyear3: display %9.0f maxyear3

drop if year!=`=maxyear3'

if `=maxyear3'!=. {
	* Statistics for Figure 3
	* Percentiles
	foreach x in mnf_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Share of manufacturing in GDP, `=maxyear3'") subtitle("`j'") note("Note: Manufacturing corresponds to ISIC Rev.3 divisions 15-37" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Manufacturing, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter mnf_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter mnf_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter mnf_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure3`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure3`ctry'_2A1.png") append
	
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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & ind_gdp!=.
	scalar maxyear4=r(max)
	bys year: count if loggdppc2!=. & ind_gdp!=.
	if r(N)<100 {
		drop if year==`=maxyear4'
	}
	continue, break
}
scalar drop maxyear4
summ year if wbcode=="`ctry'" & loggdppc2!=. & ind_gdp!=.
scalar maxyear4=r(max)
local maxyear4: display %9.0f maxyear4

drop if year!=`=maxyear4'

if `=maxyear4'!=. {
	* Statistics for Figure 4
	* Percentiles
	foreach x in ind_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Share of industry in GDP, `=maxyear4'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Industry, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ind_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ind_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ind_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure4`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure4`ctry'_2A1.png") append
	
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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & ss_gdp!=.
	scalar maxyear5=r(max)
	bys year: count if loggdppc2!=. & ss_gdp!=.
	if r(N)<100 {
		drop if year==`=maxyear5'
	}
	continue, break
}
scalar drop maxyear5
summ year if wbcode=="`ctry'" & loggdppc2!=. & ss_gdp!=.
scalar maxyear5=r(max)
local maxyear5: display %9.0f maxyear5

drop if year!=`=maxyear4'

if `=maxyear4'!=. {
	* Statistics for Figure 4
	* Percentiles
	foreach x in ss_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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

	* Figure 5: Services as % of GDP (vs World)
	lpoly ss_gdp loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y5'(1)`=max_y5')) ysc(range(`=min_x5'(1)`=max_x5')) /*
	*/ title("Share of services in GDP, `=maxyear5'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Services, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ss_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ss_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ss_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure5`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure5`ctry'_2A1.png") append
	
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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & emp_agr!=.
	scalar maxyear6=r(max)
	bys year: count if loggdppc2!=. & emp_agr!=.
	if r(N)<100 {
		drop if year==`=maxyear6'
	}
	continue, break
}
scalar drop maxyear6
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_agr!=.
scalar maxyear6=r(max)
local maxyear6: display %9.0f maxyear6

drop if year!=`=maxyear6'

if `=maxyear6'!=. {
	* Statistics for Figure 6
	* Percentiles
	foreach x in emp_agr loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Agriculture employment, `=maxyear6'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in agriculture (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_agr loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_agr loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_agr loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure6`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure6`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & emp_ind!=.
	scalar maxyear7=r(max)
	bys year: count if loggdppc2!=. & emp_ind!=.
	if r(N)<100 {
		drop if year==`=maxyear7'
	}
	continue, break
}
scalar drop maxyear7
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ind!=.
scalar maxyear7=r(max)
local maxyear7: display %9.0f maxyear7

drop if year!=`=maxyear7'

if `=maxyear7'!=. {
	* Statistics for Figure 7
	* Percentiles
	foreach x in emp_ind loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Industry employment, `=maxyear7'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in industry (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ind loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ind loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ind loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure7`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure7`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & emp_ss!=.
	scalar maxyear8=r(max)
	bys year: count if loggdppc2!=. & emp_ss!=.
	if r(N)<100 {
		drop if year==`=maxyear8'
	}
	continue, break
}
scalar drop maxyear8
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ss!=.
scalar maxyear8=r(max)
local maxyear8: display %9.0f maxyear8

drop if year!=`=maxyear8'

if `=maxyear8'!=. {
	* Statistics for Figure 8
	* Percentiles
	foreach x in emp_ss loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Services employment, `=maxyear8'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in services (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ss loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ss loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ss loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure8`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure8`ctry'_2A1.png") append

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
gen logenergypc=log(energypc)
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & logenergypc!=.
	scalar maxyear9=r(max)
	bys year: count if loggdppc2!=. & logenergypc!=.
	if r(N)<100 {
		drop if year==`=maxyear9'
	}
	continue, break
}
scalar drop maxyear9
summ year if wbcode=="`ctry'" & loggdppc2!=. & logenergypc!=.
scalar maxyear9=r(max)
local maxyear9: display %9.0f maxyear9

drop if year!=`=maxyear9'

if `=maxyear9'!=. {
	* Statistics for Figure 9
	* Percentiles
	foreach x in logenergypc loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Energy consumption per capita, `=maxyear9'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Energy use (kg of oil equivalent per capita), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter logenergypc loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter logenergypc loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter logenergypc loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure9`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure9`ctry'_2A1.png") append

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
gen kpw=log(ck*1000000/SL_TLF_TOTL_IN)

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & kpw!=.
	scalar maxyear10=r(max)
	bys year: count if loggdppc2!=. & kpw!=.
	if r(N)<100 {
		drop if year==`=maxyear10'
	}
	continue, break
}
scalar drop maxyear10
summ year if wbcode=="`ctry'" & loggdppc2!=. & kpw!=.
scalar maxyear10=r(max)
local maxyear10: display %9.0f maxyear10

drop if year!=`=maxyear10'

if `=maxyear10'!=. {
	* Statistics for Figure 10
	* Percentiles
	foreach x in kpw loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Capital per worker, `=maxyear10'") subtitle("`j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("Capital stock/labor force" "(at current PPP 2005 US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter kpw loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter kpw loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter kpw loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure10`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure10`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & school!=.
	scalar maxyear11=r(max)
	bys year: count if loggdppc2!=. & school!=.
	if r(N)<100 {
		drop if year==`=maxyear11'
	}
	continue, break
}
scalar drop maxyear11
summ year if wbcode=="`ctry'" & loggdppc2!=. & school!=.
scalar maxyear11=r(max)
local maxyear11: display %9.0f maxyear11

drop if year!=`=maxyear11'

if `=maxyear11'!=. {
	* Statistics for Figure 11
	* Percentiles
	foreach x in school loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Years of schooling, `=maxyear11'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Years of schooling") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter school loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter school loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter school loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure11`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure11`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & prim!=.
	scalar maxyear12=r(max)
	bys year: count if loggdppc2!=. & prim!=.
	if r(N)<100 {
		drop if year==`=maxyear12'
	}
	continue, break
}
scalar drop maxyear12
summ year if wbcode=="`ctry'" & loggdppc2!=. & prim!=.
scalar maxyear12=r(max)
local maxyear12: display %9.0f maxyear12

drop if year!=`=maxyear12'

if `=maxyear12'!=. {
	* Statistics for Figure 12
	* Percentiles
	foreach x in prim loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	lpoly prim loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y12'(1)`=max_y12')) ysc(range(`=min_x12'(1)`=max_x12')) /*
	*/ title("Primary schooling, `=maxyear12'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Primary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter prim loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter prim loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter prim loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure12`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure12`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & sec!=.
	scalar maxyear13=r(max)
	bys year: count if loggdppc2!=. & sec!=.
	if r(N)<100 {
		drop if year==`=maxyear13'
	}
	continue, break
}
scalar drop maxyear13
summ year if wbcode=="`ctry'" & loggdppc2!=. & sec!=.
scalar maxyear13=r(max)
local maxyear13: display %9.0f maxyear13

drop if year!=`=maxyear13'

if `=maxyear13'!=. {
	* Statistics for Figure 13
	* Percentiles
	foreach x in sec loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	lpoly sec loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y13'(1)`=max_y13')) ysc(range(`=min_x13'(1)`=max_x13')) /*
	*/ title("Secondary schooling, `=maxyear13'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Secondary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter sec loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter sec loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter sec loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure13`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure13`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & univ!=.
	scalar maxyear14=r(max)
	bys year: count if loggdppc2!=. & univ!=.
	if r(N)<100 {
		drop if year==`=maxyear14'
	}
	continue, break
}
scalar drop maxyear14
summ year if wbcode=="`ctry'" & loggdppc2!=. & univ!=.
scalar maxyear14=r(max)
local maxyear14: display %9.0f maxyear14

drop if year!=`=maxyear14'

if `=maxyear14'!=. {
	* Statistics for Figure 14
	* Percentiles
	foreach x in univ loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	lpoly univ loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y14'(1)`=max_y14')) ysc(range(`=min_x14'(1)`=max_x14')) /*
	*/ title("Tertiary schooling, `=maxyear14'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Tertiary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter univ loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter univ loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter univ loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure14`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure14`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & journal!=.
	scalar maxyear15=r(max)
	bys year: count if loggdppc2!=. & journal!=.
	if r(N)<100 {
		drop if year==`=maxyear15'
	}
	continue, break
}
scalar drop maxyear15
summ year if wbcode=="`ctry'" & loggdppc2!=. & journal!=.
scalar maxyear15=r(max)
local maxyear15: display %9.0f maxyear15

drop if year!=`=maxyear15'

if `=maxyear15'!=. {
	* Statistics for Figure 15
	* Percentiles
	foreach x in journal loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Scientific and Technical Journal Articles, `=maxyear15'") subtitle("Per 1,000 people, `j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Scientific and technical journal articles per 1,000 people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter journal loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter journal loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter journal loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure15`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure15`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & research!=.
	scalar maxyear16=r(max)
	bys year: count if loggdppc2!=. & research!=.
	if r(N)<100 {
		drop if year==`=maxyear16'
	}
	continue, break
}
scalar drop maxyear16
summ year if wbcode=="`ctry'" & loggdppc2!=. & research!=.
scalar maxyear16=r(max)
local maxyear16: display %9.0f maxyear16

drop if year!=`=maxyear16'

if `=maxyear16'!=. {
	* Statistics for Figure 16
	* Percentiles
	foreach x in research loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	lpoly research loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.1fc)) xsc(range(`=min_y16'(1)`=max_y16')) /*
	*/ title("Researchers in R&D, `=maxyear16'") subtitle("Per million people, `j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Researchers in R&D per million people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter research loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter research loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter research loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure16`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure16`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & infant!=.
	scalar maxyear17=r(max)
	bys year: count if loggdppc2!=. & infant!=.
	if r(N)<100 {
		drop if year==`=maxyear17'
	}
	continue, break
}
scalar drop maxyear17
summ year if wbcode=="`ctry'" & loggdppc2!=. & infant!=.
scalar maxyear17=r(max)
local maxyear17: display %9.0f maxyear17

drop if year!=`=maxyear17'

if `=maxyear17'!=. {
	* Statistics for Figure 17
	* Percentiles
	foreach x in infant loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Infant mortality, `=maxyear17'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Mortality rate, infant (per 1,000 live births)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter infant loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter infant loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter infant loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure17`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure17`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & fertil!=.
	scalar maxyear18=r(max)
	bys year: count if loggdppc2!=. & fertil!=.
	if r(N)<100 {
		drop if year==`=maxyear18'
	}
	continue, break
}
scalar drop maxyear18
summ year if wbcode=="`ctry'" & loggdppc2!=. & fertil!=.
scalar maxyear18=r(max)
local maxyear18: display %9.0f maxyear18

drop if year!=`=maxyear18'

if `=maxyear18'!=. {
	* Statistics for Figure 18
	* Percentiles
	foreach x in fertil loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Fertility rate, `=maxyear18'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Fertility rate, total (births per woman)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter fertil loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter fertil loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter fertil loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure18`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure18`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & life!=.
	scalar maxyear19=r(max)
	bys year: count if loggdppc2!=. & life!=.
	if r(N)<100 {
		drop if year==`=maxyear19'
	}
	continue, break
}
scalar drop maxyear19
summ year if wbcode=="`ctry'" & loggdppc2!=. & life!=.
scalar maxyear19=r(max)
local maxyear19: display %9.0f maxyear19

drop if year!=`=maxyear19'

if `=maxyear19'!=. {
	* Statistics for Figure 19
	* Percentiles
	foreach x in life loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Life expectancy, `=maxyear19'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Life expectancy at birth, total (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter life loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter life loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter life loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure19`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure19`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & pop_g!=.
	scalar maxyear20=r(max)
	bys year: count if loggdppc2!=. & pop_g!=.
	if r(N)<100 {
		drop if year==`=maxyear20'
	}
	continue, break
}
scalar drop maxyear20
summ year if wbcode=="`ctry'" & loggdppc2!=. & pop_g!=.
scalar maxyear20=r(max)
local maxyear20: display %9.0f maxyear20

drop if year!=`=maxyear20'

if `=maxyear20'!=. {
	* Statistics for Figure 20
	* Percentiles
	foreach x in pop_g loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Population growth, `=maxyear20'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Population growth (annual %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter pop_g loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter pop_g loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter pop_g loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure20`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure20`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & depend!=.
	scalar maxyear21=r(max)
	bys year: count if loggdppc2!=. & depend!=.
	if r(N)<100 {
		drop if year==`=maxyear21'
	}
	continue, break
}
scalar drop maxyear21
summ year if wbcode=="`ctry'" & loggdppc2!=. & depend!=.
scalar maxyear21=r(max)
local maxyear21: display %9.0f maxyear21

drop if year!=`=maxyear21'

if `=maxyear21'!=. {
	* Statistics for Figure 21
	* Percentiles
	foreach x in depend loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Demographic dividend, `=maxyear21'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Age dependency ratio (% of working-age population)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter depend loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter depend loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter depend loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure21`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure21`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & ctfp!=.
	scalar maxyear22=r(max)
	bys year: count if loggdppc2!=. & ctfp!=.
	if r(N)<100 {
		drop if year==`=maxyear22'
	}
	continue, break
}
scalar drop maxyear22
summ year if wbcode=="`ctry'" & loggdppc2!=. & ctfp!=.
scalar maxyear22=r(max)
local maxyear22: display %9.0f maxyear22

drop if year!=`=maxyear22'

if `=maxyear22'!=. {
	* Statistics for Figure 22
	* Percentiles
	foreach x in ctfp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Total Factor Productivity, `=maxyear22'") subtitle("Relative to USA, `j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("TFP level at current PPPs (USA=1)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ctfp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ctfp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ctfp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure22`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure22`ctry'_2A1.png") append

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

* Maximum years
forval x=2012(-1)1980 {
	summ year if loggdppc2!=. & tax_gdp!=.
	scalar maxyear23=r(max)
	bys year: count if loggdppc2!=. & tax_gdp!=.
	if r(N)<100 {
		drop if year==`=maxyear23'
	}
	continue, break
}
scalar drop maxyear23
summ year if wbcode=="`ctry'" & loggdppc2!=. & tax_gdp!=.
scalar maxyear23=r(max)
local maxyear23: display %9.0f maxyear23

drop if year!=`=maxyear23'

if `=maxyear23'!=. {
	* Statistics for Figure 23
	* Percentiles
	foreach x in tax_gdp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Government revenue, `=maxyear23'") subtitle("`j'") note("Data source: World Economic Outlook and World Development Indicators") /*
	*/ ytitle("General government revenue (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tax_gdp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tax_gdp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tax_gdp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure23`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure23`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & open!=.
	scalar maxyear24=r(max)
	bys year: count if loggdppc2!=. & open!=.
	if r(N)<100 {
		drop if year==`=maxyear24'
	}
	continue, break
}
scalar drop maxyear24
summ year if wbcode=="`ctry'" & loggdppc2!=. & open!=.
scalar maxyear24=r(max)
local maxyear24: display %9.0f maxyear24

drop if year!=`=maxyear24'

if `=maxyear24'!=. {
	* Statistics for Figure 24
	* Percentiles
	foreach x in open loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Openness, `=maxyear24'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Exports + Imports of goods and services (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter open loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter open loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter open loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure24`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure24`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & demo!=.
	scalar maxyear25=r(max)
	bys year: count if loggdppc2!=. & demo!=.
	if r(N)<100 {
		drop if year==`=maxyear25'
	}
	continue, break
}
scalar drop maxyear25
summ year if wbcode=="`ctry'" & loggdppc2!=. & demo!=.
scalar maxyear25=r(max)
local maxyear25: display %9.0f maxyear25

drop if year!=`=maxyear25'

if `=maxyear25'!=. {
	* Statistics for Figure 25
	* Percentiles
	foreach x in demo loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Democracy, `=maxyear25'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House/Polity) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Democracy (Freedom House/Imputed Polity)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter demo loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter demo loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter demo loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure25`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure25`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & rule!=.
	scalar maxyear26=r(max)
	bys year: count if loggdppc2!=. & rule!=.
	if r(N)<100 {
		drop if year==`=maxyear26'
	}
	continue, break
}
scalar drop maxyear26
summ year if wbcode=="`ctry'" & loggdppc2!=. & rule!=.
scalar maxyear26=r(max)
local maxyear26: display %9.0f maxyear26

drop if year!=`=maxyear26'

if `=maxyear26'!=. {
	* Statistics for Figure 26
	* Percentiles
	foreach x in rule loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Rule of Law, `=maxyear26'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Rule of Law") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter rule loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter rule loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter rule loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure26`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure26`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & econ_freedom!=.
	scalar maxyear27=r(max)
	bys year: count if loggdppc2!=. & econ_freedom!=.
	if r(N)<100 {
		drop if year==`=maxyear27'
	}
	continue, break
}
scalar drop maxyear27
summ year if wbcode=="`ctry'" & loggdppc2!=. & econ_freedom!=.
scalar maxyear27=r(max)
local maxyear27: display %9.0f maxyear27

drop if year!=`=maxyear27'

if `=maxyear27'!=. {
	* Statistics for Figure 27
	* Percentiles
	foreach x in econ_freedom loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Economic Freedom, `=maxyear27'") subtitle("`j'") note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
	*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Economic Freedom Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter econ_freedom loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter econ_freedom loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter econ_freedom loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure27`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure27`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & bus_freedom!=.
	scalar maxyear28=r(max)
	bys year: count if loggdppc2!=. & bus_freedom!=.
	if r(N)<100 {
		drop if year==`=maxyear28'
	}
	continue, break
}
scalar drop maxyear28
summ year if wbcode=="`ctry'" & loggdppc2!=. & bus_freedom!=.
scalar maxyear28=r(max)
local maxyear28: display %9.0f maxyear28

drop if year!=`=maxyear28'

if `=maxyear28'!=. {
	* Statistics for Figure 28
	* Percentiles
	foreach x in bus_freedom loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Business Freedom, `=maxyear28'") subtitle("`j'") note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
	*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
	*/ "and closing a business (time, cost, and recovery rate)" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Business Freedom score") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter bus_freedom loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter bus_freedom loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter bus_freedom loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure28`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure28`ctry'_2A1.png") append

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
gen tech_exp=log(TX_VAL_TECH_CD/SP_POP_TOTL)
preserve

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & tech_exp!=.
	scalar maxyear29=r(max)
	bys year: count if loggdppc2!=. & tech_exp!=.
	if r(N)>=100 {
		keep if year==`=maxyear29'
	}
	continue, break
}
scalar drop maxyear29
summ year if wbcode=="`ctry'" & loggdppc2!=. & tech_exp!=.
scalar maxyear29=r(max)
local maxyear29: display %9.0f maxyear29

drop if year!=`=maxyear29'

if `=maxyear29'!=. {
	* Statistics for Figure 29
	* Percentiles
	foreach x in tech_exp loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("High-technology exports per capita, `=maxyear29'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("High-technology exports per capita (current US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tech_exp loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tech_exp loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tech_exp loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure29`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure29`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & diversity_rca!=.
	scalar maxyear30=r(max)
	bys year: count if loggdppc2!=. & diversity_rca!=.
	if r(N)>=100 {
		keep if year==`=maxyear30'
	}
	continue, break
}
scalar drop maxyear30
summ year if wbcode=="`ctry'" & loggdppc2!=. & diversity_rca!=.
scalar maxyear30=r(max)
local maxyear30: display %9.0f maxyear30

drop if year!=`=maxyear30'

if `=maxyear30'!=. {
	* Statistics for Figure 30
	* Percentiles
	foreach x in diversity_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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

	* Figure 30: Diversity of exports (vs World)
	lpoly diversity_rca loggdppc2, ci at(loggdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y30'(1)`=max_y30')) ysc(range(`=min_x30'(100)`=max_x30')) /*
	*/ title("Diversity of exports, `=maxyear30'") subtitle("`j'") note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
	*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database") /*
	*/ ytitle("Number of products exported with RCA") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter diversity_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter diversity_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter diversity_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure30`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure30`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & eci_rca!=.
	scalar maxyear31=r(max)
	bys year: count if loggdppc2!=. & eci_rca!=.
	if r(N)>=100 {
		keep if year==`=maxyear31'
	}
	continue, break
}
scalar drop maxyear31
summ year if wbcode=="`ctry'" & loggdppc2!=. & eci_rca!=.
scalar maxyear31=r(max)
local maxyear31: display %9.0f maxyear31

drop if year!=`=maxyear31'

if `=maxyear31'!=. {
	* Statistics for Figure 31
	* Percentiles
	foreach x in eci_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Economic Complexity, `=maxyear31'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Economic Complexity Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter eci_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter eci_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter eci_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure31`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure31`ctry'_2A1.png") append

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

* Maximum years
forval x=2013(-1)1960 {
	summ year if loggdppc2!=. & coi_rca!=.
	scalar maxyear32=r(max)
	bys year: count if loggdppc2!=. & coi_rca!=.
	if r(N)>=100 {
		keep if year==`=maxyear32'
	}
	continue, break
}
scalar drop maxyear32
summ year if wbcode=="`ctry'" & loggdppc2!=. & coi_rca!=.
scalar maxyear32=r(max)
local maxyear32: display %9.0f maxyear32

drop if year!=`=maxyear32'

if `=maxyear32'!=. {
	* Statistics for Figure 32
	* Percentiles
	foreach x in coi_rca loggdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
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
	*/ title("Complexity Outlook, `=maxyear32'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Complexity Outlook Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter coi_rca loggdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter coi_rca loggdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter coi_rca loggdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure32`ctry'_2A1.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A1.doc", g("$dir\figure32`ctry'_2A1.png") append

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
	capture noisily gen maxyear`x'=`=maxyear`x''
}

preserve
collapse maxyear1 rank_urban_pop n_urban_pop pct_urban_pop diff_urban_pop
rename maxyear1 year
rename rank_urban_pop rank
rename n_urban_pop n
rename pct_urban_pop percentile
rename diff_urban_pop deviation
gen variable=1
save "temp1.dta", replace
restore

preserve
collapse maxyear2 rank_agr_gdp n_agr_gdp pct_agr_gdp diff_agr_gdp
rename maxyear2 year
rename rank_agr_gdp rank
rename n_agr_gdp n
rename pct_agr_gdp percentile
rename diff_agr_gdp deviation
gen variable=2
save "temp2.dta", replace
restore

preserve
collapse maxyear3 rank_mnf_gdp n_mnf_gdp pct_mnf_gdp diff_mnf_gdp
rename maxyear3 year
rename rank_mnf_gdp rank
rename n_mnf_gdp n
rename pct_mnf_gdp percentile
rename diff_mnf_gdp deviation
gen variable=3
save "temp3.dta", replace
restore

preserve
collapse maxyear4 rank_ind_gdp n_ind_gdp pct_ind_gdp diff_ind_gdp
rename maxyear4 year
rename rank_ind_gdp rank
rename n_ind_gdp n
rename pct_ind_gdp percentile
rename diff_ind_gdp deviation
gen variable=4
save "temp4.dta", replace
restore

preserve
collapse maxyear5 rank_ss_gdp n_ss_gdp pct_ss_gdp diff_ss_gdp
rename maxyear5 year
rename rank_ss_gdp rank
rename n_ss_gdp n
rename pct_ss_gdp percentile
rename diff_ss_gdp deviation
gen variable=5
save "temp5.dta", replace
restore

preserve
collapse maxyear6 rank_emp_agr n_emp_agr pct_emp_agr diff_emp_agr
rename maxyear6 year
rename rank_emp_agr rank
rename n_emp_agr n
rename pct_emp_agr percentile
rename diff_emp_agr deviation
gen variable=6
save "temp6.dta", replace
restore

preserve
collapse maxyear7 rank_emp_ind n_emp_ind pct_emp_ind diff_emp_ind
rename maxyear7 year
rename rank_emp_ind rank
rename n_emp_ind n
rename pct_emp_ind percentile
rename diff_emp_ind deviation
gen variable=7
save "temp7.dta", replace
restore

preserve
collapse maxyear8 rank_emp_ss n_emp_ss pct_emp_ss diff_emp_ss
rename maxyear8 year
rename rank_emp_ss rank
rename n_emp_s n
rename pct_emp_ss percentile
rename diff_emp_ss deviation
gen variable=8
save "temp8.dta", replace
restore

preserve
collapse maxyear9 rank_logenergypc n_logenergypc pct_logenergypc diff_logenergypc
rename maxyear9 year
rename rank_logenergypc rank
rename n_logenergypc n
rename pct_logenergypc percentile
rename diff_logenergypc deviation
gen variable=9
save "temp9.dta", replace
restore

preserve
collapse maxyear10 rank_kpw n_kpw pct_kpw diff_kpw
rename maxyear10 year
rename rank_kpw rank
rename n_kpw n
rename pct_kpw percentile
rename diff_kpw deviation
gen variable=10
save "temp10.dta", replace
restore

preserve
collapse maxyear11 rank_school n_school pct_school diff_school
rename maxyear11 year
rename rank_school rank
rename n_school n
rename pct_school percentile
rename diff_school deviation
gen variable=11
save "temp11.dta", replace
restore

preserve
collapse maxyear12 rank_prim n_prim pct_prim diff_prim
rename maxyear12 year
rename rank_prim rank
rename n_prim n
rename pct_prim percentile
rename diff_prim deviation
gen variable=12
save "temp12.dta", replace
restore

preserve
collapse maxyear13 rank_sec n_sec pct_sec diff_sec
rename maxyear13 year
rename rank_sec rank
rename n_sec n
rename pct_sec percentile
rename diff_sec deviation
gen variable=13
save "temp13.dta", replace
restore

preserve
collapse maxyear14 rank_univ n_univ pct_univ diff_univ
rename maxyear14 year
rename rank_univ rank
rename n_univ n
rename pct_univ percentile
rename diff_univ deviation
gen variable=14
save "temp14.dta", replace
restore

preserve
collapse maxyear15 rank_journal n_journal pct_journal diff_journal
rename maxyear15 year
rename rank_journal rank
rename n_journal n
rename pct_journal percentile
rename diff_journal deviation
gen variable=15
save "temp15.dta", replace
restore

preserve
capture noisily {
collapse maxyear16 rank_research n_research pct_research diff_research
rename maxyear16 year
rename rank_research rank
rename n_research n
rename pct_research percentile
rename diff_research deviation
gen variable=16
save "temp16.dta", replace
}
restore

preserve
collapse maxyear17 rank_infant n_infant pct_infant diff_infant
rename maxyear17 year
rename rank_infant rank
rename n_infant n
rename pct_infant percentile
rename diff_infant deviation
gen variable=17
save "temp17.dta", replace
restore

preserve
collapse maxyear18 rank_fertil n_fertil pct_fertil diff_fertil
rename maxyear18 year
rename rank_fertil rank
rename n_fertil n
rename pct_fertil percentile
rename diff_fertil deviation
gen variable=18
save "temp18.dta", replace
restore

preserve
collapse maxyear19 rank_life n_life pct_life diff_life
rename maxyear19 year
rename rank_life rank
rename n_life n
rename pct_life percentile
rename diff_life deviation
gen variable=19
save "temp19.dta", replace
restore

preserve
collapse maxyear20 rank_pop_g n_pop_g pct_pop_g diff_pop_g
rename maxyear20 year
rename rank_pop_g rank
rename n_pop_g n
rename pct_pop_g percentile
rename diff_pop_g deviation
gen variable=20
save "temp20.dta", replace
restore

preserve
collapse maxyear21 rank_depend n_depend pct_depend diff_depend
rename maxyear21 year
rename rank_depend rank
rename n_depend n
rename pct_depend percentile
rename diff_depend deviation
gen variable=21
save "temp21.dta", replace
restore

preserve
collapse maxyear22 rank_ctfp n_ctfp pct_ctfp diff_ctfp
rename maxyear22 year
rename rank_ctfp rank
rename n_ctfp n
rename pct_ctfp percentile
rename diff_ctfp deviation
gen variable=22
save "temp22.dta", replace
restore

preserve
collapse maxyear23 rank_tax_gdp n_tax_gdp pct_tax_gdp diff_tax_gdp
rename maxyear23 year
rename rank_tax_gdp rank
rename n_tax_gdp n
rename pct_tax_gdp percentile
rename diff_tax_gdp deviation
gen variable=23
save "temp23.dta", replace
restore

preserve
collapse maxyear24 rank_open n_open pct_open diff_open
rename maxyear24 year
rename rank_open rank
rename n_open n
rename pct_open percentile
rename diff_open deviation
gen variable=24
save "temp24.dta", replace
restore

preserve
collapse maxyear25 rank_demo n_demo pct_demo diff_demo
rename maxyear25 year
rename rank_demo rank
rename n_demo n
rename pct_demo percentile
rename diff_demo deviation
gen variable=25
save "temp25.dta", replace
restore

preserve
collapse maxyear26 rank_rule n_rule pct_rule diff_rule
rename maxyear26 year
rename rank_rule rank
rename n_rule n
rename pct_rule percentile
rename diff_rule deviation
gen variable=26
save "temp26.dta", replace
restore

preserve
collapse maxyear27 rank_econ_freedom n_econ_freedom pct_econ_freedom diff_econ_freedom
rename maxyear27 year
rename rank_econ_freedom rank
rename n_econ_freedom n
rename pct_econ_freedom percentile
rename diff_econ_freedom deviation
gen variable=27
save "temp27.dta", replace
restore

preserve
collapse maxyear28 rank_bus_freedom n_bus_freedom pct_bus_freedom diff_bus_freedom
rename maxyear28 year
rename rank_bus_freedom rank
rename n_bus_freedom n
rename pct_bus_freedom percentile
rename diff_bus_freedom deviation
gen variable=28
save "temp28.dta", replace
restore

preserve
collapse maxyear29 rank_tech_exp n_tech_exp pct_tech_exp diff_tech_exp
rename maxyear29 year
rename rank_tech_exp rank
rename n_tech_exp n
rename pct_tech_exp percentile
rename diff_tech_exp deviation
gen variable=29
save "temp29.dta", replace
restore

preserve
collapse maxyear30 rank_diversity_rca n_diversity_rca pct_diversity_rca diff_diversity_rca
rename maxyear30 year
rename rank_diversity_rca rank
rename n_diversity_rca n
rename pct_diversity_rca percentile
rename diff_diversity_rca deviation
gen variable=30
save "temp30.dta", replace
restore

preserve
collapse maxyear31 rank_eci_rca n_eci_rca pct_eci_rca diff_eci_rca
rename maxyear31 year
rename rank_eci_rca rank
rename n_eci_rca n
rename pct_eci_rca percentile
rename diff_eci_rca deviation
gen variable=31
save "temp31.dta", replace
restore

preserve
collapse maxyear32 rank_coi_rca n_coi_rca pct_coi_rca diff_coi_rca
rename maxyear32 year
rename rank_coi_rca rank
rename n_coi_rca n
rename pct_coi_rca percentile
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
export excel using "$dir\table`ctry'1", firstrow(var) sheetreplace

*************************************************************************************
scalar drop _all
macro drop _all
erase "temp.dta"
forval x=1/32 {
	capture noisily erase "temp`x'.dta"
}
