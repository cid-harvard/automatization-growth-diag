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
keep country wbcode year loggdppc2 urban_pop

* Minimum and maximum years
forval x=1960(1)2013 {
		count if loggdppc2!=. & year==`x' & urban_pop!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & urban_pop!=.
scalar maxyear1=r(max)
local maxyear1: display %9.0f maxyear1
scalar minyear1=r(min)
local minyear1: display %9.0f minyear1

keep if year==`=minyear1' | year==`=maxyear1'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ urban_pop if wbcode=="`ctry'" & year==`=minyear1'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear1'
scalar x1=r(mean)
gen x1=`=x1'
summ urban_pop if wbcode=="`ctry'" & year==`=maxyear1'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear1'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_urban_pop=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly urban_pop loggdppc2 if year==`=minyear1', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly urban_pop loggdppc2 if year==`=maxyear1', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_urban_pop2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_urban_pop_diff=D_urban_pop/D_urban_pop2

if `=maxyear1'!=. & `=minyear1'!=. {
	* Figure 1: Urban population as % of total (vs World)
	lpoly urban_pop loggdppc2 if year==`=minyear1', noscatter /*
	*/ title("Urbanization, `=minyear1' and `=maxyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Urban population (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear1'") lab(2 "`=maxyear1'")) /*
	*/ addplot(lpoly urban_pop loggdppc2 if year==`=maxyear1' || /*
	*/ scatter urban_pop loggdppc2 if wbcode=="`ctry'" & year==`=minyear1', mlab(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter urban_pop loggdppc2 if wbcode=="`ctry'" & year==`=maxyear1', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure1`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure1`ctry'_2C.png") replace
}
restore

*********************************************************
** STRUCTURAL TRANSFORMATION: AGRICULTURE SHARE OF GDP **
*********************************************************
rename NV_AGR_TOTL_ZS agr_gdp
preserve
keep country wbcode year loggdppc2 agr_gdp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & agr_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & agr_gdp!=.
scalar maxyear2=r(max)
local maxyear2: display %9.0f maxyear2
scalar minyear2=r(min)
local minyear2: display %9.0f minyear2

keep if year==`=minyear2' | year==`=maxyear2'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ agr_gdp if wbcode=="`ctry'" & year==`=minyear2'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear2'
scalar x1=r(mean)
gen x1=`=x1'
summ agr_gdp if wbcode=="`ctry'" & year==`=maxyear2'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear2'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_agr_gdp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly agr_gdp loggdppc2 if year==`=minyear2', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly agr_gdp loggdppc2 if year==`=maxyear2', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_agr_gdp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_agr_gdp_diff=D_agr_gdp/D_agr_gdp2

if `=maxyear2'!=. & `=minyear2'!=. {
	* Figure 2: Agriculture as % of GDP (vs World)
	lpoly agr_gdp loggdppc2 if year==`=minyear2', noscatter /*
	*/ title("Share of agriculture in GDP, `=minyear2' and `=maxyear2'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Agriculture, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear2'") lab(2 "`=maxyear2'")) /*
	*/ addplot(lpoly agr_gdp loggdppc2 if year==`=maxyear2' || /*
	*/ scatter agr_gdp loggdppc2 if wbcode=="`ctry'" & year==`=minyear2', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter agr_gdp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear2', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure2`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure2`ctry'_2C.png") append
}
restore

***********************************************************
** STRUCTURAL TRANSFORMATION: MANUFACTURING SHARE OF GDP **
***********************************************************
rename NV_IND_MANF_ZS mnf_gdp
preserve
keep country wbcode year loggdppc2 mnf_gdp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & mnf_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & mnf_gdp!=.
scalar maxyear3=r(max)
local maxyear3: display %9.0f maxyear3
scalar minyear3=r(min)
local minyear3: display %9.0f minyear3

keep if year==`=minyear3' | year==`=maxyear3'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ mnf_gdp if wbcode=="`ctry'" & year==`=minyear3'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear3'
scalar x1=r(mean)
gen x1=`=x1'
summ mnf_gdp if wbcode=="`ctry'" & year==`=maxyear3'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear3'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_mnf_gdp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly mnf_gdp loggdppc2 if year==`=minyear3', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly mnf_gdp loggdppc2 if year==`=maxyear3', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_mnf_gdp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_mnf_gdp_diff=D_mnf_gdp/D_mnf_gdp2

if `=maxyear3'!=. & `=minyear3'!=. {
	* Figure 3: Manufacturing as % of GDP (vs World)
	lpoly mnf_gdp loggdppc2 if year==`=minyear3', noscatter /*
	*/ title("Share of manufacturing in GDP, `=minyear3' and `=maxyear3'") subtitle("`j'") /*
	*/ note("Note: Manufacturing corresponds to ISIC Rev.3 divisions 15-37" "Data source: World Development Indicators") /*
	*/ ytitle("Manufacturing, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear3'") lab(2 "`=maxyear3'")) /*
	*/ addplot(lpoly mnf_gdp loggdppc2 if year==`=maxyear3' || /*
	*/ scatter mnf_gdp loggdppc2 if wbcode=="`ctry'" & year==`=minyear3', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter mnf_gdp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear3', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure3`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure3`ctry'_2C.png") append
}
restore

******************************************************
** STRUCTURAL TRANSFORMATION: INDUSTRY SHARE OF GDP **
******************************************************
rename NV_IND_TOTL_ZS ind_gdp
preserve
keep country wbcode year loggdppc2 ind_gdp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ind_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ind_gdp!=.
scalar maxyear4=r(max)
local maxyear4: display %9.0f maxyear4
scalar minyear4=r(min)
local minyear4: display %9.0f minyear4

keep if year==`=minyear4' | year==`=maxyear4'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ ind_gdp if wbcode=="`ctry'" & year==`=minyear4'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear4'
scalar x1=r(mean)
gen x1=`=x1'
summ ind_gdp if wbcode=="`ctry'" & year==`=maxyear4'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear4'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_ind_gdp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly ind_gdp loggdppc2 if year==`=minyear4', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly ind_gdp loggdppc2 if year==`=maxyear4', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_ind_gdp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_ind_gdp_diff=D_ind_gdp/D_ind_gdp2

if `=maxyear4'!=. & `=minyear4'!=. {
	* Figure 4: Industry as % of GDP (vs World)
	lpoly ind_gdp loggdppc2 if year==`=minyear4', noscatter /*
	*/ title("Share of industry in GDP, `=minyear4' and `=maxyear4'") subtitle("`j'") /*
	*/ note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" "Data source: World Development Indicators") /*
	*/ ytitle("Industry, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear4'") lab(2 "`=maxyear4'")) /*
	*/ addplot(lpoly ind_gdp loggdppc2 if year==`=maxyear4' || /*
	*/ scatter ind_gdp loggdppc2 if wbcode=="`ctry'" & year==`=minyear4', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter ind_gdp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear4', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure4`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure4`ctry'_2C.png") append
}
restore

******************************************************
** STRUCTURAL TRANSFORMATION: SERVICES SHARE OF GDP **
******************************************************
rename NV_SRV_TETC_ZS ss_gdp
preserve
keep country wbcode year loggdppc2 ss_gdp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ss_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ss_gdp!=.
scalar maxyear5=r(max)
local maxyear5: display %9.0f maxyear5
scalar minyear5=r(min)
local minyear5: display %9.0f minyear5

keep if year==`=minyear5' | year==`=maxyear5'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ ss_gdp if wbcode=="`ctry'" & year==`=minyear5'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear5'
scalar x1=r(mean)
gen x1=`=x1'
summ ss_gdp if wbcode=="`ctry'" & year==`=maxyear5'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear5'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_ss_gdp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly ss_gdp loggdppc2 if year==`=minyear5', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly ss_gdp loggdppc2 if year==`=maxyear5', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_ss_gdp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_ss_gdp_diff=D_ss_gdp/D_ss_gdp2

if `=maxyear5'!=. & `=minyear5'!=. {
	* Figure 5: Services as % of GDP (vs World)
	lpoly ss_gdp loggdppc2 if year==`=minyear5', noscatter /*
	*/ title("Share of services in GDP, `=minyear5' and `=maxyear5'") subtitle("`j'") /*
	*/ note("Note: Services correspond to ISIC Rev.3 divisions 50-99" "Data source: World Development Indicators") /*
	*/ ytitle("Services, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear5'") lab(2 "`=maxyear5'")) /*
	*/ addplot(lpoly ss_gdp loggdppc2 if year==`=maxyear5' || /*
	*/ scatter ss_gdp loggdppc2 if wbcode=="`ctry'" & year==`=minyear5', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter ss_gdp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear5', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure5`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure5`ctry'_2C.png") append
}
restore

**********************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN AGRICULTURE **
**********************************************************
rename SL_AGR_EMPL_ZS emp_agr
preserve
keep country wbcode year loggdppc2 emp_agr

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_agr!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_agr!=.
scalar maxyear6=r(max)
local maxyear6: display %9.0f maxyear6
scalar minyear6=r(min)
local minyear6: display %9.0f minyear6

keep if year==`=minyear6' | year==`=maxyear6'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ emp_agr if wbcode=="`ctry'" & year==`=minyear6'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear6'
scalar x1=r(mean)
gen x1=`=x1'
summ emp_agr if wbcode=="`ctry'" & year==`=maxyear6'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear6'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_emp_agr=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly emp_agr loggdppc2 if year==`=minyear6', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly emp_agr loggdppc2 if year==`=maxyear6', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_emp_agr2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_emp_agr_diff=D_emp_agr/D_emp_agr2

if `=maxyear6'!=. & `=minyear6'!=. {
	* Figure 6: Employment in agriculture (vs World)
	lpoly emp_agr loggdppc2 if year==`=minyear6', noscatter /*
	*/ title("Agriculture employment, `=minyear6' and `=maxyear6'") subtitle("`j'") /*
	*/ note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" "Data source: World Development Indicators") /*
	*/ ytitle("Employment in agriculture (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear6'") lab(2 "`=maxyear6'")) /*
	*/ addplot(lpoly emp_agr loggdppc2 if year==`=maxyear6' || /*
	*/ scatter emp_agr loggdppc2 if wbcode=="`ctry'" & year==`=minyear6', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter emp_agr loggdppc2 if wbcode=="`ctry'" & year==`=maxyear6', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure6`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure6`ctry'_2C.png") append
}
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN INDUSTRY **
*******************************************************
rename SL_IND_EMPL_ZS emp_ind
preserve
keep country wbcode year loggdppc2 emp_ind

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_ind!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ind!=.
scalar maxyear7=r(max)
local maxyear7: display %9.0f maxyear7
scalar minyear7=r(min)
local minyear7: display %9.0f minyear7

keep if year==`=minyear7' | year==`=maxyear7'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ emp_ind if wbcode=="`ctry'" & year==`=minyear7'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear7'
scalar x1=r(mean)
gen x1=`=x1'
summ emp_ind if wbcode=="`ctry'" & year==`=maxyear7'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear7'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_emp_ind=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly emp_ind loggdppc2 if year==`=minyear7', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly emp_ind loggdppc2 if year==`=maxyear7', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_emp_ind2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_emp_ind_diff=D_emp_ind/D_emp_ind2

if `=maxyear7'!=. & `=minyear7'!=. {
	* Figure 7: Employment in industry (vs World)
	lpoly emp_ind loggdppc2 if year==`=minyear7', noscatter /*
	*/ title("Industry employment, `=minyear7' and `=maxyear7'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in industry (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear7'") lab(2 "`=maxyear7'"))	/*
	*/ addplot(lpoly emp_ind loggdppc2 if year==`=maxyear7'	|| /*
	*/ scatter emp_ind loggdppc2 if wbcode=="`ctry'" & year==`=minyear7', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter emp_ind loggdppc2 if wbcode=="`ctry'" & year==`=maxyear7', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
		
	* Exporting results into word document
	gr export "$dir\figure7`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure7`ctry'_2C.png") append
}
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN SERVICES **
*******************************************************
rename SL_SRV_EMPL_ZS emp_ss
preserve
keep country wbcode year loggdppc2 emp_ss

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & emp_ss!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & emp_ss!=.
scalar maxyear8=r(max)
local maxyear8: display %9.0f maxyear8
scalar minyear8=r(min)
local minyear8: display %9.0f minyear8

keep if year==`=minyear8' | year==`=maxyear8'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ emp_ss if wbcode=="`ctry'" & year==`=minyear8'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear8'
scalar x1=r(mean)
gen x1=`=x1'
summ emp_ss if wbcode=="`ctry'" & year==`=maxyear8'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear8'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_emp_ss=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly emp_ss loggdppc2 if year==`=minyear8', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly emp_ss loggdppc2 if year==`=maxyear8', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_emp_ss2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_emp_ss_diff=D_emp_ss/D_emp_ss2

if `=maxyear8'!=. & `=minyear8'!=. {
	* Figure 8: Employment in services (vs World)
	lpoly emp_ss loggdppc2 if year==`=minyear8', noscatter /*
	*/ title("Services employment, `=minyear8' and `=maxyear8'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in services (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear8'") lab(2 "`=maxyear8'"))	/*
	*/ addplot(lpoly emp_ss loggdppc2 if year==`=maxyear8'	|| /*
	*/ scatter emp_ss loggdppc2 if wbcode=="`ctry'" & year==`=minyear8', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter emp_ss loggdppc2 if wbcode=="`ctry'" & year==`=maxyear8', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure8`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure8`ctry'_2C.png") append
}
restore

********************************************************************************************************************************************************

*****************************************************
** PHYSICAL CAPITAL: ENERGY CONSUMPTION PER CAPITA **
*****************************************************
rename EG_USE_PCAP_KG_OE energypc
gen logenergypc=log10(energypc)
preserve
keep country wbcode year loggdppc2 logenergypc

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & logenergypc!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & logenergypc!=.
scalar maxyear9=r(max)
local maxyear9: display %9.0f maxyear9
scalar minyear9=r(min)
local minyear9: display %9.0f minyear9

keep if year==`=minyear9' | year==`=maxyear9'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ logenergypc if wbcode=="`ctry'" & year==`=minyear9'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear9'
scalar x1=r(mean)
gen x1=`=x1'
summ logenergypc if wbcode=="`ctry'" & year==`=maxyear9'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear9'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_energypc=(10^(`=y2')-10^(`=y1'))/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly logenergypc loggdppc2 if year==`=minyear9', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly logenergypc loggdppc2 if year==`=maxyear9', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_energypc2=(10^(`=y4')-10^(`=y3'))/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_energypc_diff=D_energypc/D_energypc2

if `=maxyear9'!=. & `=minyear9'!=. {
	* Figure 9: Energy consumption per capita (vs World)
	lpoly logenergypc loggdppc2 if year==`=minyear9', noscatter /*
	*/ title("Energy consumption per capita, `=minyear9' and `=maxyear9'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Energy use (kg of oil equivalent per capita), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear9'") lab(2 "`=maxyear9'"))	/*
	*/ addplot(lpoly logenergypc loggdppc2 if year==`=maxyear9' || /*
	*/ scatter logenergypc loggdppc2 if wbcode=="`ctry'" & year==`=minyear9', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter logenergypc loggdppc2 if wbcode=="`ctry'" & year==`=maxyear9', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure9`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure9`ctry'_2C.png") append
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
gen kpw=log10(ck*1000000/SL_TLF_TOTL_IN)
keep country wbcode year loggdppc2 kpw

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & kpw!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & kpw!=.
scalar maxyear10=r(max)
local maxyear10: display %9.0f maxyear10
scalar minyear10=r(min)
local minyear10: display %9.0f minyear10

keep if year==`=minyear10' | year==`=maxyear10'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ kpw if wbcode=="`ctry'" & year==`=minyear10'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear10'
scalar x1=r(mean)
gen x1=`=x1'
summ kpw if wbcode=="`ctry'" & year==`=maxyear10'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear10'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_kpw=(10^(`=y2')-10^(`=y1'))/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly kpw loggdppc2 if year==`=minyear10', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly kpw loggdppc2 if year==`=maxyear10', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_kpw2=(10^(`=y4')-10^(`=y3'))/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_kpw_diff=D_kpw/D_kpw2

if `=maxyear10'!=. & `=minyear10'!=. {
	* Figure 10: Capital per worker (vs World)
	lpoly kpw loggdppc2 if year==`=minyear10', noscatter /*
	*/ title("Capital per worker, `=minyear10' and `=maxyear10'") subtitle("`j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("Capital stock/labor force" "(at current PPP 2005 US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear10'") lab(2 "`=maxyear10'"))	/*
	*/ addplot(lpoly kpw loggdppc2 if year==`=maxyear10' || /*
	*/ scatter kpw loggdppc2 if wbcode=="`ctry'" & year==`=minyear10', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter kpw loggdppc2 if wbcode=="`ctry'" & year==`=maxyear10', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure10`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure10`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 school

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & school!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & school!=.
scalar maxyear11=r(max)
local maxyear11: display %9.0f maxyear11
scalar minyear11=r(min)
local minyear11: display %9.0f minyear11

keep if year==`=minyear11' | year==`=maxyear11'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ school if wbcode=="`ctry'" & year==`=minyear11'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear11'
scalar x1=r(mean)
gen x1=`=x1'
summ school if wbcode=="`ctry'" & year==`=maxyear11'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear11'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_school=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly school loggdppc2 if year==`=minyear11', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly school loggdppc2 if year==`=maxyear11', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_school2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_school_diff=D_school/D_school2

if `=maxyear11'!=. & `=minyear11'!=. {
	* Figure 11: Years of schooling (vs World)
	lpoly school loggdppc2 if year==`=minyear11', noscatter /*
	*/ title("Years of schooling, `=minyear11' and `=maxyear11'") subtitle("Population aged 25 and over, `j'") /*
	*/ note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Years of schooling") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear11'") lab(2 "`=maxyear11'"))	/*
	*/ addplot(lpoly school loggdppc2 if year==`=maxyear11' || /*
	*/ scatter school loggdppc2 if wbcode=="`ctry'" & year==`=minyear11', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter school loggdppc2 if wbcode=="`ctry'" & year==`=maxyear11', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure11`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure11`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 prim

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & prim!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & prim!=.
scalar maxyear12=r(max)
local maxyear12: display %9.0f maxyear12
scalar minyear12=r(min)
local minyear12: display %9.0f minyear12

keep if year==`=minyear12' | year==`=maxyear12'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ prim if wbcode=="`ctry'" & year==`=minyear12'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear12'
scalar x1=r(mean)
gen x1=`=x1'
summ prim if wbcode=="`ctry'" & year==`=maxyear12'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear12'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_prim=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly prim loggdppc2 if year==`=minyear12', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly prim loggdppc2 if year==`=maxyear12', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_prim2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_prim_diff=D_prim/D_prim2

if `=maxyear12'!=. & `=minyear12'!=. {
	* Figure 12: Primary schooling (vs World)
	lpoly prim loggdppc2 if year==`=minyear12', noscatter /*
	*/ title("Primary schooling, `=minyear12' and `=maxyear12'") subtitle("Population aged 25 and over, `j'") /*
	*/ note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Primary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear12'") lab(2 "`=maxyear12'"))	/*
	*/ addplot(lpoly prim loggdppc2 if year==`=maxyear12' || /*
	*/ scatter prim loggdppc2 if wbcode=="`ctry'" & year==`=minyear12', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter prim loggdppc2 if wbcode=="`ctry'" & year==`=maxyear12', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure12`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure12`ctry'_2C.png") append
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

keep country wbcode year loggdppc2 sec

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & sec!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & sec!=.
scalar maxyear13=r(max)
local maxyear13: display %9.0f maxyear13
scalar minyear13=r(min)
local minyear13: display %9.0f minyear13

keep if year==`=minyear13' | year==`=maxyear13'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ sec if wbcode=="`ctry'" & year==`=minyear13'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear13'
scalar x1=r(mean)
gen x1=`=x1'
summ sec if wbcode=="`ctry'" & year==`=maxyear13'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear13'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_sec=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly sec loggdppc2 if year==`=minyear13', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly sec loggdppc2 if year==`=maxyear13', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_sec2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_sec_diff=D_sec/D_sec2

if `=maxyear13'!=. & `=minyear13'!=. {
	* Figure 13: Secondary enrollment (vs World)
	lpoly sec loggdppc2 if year==`=minyear13', noscatter /*
	*/ title("Secondary schooling, `=minyear13' and `=maxyear13'") subtitle("Population aged 25 and over, `j'") /*
	*/ note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Secondary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear13'") lab(2 "`=maxyear13'"))	/*
	*/ addplot(lpoly sec loggdppc2 if year==`=maxyear13' || /*
	*/ scatter sec loggdppc2 if wbcode=="`ctry'" & year==`=minyear13', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter sec loggdppc2 if wbcode=="`ctry'" & year==`=maxyear13', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure13`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure13`ctry'_2C.png") append
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

keep country wbcode year loggdppc2 univ

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & univ!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & univ!=.
scalar maxyear14=r(max)
local maxyear14: display %9.0f maxyear14
scalar minyear14=r(min)
local minyear14: display %9.0f minyear14

keep if year==`=minyear14' | year==`=maxyear14'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ univ if wbcode=="`ctry'" & year==`=minyear14'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear14'
scalar x1=r(mean)
gen x1=`=x1'
summ univ if wbcode=="`ctry'" & year==`=maxyear14'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear14'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_univ=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly univ loggdppc2 if year==`=minyear14', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly univ loggdppc2 if year==`=maxyear14', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_univ2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_univ_diff=D_univ/D_univ2

if `=maxyear14'!=. & `=minyear14'!=. {
	* Figure 14: Tertiary schooling (vs World)
	lpoly univ loggdppc2 if year==`=minyear14', noscatter /*
	*/ title("Tertiary schooling, `=minyear14' and `=maxyear14'") subtitle("Population aged 25 and over, `j'") /*
	*/ note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Tertiary schooling attained in Pop. (%)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear14'") lab(2 "`=maxyear14'"))	/*
	*/ addplot(lpoly univ loggdppc2 if year==`=maxyear14' || /*
	*/ scatter univ loggdppc2 if wbcode=="`ctry'" & year==`=minyear14', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter univ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear14', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure14`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure14`ctry'_2C.png") append
}
restore

**************************************************************
** HUMAN CAPITAL: SCIENTIFIC AND TECHNICAL JOURNAL ARTICLES **
**************************************************************
gen journal=IP_JRN_ARTC_SC*1000/SP_POP_TOTL
preserve
keep country wbcode year loggdppc2 journal

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & journal!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & journal!=.
scalar maxyear15=r(max)
local maxyear15: display %9.0f maxyear15
scalar minyear15=r(min)
local minyear15: display %9.0f minyear15

keep if year==`=minyear15' | year==`=maxyear15'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ journal if wbcode=="`ctry'" & year==`=minyear15'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear15'
scalar x1=r(mean)
gen x1=`=x1'
summ journal if wbcode=="`ctry'" & year==`=maxyear15'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear15'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_journal=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly journal loggdppc2 if year==`=minyear15', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly journal loggdppc2 if year==`=maxyear15', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_journal2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_journal_diff=D_journal/D_journal2

if `=maxyear15'!=. & `=minyear15'!=. {
	* Figure 15: Journals (vs World)
	lpoly journal loggdppc2 if year==`=minyear15', noscatter /*
	*/ title("Scientific and Technical Journal Articles, `=minyear15' and `=maxyear15'") subtitle("Per 1,000 people, `j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Scientific and technical journal articles per 1,000 people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear15'") lab(2 "`=maxyear15'"))	/*
	*/ addplot(lpoly journal loggdppc2 if year==`=maxyear15' || /*
	*/ scatter journal loggdppc2 if wbcode=="`ctry'" & year==`=minyear15', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter journal loggdppc2 if wbcode=="`ctry'" & year==`=maxyear15', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure15`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure15`ctry'_2C.png") append
}
restore

***************************************
** HUMAN CAPITAL: RESEARCHERS IN R&D **
***************************************
rename SP_POP_SCIE_RD_P6 research
preserve
keep country wbcode year loggdppc2 research

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & research!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & research!=.
scalar maxyear16=r(max)
local maxyear16: display %9.0f maxyear16
scalar minyear16=r(min)
local minyear16: display %9.0f minyear16

if `=maxyear16'!=. & `=minyear16'!=. {
	keep if year==`=minyear16' | year==`=maxyear16'

	* Checking that we are using the same countries
	bys wbcode: gen n=_n
	bys wbcode: egen m=max(n)
	drop if m!=2
	drop n m

	* Coordinates for country
	summ research if wbcode=="`ctry'" & year==`=minyear16'
	scalar y1=r(mean)
	gen y1=`=y1'
	summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear16'
	scalar x1=r(mean)
	gen x1=`=x1'
	summ research if wbcode=="`ctry'" & year==`=maxyear16'
	scalar y2=r(mean)
	gen y2=`=y2'
	summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear16'
	scalar x2=r(mean)
	gen x2=`=x2'

	* Slope for country
	scalar D_research=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))
	
	* Coordinates for world
	lpoly research loggdppc2 if year==`=minyear16', at(loggdppc2) gen(pred1) nogr
	summ pred1 if loggdppc2==x1
	scalar y3=r(mean) 
	lpoly research loggdppc2 if year==`=maxyear16', at(loggdppc2) gen(pred2) nogr
	summ pred2 if loggdppc2==x2
	scalar y4=r(mean)

	* Slope for predicted country
	scalar D_research2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

	* Difference between real and predicted
	scalar D_research_diff=D_research/D_research2

	* Figure 16: Researchers in R&D (vs World)
	lpoly research loggdppc2 if year==`=minyear16', noscatter /*
	*/ title("Researchers in R&D, `=minyear16' and `=maxyear16'") subtitle("Per million people, `j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Researchers in R&D per million people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear16'") lab(2 "`=maxyear16'"))	/*
	*/ addplot(lpoly research loggdppc2 if year==`=maxyear16' || /*
	*/ scatter research loggdppc2 if wbcode=="`ctry'" & year==`=minyear16', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter research loggdppc2 if wbcode=="`ctry'" & year==`=maxyear16', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure16`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure16`ctry'_2C.png") append
}
restore
********************************************************************************************************************************************************

**********************************
** POPULATION: INFANT MORTALITY **
**********************************
rename SP_DYN_IMRT_IN infant
preserve
keep country wbcode year loggdppc2 infant

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & infant!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & infant!=.
scalar maxyear17=r(max)
local maxyear17: display %9.0f maxyear17
scalar minyear17=r(min)
local minyear17: display %9.0f minyear17

keep if year==`=minyear17' | year==`=maxyear17'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ infant if wbcode=="`ctry'" & year==`=minyear17'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear17'
scalar x1=r(mean)
gen x1=`=x1'
summ infant if wbcode=="`ctry'" & year==`=maxyear17'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear17'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_infant=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly infant loggdppc2 if year==`=minyear17', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly infant loggdppc2 if year==`=maxyear17', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_infant2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_infant_diff=D_infant/D_infant2

if `=maxyear17'!=. & `=minyear17'!=. {
	* Figure 17: Infant mortality (vs World)
	lpoly infant loggdppc2 if year==`=minyear17', noscatter /*
	*/ title("Infant mortality, `=minyear17' and `=maxyear17'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Mortality rate, infant (per 1,000 live births)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear17'") lab(2 "`=maxyear17'"))	/*
	*/ addplot(lpoly infant loggdppc2 if year==`=maxyear17' || /*
	*/ scatter infant loggdppc2 if wbcode=="`ctry'" & year==`=minyear17', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter infant loggdppc2 if wbcode=="`ctry'" & year==`=maxyear17', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure17`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure17`ctry'_2C.png") append
}
restore

********************************
** POPULATION: FERTILITY RATE **
********************************
rename SP_DYN_TFRT_IN fertil
preserve
keep country wbcode year loggdppc2 fertil

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & fertil!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & fertil!=.
scalar maxyear18=r(max)
local maxyear18: display %9.0f maxyear18
scalar minyear18=r(min)
local minyear18: display %9.0f minyear18

keep if year==`=minyear18' | year==`=maxyear18'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ fertil if wbcode=="`ctry'" & year==`=minyear18'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear18'
scalar x1=r(mean)
gen x1=`=x1'
summ fertil if wbcode=="`ctry'" & year==`=maxyear18'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear18'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_fertil=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly fertil loggdppc2 if year==`=minyear18', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly fertil loggdppc2 if year==`=maxyear18', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_fertil2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_fertil_diff=D_fertil/D_fertil2

if `=maxyear18'!=. & `=minyear18'!=. {
	* Figure 18: Fertility rate (vs World)
	lpoly fertil loggdppc2 if year==`=minyear18', noscatter /*
	*/ title("Fertility rate, `=minyear18' and `=maxyear18'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Fertility rate, total (births per woman)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear18'") lab(2 "`=maxyear18'"))	/*
	*/ addplot(lpoly fertil loggdppc2 if year==`=maxyear18' || /*
	*/ scatter fertil loggdppc2 if wbcode=="`ctry'" & year==`=minyear18', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter fertil loggdppc2 if wbcode=="`ctry'" & year==`=maxyear18', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure18`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure18`ctry'_2C.png") append
}
restore

*********************************
** POPULATION: LIFE EXPECTANCY **
*********************************
rename SP_DYN_LE00_IN life
preserve
keep country wbcode year loggdppc2 life

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & life!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & life!=.
scalar maxyear19=r(max)
local maxyear19: display %9.0f maxyear19
scalar minyear19=r(min)
local minyear19: display %9.0f minyear19

keep if year==`=minyear19' | year==`=maxyear19'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ life if wbcode=="`ctry'" & year==`=minyear19'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear19'
scalar x1=r(mean)
gen x1=`=x1'
summ life if wbcode=="`ctry'" & year==`=maxyear19'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear19'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_life=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly life loggdppc2 if year==`=minyear19', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly life loggdppc2 if year==`=maxyear19', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_life2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_life_diff=D_life/D_life2

if `=maxyear19'!=. & `=minyear19'!=. {
	* Figure 19: Life Expectancy (vs World)
	lpoly life loggdppc2 if year==`=minyear19', noscatter /*
	*/ title("Life expectancy, `=minyear19' and `=maxyear19'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Life expectancy at birth, total (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear19'") lab(2 "`=maxyear19'"))	/*
	*/ addplot(lpoly life loggdppc2 if year==`=maxyear19' || /*
	*/ scatter life loggdppc2 if wbcode=="`ctry'" & year==`=minyear19', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter life loggdppc2 if wbcode=="`ctry'" & year==`=maxyear19', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure19`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure19`ctry'_2C.png") append
}
restore

***********************************
** POPULATION: POPULATION GROWTH **
***********************************
rename SP_POP_GROW pop_g
preserve
keep country wbcode year loggdppc2 pop_g

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & pop_g!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & pop_g!=.
scalar maxyear20=r(max)
local maxyear20: display %9.0f maxyear20
scalar minyear20=r(min)
local minyear20: display %9.0f minyear20

keep if year==`=minyear20' | year==`=maxyear20'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ pop_g if wbcode=="`ctry'" & year==`=minyear20'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear20'
scalar x1=r(mean)
gen x1=`=x1'
summ pop_g if wbcode=="`ctry'" & year==`=maxyear20'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear20'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_pop_g=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly pop_g loggdppc2 if year==`=minyear20', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly pop_g loggdppc2 if year==`=maxyear20', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_pop_g2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_pop_g_diff=D_pop_g/D_pop_g2

if `=maxyear20'!=. & `=minyear20'!=. {
	* Figure 20: Population growth (vs World)
	lpoly pop_g loggdppc2 if year==`=minyear20', noscatter /*
	*/ title("Population growth, `=minyear20' and `=maxyear20'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Population growth (annual %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear20'") lab(2 "`=maxyear20'"))	/*
	*/ addplot(lpoly pop_g loggdppc2 if year==`=maxyear20' || /*
	*/ scatter pop_g loggdppc2 if wbcode=="`ctry'" & year==`=minyear20', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter pop_g loggdppc2 if wbcode=="`ctry'" & year==`=maxyear20', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure20`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure20`ctry'_2C.png") append
}
restore

**************************************
** POPULATION: DEMOGRAPHIC DIVIDEND **
**************************************
rename SP_POP_DPND depend
preserve
keep country wbcode year loggdppc2 depend

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & depend!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & depend!=.
scalar maxyear21=r(max)
local maxyear21: display %9.0f maxyear21
scalar minyear21=r(min)
local minyear21: display %9.0f minyear21

keep if year==`=minyear21' | year==`=maxyear21'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ depend if wbcode=="`ctry'" & year==`=minyear21'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear21'
scalar x1=r(mean)
gen x1=`=x1'
summ depend if wbcode=="`ctry'" & year==`=maxyear21'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear21'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_depend=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly depend loggdppc2 if year==`=minyear21', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly depend loggdppc2 if year==`=maxyear21', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_depend2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_depend_diff=D_depend/D_depend2

if `=maxyear21'!=. & `=minyear21'!=. {
	* Figure 21: Demographic Dividend (vs World)
	lpoly depend loggdppc2 if year==`=minyear21', noscatter /*
	*/ title("Demographic dividend, `=minyear21' and `=maxyear21'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Age dependency ratio (% of working-age population)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear21'") lab(2 "`=maxyear21'"))	/*
	*/ addplot(lpoly depend loggdppc2 if year==`=maxyear21' || /*
	*/ scatter depend loggdppc2 if wbcode=="`ctry'" & year==`=minyear21', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter depend loggdppc2 if wbcode=="`ctry'" & year==`=maxyear21', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure21`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure21`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 ctfp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & ctfp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & ctfp!=.
scalar maxyear22=r(max)
local maxyear22: display %9.0f maxyear22
scalar minyear22=r(min)
local minyear22: display %9.0f minyear22

keep if year==`=minyear22' | year==`=maxyear22'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ ctfp if wbcode=="`ctry'" & year==`=minyear22'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear22'
scalar x1=r(mean)
gen x1=`=x1'
summ ctfp if wbcode=="`ctry'" & year==`=maxyear22'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear22'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_ctfp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly ctfp loggdppc2 if year==`=minyear22', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly ctfp loggdppc2 if year==`=maxyear22', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_ctfp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_ctfp_diff=D_ctfp/D_ctfp2

if `=maxyear22'!=. & `=minyear22'!=. {
	* Figure 22: Total Factor Productivity  (vs World)
	lpoly ctfp loggdppc2 if year==`=minyear22', noscatter /*
	*/ title("Total Factor Productivity, `=minyear22' and `=maxyear22'") subtitle("Relative to USA, `j'") /*
	*/ note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("TFP level at current PPPs (USA=1)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear22'") lab(2 "`=maxyear22'"))	/*
	*/ addplot(lpoly ctfp loggdppc2 if year==`=maxyear22' || /*
	*/ scatter ctfp loggdppc2 if wbcode=="`ctry'" & year==`=minyear22', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter ctfp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear22', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure22`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure22`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 tax_gdp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & tax_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & tax_gdp!=.
scalar maxyear23=r(max)
local maxyear23: display %9.0f maxyear23
scalar minyear23=r(min)
local minyear23: display %9.0f minyear23

keep if year==`=minyear23' | year==`=maxyear23'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ tax_gdp if wbcode=="`ctry'" & year==`=minyear23'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear23'
scalar x1=r(mean)
gen x1=`=x1'
summ tax_gdp if wbcode=="`ctry'" & year==`=maxyear23'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear23'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_tax_gdp=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly tax_gdp loggdppc2 if year==`=minyear23', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly tax_gdp loggdppc2 if year==`=maxyear23', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_tax_gdp2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_tax_gdp_diff=D_tax_gdp/D_tax_gdp2

if `=maxyear23'!=. & `=minyear23'!=. {
	* Figure 23: Tax revenue (% of GDP) (vs World)
	lpoly tax_gdp loggdppc2 if year==`=minyear23', noscatter /*
	*/ title("Government revenue, `=minyear23' and `=maxyear23'") subtitle("`j'") /*
	*/ note("Data source: World Economic Outlook and World Development Indicators") /*
	*/ ytitle("General government revenue (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear23'") lab(2 "`=maxyear23'"))	/*
	*/ addplot(lpoly tax_gdp loggdppc2 if year==`=maxyear23' || /*
	*/ scatter tax_gdp loggdppc2 if wbcode=="`ctry'" & year==`=minyear23', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter tax_gdp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear23', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure23`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure23`ctry'_2C.png") append
}
restore

***************************************
** POLICY AND INSTITUTIONS: OPENNESS **
***************************************
gen open=NE_EXP_GNFS_ZS+NE_IMP_GNFS_ZS
preserve
keep country wbcode year loggdppc2 open

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & open!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & open!=.
scalar maxyear24=r(max)
local maxyear24: display %9.0f maxyear24
scalar minyear24=r(min)
local minyear24: display %9.0f minyear24

keep if year==`=minyear24' | year==`=maxyear24'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ open if wbcode=="`ctry'" & year==`=minyear24'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear24'
scalar x1=r(mean)
gen x1=`=x1'
summ open if wbcode=="`ctry'" & year==`=maxyear24'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear24'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_open=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly open loggdppc2 if year==`=minyear24', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly open loggdppc2 if year==`=maxyear24', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_open2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_open_diff=D_open/D_open2

if `=maxyear24'!=. & `=minyear24'!=. {
	* Figure 24: Openness (% of GDP) (vs World)
	lpoly open loggdppc2 if year==`=minyear24', noscatter /*
	*/ title("Openness, `=minyear24' and `=maxyear24'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Exports + Imports of goods and services (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear24'") lab(2 "`=maxyear24'"))	/*
	*/ addplot(lpoly open loggdppc2 if year==`=maxyear24' || /*
	*/ scatter open loggdppc2 if wbcode=="`ctry'" & year==`=minyear24', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter open loggdppc2 if wbcode=="`ctry'" & year==`=maxyear24', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure24`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure24`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 demo

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & demo!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & demo!=.
scalar maxyear25=r(max)
local maxyear25: display %9.0f maxyear25
scalar minyear25=r(min)
local minyear25: display %9.0f minyear25

keep if year==`=minyear25' | year==`=maxyear25'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ demo if wbcode=="`ctry'" & year==`=minyear25'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear25'
scalar x1=r(mean)
gen x1=`=x1'
summ demo if wbcode=="`ctry'" & year==`=maxyear25'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear25'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_demo=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly demo loggdppc2 if year==`=minyear25', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly demo loggdppc2 if year==`=maxyear25', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_demo2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_demo_diff=D_demo/D_demo2

if `=maxyear25'!=. & `=minyear25'!=. {
	* Figure 25: Democracy (vs World)
	lpoly demo loggdppc2 if year==`=minyear25', noscatter /*
	*/ title("Democracy, `=minyear25' and `=maxyear25'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House/Polity) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Democracy (Freedom House/Imputed Polity)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear25'") lab(2 "`=maxyear25'"))	/*
	*/ addplot(lpoly demo loggdppc2 if year==`=maxyear25' || /*
	*/ scatter demo loggdppc2 if wbcode=="`ctry'" & year==`=minyear25', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter demo loggdppc2 if wbcode=="`ctry'" & year==`=maxyear25', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure25`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure25`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 rule

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & rule!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & rule!=.
scalar maxyear26=r(max)
local maxyear26: display %9.0f maxyear26
scalar minyear26=r(min)
local minyear26: display %9.0f minyear26

keep if year==`=minyear26' | year==`=maxyear26'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ rule if wbcode=="`ctry'" & year==`=minyear26'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear26'
scalar x1=r(mean)
gen x1=`=x1'
summ rule if wbcode=="`ctry'" & year==`=maxyear26'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear26'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_rule=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly rule loggdppc2 if year==`=minyear26', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly rule loggdppc2 if year==`=maxyear26', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_rule2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_rule_diff=D_rule/D_rule2

if `=maxyear26'!=. & `=minyear26'!=. {
	* Figure 26: Rule of Law (vs World)
	lpoly rule loggdppc2 if year==`=minyear26', noscatter /*
	*/ title("Rule of Law, `=minyear26' and `=maxyear26'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Rule of Law") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear26'") lab(2 "`=maxyear26'"))	/*
	*/ addplot(lpoly rule loggdppc2 if year==`=maxyear26' || /*
	*/ scatter rule loggdppc2 if wbcode=="`ctry'" & year==`=minyear26', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter rule loggdppc2 if wbcode=="`ctry'" & year==`=maxyear26', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure26`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure26`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 econ_freedom

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & econ_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & econ_freedom!=.
scalar maxyear27=r(max)
local maxyear27: display %9.0f maxyear27
scalar minyear27=r(min)
local minyear27: display %9.0f minyear27

keep if year==`=minyear27' | year==`=maxyear27'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ econ_freedom if wbcode=="`ctry'" & year==`=minyear27'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear27'
scalar x1=r(mean)
gen x1=`=x1'
summ econ_freedom if wbcode=="`ctry'" & year==`=maxyear27'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear27'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_econ_freedom=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly econ_freedom loggdppc2 if year==`=minyear27', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly econ_freedom loggdppc2 if year==`=maxyear27', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_econ_freedom2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_econ_freedom_diff=D_econ_freedom/D_econ_freedom2

if `=maxyear27'!=. & `=minyear27'!=. {
	* Figure 27: Economic Freedom (vs World)
	lpoly econ_freedom loggdppc2 if year==`=minyear27', noscatter /*
	*/ title("Economic Freedom, `=minyear27' and `=maxyear27'") subtitle("`j'") note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
	*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Economic Freedom Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear27'") lab(2 "`=maxyear27'"))	/*
	*/ addplot(lpoly econ_freedom loggdppc2 if year==`=maxyear27' || /*
	*/ scatter econ_freedom loggdppc2 if wbcode=="`ctry'" & year==`=minyear27', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter econ_freedom loggdppc2 if wbcode=="`ctry'" & year==`=maxyear27', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure27`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure27`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 bus_freedom

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & bus_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & bus_freedom!=.
scalar maxyear28=r(max)
local maxyear28: display %9.0f maxyear28
scalar minyear28=r(min)
local minyear28: display %9.0f minyear28

keep if year==`=minyear28' | year==`=maxyear28'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ bus_freedom if wbcode=="`ctry'" & year==`=minyear28'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear28'
scalar x1=r(mean)
gen x1=`=x1'
summ bus_freedom if wbcode=="`ctry'" & year==`=maxyear28'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear28'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_bus_freedom=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly bus_freedom loggdppc2 if year==`=minyear28', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly bus_freedom loggdppc2 if year==`=maxyear28', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_bus_freedom2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_bus_freedom_diff=D_bus_freedom/D_bus_freedom2

if `=maxyear28'!=. & `=minyear28'!=. {
	* Figure 28: Business Freedom (vs World)
	lpoly bus_freedom loggdppc2 if year==`=minyear28', noscatter /*
	*/ title("Business Freedom, `=minyear28' and `=maxyear28'") subtitle("`j'") /*
	*/ note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
	*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
	*/ "and closing a business (time, cost, and recovery rate)" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Business Freedom score") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear28'") lab(2 "`=maxyear28'"))	/*
	*/ addplot(lpoly bus_freedom loggdppc2 if year==`=maxyear28' || /*
	*/ scatter bus_freedom loggdppc2 if wbcode=="`ctry'" & year==`=minyear28', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter bus_freedom loggdppc2 if wbcode=="`ctry'" & year==`=maxyear28', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure28`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure28`ctry'_2C.png") append
}
restore

********************************************************************************************************************************************************

****************************************************************
** COMPOSITION OF EXPORTS: HIGH-TECHNOLOGY EXPORTS PER CAPITA **
****************************************************************
gen tech_exp=log10(TX_VAL_TECH_CD/SP_POP_TOTL)
preserve
keep country wbcode year loggdppc2 tech_exp

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & tech_exp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & tech_exp!=.
scalar maxyear29=r(max)
local maxyear29: display %9.0f maxyear29
scalar minyear29=r(min)
local minyear29: display %9.0f minyear29

keep if year==`=minyear29' | year==`=maxyear29'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ tech_exp if wbcode=="`ctry'" & year==`=minyear29'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear29'
scalar x1=r(mean)
gen x1=`=x1'
summ tech_exp if wbcode=="`ctry'" & year==`=maxyear29'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear29'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_tech_exp=(10^(`=y2')-10^(`=y1'))/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly tech_exp loggdppc2 if year==`=minyear29', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly tech_exp loggdppc2 if year==`=maxyear29', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_tech_exp2=(10^(`=y4')-10^(`=y3'))/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_tech_exp_diff=D_tech_exp/D_tech_exp2

if `=maxyear29'!=. & `=minyear29'!=. {
	* Figure 29: High-technology exports (vs World)
	lpoly tech_exp loggdppc2 if year==`=minyear29', noscatter /*
	*/ title("High-technology exports per capita, `=minyear29' and `=maxyear29'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("High-technology exports per capita (current US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear29'") lab(2 "`=maxyear29'"))	/*
	*/ addplot(lpoly tech_exp loggdppc2 if year==`=maxyear29' || /*
	*/ scatter tech_exp loggdppc2 if wbcode=="`ctry'" & year==`=minyear29', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter tech_exp loggdppc2 if wbcode=="`ctry'" & year==`=maxyear29', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure29`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure29`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 diversity_rca

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & diversity_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & diversity_rca!=.
scalar maxyear30=r(max)
local maxyear30: display %9.0f maxyear30
scalar minyear30=r(min)
local minyear30: display %9.0f minyear30

keep if year==`=minyear30' | year==`=maxyear30'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ diversity_rca if wbcode=="`ctry'" & year==`=minyear30'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear30'
scalar x1=r(mean)
gen x1=`=x1'
summ diversity_rca if wbcode=="`ctry'" & year==`=maxyear30'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear30'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_diversity_rca=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly diversity_rca loggdppc2 if year==`=minyear30', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly diversity_rca loggdppc2 if year==`=maxyear30', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_diversity_rca2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_diversity_rca_diff=D_diversity_rca/D_diversity_rca2

if `=maxyear30'!=. & `=minyear30'!=. {
	* Figure 30: Diversity of exports (vs World)
	lpoly diversity_rca loggdppc2 if year==`=minyear30', noscatter /*
	*/ title("Diversity of exports, `=minyear30' and `=maxyear30'") subtitle("`j'") /*
	*/ note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
	*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database") /*
	*/ ytitle("Number of products exported with RCA") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear30'") lab(2 "`=maxyear30'"))	/*
	*/ addplot(lpoly diversity_rca loggdppc2 if year==`=maxyear30' || /*
	*/ scatter diversity_rca loggdppc2 if wbcode=="`ctry'" & year==`=minyear30', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter diversity_rca loggdppc2 if wbcode=="`ctry'" & year==`=maxyear30', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure30`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure30`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 eci_rca

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & eci_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & eci_rca!=.
scalar maxyear31=r(max)
local maxyear31: display %9.0f maxyear31
scalar minyear31=r(min)
local minyear31: display %9.0f minyear31

keep if year==`=minyear31' | year==`=maxyear31'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ eci_rca if wbcode=="`ctry'" & year==`=minyear31'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear31'
scalar x1=r(mean)
gen x1=`=x1'
summ eci_rca if wbcode=="`ctry'" & year==`=maxyear31'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear31'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_eci_rca=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly eci_rca loggdppc2 if year==`=minyear31', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly eci_rca loggdppc2 if year==`=maxyear31', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_eci_rca2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_eci_rca_diff=D_eci_rca/D_eci_rca2

if `=maxyear31'!=. & `=minyear31'!=. {
	* Figure 31: Economic Complexity Index (vs World)
	lpoly eci_rca loggdppc2 if year==`=minyear31', noscatter /*
	*/ title("Economic Complexity, `=minyear31' and `=maxyear31'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Economic Complexity Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear31'") lab(2 "`=maxyear31'"))	/*
	*/ addplot(lpoly eci_rca loggdppc2 if year==`=maxyear31' || /*
	*/ scatter eci_rca loggdppc2 if wbcode=="`ctry'" & year==`=minyear31', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter eci_rca loggdppc2 if wbcode=="`ctry'" & year==`=maxyear31', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure31`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure31`ctry'_2C.png") append
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
keep country wbcode year loggdppc2 coi_rca

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if loggdppc2!=. & year==`x' & coi_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & loggdppc2!=. & coi_rca!=.
scalar maxyear32=r(max)
local maxyear32: display %9.0f maxyear32
scalar minyear32=r(min)
local minyear32: display %9.0f minyear32

keep if year==`=minyear32' | year==`=maxyear32'

* Checking that we are using the same countries
bys wbcode: gen n=_n
bys wbcode: egen m=max(n)
drop if m!=2
drop n m

* Coordinates for country
summ coi_rca if wbcode=="`ctry'" & year==`=minyear32'
scalar y1=r(mean)
gen y1=`=y1'
summ loggdppc2 if wbcode=="`ctry'" & year==`=minyear32'
scalar x1=r(mean)
gen x1=`=x1'
summ coi_rca if wbcode=="`ctry'" & year==`=maxyear32'
scalar y2=r(mean)
gen y2=`=y2'
summ loggdppc2 if wbcode=="`ctry'" & year==`=maxyear32'
scalar x2=r(mean)
gen x2=`=x2'

* Slope for country
scalar D_coi_rca=(`=y2'-`=y1')/(10^(`=x2')-10^(`=x1'))

* Coordinates for world
lpoly coi_rca loggdppc2 if year==`=minyear32', at(loggdppc2) gen(pred1) nogr
summ pred1 if loggdppc2==x1
scalar y3=r(mean) 
lpoly coi_rca loggdppc2 if year==`=maxyear32', at(loggdppc2) gen(pred2) nogr
summ pred2 if loggdppc2==x2
scalar y4=r(mean)

* Slope for predicted country
scalar D_coi_rca2=(`=y4'-`=y3')/(10^(`=x2')-10^(`=x1'))

* Difference between real and predicted
scalar D_coi_rca_diff=D_coi_rca/D_coi_rca2

if `=maxyear32'!=. & `=minyear32'!=. {
	* Figure 32: Economic Complexity Index (vs World)
	lpoly coi_rca loggdppc2 if year==`=minyear32', noscatter /*
	*/ title("Complexity Outlook, `=minyear32' and `=maxyear32'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Complexity Outlook Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear32'") lab(2 "`=maxyear32'"))	/*
	*/ addplot(lpoly coi_rca loggdppc2 if year==`=maxyear32' || /*
	*/ scatter coi_rca loggdppc2 if wbcode=="`ctry'" & year==`=minyear32', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter coi_rca loggdppc2 if wbcode=="`ctry'" & year==`=maxyear32', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure32`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure32`ctry'_2C.png") append
}
restore
********************************************************************************************************************************************************
foreach var in urban_pop agr_gdp mnf_gdp ind_gdp ss_gdp emp_agr emp_ind emp_ss energypc kpw school prim sec univ journal research infant fertil life /*
*/ pop_g depend ctfp tax_gdp open demo rule econ_freedom bus_freedom tech_exp diversity_rca eci_rca coi_rca {
	capture noisily gen D_`var'=`=D_`var''
	capture noisily gen P_`var'=`=D_`var'2'
	capture noisily gen diff_`var'=`=D_`var'_diff'
}

forval x=1/32 {
	capture noisily gen minyear`x'=`=minyear`x''
	capture noisily gen maxyear`x'=`=maxyear`x''
}

preserve
collapse minyear1 maxyear1 D_urban_pop P_urban_pop diff_urban_pop
rename minyear1 minyear
rename maxyear1 maxyear
rename D_urban_pop slope
rename P_urban_pop pred
rename diff_urban_pop ratio
gen variable=1
save "temp1.dta", replace
restore

preserve
collapse minyear2 maxyear2 D_agr_gdp P_agr_gdp diff_agr_gdp
rename minyear2 minyear
rename maxyear2 maxyear
rename D_agr_gdp slope
rename P_agr_gdp pred
rename diff_agr_gdp ratio
gen variable=2
save "temp2.dta", replace
restore

preserve
collapse minyear3 maxyear3 D_mnf_gdp P_mnf_gdp diff_mnf_gdp
rename minyear3 minyear
rename maxyear3 maxyear
rename D_mnf_gdp slope
rename P_mnf_gdp pred
rename diff_mnf_gdp ratio
gen variable=3
save "temp3.dta", replace
restore

preserve
collapse minyear4 maxyear4 D_ind_gdp P_ind_gdp diff_ind_gdp
rename minyear4 minyear
rename maxyear4 maxyear
rename D_ind_gdp slope
rename P_ind_gdp pred
rename diff_ind_gdp ratio
gen variable=4
save "temp4.dta", replace
restore

preserve
collapse minyear5 maxyear5 D_ss_gdp P_ss_gdp diff_ss_gdp
rename minyear5 minyear
rename maxyear5 maxyear
rename D_ss_gdp slope
rename P_ss_gdp pred
rename diff_ss_gdp ratio
gen variable=5
save "temp5.dta", replace
restore

preserve
collapse minyear6 maxyear6 D_emp_agr P_emp_agr diff_emp_agr
rename minyear6 minyear
rename maxyear6 maxyear
rename D_emp_agr slope
rename P_emp_agr pred
rename diff_emp_agr ratio
gen variable=6
save "temp6.dta", replace
restore

preserve
collapse minyear7 maxyear7 D_emp_ind P_emp_ind diff_emp_ind
rename minyear7 minyear
rename maxyear7 maxyear
rename D_emp_ind slope
rename P_emp_ind pred
rename diff_emp_ind ratio
gen variable=7
save "temp7.dta", replace
restore

preserve
collapse minyear8 maxyear8 D_emp_ss P_emp_ss diff_emp_ss
rename minyear8 minyear
rename maxyear8 maxyear
rename D_emp_ss slope
rename P_emp_s pred
rename diff_emp_ss ratio
gen variable=8
save "temp8.dta", replace
restore

preserve
collapse minyear9 maxyear9 D_energypc P_energypc diff_energypc
rename minyear9 minyear
rename maxyear9 maxyear
rename D_energypc slope
rename P_energypc pred
rename diff_energypc ratio
gen variable=9
save "temp9.dta", replace
restore

preserve
collapse minyear10 maxyear10 D_kpw P_kpw diff_kpw
rename minyear10 minyear
rename maxyear10 maxyear
rename D_kpw slope
rename P_kpw pred
rename diff_kpw ratio
gen variable=10
save "temp10.dta", replace
restore

preserve
collapse minyear11 maxyear11 D_school P_school diff_school
rename minyear11 minyear
rename maxyear11 maxyear
rename D_school slope
rename P_school pred
rename diff_school ratio
gen variable=11
save "temp11.dta", replace
restore

preserve
collapse minyear12 maxyear12 D_prim P_prim diff_prim
rename minyear12 minyear
rename maxyear12 maxyear
rename D_prim slope
rename P_prim pred
rename diff_prim ratio
gen variable=12
save "temp12.dta", replace
restore

preserve
collapse minyear13 maxyear13 D_sec P_sec diff_sec
rename minyear13 minyear
rename maxyear13 maxyear
rename D_sec slope
rename P_sec pred
rename diff_sec ratio
gen variable=13
save "temp13.dta", replace
restore

preserve
collapse minyear14 maxyear14 D_univ P_univ diff_univ
rename minyear14 minyear
rename maxyear14 maxyear
rename D_univ slope
rename P_univ pred
rename diff_univ ratio
gen variable=14
save "temp14.dta", replace
restore

preserve
collapse minyear15 maxyear15 D_journal P_journal diff_journal
rename minyear15 minyear
rename maxyear15 maxyear
rename D_journal slope
rename P_journal pred
rename diff_journal ratio
gen variable=15
save "temp15.dta", replace
restore

preserve
capture noisily {
collapse minyear16 maxyear16 D_research P_research diff_research
rename minyear16 minyear
rename maxyear16 maxyear
rename D_research slope
rename P_research pred
rename diff_research ratio
gen variable=16
save "temp16.dta", replace
}
restore

preserve
collapse minyear17 maxyear17 D_infant P_infant diff_infant
rename minyear17 minyear
rename maxyear17 maxyear
rename D_infant slope
rename P_infant pred
rename diff_infant ratio
gen variable=17
save "temp17.dta", replace
restore

preserve
collapse minyear18 maxyear18 D_fertil P_fertil diff_fertil
rename minyear18 minyear
rename maxyear18 maxyear
rename D_fertil slope
rename P_fertil pred
rename diff_fertil ratio
gen variable=18
save "temp18.dta", replace
restore

preserve
collapse minyear19 maxyear19 D_life P_life diff_life
rename minyear19 minyear
rename maxyear19 maxyear
rename D_life slope
rename P_life pred
rename diff_life ratio
gen variable=19
save "temp19.dta", replace
restore

preserve
collapse minyear20 maxyear20 D_pop_g P_pop_g diff_pop_g
rename minyear20 minyear
rename maxyear20 maxyear
rename D_pop_g slope
rename P_pop_g pred
rename diff_pop_g ratio
gen variable=20
save "temp20.dta", replace
restore

preserve
collapse minyear21 maxyear21 D_depend P_depend diff_depend
rename minyear21 minyear
rename maxyear21 maxyear
rename D_depend slope
rename P_depend pred
rename diff_depend ratio
gen variable=21
save "temp21.dta", replace
restore

preserve
collapse minyear22 maxyear22 D_ctfp P_ctfp diff_ctfp
rename minyear22 minyear
rename maxyear22 maxyear
rename D_ctfp slope
rename P_ctfp pred
rename diff_ctfp ratio
gen variable=22
save "temp22.dta", replace
restore

preserve
collapse minyear23 maxyear23 D_tax_gdp P_tax_gdp diff_tax_gdp
rename minyear23 minyear
rename maxyear23 maxyear
rename D_tax_gdp slope
rename P_tax_gdp pred
rename diff_tax_gdp ratio
gen variable=23
save "temp23.dta", replace
restore

preserve
collapse minyear24 maxyear24 D_open P_open diff_open
rename minyear24 minyear
rename maxyear24 maxyear
rename D_open slope
rename P_open pred
rename diff_open ratio
gen variable=24
save "temp24.dta", replace
restore

preserve
collapse minyear25 maxyear25 D_demo P_demo diff_demo
rename minyear25 minyear
rename maxyear25 maxyear
rename D_demo slope
rename P_demo pred
rename diff_demo ratio
gen variable=25
save "temp25.dta", replace
restore

preserve
collapse minyear26 maxyear26 D_rule P_rule diff_rule
rename minyear26 minyear
rename maxyear26 maxyear
rename D_rule slope
rename P_rule pred
rename diff_rule ratio
gen variable=26
save "temp26.dta", replace
restore

preserve
collapse minyear27 maxyear27 D_econ_freedom P_econ_freedom diff_econ_freedom
rename minyear27 minyear
rename maxyear27 maxyear
rename D_econ_freedom slope
rename P_econ_freedom pred
rename diff_econ_freedom ratio
gen variable=27
save "temp27.dta", replace
restore

preserve
collapse minyear28 maxyear28 D_bus_freedom P_bus_freedom diff_bus_freedom
rename minyear28 minyear
rename maxyear28 maxyear
rename D_bus_freedom slope
rename P_bus_freedom pred
rename diff_bus_freedom ratio
gen variable=28
save "temp28.dta", replace
restore

preserve
collapse minyear29 maxyear29 D_tech_exp P_tech_exp diff_tech_exp
rename minyear29 minyear
rename maxyear29 maxyear
rename D_tech_exp slope
rename P_tech_exp pred
rename diff_tech_exp ratio
gen variable=29
save "temp29.dta", replace
restore

preserve
collapse minyear30 maxyear30 D_diversity_rca P_diversity_rca diff_diversity_rca
rename minyear30 minyear
rename maxyear30 maxyear
rename D_diversity_rca slope
rename P_diversity_rca pred
rename diff_diversity_rca ratio
gen variable=30
save "temp30.dta", replace
restore

preserve
collapse minyear31 maxyear31 D_eci_rca P_eci_rca diff_eci_rca
rename minyear31 minyear
rename maxyear31 maxyear
rename D_eci_rca slope
rename P_eci_rca pred
rename diff_eci_rca ratio
gen variable=31
save "temp31.dta", replace
restore

preserve
collapse minyear32 maxyear32 D_coi_rca P_coi_rca diff_coi_rca
rename minyear32 minyear
rename maxyear32 maxyear
rename D_coi_rca slope
rename P_coi_rca pred
rename diff_coi_rca ratio
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
order variable minyear maxyear
export excel using "$dir\table`ctry'3", firstrow(var) sheetreplace

*************************************************************************************

scalar drop _all
macro drop _all
erase "temp.dta"
forval x=1/32{
	capture noisily erase "temp`x'.dta"
}
