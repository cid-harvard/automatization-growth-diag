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


**************************************************************************************************
********************************** LOW EXPECTED PRIVATE RETURNS **********************************
**************************************************************************************************

**********************************************************************
************************* LOW SOCIAL RETURNS *************************
**********************************************************************

***********************************************************************
************************* LOW APPROPRIABILITY *************************
***********************************************************************

