// EcoMender Bot : Task 1B : Color Detection using State Machines
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will detect colors red, green, and blue using state machine and frequency detection.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Color Detection
//Inputs : clk_1MHz, cs_out
//Output : filter, color

// Module Declaration
module colordet (
    input  clk_1MHz, cs_out,
    output reg [1:0] filter, color,
	output reg s0, s1, s2, s3, oe
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;


//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

// Declare required registers
reg [9:0] counter;
reg [9:0]freq_counter ;       
reg [9:0] freq_counterG;
reg [9:0] freq_counterR;
reg [9:0] freq_counterB;
reg [9:0] freq_counterC;  // for combined color counter values

// Initial block for reset
initial begin
    filter = 2;
    color = 0;
    counter = 0;
    freq_counterG = 0;
    freq_counterR = 0;
    freq_counterB = 0;
    s0 = 1;
    s1 = 1;
    oe = 1;
end

// Edge detection and state machine logic
always @(posedge clk_1MHz) begin
    // Increment the main 500-cycle counter
    counter <= counter + 9'b1;
    
    // Reset counter after 500 cycles
   if (counter == 1000)
        counter <= 0;
		  
    // State machine logic
    case (filter)
        2'b11: begin
            //filter <= 3; // Green filter
				s2 <= 1;
				s3 <= 1;
            if (counter == 999) begin   // After 500 clock cycles, move to next state
                freq_counterG <= freq_counter; // Store Green freq_counter with color bits
                counter <= 0;           // Reset the 500-cycle counter
                filter <= 0;            // Move to Red filter
            end
        end

        2'b00: begin
            //filter <= 0; // Red filter
				s2 <= 0;
				s3 <= 0;
            if (counter == 999) begin   // After 500 clock cycles, move to next state
                // Compare Red frequency with current max frequency (ignore the 2 MSBs)
                freq_counterR <= freq_counter;
                counter <= 0;           // Reset the 500-cycle counter
                filter <= 1;            // Move to Blue filter
            end
        end

       2'b01: begin
           // filter <= 1; // Blue filter
			  s2 <= 0;
			  s3 <= 1;
            if (counter == 999) begin   // After 500 clock cycles, move to next state
                // Compare Blue frequency with current max frequency (ignore the 2 MSBs)
                freq_counterB <= freq_counter;
						 counter <= 0;
						 filter <= 2;// Update with Blue frequency
                end
		  end

        2'b10: begin	  
				s2 <= 1;
				s3 <= 0;
            if (counter == 999) begin 
//                counter <= 0;
					freq_counterC = freq_counterB + freq_counterG + freq_counterR ;
					
					//ADD WHITE LOGIC
					if (freq_counterR && freq_counterB && freq_counterG) begin
					
                    // minor tuning for each color to be detected 
					if(freq_counterG > freq_counterR && freq_counterG > freq_counterB && freq_counterC < 35)
						color <= 2'b10; //green
					else if (freq_counterR > ( freq_counterB + 2) &&  freq_counterR > freq_counterG && freq_counterC < 35 )
						color <= 2'b01; //red
					else if (freq_counterB > freq_counterR  && freq_counterB > freq_counterG && freq_counterC < 35 && freq_counterG > freq_counterR)
						color <= 2'b11; //blue
					else color <= 2'b00;
				end else // all three couner are zero then its white
					color <= 2'b00;

                    // this is not in the else block 
				freq_counterG = 0;
				freq_counterB = 0;
				freq_counterR = 0;
				freq_counterC = 0;			
                filter <= 3; 
                counter <= 0;
            end
        end
		  
		  default : color = 2'b00;
		  
    endcase
end



// Frequency counting logic (counts cs_out pulses when counter is between 700 and 1000)
always @(posedge cs_out) begin
    if (counter > 700 && counter < 999) begin
        freq_counter <= freq_counter + 9'b1;
    end else begin
        freq_counter <= 0;
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule

