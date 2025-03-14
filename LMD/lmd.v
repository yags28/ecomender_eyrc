/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         lmd (lfa motor driver)
# File Description: top module for complete line following and motor driver assembly.
# important modules: LFA_asssembly, motor_driver_upper, motor_driver_lower
*/

module lmd(
    clk_3125,
    dout_adc,
    reset,
    din_adc,
    adc_clk,
    MD_ENA,
    MD_ENB,
    MD_IN1,
    MD_IN2,
    MD_IN3,
    MD_IN4,
    tap_dest_reached,
    adc_cs,
    tap_current_node,
    tap_left,
    tap_centre,
    tap_right,
    go_go,
    node_found,
	 dir_out,
	 dir_arr_len,
	 run_done,
	 cpu_done
);


input wire    clk_3125;
input wire  dout_adc;
input wire  reset;
output wire din_adc;
output wire adc_clk;
output wire MD_ENA;
output wire MD_ENB;
output wire MD_IN1;
output wire MD_IN2;
output wire MD_IN3;
output wire MD_IN4;
output wire tap_dest_reached;
output wire adc_cs;
output wire [3:0] tap_current_node;
output wire [11:0] tap_left;
output wire [11:0] tap_centre;
output wire [11:0] tap_right;
input wire go_go;
output wire node_found;
input wire [1:0] dir_out;
input wire [3:0] dir_arr_len;
input wire run_done, cpu_done;



wire    SYNTHESIZED_WIRE_9;
wire    [2:0] SYNTHESIZED_WIRE_6;
wire    [1:0] SYNTHESIZED_WIRE_7;
wire 	  speed_turn_w;

assign  adc_clk = clk_3125;

// parameter [13:0] TURN_REGISTER_VALUE = 13'b01010110101011; //01010110101011
//reg [1:0] turn_reg_array [11:0];
//
//wire [13:0] turn_register; // idx 
//	 
//assign turn_register = {turn_reg_array[11], turn_reg_array[10], turn_reg_array[9], 
//                            turn_reg_array[8], turn_reg_array[7], turn_reg_array[6], 
//                            turn_reg_array[5], turn_reg_array[4], turn_reg_array[3], 
//                            turn_reg_array[2], turn_reg_array[1], turn_reg_array[0]};


// try reducing the clock below 3.125Mhz for lower resource useage?
LFA_asssembly   b2v_inst2(
    .clk_3_125M(clk_3125),
    .dout(dout_adc),
    .adc_cs_n(adc_cs),
    .din(din_adc),
    .is_line(SYNTHESIZED_WIRE_9),
    .is_node(node_found),
    .deviation(SYNTHESIZED_WIRE_6),
    .tap_centre(tap_centre),
    .tap_left(tap_left),
    .tap_right(tap_right));

motor_driver_upper  b2v_inst(
    .clk(clk_3125),
    .reset(reset),
    .node_detected(node_found),
    .line_found(SYNTHESIZED_WIRE_9),
    .turn_register(turn_register),
    .dest_reached(tap_dest_reached),
    .current_node(tap_current_node),
    .direction(SYNTHESIZED_WIRE_7),
    .go_go(go_go),
    .speed_turn(speed_turn_w),
	 .dir_out(dir_out),
	 .dir_arr_len(dir_arr_len),
	 .run_done(run_done),
	 .cpu_done(cpu_done)
    );

motor_driver_lower  b2v_instre(
    .clk(clk_3125),
    .reset(reset),
    .line_found(SYNTHESIZED_WIRE_9),
    .lfa_input(SYNTHESIZED_WIRE_6),
    .direction(SYNTHESIZED_WIRE_7),
    .enA(MD_ENA),
    .enB(MD_ENB),
    .in1(MD_IN1),
    .in2(MD_IN2),
    .in3(MD_IN3),
    .in4(MD_IN4),
    .dest_reached(tap_dest_reached),
    .go_go(go_go),
    .speed_turn(speed_turn_w));

endmodule
