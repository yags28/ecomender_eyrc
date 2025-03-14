/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         lower_mdr_driver (or motor driver lower)
# File Description: controls the speed of motors and assigns the signals to motor driver
*/

module motor_driver_lower (
    input wire clk,                
    input wire reset,              
    input wire [2:0] lfa_input, 
    input [1:0] direction,        
    input wire line_found,         
    output reg enA,                
    output reg enB,                
    output reg in1, in2, in3, in4 , 
	input dest_reached,
	input wire go_go,
	input wire speed_turn
);

// Parameters for PWM
reg [11:0] pwm_counter;            // 13-bit counter for PWM generation thuss the output freq of pwm is ~6KHz
wire no_go_go;
reg signed [12:0] pwm_threshold_A;         // Threshold for enA (constant)
reg signed [12:0] pwm_threshold_B;         // Threshold for enB (variable)
reg signed [12:0] scaled_deviation;

// PWM Initialization
initial begin
    pwm_counter = 0;
	pwm_threshold_B = 2000;     // left motor
	pwm_threshold_A = 1600;		 // right motor beside colour sensor
	end
	
assign no_go_go = !go_go;

// PWM Counter Logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pwm_counter <= 0;
    end else begin
        pwm_counter <= pwm_counter + 1; // Increment PWM counter
    end
end


// Generate PWM Signal
always @(posedge clk or posedge reset) begin
    if (reset) begin
        enA <= 0;
        enB <= 0;
    end else begin
        enA <= (pwm_counter < pwm_threshold_A) ? 1 : 0; // Constant PWM for enA
            enB <= (pwm_counter < pwm_threshold_B) ? 1 : 0; // Variable PWM for enB
    end
end
/*
    DIRECTION HELP:
    00: Forward
    10: Left
    01: Right
    11: Backward
    TO STOP: make the PWM speed as 0
*/

// Direction Control Logic
always @(posedge clk or posedge reset or posedge dest_reached or posedge no_go_go) begin
    if (reset || dest_reached || no_go_go) begin
        in1 <= 0; in2 <= 0;
        in3 <= 0; in4 <= 0;
    end else begin
        case(direction)
            2'b00: begin // Forward
                in1 <= 0; in2 <= 1;
					 in3 <= 1; in4 <= 0;
            
            end
            2'b01: begin //right
                in1 <= 1; in2 <= 0;
                in3 <= 1; in4 <= 0;
            end
            2'b10: begin //left
                in1 <= 0; in2 <= 1;
                in3 <= 0; in4 <= 1;
            end
				2'b11: begin //in case of back logic take a longer left turn 
                in1 <= 0; in2 <= 1;
                in3 <= 0; in4 <= 1;
            end
//            2'b11: begin//backward
//                in1 <= 1; in2 <= 0;
//                in3 <= 0; in4 <= 1;
//            end
            default: begin
                in1 <= 0; in2 <= 0;
                in3 <= 0; in4 <= 0;
            end
    endcase

    end
end

    always @(*) begin
//	    if (speed_turn) begin
//			pwm_threshold_B = 1575;
//			pwm_threshold_A = 1750;
//		 end
//		 else 
		 begin
        case (lfa_input)
    4: begin
        // extreme right
		  pwm_threshold_B = 3880;		//3930  // 3830
		  pwm_threshold_A = 830;		//1180   // 880 .
    end
    2: begin  //010 and 101
        // forward and line
		  pwm_threshold_B = 2350;		//2450
		  pwm_threshold_A = 2700;
    end
    6: begin
        // right  //+100 -100
		  pwm_threshold_B = 3880;		//3930  // 3830
		  pwm_threshold_A = 830;
//		  pwm_threshold_B = 3090;		//3140
//		  pwm_threshold_A = 1690;		//2040
    end
    1: begin
        // extreme left
		  pwm_threshold_B = 670;		//970
		  pwm_threshold_A = 4095;		//4420
		  
    end
    3: begin
        // left
		  pwm_threshold_B = 670;		//970
		  pwm_threshold_A = 4095;
    end
    7: begin
        // node
		  // left
		  pwm_threshold_B = 1100;
		  pwm_threshold_A = 1400;
    end
    default: begin
        // default case
		  pwm_threshold_B = 2150;		//2450
		  pwm_threshold_A = 2500;		//2800 
	 end
	 
	endcase
	end
end
endmodule	

