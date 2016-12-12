* International vs. Domestic Price of Quinoa *

use "/Users/rtenorio/Google Drive/Archives/Microeconomics of Development_Dreamteam/Final Paper - Quinoa/Data/master data and merge/master.dta", clear

rename price price_intl

label variable price_intl "International Price per Kilo in USD"

merge m:1 year using "/Users/rtenorio/Google Drive/Archives/Microeconomics of Development_Dreamteam/Final Paper - Quinoa/Data/national_prod_price_exp.dta", nogen

* convert price domestic to USD
replace price_dom = price_dom/ex_rate

label variable price_dom "Domestic Price per Kilo in USD"

line price_dom price_intl year, title("Quinoa Prices in USD (2004-2012)") saving("/Users/rtenorio/Google Drive/Archives/Microeconomics of Development_Dreamteam/Final Paper - Quinoa/graphs/intl_dom_price.gph")

save "master_mar_2.dta", replace
