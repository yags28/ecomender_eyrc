
module ship_master(
    input clk,
    input read_done,
    input msgType,
    // reg data input
    input [1:0] reg_pos_in,
    input [2:0] reg_data,
    input reg_write_en,
    // travel related
    input travel_done,
    output reg run_done,
    output wire [5:0] node_id,
	output reg [5:0] node_start,
    output reg node_select,start_cpu, pick_mode
);

// message array
reg [2:0] message [0:2];

// internal registers
reg [1:0] current_unit;
reg [2:0] data;
//reg node_select;
reg signed[3:0] reg_pos;
//reg node_start;
reg [3:0] start_delay_counter;

// Define the node values
localparam MU1 = 3'b001;
localparam MU2 = 3'b010;
localparam MU3 = 3'b011;
localparam SU1 = 3'b101;
localparam SU2 = 3'b110;
localparam SU3 = 3'b111;

// interpretor instantiation
interpretor uut (
    .current_unit(current_unit),
    .msgType(msgType),
    .node_select(node_select),
    .data(data),
    .node_id(node_id)
);

initial begin
    message[0] = 3'b000;
    message[1] = 3'b000;
    message[2] = 3'b000;
	 //message[3] = 3'b000;
    current_unit = 2'b10; // Error state fsu
    reg_pos = 0;
    node_start = 5'd01;
    start_delay_counter = 4'd0;
	 state = 3'b0;
	 next_state = 3'b0;
end

// Synchronous write logic
always @(posedge clk) begin
    if (reg_write_en && !msgType) begin
        message[reg_pos_in] <= reg_data;
    end
    // if (msgType && read_done) begin
    //     current_unit <= reg_data[1:0];
    // end
end

reg [2:0] state;
reg [2:0] next_state; // Temporary state variable

/*
The issue occurs because pos needs to represent values below zero and above two during transitions.
A 2-bit wireister (wire [1:0] pos;) wraps around when subtracting from zero or adding beyond two, causing incorrect behavior.
*/
reg signed [3:0] stack;

//State declarations
localparam IDLE = 3'b000;
localparam SCAN_MU_2_0 = 3'b001;
localparam SCAN_MU_0_2 = 3'b010;
localparam SCAN_SU_2_0 = 3'b011;
localparam SCAN_SU_0_2 = 3'b100;
localparam WAIT_FOR_TRAVEL_DONE = 3'b101; // New waiting state
localparam DONE      = 3'b110;

always @(posedge clk) begin
    if (!msgType) begin 
	 case (state)
        IDLE: begin // Idle state, wait for update
				if(run_done)begin
					state <= IDLE;
					run_done <= 0;
					end
            if (read_done) begin
                reg_pos <= 2; // Start scanning from the rightmost position
                stack <= 0;   // Initialize the stack
                state <= SCAN_MU_2_0; // Start scanning for MUs
                run_done <= 0;
            end else
                state <= IDLE;
        end

        SCAN_MU_2_0: begin // Scan from pos 2 to 0 for MU
            if (reg_pos >= 0) begin
					 pick_mode = 1'b1;
                if (message[reg_pos] >= MU1 && message[reg_pos] <= MU3) begin
                    data <= reg_pos[1:0]; // Output the *POSITION*
                    node_select <= 0;     // Indicate it's a position
                    stack <= stack + 1;   // Increment stack (count of MUs)
                    reg_pos <= reg_pos - 1;
                    next_state <= (reg_pos == 0) ? SCAN_MU_0_2 : SCAN_MU_2_0; // Store next state before waiting
                    state <= WAIT_FOR_TRAVEL_DONE; // Move to waiting state after writing data
                end else if (reg_pos == 0) begin
                    // next_state <= SCAN_MU_0_2; // Store next state before waiting
                    state <= SCAN_MU_0_2; // Move to waiting state after writing data
                end else begin 
                    reg_pos <= reg_pos - 1; // Move to the next position (left)
                end 
            end else begin 
                reg_pos <= reg_pos - 1; // Move to the next position (left)
            end 
        end

        SCAN_MU_0_2: begin // Scan from reg_pos 0 to 2 for MU
            if (reg_pos <= 2) begin 
				pick_mode = 1'b0;
                if (message[reg_pos] >= MU1 && message[reg_pos] <= MU3) begin 
                    data <= message[reg_pos]; // Output the *VALUE*
//						  reg_pos_old <= reg_pos     // viahfsgisue
                    node_select <= 1;         // Indicate it's a value 
                    stack <= stack - 1;       // Decrement stack 
                    reg_pos <= reg_pos + 1;
                    next_state <= (reg_pos == 2) ? SCAN_SU_2_0 : SCAN_MU_0_2; // Store next state before waiting 
                    state <= WAIT_FOR_TRAVEL_DONE; // Move to waiting state after writing data 
                end else if (reg_pos == 2) begin 
                    // next_state <= SCAN_SU_2_0; // Store next state before waiting 
                    state <= SCAN_SU_2_0; // Move to waiting state after writing data 
                end else begin 
                    reg_pos <= reg_pos + 1;      // Move to the next position (right) 
                end 
            end else begin 
                reg_pos <= reg_pos + 1;      // Move to the next position (right) 
            end 
        end

        SCAN_SU_2_0: begin // Scan from pos 2 to 0 for SU 
            if (reg_pos >= 0) begin 
					 pick_mode = 1'b1;
                if (message[reg_pos] >= SU1 && message[reg_pos] <= SU3) begin 
                    data <= message[reg_pos]; // Output the *VALUE* 
                    node_select <= 1;         // Indicate it's a value 
                    stack <= stack + 1;       // Increment stack (count of SUs) 
                    reg_pos <= reg_pos - 1; 
                    next_state <= (reg_pos == 0) ? SCAN_SU_0_2 : SCAN_SU_2_0; // Store next state before waiting 
                    state <= WAIT_FOR_TRAVEL_DONE; // Move to waiting state after writing data 
                end else if (reg_pos == 0) begin 
                    //next_state <= SCAN_SU_0_2; // Store next state before waiting 
                    state <= SCAN_SU_0_2; // Move to waiting state after writing data 
                end else begin 
                    reg_pos <= reg_pos - 1;      // Move to the next position (left) 
                end 
            end else begin 
                reg_pos <= reg_pos - 1;      // Move to the next position (left) 
            end  
        end

        SCAN_SU_0_2: begin // Scan from pos 0 to 2 for SU  
            if (reg_pos <= 2) begin  
					 pick_mode = 1'b1;
                if (message[reg_pos] >= SU1 && message[reg_pos] <= SU3) begin  
                    data <= reg_pos[1:0];     // Output the *POSITION*  
                    node_select <= 0;         // Indicate it's a position  
                    stack <= stack - 1; 
                    reg_pos <= reg_pos + 1;
                    next_state <= (reg_pos == 2) ? DONE : SCAN_SU_0_2;
                    state <= WAIT_FOR_TRAVEL_DONE;      // Decrement stack  
                end  
                else if (reg_pos == 2) begin  
                    state <= DONE;           // All scanning is complete  
                end  else begin
                reg_pos <= reg_pos + 1;      // Move to the next position (right)  
            end 
				end
				else begin 
                reg_pos <= reg_pos + 1; 
            end            // Handle wraparound  
              
        end

        WAIT_FOR_TRAVEL_DONE: begin   // New waiting state logic  

        if (start_delay_counter < 5)begin
            start_delay_counter <= start_delay_counter + 1;
            start_cpu <= 1 ; // Indicate start of travel
        end else begin
            start_cpu <= 0; 

        end
            
            if(travel_done) begin         // Wait until travel_done goes high  
                state <= next_state;       // Return to stored next_state  
                node_start <= node_id ;           
                start_delay_counter <= 0;  // Reset delay counter
            end  
        end  

        DONE: begin  
            run_done <= 1;               // Signal completion  
            state <= IDLE;				// Return to the idle state  
        end  

        default: state <= IDLE;   
    endcase
end	 
end  

//assign node_id = data;   // Connect internal data to output node_id  

endmodule 