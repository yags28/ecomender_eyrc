/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         lfa_assembly
# File Description: interface adc+lfa and deviation control
*/

module LFA_asssembly(
	clk_3_125M,
	dout,
	adc_cs_n,
	din,
	deviation,
	tap_left,
	tap_centre,
	tap_right,
	is_line,
	is_node
);


input wire	clk_3_125M;
input wire	dout;
output wire	adc_cs_n;
output wire	din;
output wire	[2:0] deviation;
output wire [11:0]	tap_left, tap_centre, tap_right;
output wire is_line, is_node;


ADC_Controller	b2v_inst(
	.dout(dout),
	.adc_sck(clk_3_125M),
	.adc_cs_n(adc_cs_n),
	.din(din),
	.center_value(tap_centre),
	.left_value(tap_left),
	.right_value(tap_right));


/*
Purpose:
---
deviation control sets the threshold for the lfa values and returns a  3 bit value for the state of line below the lfa sensor array
*/

// redo this instantiation as the module IO has changed and also the parametrs have changed
DeviationControl	b2v_inst2(
	.center_value(tap_centre),
	.left_value(tap_left),
	.right_value(tap_right),
	.lfa_input(deviation),
	.is_line(is_line),
	.is_node(is_node),
	.lost_path()
	);


endmodule