module RISC_V_Wrapper (
    input wire clk,
    input wire rst,  // External reset
    input wire [31:0] SP, // Start Point from CPU_top
    input wire [31:0] EP,
	 input wire start, // End Point from CPU_top
    output [31:0] cpu_Result,
    output [31:0] cpu_WriteData, cpu_DataAdr, cpu_ReadData, cpu_PC,
    output cpu_MemWrite,
	 output reg reset_internal,
	 input wire [3:0] pos_in,
	 output wire [1:0] data_out,
	 output wire [23:0] dir_array_aggr,
	 output reg [3:0] i,
	 output reg cpu_done
);

    // State Machine Parameters
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
	 parameter DONE = 2'b10;
    
    // State registers
    reg [1:0] current_state, next_state;
    
	 reg [1:0] dir_array [0:15];
    // Internal registers
    reg [3:0] state;
    reg [15:0] counter;
    //reg reset_internal;
    reg [31:0] Ext_DataAdr, Ext_WriteData;
    reg Ext_MemWrite;
	 integer j;
//	 reg cpu_done;
	 

	 
	     // Initialize reset_internal
    initial begin 
        reset_internal <= 1;
        state <= 0;
        counter <= 0;
        Ext_MemWrite <= 1;
        Ext_WriteData <= 32'd14;
        Ext_DataAdr <= 32'h02000014;
		  i = 0;
		  cpu_done <= 1'b0;
//		  dir_array_aggr <= {0};
			 for (j = 0; j < 16; j = j + 1) begin
				  dir_array[j] = 2'b00;
			 end
	 end
	 
	 assign dir_array_aggr = {	dir_array[0], dir_array[1], dir_array[2], dir_array[3], 
										dir_array[4], dir_array[5], dir_array[6], dir_array[7], 
										dir_array[8], dir_array[9], dir_array[10], dir_array[11] };
										
//	 always @(posedge clk) begin
//		
//	 end
	 assign data_out = dir_array[pos_in];
	
    // Instantiate the CPU
    t1c_riscv_cpu Cpu_PLZ_Work (
        .clk(clk), 
        .reset(reset_internal),
        .Ext_MemWrite(Ext_MemWrite),
        .Ext_WriteData(Ext_WriteData), 
        .Ext_DataAdr(Ext_DataAdr),
        .MemWrite(cpu_MemWrite),
        .WriteData(cpu_WriteData), 
        .DataAdr(cpu_DataAdr), 
        .ReadData(cpu_ReadData),
        .PC(cpu_PC), 
        .Result(cpu_Result)
    );		
	 
    // State transition logic
    always @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic - now checking CPU signals
    always @(*) begin
        case (current_state)
            IDLE: begin
				cpu_done = 1'b0;
				if (start) begin
                // Move to START when new SP/EP values arrive
                next_state = START;
					 
					 end
            end
            START: begin
					 cpu_done = 1'b0;
                // Go back to IDLE when CPU signals match end condition
                if (cpu_DataAdr == 32'h0200000C && cpu_WriteData == 32'h1 && cpu_MemWrite) begin
                    next_state = DONE;
                end else begin
                    next_state = START;
                end
            end
				DONE:begin
					next_state = DONE;
					cpu_done = 1'b1;
				end
            default: next_state = IDLE;
        endcase
    end



    // State Machine Execution - only active in START state
    always @(posedge clk) begin
        if (current_state == IDLE) begin
            // Reset state machine for next run
            state <= 0;
            counter <= 0;
            reset_internal <= 1;
            Ext_MemWrite <= 0;
            Ext_WriteData <= 0;
            Ext_DataAdr <= 0;
				i = 0;	
    end

         
        else if (current_state == START) begin
            case (state)
                0: begin
                    Ext_MemWrite <= 1;  
                    Ext_WriteData <= SP;
                    Ext_DataAdr <= 32'h02000000;  
                    state <= 1;  
                    counter <= 0;  
						//  dir_array <= {0};
						for (j = 0; j < 16; j = j + 1) begin
				dir_array[j] = 2'b00;
                end
					 end

                1: begin
                    if (counter < 8) counter <= counter + 1;
                    else begin
                        Ext_MemWrite <= 0;
                        state <= 2;
                        counter <= 0;
                    end
                end

                2: begin
                    Ext_MemWrite <= 1;  
                    Ext_WriteData <= EP;
                    Ext_DataAdr <= 32'h02000004;  
                    state <= 3;  
                    counter <= 0;  
                end

                3: begin
                    if (counter < 8) counter <= counter + 1;
                    else begin
                        Ext_MemWrite <= 0;
                        state <= 4;
                        counter <= 0;
                    end
                end

                4: begin
                    Ext_MemWrite <= 1;
                    Ext_WriteData <= 0;  
                    Ext_DataAdr <= 32'h02000008;  
                    state <= 5;
                    counter <= 0;
                end

                5: begin
                    if (counter < 8) counter <= counter + 1;
                    else begin
                        Ext_MemWrite <= 0;
                        state <= 6;
                        counter <= 0;
                    end
                end

                6: begin
                    Ext_MemWrite <= 1;
                    Ext_WriteData <= 0;
                    Ext_DataAdr <= 32'h0200000C;
                    state <= 7;
                    counter <= 0;
                end

                7: begin
                    if (counter < 8) counter <= counter + 1;
                    else begin
                        Ext_MemWrite <= 0;
                        state <= 9;
                        counter <= 0;
                    end
                end


                9: begin
                    if (counter < 8) counter <= counter + 1;
                    else begin
                        Ext_MemWrite <= 0;
                        reset_internal <= 0;
                        state <= 10;
                        counter <= 0;
                    end
                end

                10: begin
                    // Now just waiting for CPU signals to trigger return to IDLE
                    // No need to set specific values here
                    Ext_MemWrite <= 0;
						  
						  if (cpu_DataAdr == 32'h02000010 && cpu_MemWrite) begin
                    dir_array[i] <= cpu_WriteData[1:0];
						  i <= i + 1;
                end
                end

                default: state <= 10;
            endcase
        end
    end
endmodule
