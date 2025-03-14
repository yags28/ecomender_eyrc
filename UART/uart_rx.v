
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

parameter BIT_PERIOD = 26;
//parameter BUFFER_SIZE = 25;

// Internal Registers
reg [3:0] state_counter = 0;
reg [7:0] temp_reg = 0;
reg [4:0] bit_length_counter = 31;
reg temp_parity = 0;
reg parity_bit = 0;

// Receive Buffer
//reg [7:0] rx_buffer [0:BUFFER_SIZE-1];
//integer i;

// Initialize outputs
initial begin
    rx_msg = 0;
    rx_parity = 0;
    rx_complete = 0;
//    for (i = 0; i < BUFFER_SIZE; i = i + 1) begin
//        rx_buffer[i] = 8'h00;
//    end
end

// UART Receiver Logic
always @(posedge clk_3125) begin 
    case (state_counter)
        0: begin 
            rx_complete <= 0;
            parity_bit <= 0;
            if (rx == 0) begin
                bit_length_counter <= bit_length_counter + 1;
            end
            if (bit_length_counter == BIT_PERIOD) begin
                bit_length_counter <= 0;
                state_counter <= 1;
            end
        end
        1, 2, 3, 4, 5, 6, 7, 8: begin
            bit_length_counter <= bit_length_counter + 1;
            if (bit_length_counter == (BIT_PERIOD/2)) begin
                temp_reg[8-state_counter] <= rx;
                parity_bit <= parity_bit ^ rx;
            end
            if (bit_length_counter == BIT_PERIOD) begin
                bit_length_counter <= 0;
                state_counter <= state_counter + 1;
            end
        end
        9: begin
            bit_length_counter <= bit_length_counter + 1;
            if (bit_length_counter == (BIT_PERIOD/2)) begin
                temp_parity <= rx;
            end
            if (bit_length_counter == BIT_PERIOD) begin
                bit_length_counter <= 0;
                state_counter <= state_counter + 1;
            end
        end
        10: begin
            bit_length_counter <= bit_length_counter + 1;
            if (bit_length_counter == BIT_PERIOD) begin
                bit_length_counter <= 0;
                state_counter <= 0;
                if (parity_bit == temp_parity) begin
                    rx_msg <= temp_reg;
                end else begin
                    rx_msg <= 8'h3F;
                end
                rx_parity <= temp_parity;
                rx_complete <= 1;
            end
        end
        default: state_counter <= 0;
    endcase
end

//// Store Received Data in Buffer
//always @(posedge rx_complete) begin
//    for (i = BUFFER_SIZE-1; i > 0; i = i - 1) begin
//        rx_buffer[i] <= rx_buffer[i-1];
//    end
//    rx_buffer[0] <= rx_msg;
//end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
