/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         color_detection
# File Description: top module for color sensor arrengement.
*/

module color_detection(
	input clk_1MHz, cs_out,
	output  [1:0] filter,Stable_Color,
	 output  s0, s1, s2, s3, oe
//	 output clk_1MHz
);

wire color;

colordet cdt(clk_1MHz, cs_out,filter, color,
	 s0, s1, s2, s3, oe);
	 
	 
//Frequency_Scaling #(.COUNTER_WIDTH(5), .MAX_COUNT(24)) fqs1MZ (clk_50m, clk_1MHz);

Stable_Color SC(
.clk(clk_50m),
.rst(),
.color_current(color),
.color_prev(Stable_Color)
);

endmodule