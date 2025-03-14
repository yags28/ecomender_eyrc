/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         uart_mod
# File Description: top level for the uart assemnbly including the uart_tx and uart_rx modules
*/

module uart_mod(
    input clk50M,
    output wire tx,
    input [4:0] current_pos,
    input [3:0] led_color,
    output reg go_go,
    input wire rx,
    output wire[7:0] msg_rec,
	 input wire [1:0] col_curr,
	 input wire run_done,
	 input wire node_found,
	 output wire [7:0] message_char,
	 input wire [4:0] message_pos,
	 output reg msg_completely_received,
	 input wire nf_read_done,
	 // Register to store the complete aggregated message
    output reg [127:0] aggregated_message // 128-bit register to store the full message (16 bytes)
//    output reg start_grip   // Gripper activation signal
//    output reg pick_mode     // Pick (1) or Place (0) mode
	 );

reg tx_start;
reg [7:0]data_bits;
wire tx_done;
reg [4:0] state_counter;
reg start;
wire rx_complete;
reg [7:0] Message_Received;
reg [3:0] led_color_prev;
reg [3:0] k = 0;
wire [7:0] message_byte;
reg [1:0] msg_state;
reg msg_done;
reg [3:0] byte_counter;
reg message_ready_prev;
integer m;

  // Message stack to store received messages (16 messages of 8 bits each)
    reg [7:0] message_stack [0:23]; 
    reg [5:0] stack_ptr = 0; // Stack pointer to track the current position


uart_scale fqs3_125mhz (clk50M, clk_3_125Mhz);
 
 always @(*) begin
	for(k = 0; k < 8; k = k + 1 ) begin
		Message_Received[k] <= msg_rec[7 - k];      
   end
 end
 
 integer i;
	 reg [3:0] shift_index = 0;
    always @(posedge clk_3_125Mhz) begin
	 msg_completely_received <= 0;
	if (rx_complete) begin
            message_stack[stack_ptr][7:0] <= Message_Received[7:0];
            if (stack_ptr < 23) 
                stack_ptr <= stack_ptr + 1;  
            else  
                stack_ptr <= 0;
				if (Message_Received == 8'h23)begin 
					msg_completely_received <= 1;
				end 
//				else begin
//				msg_completely_received <= 0;
//				end
        end  
	 if (nf_read_done) begin
		for (m = 0; m <= 23; m=m+1)begin
				message_stack[m] <= 8'b0;
//				msg_completely_received <= 0;
		end	
	stack_ptr <= 0;	
		end
    end


reg rex_state;
reg next_state;
reg current_state;
wire message_ready;
reg [1:0] uart_state, next_uart_state;
reg [3:0] read_index;

// Instantiate the UART transmitter (assuming proper implementation of uart_tx)
uart_tx uart_tx_inst (
    .clk_3125(clk_3_125Mhz),				// changed from clk_1hz
    .parity_type(1'b0),            
    .tx_start(tx_start),				// send when message is complete
    .data(message_byte),			
//	 .data_in(msg_rec),
//	 .message_buffer(message_buffer),
    .tx(tx),
    .tx_done(tx_done)
    //.state_counter(uart_tx_state)
    );
	 
uart_rx uart_rx_inst(
    .clk_3125(clk_3_125Mhz),
    .rx(rx),
    .rx_msg(msg_rec),
    .rx_parity(),
    .rx_complete(rx_complete)
    );
	 
message_formatter message_formatter_inst (
    .clk(clk_3_125Mhz),
    .rst(1'b0),
    .message_type(3'b000), // Example: SLM
    .location(3'b001),     // Example: FSU
    .numData(2'b01),       // Example: 1
    .colorData(2'b01),  // Dynamic input
    .write_enable(1'b1),   // Always enable message formatting
    .read_index(read_index),
    .message_byte(message_byte),
    .message_ready(message_ready)
);
	 
parameter IDLE = 2'b00;
parameter ACTIVE = 2'b01;
parameter WAITING = 2'b10;
parameter MSG_IDLE = 2'b00;
parameter MSG_PROCESSING = 2'b01;
parameter MSG_COMPLETE = 2'b10;

// Initialization
initial begin
    tx_start <= 0;
    state_counter <= 0;
    start <= 0;
	 timre_df <= 0;
	 stack_ptr <= 0;
end

reg [21:0] timre_df;

always @(posedge clk_3_125Mhz) begin
	timre_df <= timre_df + 22'b1;
end

assign timer_dd = (!timre_df) ? 1 : 0;

    // State transition process for recieve message
//    always @(posedge clk_3_125Mhz) begin
//        current_state <= next_state;
//    end

    always @(posedge clk_3_125Mhz) begin
        case (rex_state)
            IDLE: begin
                if (Message_Received == 8'h23 ) begin			//msg_completely_received
                    current_state <= ACTIVE;
                end else begin
                    current_state <= IDLE;
                end
            end
            ACTIVE: begin
                    current_state <= ACTIVE;
            end
            default: current_state <= IDLE;
        endcase
    end
	 
	 
		 ///////////////////////
	 
	 

	 
	 //////////////////////
	 
	     // Output logic process for recieve message
    always @(*) begin
        case (current_state)
            IDLE: go_go <= 0;
            ACTIVE: go_go <= 1;
        endcase
    end

// this is just to store the previous led color used to send uart message
always @(posedge clk_3_125Mhz) begin
	led_color_prev <= led_color;
end



always @(posedge clk_3_125Mhz) begin
    case (msg_state)
        MSG_IDLE: begin
            msg_done <= 1'b0;
            read_index <= 4'd0;
            tx_start <= 1'b0;  // Ensure it's reset
            if (message_ready && 0) begin  
                msg_state <= MSG_PROCESSING;
                tx_start <= 1'b1;  // Start transmission
                data_bits <= message_byte;  // Load first byte
            end
        end
        
        MSG_PROCESSING: begin
            if (tx_start) tx_start <= 1'b0;  // Ensure tx_start is a single-cycle pulse
            
            if (tx_done) begin  // Check if current transmission is done
                if (message_byte == 8'h23) begin  // End of message
                    msg_state <= MSG_COMPLETE;
                end else begin
                    
                    read_index <= read_index + 1;
						  tx_start <= 1'b1;  // Pulse to start the next transmission
                end
            end
        end
        
        MSG_COMPLETE: begin
            msg_done <= 1'b1;
            tx_start <= 1'b0;  // Ensure transmission stops
//            if (!message_ready) begin  //  Wait for message_ready to go low
                msg_state <= MSG_IDLE;
//            end
        end
        
        default: msg_state <= MSG_IDLE;
    endcase
end

assign message_char = message_stack[message_pos];
    
endmodule				