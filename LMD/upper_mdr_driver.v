// this one is final for motor driver upper
/*
# Team ID:          3800
# Theme:            ecomender bot
# Author List:      manny, priyank, yagnesh, sohum 
# Filename:         upper_mdr_driver (or motor driver upper)
# File Description: main FSM for line following and turnig at nodes, only controls direction of motors
*/



module motor_driver_upper (
  input wire clk,                  
  input wire reset,                
  input wire node_detected,        
  input wire line_found,               
  input wire [0:13] turn_register,  
  output reg [3:0] current_node,            
  output reg [1:0] direction,       
  output reg dest_reached,
  output reg [3:0] current_state, next_state, 
  output reg delay_state_n, delay_state_t,
  input wire go_go,
  output reg speed_turn ,
  input wire [1:0] dir_out,
  input wire [3:0] dir_arr_len,
  input wire run_done, cpu_done
);

reg [3:0]   temp_node;
reg [22:0]  delay_n;
reg [22:0]  delay_t;
reg [23:0]  delay_b;

// State encoding
parameter LINE_FOLLOW = 3'b000;
parameter NODE_CHAOS = 3'b001;
parameter DELAY = 3'b010;
parameter TURN = 3'b011;
parameter TRAVEL_DONE = 3'b100;
parameter START_TURN = 3'b101;
parameter START_RIGHT = 3'b110;
parameter IDLE = 3'b111;
parameter PATH_CHAOS =4'b1000;

//reg [2:0] current_state, next_state;
reg delay_trigger_n;
reg delay_trigger_t;
reg delay_trigger_b;
reg delay_done_n;
reg delay_done_t;
reg delay_done_b;
//reg virgin_turn_flag;

initial begin
  current_node = 4'b1111; // Start at node 0
  temp_node = 4'b0000;      // Start at register pointer 0
  direction = 2'b00;     // Default direction
  current_state <= IDLE;
  dest_reached <= 1'b0;
  delay_trigger_t<= 1'b0;
  delay_trigger_n <= 1'b0;
  delay_trigger_b <= 1'b0;
  speed_turn = 1'b0;
end

// delay counter for the node
always @(posedge clk or posedge reset) begin
    if (reset) begin
        delay_n <= 23'b0;          // Reset delay counter
        delay_done_n <= 1'b0;      // Reset delay_done flag
        delay_state_n <= 1'b0;   // Reset state to IDLE
    end else begin
        case (delay_state_n)
            1'b0: begin // IDLE state
                delay_n <= 23'b0;  // Keep counter at 0
                delay_done_n <= 1'b0; // Ensure delay_done is low
                if (delay_trigger_n) begin
                    delay_state_n <= 1'b1; // Transition to COUNTING on trigger
                end
            end

            1'b1: begin // COUNTING state
                if (delay_n == 23'd781250) begin //-50000 //781250
                    delay_done_n <= 1'b1;    // Set delay_done when target reached
                    delay_n <= 23'b0;        // Reset counter
                    delay_state_n <= 1'b0; // Return to IDLE
                end else begin
                    delay_n <= delay_n + 1;    // Increment counter
                    delay_done_n <= 1'b0;    // Ensure delay_done remains low
                end
            end
        endcase
    end
end

// delay counter for the turn
always @(posedge clk or posedge reset) begin
    if (reset) begin
        delay_t <= 23'b0;          // Reset delay counter
        delay_done_t <= 1'b0;      // Reset delay_done flag
        delay_state_t <= 1'b0;   // Reset state to IDLE
    end else begin
        case (delay_state_t)
            1'b0: begin // IDLE state
                delay_t <= 23'b0;  // Keep counter at 0
                delay_done_t <= 1'b0; // Ensure delay_done is low
                if (delay_trigger_t) begin
                    delay_state_t <= 1'b1; // Transition to COUNTING on trigger
                end
            end

            1'b1: begin // COUNTING state
                if (delay_t == 23'd1562500) begin    //-30000 //1562500
                    delay_done_t <= 1'b1;    // Set delay_done when target reached  
                    delay_t <= 23'b0;        // Reset counter
                    delay_state_t <= 1'b0; // Return to IDLE
                end else begin
                    delay_t <= delay_t + 1;    // Increment counter
                    delay_done_t <= 1'b0;    // Ensure delay_done remains low
                end
            end
        endcase
    end
end

// Replace the state transition block with:
always @(posedge clk or posedge reset) begin
  if (reset) begin
    current_state <= IDLE;
    current_node <= 4'b0000;
    temp_node <= 4'b0000;
  end else begin
    current_state <= next_state;
    // Add sequential updates for other signals
	 if (cpu_done) begin
      current_node = 4'b0000;
    end
    if (current_state == NODE_CHAOS) begin
      temp_node <= current_node + 1;
    end
    if (current_state == DELAY && delay_done_n) begin
      current_node <= temp_node;
    end
  end
end

// Create separate combinational block for next_state logic
always @(*) begin
  // Default assignment to prevent latches
  next_state = current_state;
  
  case (current_state)
	 IDLE: begin
		if (go_go) next_state = START_RIGHT;
	 end
	 
    LINE_FOLLOW: begin
      if (node_detected) next_state = NODE_CHAOS;
    end
    
    NODE_CHAOS: begin
      next_state = DELAY;
    end
	 
	 PATH_CHAOS: begin
      next_state = DELAY;
    end
    
    DELAY: begin
      if (delay_done_n) begin
        if (dir_out != 0) next_state = START_TURN;
        else next_state = LINE_FOLLOW;
      end
    end
    
    START_TURN: begin			// include the left turn for back using twice wala delay also edit the below signal assignment always block to add the backward delay trigger
      if (delay_done_t) 
	  next_state = TURN;
    end
    
	 START_RIGHT: begin
      if (delay_done_t) 
	  next_state = TURN;
    end
	 
    TURN: begin
      if (line_found) begin
        if (current_node == dir_arr_len) next_state = TRAVEL_DONE;
        else next_state = LINE_FOLLOW ;
      end
		else begin
    next_state = TURN;  // Stay in TURN state until line is found
  end
    end
    
    TRAVEL_DONE: begin
      next_state = TRAVEL_DONE;
		if(go_go) begin 
				next_state = PATH_CHAOS;
//				delay_trigger_n = 1'b1;
		end
    end
    
    default: next_state = LINE_FOLLOW;
  endcase
end

// Separate combinational block for outputs
always @(*) begin
  
  case (current_state)

  
	 PATH_CHAOS: begin
      delay_trigger_n = 1'b1;
		dest_reached = 1'b0;
		speed_turn = 1'b0;
    end
    
    NODE_CHAOS: begin
      delay_trigger_n = 1'b1;
		dest_reached = 1'b0;
		speed_turn = 1'b0;
    end
    
	 START_RIGHT: begin
		delay_trigger_n = 1'b0;
      direction = 2'b01;                 // 2'b01
      delay_trigger_t = 1'b1;
		dest_reached = 1'b0;
		speed_turn = 1'b1;
    end
	 
    START_TURN: begin
		delay_trigger_n = 1'b0;
      direction = dir_out;                 // PUT DIR_ARRAY output
      delay_trigger_t = 1'b1;
		dest_reached = 1'b0;
		speed_turn = 1'b1;
    end
    
    TURN: begin
		delay_trigger_t = 1'b0;
//      direction = dir_out;
		dest_reached = 1'b0;
		speed_turn = 1'b1;
    end
    
    TRAVEL_DONE: begin
      dest_reached = 1'b1;
		speed_turn = 1'b0;
		
    end
	 
	 default: begin
	   // Default assignments
	  direction = 2'b00;
	  delay_trigger_n = 1'b0;
	  delay_trigger_t = 1'b0;
	  dest_reached = 1'b0;
	  speed_turn = 1'b0;
	  end
  endcase
end

endmodule
