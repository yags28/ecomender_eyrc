/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         deviation_control
# File Description: apply thresholds and return the state of the line below the lfa sensor array
*/

module DeviationControl(
    input signed [11:0] left_value, center_value, right_value,  // Sensor data from ADC Controller
    output reg signed [5:0] deviation_scaled, // Deviation scaled to -32 to 31
    
	 output reg [2:0] lfa_input,

    //flag for line and node
    output reg is_line,        
    output reg is_node,        
    output reg lost_path
	 
	 
);

    // Threshold for detecting black line (assuming)
    parameter THRESHOLD_LR = 90;
	 parameter THRESHOLD_C = 85;

    

    always @(*) begin
        lfa_input[0] = (right_value > THRESHOLD_LR) ? 1'b1 : 1'b0;
        lfa_input[1] = (center_value > THRESHOLD_C) ? 1'b1 : 1'b0;
        lfa_input[2] = (left_value > THRESHOLD_LR) ? 1'b1 : 1'b0;
    end
    

always @(*) begin
 
 case (lfa_input)
    0: begin
        lost_path = 1;
		  is_line = 0;
		  is_node = 0;
    end
    2: begin
        // forward and line
		  is_line = 1;
		  lost_path = 0;
		  is_node = 0;
		  end
    7: begin
        // node
		  is_line = 0;
		  lost_path = 0;
		  is_node = 1;
    end
    default: begin
        is_node = 0;
		  lost_path = 0;
		  is_line = 0;
    end
endcase

end
endmodule

