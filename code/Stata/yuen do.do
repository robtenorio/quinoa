*Independent Study
*Comparison of crops produced in Peru

clear 
cd "C:\Users\Yuen HO\Google Drive\Ind Study Powerhouse\Data"
set more off

*Comparsison of crops produced in Peru by hectare
import excel using "crop production", sheet ("final2") firstrow clear

graph bar (max) potato rice Hardyellowcorn yucca wheat quinoa if Year >= 2004, ///
over(Year) asyvars title("Production of Staple Crops in Peru") ytitle("Production by thousands of metric tons") legend(label(1 "Potato") label(2 "Rice") label(3 "Corn") label(4 "Yucca") label(5 "Wheat") label(6 "Quinoa"))

save using "crop_production", replace
