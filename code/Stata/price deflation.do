* Almost Ideal Demand System - Deaton Muellbauer, 1980
use master.dta, clear

set more off
* first lets adjust all the income and price data to real 2012 soles

* create a Laspeyres index using all the goods in our food basket, with 2012 as the base

local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "avocado" "grape" "pear" "strawberry" "passion_fruit" "granadilla" "chirimoya" "papaya" "watermelon" "peanut" "lentil" "sweet_potato" "quinoa" "'

* first calculate the base price and base expenditure proportions for all foods

* calculate the mean price for all years
foreach k of local foods {
	bysort year: egen `k'_price_year = mean(`k'_price) 
	label variable `k'_price_year "The mean price of `k' products for HHs in 2012"
	}

* create the base price for year = 2012
foreach k of local foods {
	generate `k'_price_2012_temp = `k'_price_year if year == 2012
	}

foreach k of local foods {
	egen `k'_price_2012 = max(`k'_price_2012_temp)
	}

* calculate the mean expenditure proportion for all years
foreach k of local foods {
	bysort year: egen `k'_per_fexp_year = mean(`k'_per_totan_fexp) 
	label variable `k'_per_fexp_year "The mean expenditure  of `k' products by total food expenditure by year"
	}

* create the base food expenditure proportion for year = 2012
foreach k of local foods {
	generate `k'_per_fexp_2012_temp = `k'_per_fexp_year if year == 2012
	}

foreach k of local foods {
	egen `k'_per_fexp_2012 = max(`k'_per_fexp_2012_temp)
	}

* now divide the price in each year for each food by the base year price for that food
foreach k of local foods {
	generate `k'_price_ratio = `k'_price_year/`k'_price_2012
	label variable `k'_price_ratio "The price ratio of year t to year 2012 for `k'"
	}

* then sum the price ratio
egen price_ratio_sum = rowtotal(rice_price_ratio-quinoa_price_ratio)

* now multiply the price ratio by the food expenditure proportion in 2012

foreach k of local foods {
	gen `k'_prod_ratios = `k'_price_ratio*`k'_per_fexp_2012
	}

egen food_price_index = rowtotal(rice_prod_ratio-quinoa_prod_ratio)
label variable food_price_index "Laspeyres Index for Food Basket"

drop rice_price_year-quinoa_prod_ratios

*****************************
* Create Imputed Price Data *
*****************************

foreach k of local foods {
	bysort year dep: egen `k'_price_temp = mean(`k'_price)
	
	replace `k'_price = `k'_price_temp if missing(`k'_price)
	
	drop `k'_price_temp
	
	}

**********************************
* Deflate Prices and Expenditure *
**********************************

foreach var of varlist *_tot_an_exp  {
	gen `var'_def = `var'/food_price_index
	
	label variable `var'_def "Deflated `var' for CPI"
	}

	* generate log versions of deflated prices
foreach var of varlist rice_price-quinoa_price {
	gen `var'_def = `var'/food_price_index
	
	label variable `var'_def "Deflated `var' for CPI"
	}

gen totan_fexp_def = totan_fexp/food_price_index
label variable totan_fexp_def "Total annual deflated food basket expenditure"

foreach var of varlist *_price_def {
	gen ln_`var' = ln(`var')
	label variable ln_`var' "nat log of `var'"
	}

* generate the linear approximation of the nonlinear price index P

foreach k of local foods {
	gen `k'_P_temp = `k'_per_totan_fexp*ln_`k'_price_def
	}

egen P = rowtotal(rice_P_temp-quinoa_P_temp)

generate ln_P = ln(P)
label variable ln_P "Index P for the AIDS Model"

drop *_P_temp
	
gen X_P = totan_fexp_def/ln_P

* FINALLY RUN SOME MUTHA FUCKIN' REGRESSIONS

local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "avocado" "grape" "pear" "strawberry" "passion_fruit" "granadilla" "chirimoya" "papaya" "watermelon" "peanut" "lentil" "sweet_potato" "quinoa" "'
set more off
foreach k of local foods {

	preserve 
	
	drop ln_`k'_price_def
	
	reg `k'_per_totan_fexp ln_*_price_def X_P if `k'_producer != 1 [pweight=factor07], robust
	
	restore
	}


















































