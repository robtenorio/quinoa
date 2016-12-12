use "enaho01-2004-601.dta", clear

set more off

egen x = count(1), by(produc61)
 
list produc61 x

keep if x >= 19000

save "produc61.dta", replace

log using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Do Files/produc61.log", replace

tab produc61

label list produc61

log close

codebookout "produc61_2004_2.xlsx", replace
