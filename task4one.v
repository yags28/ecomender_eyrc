/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         task4one
# File Description: this is the top level module for the entire project.
*/

module task4one (
    input wire clk,                // Main clock signal
    input wire reset,              // Reset signal
    input wire cs_out,             // Color sensor output as input to fpga
	input wire dout,
//	input wire ir_input,
	input wire uart_rx, 
   output wire adc_cs_n, din, adc_clk,
	output s0w, s1w, s2w, s3w, // color sensor interface registers
	output wire oew,
   output wire enA, enB,          // Motor driver enable pins
   output wire in1, in2, in3, in4, // Motor driver input pins
   output wire [2:0] led1, led2, led3, led4,// LED output pins	 
	output wire [1:0] color, //Non_RGB_Col_Prev  ,   // Detected color
	output wire uart_tx,           // UART transmit
//	output wire [11:0] lv, cv, rv,
// 	output wire  sarm_pwm,           
//    output wire  sclaw_pwm,
   input wire ir_in,
	output wire place_done,pick_done,sclaw_pwm,sarm_pwm
   
);

// Internal signals
wire [1:0] filter, prevCol;                // Filter state from color detection module
wire [1:0] upper_node_direction;  // Upper module motor direction
wire [2:0] upper_node_speed;      // Upper module motor speed
wire [5:0] deviation;             // Deviation from line follower
wire [3:0] curr_pos;
wire is_node, dest_reached, is_line;	
wire clk_1MHZ;
wire go_go;
reg node_pos;
wire node_mila;
wire obstacle_detected;
wire [3:0] gripper_state;
wire pick_mode;
wire start_grip;
wire msg_rec;
wire [1:0] data_out;
wire [3:0] dir_arr_len;
wire run_done, cpu_done;
wire [7:0 ] message_char;
wire [4:0] message_pos;
wire msg_completely_received;
wire nf_read_done;
wire msgType;
wire [1:0] reg_pos;
wire [2:0] reg_data;
wire reg_write_en;

// initialize world_FSM here and send the signals 


gripper gp(
	.clk(clk),
	.reset(1'b0),
	.obstacle_detected(!ir_in),
	.start_grip(), // issue: as travel done is high new path is computed. wait for pick done then compute new path 
	.pick_mode(pick_mode),
	.sarm_pwm(sarm_pwm),
	.sclaw_pwm(sclaw_pwm),
	.pick_done(pick_done),
	.place_done(place_done),
	.state(gripper_state), 
);

led_controller ledc(
    .color_current(color),
    .done(dest_reached),
    .clk(clk),
	 .msg_rec(msg_rec),
	 .place_done(place_done),
	 .current_pos(curr_pos),
    .led1(led1),
	 .led2(led2),
    .led3(led3),
	 .led4(led4),
	 .msgType(msgType)
);

// Color Detection Module
color_detection color_detect_inst (
    .clk_50m(clk),
    .cs_out(cs_out),
    .filter(filter),
    .Stable_Color(color),
    .s0(s0w),
    .s1(s1w),
    .s2(s2w),
    .s3(s3w),
    .oe(oew),
	 .clk_1MHz(clk_1MHZ)
);

// UART Module
uart_mod uart_inst (
	.led_color(led1),
    .clk50M(clk),
	.current_pos(curr_pos),
    .tx(uart_tx),
	.go_go(go_go),
	.rx(uart_rx),
	.col_curr(color) ,
	.node_found(node_mila),
	.run_done(run_done),
	.message_char(message_char),
	.message_pos(message_pos),
	.msg_completely_received(msg_completely_received),
	.done(nf_read_done),
	//reg write
    .reg_pos(),
    .reg_data(),
    .reg_write_en(), 
    .msgType(),
    .done()
);

world_FSM wfsm(
    .clk_3125(),
    .csl_reg_data(),
    .csl_reg_write_en(),
    .msgType()
);

// lmd is lfa + motor driver. this instentiation is for the line follower module
lmd imd_inst(
	.clk(clk),
	.dout_adc(dout),
	.reset(1'd0),
	.din_adc(din),
	.adc_clk(adc_clk),
	.MD_ENA(enA),
	.MD_ENB(enB),
	.MD_IN1(in1),
	.MD_IN2(in2),
	.MD_IN3(in3),
	.MD_IN4(in4),
	.tap_dest_reached(dest_reached),
	.adc_cs(adc_cs_n),
	.tap_current_node(curr_pos),
	.go_go(go_go),
	.node_found(node_mila),
	.dir_out(data_out),
	.dir_arr_len(dir_arr_len),
	.run_done(run_done),
	.cpu_done(cpu_done)
	);
	
//	
//nodeFinder give_us_NODES(
//    .clk(clk),
//    .msg_received(msg_completely_received), // CHeck this 
//    .msgType(msgType), // o/p
//    .done(nf_read_done),   // o/p
//    //message handle
//    .message_char(message_char), // Check this 
//    .message_pos(message_pos),  // o/p 
//    //reg write
//    .reg_pos(),  //o/p 
//    .reg_data(),  // o/p 
//    .reg_write_en(),  // o/p 
//    //travel related
//    .travel_done(dest_reached),   //Needed 
//    .run_done(run_done),    //Prolly needed
//    .node_id(),  // o/p 
//   // output wire [2:0] scan_state,
//    .node_select(),  //o/p
//	 .start_cpu(),    // o/p 
//    .node_start(),    //o/p
//	 .cpu_done(cpu_done),       //o/p 
//	 .pick_mode(pick_mode),
//	 .curr_pos(curr_pos),
//	 .data_out(data_out),
//	 .dir_arr_len(dir_arr_len)
//);	

endmodule
