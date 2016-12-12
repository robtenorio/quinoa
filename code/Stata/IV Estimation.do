* using international prices as an instrument

* structural equation
reg ln_quinoa_tot_an_exp_def ln_moexphh_def rural earner_per_mem ///
if quinoa_producer == 1 [pweight=factor07], robust

* first stage
reg ln_moexphh_def ln_price_soles_def rural earner_per_mem if quinoa_producer == 1 ///
[pweight=factor07], robust

* 2SLS
ivreg ln_quinoa_tot_an_exp_def rural earner_per_mem (ln_moexphh_def=ln_price_soles_def) ///
[pweight=factor07], robust

