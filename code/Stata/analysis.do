**********
*Analysis*
**********

clear
set more off
cd "C:\Users\Yuen HO\Google Drive\Ind Study Powerhouse\Data\master data and merge"

use "merged_food_basket_2004_2011", clear

**Basic Engel curve estimations
*Using annual expenditure data (not indexed)
reg quin_tot_an_exp ln_exphhgross agdummy rural hhearn tothhmem, robust 

*Adding controls for all other foods
reg quin_tot_an_exp ln_exphhgross agdummy rural hhearn tothhmem biscuit_tot_an_exp-sweet_potato_tot_an_exp, robust

