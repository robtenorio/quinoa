* generate graph for consumption and price

use master_mar_2.dta, clear

* generate graph for HH consumption of Quinoa and Domestic Price
twoway (line perc_quin_cons year, yaxis(1)) (line GDP_change year, yaxis(1)) (line price_dom year, yaxis(2)) if dep == "Peru"

* generate Peru-level tonnage variables

*****************************************
* Add Peru Total Metric Tons Produced   *
*****************************************

replace ton = 26997 if dep == "Peru" & year == 2004
replace ton = 32590 if dep == "Peru" & year == 2005
replace ton = 30428 if dep == "Peru" & year == 2006
replace ton = 31824 if dep == "Peru" & year == 2007
replace ton = 29867 if dep == "Peru" & year == 2008
replace ton = 39397 if dep == "Peru" & year == 2009
replace ton = 41079 if dep == "Peru" & year == 2010
replace ton = 41182 if dep == "Peru" & year == 2011
replace ton = 44213 if dep == "Peru" & year == 2012

*****************************************
* Add Peru Domestic Price in USD Data   *
*****************************************

replace price_dom = 1.11 if dep == "Peru" & year == 2004
replace price_dom = 1.16 if dep == "Peru" & year == 2005
replace price_dom = 1.18 if dep == "Peru" & year == 2006
replace price_dom = 1.22 if dep == "Peru" & year == 2007
replace price_dom = 1.60 if dep == "Peru" & year == 2008
replace price_dom = 3.36 if dep == "Peru" & year == 2009
replace price_dom = 3.38 if dep == "Peru" & year == 2010
replace price_dom = 3.68 if dep == "Peru" & year == 2011
replace price_dom = 3.88 if dep == "Peru" & year == 2012

sort year

by year: egen ex_rate_new = max(ex_rate)

generate price_dom_peru = price_dom/ex_rate_new if dep == "Peru"

* create graph of price and production
twoway (line price_dom_peru year, yaxis(1)) (line ton year, yaxis(2)) if dep == "Peru"

