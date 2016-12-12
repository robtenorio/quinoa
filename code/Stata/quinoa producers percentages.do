forvalues year = 2004/2012 {
	count if rice_producer == 1 & year == `year'
	tab obs_year if year == `year'
	}
	
display 695/19577 // .036
display 706/19916 // .035
display 756/20641 // .037
display 887/22204 //.04
display 760/21502 // .035
display 836/21753 // .038
display 900/21496 // .042
display 888/24809 // .036
display 792/25091 // .032
