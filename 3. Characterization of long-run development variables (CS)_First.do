clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* ORIGINAL DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata"
* ORIGINAL DATABASES
use "wdi2013.dta", clear
* OTHER DATABASES:
	* EDUCATION
	global education "BL2013_MF2599_v1.3.dta"
	* PHYSICAL CAPITAL
	global capital "C:\Users\Luis Miguel\Documents\Bases de Datos\Penn World Tables\pwt80\pwt80.dta"
	* TAX REVENUE
	global revenue "C:\Users\Luis Miguel\Documents\Bases de Datos\IMF\taxrevenue.dta"
	* INSTITUTIONS
	global institutions "C:\Users\Luis Miguel\Documents\Bases de Datos\The Quality of Government Institute\Standard data\qog_std_ts_20dec13.dta"
	* COMPLEXITY
	global complexity "C:\Users\Luis Miguel\Documents\Bases de Datos\CID - Harvard\complexity_y_c.dta"
* COUNTRY TO BE ANALYZED
local ctry IRL
levelsof country if wbcode=="`ctry'", local(j) clean
* RESULTS
cd "C:\Users\Luis Miguel\Dropbox\CID Research Assistantship\Automatization Growth Diagnostics\Results"
capture mkdir "`ctry'"
global dir "C:\Users\Luis Miguel\Dropbox\CID Research Assistantship\Automatization Growth Diagnostics\Results\\`ctry'"
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
gen lngdppc=ln(gdppc)
label var lngdppc "Ln(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2
gen lngdppc2=ln(gdppc2)
label var lngdppc "GDP per capita (constant 2005 US$), log"
label var lngdppc2 "GDP per capita, PPP (constant 2005 international $), log"
label var year "Years"


*********************************************
** STRUCTURAL TRANSFORMATION: URBANIZATION **
*********************************************
rename SP_URB_TOTL_IN_ZS urban_pop
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & urban_pop!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & urban_pop!=.
scalar minyear1=r(min)
local minyear1: display %9.0f minyear1

drop if year!=`=minyear1'

if `=minyear1'!=. {
	* Statistics for Figure 1
	* Percentiles
	foreach x in urban_pop lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}
	* Ranks
	foreach x in urban_pop lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | urban_pop==.
	summ lngdppc2
	scalar min_y1=r(min)
	scalar max_y1=r(max)
	summ urban_pop
	scalar min_x1=r(min)
	scalar max_x1=r(max)

	* Figure 1: Urban population as % of total (vs World)
	lpoly urban_pop lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y1'(1)`=max_y1')) ysc(range(`=min_x1'(1)`=max_x1')) /*
	*/ title("Urbanization, `=minyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Urban population (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter urban_pop lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter urban_pop lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter urban_pop lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
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
	count if lngdppc2!=. & year==`x' & agr_gdp!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & agr_gdp!=.
scalar minyear2=r(min)
local minyear2: display %9.0f minyear2

drop if year!=`=minyear2'

if `=minyear2'!=. {
	* Statistics for Figure 2
	* Percentiles
	foreach x in agr_gdp lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in agr_gdp lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | agr_gdp==.
	summ lngdppc2
	scalar min_y2=r(min)
	scalar max_y2=r(max)
	summ agr_gdp
	scalar min_x2=r(min)
	scalar max_x2=r(max)

	* Figure 2: Agriculture as % of GDP (vs World)
	lpoly agr_gdp lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y2'(1)`=max_y2')) ysc(range(`=min_x2'(1)`=max_x2')) /*
	*/ title("Share of agriculture in GDP, `=minyear2'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Agriculture, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter agr_gdp lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter agr_gdp lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter agr_gdp lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

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
	count if lngdppc2!=. & year==`x' & mnf_gdp!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & mnf_gdp!=.
scalar minyear3=r(min)
local minyear3: display %9.0f minyear3

drop if year!=`=minyear3'

if `=minyear3'!=. {
	* Statistics for Figure 3
	* Percentiles
	foreach x in mnf_gdp lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in mnf_gdp lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | mnf_gdp==.
	summ lngdppc2
	scalar min_y3=r(min)
	scalar max_y3=r(max)
	summ mnf_gdp
	scalar min_x3=r(min)
	scalar max_x3=r(max)

	* Figure 3: Manufacturing as % of GDP (vs World)
	lpoly mnf_gdp lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y3'(1)`=max_y3')) ysc(range(`=min_x3'(1)`=max_x3')) /*
	*/ title("Share of manufacturing in GDP, `=minyear3'") subtitle("`j'") note("Note: Manufacturing refers to industries belonging to ISIC Rev.3 divisions 15-37" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Manufacturing, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter mnf_gdp lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter mnf_gdp lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter mnf_gdp lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
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

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN INDUSTRY **
*******************************************************
rename SL_IND_EMPL_ZS emp_ind
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & emp_ind!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & emp_ind!=.
scalar minyear4=r(min)
local minyear4: display %9.0f minyear4

drop if year!=`=minyear4'

if `=minyear4'!=. {
	* Statistics for Figure 4
	* Percentiles
	foreach x in emp_ind lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in emp_ind lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | emp_ind==.
	summ lngdppc2
	scalar min_y4=r(min)
	scalar max_y4=r(max)
	summ emp_ind
	scalar min_x4=r(min)
	scalar max_x4=r(max)

	* Figure 4: Employment in industry (vs World)
	lpoly emp_ind lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y4'(1)`=max_y4')) ysc(range(`=min_x4'(1)`=max_x4')) /*
	*/ title("Industry employment, `=minyear4'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in industry (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ind lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ind lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ind lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure4`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure4`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & emp_ss!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & emp_ss!=.
scalar minyear5=r(min)
local minyear5: display %9.0f minyear5

drop if year!=`=minyear5'

if `=minyear5'!=. {
	* Statistics for Figure 5
	* Percentiles
	foreach x in emp_ss lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in emp_ss lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | emp_ss==.
	summ lngdppc2
	scalar min_y5=r(min)
	scalar max_y5=r(max)
	summ emp_ss
	scalar min_x5=r(min)
	scalar max_x5=r(max)

	* Figure 5: Employment in services (vs World)
	lpoly emp_ss lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y5'(1)`=max_y5')) ysc(range(`=min_x5'(1)`=max_x5')) /*
	*/ title("Services employment, `=minyear5'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in services (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter emp_ss lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter emp_ss lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter emp_ss lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure5`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure5`ctry'_2A2.png") append

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
gen lnenergypc=ln(energypc)
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & lnenergypc!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & lnenergypc!=.
scalar minyear6=r(min)
local minyear6: display %9.0f minyear6

drop if year!=`=minyear6'

if `=minyear6'!=. {
	* Statistics for Figure 6
	* Percentiles
	foreach x in lnenergypc lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in lnenergypc lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | lnenergypc==.
	summ lngdppc2
	scalar min_y6=r(min)
	scalar max_y6=r(max)
	summ lnenergypc
	scalar min_x6=r(min)
	scalar max_x6=r(max)

	* Figure 6: Energy consumption per capita (vs World)
	lpoly lnenergypc lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y6'(1)`=max_y6')) ysc(range(`=min_x6'(1)`=max_x6')) /*
	*/ title("Energy consumption per capita, `=minyear6'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Energy use (kg of oil equivalent per capita), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter lnenergypc lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter lnenergypc lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter lnenergypc lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure6`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure6`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(lnenergypc-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_lnenergypc=r(mean)
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
gen kpw=ln(ck/SL_TLF_TOTL_IN)

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & kpw!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & kpw!=.
scalar minyear7=r(min)
local minyear7: display %9.0f minyear7

drop if year!=`=minyear7'

if `=minyear7'!=. {
	* Statistics for Figure 7
	* Percentiles
	foreach x in kpw lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in kpw lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | kpw==.
	summ lngdppc2
	scalar min_y7=r(min)
	scalar max_y7=r(max)
	summ kpw
	scalar min_x7=r(min)
	scalar max_x7=r(max)

	* Figure 7: Capital per worker (vs World)
	lpoly kpw lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y7'(1)`=max_y7')) ysc(range(`=min_x7'(1)`=max_x7')) /*
	*/ title("Capital per worker, `=minyear7'") subtitle("`j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("Capital stock/labor force" "(at current PPP mil. 2005 US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter kpw lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter kpw lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter kpw lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure7`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure7`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & school!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & school!=.
scalar minyear8=r(min)
local minyear8: display %9.0f minyear8

drop if year!=`=minyear8'

if `=minyear8'!=. {
	* Statistics for Figure 8
	* Percentiles
	foreach x in school lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in school lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | school==.
	summ lngdppc2
	scalar min_y8=r(min)
	scalar max_y8=r(max)
	summ school
	scalar min_x8=r(min)
	scalar max_x8=r(max)

	* Figure 8: Years of schooling (vs World)
	lpoly school lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.0fc)) xsc(range(`=min_y8'(1)`=max_y8')) ysc(range(`=min_x8'(1)`=max_x8')) /*
	*/ title("Years of schooling, `=minyear8'") subtitle("Population aged 25 and over, `j'") note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Years of schooling") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter school lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter school lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter school lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure8`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure8`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(school-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_school=r(mean)
	drop pred se diff
}
restore

***********************************************
** HUMAN CAPITAL: SECONDARY ENROLLMENT (NET) **
***********************************************
rename SE_SEC_NENR sec
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & sec!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & sec!=.
scalar minyear9=r(min)
local minyear9: display %9.0f minyear9

drop if year!=`=minyear9'

if `=minyear9'!=. {
	* Statistics for Figure 9
	* Percentiles
	foreach x in sec lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in sec lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | sec==.
	summ lngdppc2
	scalar min_y9=r(min)
	scalar max_y9=r(max)
	summ sec
	scalar min_x9=r(min)
	scalar max_x9=r(max)

	* Figure 9: Secondary enrollment (vs World)
	lpoly sec lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y9'(1)`=max_y9')) ysc(range(`=min_x9'(1)`=max_x9')) /*
	*/ title("Secondary enrollment, `=minyear9'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("School enrollment, secondary (% net)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter sec lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter sec lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter sec lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure9`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure9`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(sec-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_sec=r(mean)
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
	count if lngdppc2!=. & year==`x' & journal!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & journal!=.
scalar minyear10=r(min)
local minyear10: display %9.0f minyear10

drop if year!=`=minyear10'

if `=minyear10'!=. {
	* Statistics for Figure 10
	* Percentiles
	foreach x in journal lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in journal lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | journal==.
	summ lngdppc2
	scalar min_y10=r(min)
	scalar max_y10=r(max)
	summ journal
	scalar min_x10=r(min)
	scalar max_x10=r(max)

	* Figure 10: Journals (vs World)
	lpoly journal lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) ylabel(,format(%9.1fc)) xsc(range(`=min_y10'(1)`=max_y10')) ysc(range(`=min_x10'(1)`=max_x10')) /*
	*/ title("Scientific and Technical Journal Articles, `=minyear10'") subtitle("Per 1,000 people, `j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Scientific and technical journal articles per 1,000 people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter journal lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter journal lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter journal lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure10`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure10`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(journal-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_journal=r(mean)
	drop pred se diff
}
restore

***************************************
** HUMAN CAPITAL: TERTIARY EDUCATION **
***************************************
rename SL_TLF_TERT_ZS univ
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & univ!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & univ!=.
scalar minyear11=r(min)
local minyear11: display %9.0f minyear11

drop if year!=`=minyear11'

if `=minyear11'!=. {
	* Statistics for Figure 11
	* Percentiles
	foreach x in univ lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in univ lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | univ==.
	summ lngdppc2
	scalar min_y11=r(min)
	scalar max_y11=r(max)
	summ univ
	scalar min_x11=r(min)
	scalar max_x11=r(max)

	* Figure 11: Tertiary education (vs World)
	lpoly univ lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y11'(1)`=max_y11')) ysc(range(`=min_x11'(1)`=max_x11')) /*
	*/ title("University education, `=minyear11'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Labor force with tertiary education (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter univ lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter univ lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter univ lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure11`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure11`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(univ-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_univ=r(mean)
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
	count if lngdppc2!=. & year==`x' & infant!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & infant!=.
scalar minyear12=r(min)
local minyear12: display %9.0f minyear12

drop if year!=`=minyear12'

if `=minyear12'!=. {
	* Statistics for Figure 12
	* Percentiles
	foreach x in infant lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in infant lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | infant==.
	summ lngdppc2
	scalar min_y12=r(min)
	scalar max_y12=r(max)
	summ infant
	scalar min_x12=r(min)
	scalar max_x12=r(max)

	* Figure 12: Infant mortality (vs World)
	lpoly infant lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y12'(1)`=max_y12')) ysc(range(`=min_x12'(50)`=max_x12')) /*
	*/ title("Infant mortality, `=minyear12'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Mortality rate, infant (per 1,000 live births)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter infant lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter infant lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter infant lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure12`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure12`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & fertil!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & fertil!=.
scalar minyear13=r(min)
local minyear13: display %9.0f minyear13

drop if year!=`=minyear13'

if `=minyear13'!=. {
	* Statistics for Figure 13
	* Percentiles
	foreach x in fertil lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in fertil lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | fertil==.
	summ lngdppc2
	scalar min_y13=r(min)
	scalar max_y13=r(max)
	summ fertil
	scalar min_x13=r(min)
	scalar max_x13=r(max)

	* Figure 13: Fertility rate (vs World)
	lpoly fertil lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y13'(1)`=max_y13')) ysc(range(`=min_x13'(1)`=max_x13')) /*
	*/ title("Fertility rate, `=minyear13'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Fertility rate, total (births per woman)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter fertil lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter fertil lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter fertil lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure13`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure13`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & life!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & life!=.
scalar minyear14=r(min)
local minyear14: display %9.0f minyear14

drop if year!=`=minyear14'

if `=minyear14'!=. {
	* Statistics for Figure 14
	* Percentiles
	foreach x in life lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in life lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | life==.
	summ lngdppc2
	scalar min_y14=r(min)
	scalar max_y14=r(max)
	summ life
	scalar min_x14=r(min)
	scalar max_x14=r(max)

	* Figure 14: Life Expectancy (vs World)
	lpoly life lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y14'(1)`=max_y14')) ysc(range(`=min_x14'(1)`=max_x14')) /*
	*/ title("Life expectancy, `=minyear14'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Life expectancy at birth, total (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter life lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter life lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter life lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure14`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure14`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & pop_g!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & pop_g!=.
scalar minyear15=r(min)
local minyear15: display %9.0f minyear15

drop if year!=`=minyear15'

if `=minyear15'!=. {
	* Statistics for Figure 15
	* Percentiles
	foreach x in pop_g lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in pop_g lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | pop_g==.
	summ lngdppc2
	scalar min_y15=r(min)
	scalar max_y15=r(max)
	summ pop_g
	scalar min_x15=r(min)
	scalar max_x15=r(max)

	* Figure 15: Population growth (vs World)
	lpoly pop_g lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y15'(1)`=max_y15')) ysc(range(`=min_x15'(1)`=max_x15')) /*
	*/ title("Population growth, `=minyear15'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Population growth (annual %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter pop_g lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter pop_g lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter pop_g lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure15`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure15`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & depend!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & depend!=.
scalar minyear16=r(min)
local minyear16: display %9.0f minyear16

drop if year!=`=minyear16'

if `=minyear16'!=. {
	* Statistics for Figure 16
	* Percentiles
	foreach x in depend lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in depend lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | depend==.
	summ lngdppc2
	scalar min_y16=r(min)
	scalar max_y16=r(max)
	summ depend
	scalar min_x16=r(min)
	scalar max_x16=r(max)

	* Figure 16: Demographic Dividend (vs World)
	lpoly depend lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y16'(1)`=max_y16')) ysc(range(`=min_x16'(1)`=max_x16')) /*
	*/ title("Demographic dividend, `=minyear16'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Age dependency ratio (% of working-age population)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter depend lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter depend lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter depend lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure16`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure16`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & ctfp!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & ctfp!=.
scalar minyear17=r(min)
local minyear17: display %9.0f minyear17

drop if year!=`=minyear17'

if `=minyear17'!=. {
	* Statistics for Figure 17
	* Percentiles
	foreach x in ctfp lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in ctfp lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | ctfp==.
	summ lngdppc2
	scalar min_y17=r(min)
	scalar max_y17=r(max)
	summ ctfp
	scalar min_x17=r(min)
	scalar max_x17=r(max)

	* Figure 17: Total Factor Productivity  (vs World)
	lpoly ctfp lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y17'(1)`=max_y17')) ysc(range(`=min_x17'(1)`=max_x17')) /*
	*/ title("Total Factor Productivity, `=minyear17'") subtitle("Relative to USA, `j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("TFP level at current PPPs (USA=1)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter ctfp lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter ctfp lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter ctfp lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure17`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure17`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & tax_gdp!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & tax_gdp!=.
scalar minyear18=r(min)
local minyear18: display %9.0f minyear18

drop if year!=`=minyear18'

if `=minyear18'!=. {
	* Statistics for Figure 18
	* Percentiles
	foreach x in tax_gdp lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in tax_gdp lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | tax_gdp==.
	summ lngdppc2
	scalar min_y18=r(min)
	scalar max_y18=r(max)
	summ tax_gdp
	scalar min_x18=r(min)
	scalar max_x18=r(max)

	* Figure 18: Tax revenue (% of GDP) (vs World)
	lpoly tax_gdp lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y18'(1)`=max_y18')) ysc(range(`=min_x18'(1)`=max_x18')) /*
	*/ title("Government revenue, `=minyear18'") subtitle("`j'") note("Data source: World Economic Outlook and World Development Indicators") /*
	*/ ytitle("General government revenue (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tax_gdp lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tax_gdp lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tax_gdp lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure18`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure18`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & open!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & open!=.
scalar minyear19=r(min)
local minyear19: display %9.0f minyear19

drop if year!=`=minyear19'

if `=minyear19'!=. {
	* Statistics for Figure 19
	* Percentiles
	foreach x in open lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in open lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | open==.
	summ lngdppc2
	scalar min_y19=r(min)
	scalar max_y19=r(max)
	summ open
	scalar min_x19=r(min)
	scalar max_x19=r(max)

	* Figure 19: Openness (% of GDP) (vs World)
	lpoly open lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y19'(1)`=max_y19')) ysc(range(`=min_x19'(100)`=max_x19'))  /*
	*/ title("Openness, `=minyear19'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Exports + Imports of goods and services (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter open lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter open lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter open lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure19`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure19`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & demo!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & demo!=.
scalar minyear20=r(min)
local minyear20: display %9.0f minyear20

drop if year!=`=minyear20'

if `=minyear20'!=. {
	* Statistics for Figure 20
	* Percentiles
	foreach x in demo lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in demo lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | demo==.
	summ lngdppc2
	scalar min_y20=r(min)
	scalar max_y20=r(max)
	summ demo
	scalar min_x20=r(min)
	scalar max_x20=r(max)

	* Figure 20: Democracy (vs World)
	lpoly demo lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y20'(1)`=max_y20')) ysc(range(`=min_x20'(1)`=max_x20'))  /*
	*/ title("Democracy, `=minyear20'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House/Polity) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Democracy (Freedom House/Imputed Polity)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter demo lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter demo lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter demo lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure20`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure20`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & rule!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & rule!=.
scalar minyear21=r(min)
local minyear21: display %9.0f minyear21

drop if year!=`=minyear21'

if `=minyear21'!=. {
	* Statistics for Figure 21
	* Percentiles
	foreach x in rule lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in rule lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | rule==.
	summ lngdppc2
	scalar min_y21=r(min)
	scalar max_y21=r(max)
	summ rule
	scalar min_x21=r(min)
	scalar max_x21=r(max)

	* Figure 21: Rule of Law (vs World)
	lpoly rule lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y21'(1)`=max_y21')) ysc(range(`=min_x21'(1)`=max_x21'))  /*
	*/ title("Rule of Law, `=minyear21'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Rule of Law") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter rule lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter rule lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter rule lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure21`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure21`ctry'_2A2.png") append

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
	count if lngdppc2!=.  & year==`x' & econ_freedom!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & econ_freedom!=.
scalar minyear22=r(min)
local minyear22: display %9.0f minyear22

drop if year!=`=minyear22'

if `=minyear22'!=. {
	* Statistics for Figure 22
	* Percentiles
	foreach x in econ_freedom lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in econ_freedom lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | econ_freedom==.
	summ lngdppc2
	scalar min_y22=r(min)
	scalar max_y22=r(max)
	summ econ_freedom
	scalar min_x22=r(min)
	scalar max_x22=r(max)

	* Figure 22: Economic Freedom (vs World)
	lpoly econ_freedom lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y22'(10)`=max_y22')) ysc(range(`=min_x22'(1)`=max_x22'))  /*
	*/ title("Economic Freedom, `=minyear22'") subtitle("`j'") note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
	*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Economic Freedom Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter econ_freedom lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter econ_freedom lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter econ_freedom lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure22`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure22`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & bus_freedom!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & bus_freedom!=.
scalar minyear23=r(min)
local minyear23: display %9.0f minyear23

drop if year!=`=minyear23'

if `=minyear23'!=. {
	* Statistics for Figure 23
	* Percentiles
	foreach x in bus_freedom lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in bus_freedom lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | bus_freedom==.
	summ lngdppc2
	scalar min_y23=r(min)
	scalar max_y23=r(max)
	summ bus_freedom
	scalar min_x23=r(min)
	scalar max_x23=r(max)

	* Figure 23: Business Freedom (vs World)
	lpoly bus_freedom lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y23'(10)`=max_y23')) ysc(range(`=min_x23'(1)`=max_x23'))  /*
	*/ title("Business Freedom, `=minyear23'") subtitle("`j'") note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
	*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
	*/ "and closing a business (time, cost, and recovery rate)" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Business Freedom score") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter bus_freedom lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter bus_freedom lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter bus_freedom lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))

	* Exporting results into word document
	gr export "$dir\figure23`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure23`ctry'_2A2.png") append

	* How many s.d. is the country from the fitted value?
	gen diff=(bus_freedom-pred)/se
	summ diff if wbcode=="`ctry'"
	scalar diff_bus_freedom=r(mean)
	drop pred se diff
}
restore

********************************************************************************************************************************************************

*****************************************************
** COMPOSITION OF EXPORTS: HIGH-TECHNOLOGY EXPORTS **
*****************************************************
gen tech_exp=TX_VAL_TECH_MF_ZS*TX_VAL_MANF_ZS_UN/100
preserve

* Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & tech_exp!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & tech_exp!=.
scalar minyear24=r(min)
local minyear24: display %9.0f minyear24

drop if year!=`=minyear24'

if `=minyear24'!=. {
	* Statistics for Figure 24
	* Percentiles
	foreach x in tech_exp lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in tech_exp lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | tech_exp==.
	summ lngdppc2
	scalar min_y24=r(min)
	scalar max_y24=r(max)
	summ tech_exp
	scalar min_x24=r(min)
	scalar max_x24=r(max)

	* Figure 24: High-technology exports (vs World)
	lpoly tech_exp lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y24'(1)`=max_y24')) ysc(range(`=min_x24'(1)`=max_x24')) /*
	*/ title("High-technology exports, `=minyear24'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("High-technology exports (% of merchandise exports)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter tech_exp lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter tech_exp lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter tech_exp lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure24`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure24`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & diversity_rca!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & diversity_rca!=.
scalar minyear25=r(min)
local minyear25: display %9.0f minyear25

drop if year!=`=minyear25'

if `=minyear25'!=. {
	* Statistics for Figure 25
	* Percentiles
	foreach x in diversity_rca lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in diversity_rca lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | diversity_rca==.
	summ lngdppc2
	scalar min_y25=r(min)
	scalar max_y25=r(max)
	summ diversity_rca
	scalar min_x25=r(min)
	scalar max_x25=r(max)

	* Figure 25: Diverisity of exports (vs World)
	lpoly diversity_rca lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y25'(1)`=max_y25')) ysc(range(`=min_x25'(100)`=max_x25')) /*
	*/ title("Diversity of exports, `=minyear25'") subtitle("`j'") note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
	*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database") /*
	*/ ytitle("Number of products exported with RCA") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter diversity_rca lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter diversity_rca lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter diversity_rca lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure25`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure25`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & eci_rca!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & eci_rca!=.
scalar minyear26=r(min)
local minyear26: display %9.0f minyear26

drop if year!=`=minyear26'

if `=minyear26'!=. {
	* Statistics for Figure 26
	* Percentiles
	foreach x in eci_rca lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in eci_rca lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | eci_rca==.
	summ lngdppc2
	scalar min_y26=r(min)
	scalar max_y26=r(max)
	summ eci_rca
	scalar min_x26=r(min)
	scalar max_x26=r(max)

	* Figure 26: Economic Complexity Index (vs World)
	lpoly eci_rca lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y26'(1)`=max_y26')) ysc(range(`=min_x26'(1)`=max_x26')) /*
	*/ title("Economic Complexity, `=minyear26'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Economic Complexity Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter eci_rca lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter eci_rca lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter eci_rca lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure26`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure26`ctry'_2A2.png") append

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
	count if lngdppc2!=. & year==`x' & coi_rca!=.
	if r(N)<100 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & coi_rca!=.
scalar minyear27=r(min)
local minyear27: display %9.0f minyear27

drop if year!=`=minyear27'

if `=minyear27'!=. {
	* Statistics for Figure 27
	* Percentiles
	foreach x in coi_rca lngdppc2 {
		xtile pct=`x' if `x'!=., nq(100)
		summ pct if wbcode=="`ctry'"
		scalar pct_`x'=r(mean)
		local pct_`x': display %9.1fc pct_`x'
		drop pct
		}

	* Ranks
	foreach x in coi_rca lngdppc2 {
		count if `x'!=.
		scalar n_`x'=r(N)
		xtile rank=1/`x' if `x'!=., nq(`=n_`x'')
		summ rank if wbcode=="`ctry'"
		scalar rank_`x'=r(mean)
		drop rank
		}
		
	* Minimum & Maximum
	drop if lngdppc2==. | coi_rca==.
	summ lngdppc2
	scalar min_y27=r(min)
	scalar max_y27=r(max)
	summ coi_rca
	scalar min_x27=r(min)
	scalar max_x27=r(max)

	* Figure 27: Economic Complexity Index (vs World)
	lpoly coi_rca lngdppc2, ci at(lngdppc2) gen(pred) se(se) legend(off) xsc(range(`=min_y27'(1)`=max_y27')) ysc(range(`=min_x27'(1)`=max_x27')) /*
	*/ title("Complexity Outlook, `=minyear27'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Complexity Outlook Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ addplot(scatter coi_rca lngdppc2, mlabsize(vsmall) mcolor(edkblue) mlabcolor(edkblue) || /*
	*/ scatter coi_rca lngdppc2 if region==`=region`ctry'', mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) || /*
	*/ scatter coi_rca lngdppc2 if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3))
	
	* Exporting results into word document
	gr export "$dir\figure27`ctry'_2A2.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2A2.doc", g("$dir\figure27`ctry'_2A2.png") append

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

foreach var in urban_pop agr_gdp mnf_gdp emp_ind emp_ss lnenergypc kpw school sec journal univ infant fertil life pop_g depend ctfp tax_gdp open demo rule /*
*/ econ_freedom bus_freedom tech_exp diversity_rca eci_rca coi_rca {
	gen rank_`var'=`=rank_`var''
	gen n_`var'=`=n_`var''
	gen pct_`var'=`=pct_`var''
	gen diff_`var'=`=diff_`var''
	}

forval x=1/27 {
	gen minyear`x'=`=minyear`x''
}

preserve
collapse minyear1 rank_urban_pop n_urban_pop pct_urban_pop diff_urban_pop
rename minyear1 year
rename rank_urban_pop rank
rename n_urban_pop n
rename pct_urban_pop percentile
rename diff_urban_pop deviation
gen variable=1
save "temp1.dta", replace
restore

preserve
collapse minyear2 rank_agr_gdp n_agr_gdp pct_agr_gdp diff_agr_gdp
rename minyear2 year
rename rank_agr_gdp rank
rename n_agr_gdp n
rename pct_agr_gdp percentile
rename diff_agr_gdp deviation
gen variable=2
save "temp2.dta", replace
restore

preserve
collapse minyear3 rank_mnf_gdp n_mnf_gdp pct_mnf_gdp diff_mnf_gdp
rename minyear3 year
rename rank_mnf_gdp rank
rename n_mnf_gdp n
rename pct_mnf_gdp percentile
rename diff_mnf_gdp deviation
gen variable=3
save "temp3.dta", replace
restore

preserve
collapse minyear4 rank_emp_ind n_emp_ind pct_emp_ind diff_emp_ind
rename minyear4 year
rename rank_emp_ind rank
rename n_emp_ind n
rename pct_emp_ind percentile
rename diff_emp_ind deviation
gen variable=4
save "temp4.dta", replace
restore

preserve
collapse minyear5 rank_emp_ss n_emp_ss pct_emp_ss diff_emp_ss
rename minyear5 year
rename rank_emp_ss rank
rename n_emp_s n
rename pct_emp_ss percentile
rename diff_emp_ss deviation
gen variable=5
save "temp5.dta", replace
restore

preserve
collapse minyear6 rank_lnenergypc n_lnenergypc pct_lnenergypc diff_lnenergypc
rename minyear6 year
rename rank_lnenergypc rank
rename n_lnenergypc n
rename pct_lnenergypc percentile
rename diff_lnenergypc deviation
gen variable=6
save "temp6.dta", replace
restore

preserve
collapse minyear7 rank_kpw n_kpw pct_kpw diff_kpw
rename minyear7 year
rename rank_kpw rank
rename n_kpw n
rename pct_kpw percentile
rename diff_kpw deviation
gen variable=7
save "temp7.dta", replace
restore

preserve
collapse minyear8 rank_school n_school pct_school diff_school
rename minyear8 year
rename rank_school rank
rename n_school n
rename pct_school percentile
rename diff_school deviation
gen variable=8
save "temp8.dta", replace
restore

preserve
collapse minyear9 rank_sec n_sec pct_sec diff_sec
rename minyear9 year
rename rank_sec rank
rename n_sec n
rename pct_sec percentile
rename diff_sec deviation
gen variable=9
save "temp9.dta", replace
restore

preserve
collapse minyear10 rank_journal n_journal pct_journal diff_journal
rename minyear10 year
rename rank_journal rank
rename n_journal n
rename pct_journal percentile
rename diff_journal deviation
gen variable=10
save "temp10.dta", replace
restore

preserve
collapse minyear11 rank_univ n_univ pct_univ diff_univ
rename minyear11 year
rename rank_univ rank
rename n_univ n
rename pct_univ percentile
rename diff_univ deviation
gen variable=11
save "temp11.dta", replace
restore

preserve
collapse minyear12 rank_infant n_infant pct_infant diff_infant
rename minyear12 year
rename rank_infant rank
rename n_infant n
rename pct_infant percentile
rename diff_infant deviation
gen variable=12
save "temp12.dta", replace
restore

preserve
collapse minyear13 rank_fertil n_fertil pct_fertil diff_fertil
rename minyear13 year
rename rank_fertil rank
rename n_fertil n
rename pct_fertil percentile
rename diff_fertil deviation
gen variable=13
save "temp13.dta", replace
restore

preserve
collapse minyear14 rank_life n_life pct_life diff_life
rename minyear14 year
rename rank_life rank
rename n_life n
rename pct_life percentile
rename diff_life deviation
gen variable=14
save "temp14.dta", replace
restore

preserve
collapse minyear15 rank_pop_g n_pop_g pct_pop_g diff_pop_g
rename minyear15 year
rename rank_pop_g rank
rename n_pop_g n
rename pct_pop_g percentile
rename diff_pop_g deviation
gen variable=15
save "temp15.dta", replace
restore

preserve
collapse minyear16 rank_depend n_depend pct_depend diff_depend
rename minyear16 year
rename rank_depend rank
rename n_depend n
rename pct_depend percentile
rename diff_depend deviation
gen variable=16
save "temp16.dta", replace
restore

preserve
collapse minyear17 rank_ctfp n_ctfp pct_ctfp diff_ctfp
rename minyear17 year
rename rank_ctfp rank
rename n_ctfp n
rename pct_ctfp percentile
rename diff_ctfp deviation
gen variable=17
save "temp17.dta", replace
restore

preserve
collapse minyear18 rank_tax_gdp n_tax_gdp pct_tax_gdp diff_tax_gdp
rename minyear18 year
rename rank_tax_gdp rank
rename n_tax_gdp n
rename pct_tax_gdp percentile
rename diff_tax_gdp deviation
gen variable=18
save "temp18.dta", replace
restore

preserve
collapse minyear19 rank_open n_open pct_open diff_open
rename minyear19 year
rename rank_open rank
rename n_open n
rename pct_open percentile
rename diff_open deviation
gen variable=19
save "temp19.dta", replace
restore

preserve
collapse minyear20 rank_demo n_demo pct_demo diff_demo
rename minyear20 year
rename rank_demo rank
rename n_demo n
rename pct_demo percentile
rename diff_demo deviation
gen variable=20
save "temp20.dta", replace
restore

preserve
collapse minyear21 rank_rule n_rule pct_rule diff_rule
rename minyear21 year
rename rank_rule rank
rename n_rule n
rename pct_rule percentile
rename diff_rule deviation
gen variable=21
save "temp21.dta", replace
restore

preserve
collapse minyear22 rank_econ_freedom n_econ_freedom pct_econ_freedom diff_econ_freedom
rename minyear22 year
rename rank_econ_freedom rank
rename n_econ_freedom n
rename pct_econ_freedom percentile
rename diff_econ_freedom deviation
gen variable=22
save "temp22.dta", replace
restore

preserve
collapse minyear23 rank_bus_freedom n_bus_freedom pct_bus_freedom diff_bus_freedom
rename minyear23 year
rename rank_bus_freedom rank
rename n_bus_freedom n
rename pct_bus_freedom percentile
rename diff_bus_freedom deviation
gen variable=23
save "temp23.dta", replace
restore

preserve
collapse minyear24 rank_tech_exp n_tech_exp pct_tech_exp diff_tech_exp
rename minyear24 year
rename rank_tech_exp rank
rename n_tech_exp n
rename pct_tech_exp percentile
rename diff_tech_exp deviation
gen variable=24
save "temp24.dta", replace
restore

preserve
collapse minyear25 rank_diversity_rca n_diversity_rca pct_diversity_rca diff_diversity_rca
rename minyear25 year
rename rank_diversity_rca rank
rename n_diversity_rca n
rename pct_diversity_rca percentile
rename diff_diversity_rca deviation
gen variable=25
save "temp25.dta", replace
restore

preserve
collapse minyear26 rank_eci_rca n_eci_rca pct_eci_rca diff_eci_rca
rename minyear26 year
rename rank_eci_rca rank
rename n_eci_rca n
rename pct_eci_rca percentile
rename diff_eci_rca deviation
gen variable=26
save "temp26.dta", replace
restore

preserve
collapse minyear27 rank_coi_rca n_coi_rca pct_coi_rca diff_coi_rca
rename minyear27 year
rename rank_coi_rca rank
rename n_coi_rca n
rename pct_coi_rca percentile
rename diff_coi_rca deviation
gen variable=27
save "temp27.dta", replace
restore

use "temp1.dta", clear
forval x=2/27 {
	append using "temp`x'.dta"
}

label def variable 1"Urbanization" 2"Share of agriculture in GDP" 3"Share of manufacturing in GDP" 4"Industry employment" 5"Services employment" /*
*/ 6"Energy consumption per capita" 7"Capital per worker" 8"Years of schooling" 9"Secondary enrollment" 10"Scientific and Technical Journal Articles" /*
*/ 11"University education" 12"Infant mortality" 13"Fertility rate" 14"Life expectancy" 15"Population growth" 16"Demographic dividend" /*
*/ 17"Total Factor Productivity" 18"Government revenue" 19"Openness" 20"Democracy" 21"Rule of Law" 22"Economic Freedom" 23"Business Freedom" /*
*/ 24"High-technology exports" 25"Diversity of exports" 26"Economic Complexity" 27"Complexity Outlook"
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
forval x=1/27 {
	erase "temp`x'.dta"
}
