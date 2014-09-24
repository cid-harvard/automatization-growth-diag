cap prog drop polyarrows
prog polyarrows
syntax varlist [if/] , year1(int) year2(int) /// 
   [ Countrycode(varname) Region(varname) year(varname) /// 
   Saving(name) PATHto(str) Name(name) INside(numlist) /// 
   xlog ylog ci hidey1 hidey2 HIDEARROWs /// 
   LHorizon(int 0) FHorizon(int 0) * ]

/// SYNTAX:

/// polyarrows yvar xvar [if], year1(int) year2(int) [ options ]

/// If only one var is given, script assumes it is the xvar, 
/// and defaults to yvar="LGDPPCKD" (log GDP per capita).
/// Unless you have a variable named LGDPPCKD, you need to 
/// specify a yvar!!

/// IMPORTANT OPTIONS:

/// countrycode(): Country ID. Default is "countrycode". 

/// region(): These are the country groups used for the arrows.
/// Default is "region"; also, removes Aggregates, N. America & S. Asia.
/// (in future, I would want to put N. America with W. Europe
/// and S. Asia with E. Asia & Pacific)

/// year(): The time variable. Default is "year."

/// inside(): Determines where the legend goes (clock position)

/// LESS IMPORTANT:

/// xlog and ylog: Pretty log scales, in powers of 10.

/// hidey1, hidey2 and hidearrows: These hide, respectively, the 
/// lines for year1, for year2, and the arrows. Can be combined.
/// The rest of the graph is exactly the same, so they're great
/// for making ppt slides where you add one line at a time.
/// Specifically, I'd do three graphs: first "hidey2 hidearrows",
/// then just "hidearrows", then none of them.

/// lhorizon(Tx) and fhorizon(Ty): Interpolates missing values 
/// from the Tx years before and/or Ty years after the year1 and 
/// year2 you specify. Never really works that well, though.

/// saving() and pathto(): For saving the graph.

/// name(): For naming the graph. Useful with the hidey options.

/// ci: Changes the lpoly's to lpolyci's. Never actually tried it.

/*
SOME EXAMPLES USING WDIv2012:

polyarrows sp_urb_totl_i, year1(1970) year2(2010) name(urb) in(4)
polyarrows sp_dyn_tfrt_in, year1(1970) year2(2010) name(fert) in(2)
polyarrows it_net_user_p2, year1(1995) year2(2010) name(net) in(4)

polyarrows nv_ind_manf_zs, year1(1980) year2(2010) name(manuf_va) in(2)
polyarrows nv_ind_totl_zs, year1(1980) year2(2010) name(ind_va) in(4)
polyarrows nv_agr_totl_zs, year1(1980) year2(2010) name(agr_va) in(2)
polyarrows nv_srv_tetc_zs, year1(1980) year2(2010) name(srv_va) in(4)

*Using hidey options:
polyarrows sl_ind_empl_zs, year1(1980) year2(2010) name(ind_emp) in(4) hidey2 hidearrows
polyarrows sl_ind_empl_zs, year1(1980) year2(2010) name(ind_emp) in(4) hidearrows
polyarrows sl_ind_empl_zs, year1(1980) year2(2010) name(ind_emp) in(4)

*/

if wordcount("`varlist'")==2 { 
   local yvar = word("`varlist'",1)
   local xvar = word("`varlist'",2)
}
else if wordcount("`varlist'")==1 { 
   *local yvar = "ny_gdp_pcap_kd"
   local xvar = "LGDPPCKD"
   local yvar = "`varlist'"
   local xfmt = `"ylab(, format("%4.2f"))"'
}

if "`region'"=="" local region = "region"
local regif = /// 
 `" & `region'~="Aggregates" & `region'~="North America" & `region'~="South Asia" & `region'~="" "'

cap drop badreg
qui gen badreg = /// 
 strmatch(`region',"*(all income levels)*")
su badreg, meano
if r(max)==1 { 
   cap qui gen `region'_original = `region'
   local badlen = length(" (all income levels)")
   qui replace `region' = /// 
    substr(`region',1,length(`region')-`badlen') /// 
    if badreg==1
}
drop badreg

if "`countrycode'"=="" local countrycode = "countrycode"
if "`year'"=="" local year = "year"

if "`if'"~="" local aif = "& `if'"

if "`name'"=="" & "`saving'"~="" /// 
 local name = "`saving'"
else if "`saving'"=="_1" | "`saving'"=="_2" | "`saving'"=="_3" /// 
 local saving = "`name'`saving'"

if "`name'"~="" local name = "name(`name', replace)"

* Graph labels:

foreach dim in x y { 
   mata `dim'tit = st_varlabel("``dim'var'")
   mata st_strscalar("`dim'tit",`dim'tit)
   local `dim'tit = `dim'tit
   
   if "``dim'tit'"~="" /// 
    local `dim'tit = `"`dim'tit("``dim'tit'")"'
   
   else local `dim'tit = `"`dim'tit("``dim'var'")"'
}

*Interpolation:
if `lhorizon'~=0 & `fhorizon'~=0 { 
	
	tempvar ift tempx tempy
	
	qui gen `ift' = (`year'>=(`year1'-`lhorizon') /// 
	 & `year'<=(`year1'+`fhorizon')) /// 
	 | (`year'>=(`year2'-`lhorizon') /// 
	 & `year'<=(`year2'+`fhorizon'))
	
	qui bys `countrycode': /// 
	 ipolate `xvar' `year' if `ift', gen(`tempx')
	qui bys `countrycode': /// 
	 ipolate `yvar' `year' if `ift', gen(`tempy')
	
	local xvar = "`tempx'"
	local yvar = "`tempy'"
}

cap enc `countrycode', g(ccode)
qui tsset ccode `year'

/*
su `year', meano
local yearmin = r(min)
local yearmax = r(max)
if `year1'==-1 local year1 `yearmin'
if `year2'==-1 local year2 `yearmax'
*/
local delta = `year2'-`year1'

tempvar ismiss
qui gen `ismiss' = /// 
 mi(`xvar',`yvar',f`delta'.`xvar',f`delta'.`yvar') /// 
 if `year'==`year1'
qui replace `ismiss' = l`delta'.`ismiss' if `year'==`year2'

local if = "if year==`year1' & ~`ismiss'"

foreach var in `yvar' `xvar' { 
   cap drop f`var'
   cap drop R`var'
   cap drop fR`var'
   
   qui gen f`var' = f`delta'.`var'
   
   qui egen R`var' = mean(`var') /// 
    if ~`ismiss' `aif' `regif', by(`region' `year')
   qui gen fR`var' = f`delta'.R`var'
}

cap drop tagRy
qui egen tagRy = tag(`region' `year') if ~`ismiss'
cap qui egen tagcy = tag(`countrycode' `year')

foreach dim in x y { 
   su ``dim'var' if ~`ismiss' & (year==`year1' | /// 
    year==`year2') `aif' `regif', meano
   local `dim'min = r(min)
   local `dim'max = r(max)
   
   if "``dim'log'"~="" { 
      local `dim'minl = ceil(log10(``dim'min'))
      local `dim'maxl = floor(log10(``dim'max'))   

      forval tick = ``dim'minl'/``dim'maxl' {
         local `dim'tlab = "``dim'tlab' "+string(10^`tick')
      }
      
      local `dim'axis = /// 
       "`dim'sc(log) `dim'lab(``dim'tlab',nogrid labs(*.9))"
   }
   else local `dim'axis = /// 
    "`dim'lab(#7,nogrid labs(*.9))"
}

* Graph formats:

local tit = "si(*1.15) m(small)"
local tit = "ytit(, `tit') xtit(,`tit')"
local cleangr = "graphr(fc(white) lc(white)) `tit'"

local squaregr = "aspect(1, place(l))"
local mlab = /// 
   "mlabp(0 ..) mlabc(black ..) mlabs(*.67 ..) mlab"
local grid = "lab(, grid glc(gs14) glw(*.6))"
local scatteri = "m(i) c(l) lc(black) lp(dash) lw(*0.7)"

local plw = "lw(*2)"

local c_arrow = "black"
local c_arrow = "lc(`c_arrow') mc(`c_arrow')"

if "`inside'"~="" { 
   local pos `inside'
   local ring = "ring(0)"
}
else local pos 2

* Hiding options:
if "`hidey1'"~="" {
   local hidey1 = "lc(none)"
}
if "`hidey2'"~="" {
   local hidey2 = "lc(none)"
}
if "`hidearrows'"~="" {
   local hidearrows = "lc(none) mc(none) mlabs(zero) mlabc(white)"
}

* Create graph:

qui count `if' & tagcy `aif' `regif'
noi di in gr "N = " in ye r(N)


tw lpoly`ci' `yvar' `xvar' `if' `aif' `regif' /// 
& tagcy, `plw' `hidey1' || lpoly`ci' f`yvar' f`xvar' /// 
`if' `aif' `regif' & tagcy, `plw' `hidey2' || /// 
pcarrow R`yvar' R`xvar' fR`yvar' fR`xvar' /// 
`if' `aif' `regif' & tagRy, /// 
`cleangr' `squaregr' y`grid' `yfmt' /// 
`mlab'(`region') `c_arrow' `name' /// 
`xtit' `ytit' `xaxis' `yaxis' scale(*.95) /// 
leg(`ring' pos(`pos') col(1) reg(lc(white)) /// 
bm(medium) si(*.75) order(1 2) symy(*0.5) /// 
lab(1 "`year1'") lab(2 "`year2'")) /// 
`hidearrows' `options'


qui if "`saving'"~="" { 
   graph export `pathto'`saving'.eps, replace
   graph export `pathto'`saving'.png, replace
}

foreach var in `yvar' `xvar' { 
   cap drop f`var'
   cap drop fR`var'
}
cap drop tempx tempy

end
