

module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
//	 output reg [3:0] state_counter
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

parameter BIT_PERIOD = 27;
reg [3:0] state_counter;

// Internal Registers
//state_counter = 0;
reg [4:0] bit_length_counter = 0;
//reg [7:0] tx_shift_reg = 0;
reg parity_bit = 0;

// Initialize outputs
initial begin
    tx = 1'b1;
    tx_done = 1'b0;
	state_counter = 0;
end

// UART Transmitter Logic
always @(posedge clk_3125) begin 
    case (state_counter)
        0: begin 
            tx = 1'b1;          // Idle high
            tx_done <= 1'b0;
            bit_length_counter <= 0;
            
            if (tx_start) begin
				    tx = 1'b0;
                parity_bit <= 0;
                state_counter <= 1;
            end
        end
        
        1: begin
            // Start bit

            bit_length_counter <= bit_length_counter + 1;
            
            if (bit_length_counter == BIT_PERIOD - 1) begin
                bit_length_counter <= 0;
                state_counter <= 2;
            end
        end
        
        2,3,4,5,6,7,8,9: begin  // Data bits
//            tx <= data[9-state_counter];  // MSB first
				tx <= data[state_counter-2];	//LSB FIRST
            bit_length_counter <= bit_length_counter + 1;
            
            if (bit_length_counter < BIT_PERIOD) begin
                parity_bit <= parity_bit ^ data[9-state_counter];
            end
            
            if (bit_length_counter == BIT_PERIOD - 1) begin
                bit_length_counter <= 0;
                state_counter <= state_counter + 1;
            end
        end
        
        10: begin  // Parity bit
            tx <= (parity_type) ? ~parity_bit : parity_bit;
            bit_length_counter <= bit_length_counter + 1;
            
            if (bit_length_counter == BIT_PERIOD - 1) begin
                bit_length_counter <= 0;
                state_counter <= state_counter + 1;
            end
        end
        
        11: begin  // Stop bit
            tx <= 1'b1;
            bit_length_counter <= bit_length_counter + 1;
            
            if (bit_length_counter == BIT_PERIOD - 1) begin
                bit_length_counter <= 0;
                state_counter <= 0;
                tx_done <= 1'b1;
            end
        end
        
        default: begin
            state_counter <= 0;
            tx <= 1'b1;
        end
    endcase
end

//endmodule

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule


