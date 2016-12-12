cd "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/master data and merge"

use "global_quinoa_demand.dta", clear

drop if year == 2002 | year == 2003 | year == 2013

sort year importer 
by year importer: generate world_imports = sum(quantity_000) if importer == "All"

by year: egen world_imports_tot = max(world_imports)

sort year importer 
by year importer: generate us_imports = sum(quantity_000) if importer == "USA"

by year: egen us_imports_tot = max(us_imports)

sort year importer 
by year importer: generate can_imports = sum(quantity_000) if importer == "CAN"

by year: egen can_imports_tot = max(can_imports)

sort year importer 
by year importer: generate eu_imports = sum(quantity_000) if importer == "EU27"

by year: egen eu_imports_tot = max(eu_imports)

drop world_imports us_imports eu_imports can_imports

generate world_imports = world_imports_tot - us_imports_tot - eu_imports_tot - can_imports_tot

drop world_imports_tot 

label variable us_imports_tot "US Imports"
label variable world_imports "ROW Imports"
label variable eu_imports_tot "EU27 Imports"
label variable can_imports_tot "CAN Imports"

merge m:1 year using "master_price.dta"

gen value = value_000*1000
gen quantity = value/price
gen quantity_000 = quantity/1000
label variable quantity_000 "000s of kilos"

graph bar (max) world_imports us_imports_tot eu_imports_tot can_imports_tot if year != 2012, ///
over(year) asyvars stack title("Global Import Demand for Quinoa") ytitle("000s kilos") legend(label(1 "World") label(2 "US") label(3 "EU27") label(4 "CAN"))

save global_quinoa_demand.dta, replace











