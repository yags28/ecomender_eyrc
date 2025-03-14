

module message_formatter(
    input clk,
    input rst,
    input [2:0] message_type, // SLM, RPM, RDM, END, DEBUG
    input [2:0] location,     // PSU, FSU, WSU, SU, MU
    input [1:0] numData,      // 1, 2, 3
    input [1:0] colorData,    // IM, IS, AS
    input write_enable,
    input [3:0] read_index,   // Index to read message_buffer
    output reg [7:0] message_byte, // Single byte output
    output reg message_ready
);

    // Internal memory array to store the formatted message
    reg [7:0] message_buffer[0:14];

    // Keeps track of the message length
    reg [3:0] write_idx; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            message_ready <= 0;
        end 
        else if (write_enable) begin
            // Reset write index
            write_idx = 0;

            // Append Message Type
            case (message_type)
                3'b000: begin 
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1; 
                    message_buffer[write_idx] = "L"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "M"; write_idx = write_idx + 1; 
                end

                3'b001: begin 
                    message_buffer[write_idx] = "R"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "P"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "M"; write_idx = write_idx + 1; 
                end

                3'b010: begin 
                    message_buffer[write_idx] = "R"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "D"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "M"; write_idx = write_idx + 1; 
                end

                3'b011: begin 
                    message_buffer[write_idx] = "E"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "N"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "D"; write_idx = write_idx + 1; 
                end

                3'b100: begin 
                    message_buffer[write_idx] = "D"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "B"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "G"; write_idx = write_idx + 1; 
                end

                default: begin 
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1; 
                end
            endcase

            // Append '-' separator
            message_buffer[write_idx] = "-"; 
            write_idx = write_idx + 1;
				
					// only if message_type == SLM RDP RPM
			if (message_type == 3'b000 || message_type == 3'b001 || message_type == 3'b010) begin

            // Append Location
            case (location)
                3'b000: begin 
                    message_buffer[write_idx] = "P"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "U"; write_idx = write_idx + 1; 
                end

                3'b001: begin 
                    message_buffer[write_idx] = "F"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "U"; write_idx = write_idx + 1; 
                end

                3'b010: begin 
                    message_buffer[write_idx] = "W"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "U"; write_idx = write_idx + 1; 
                end

                3'b011: begin 
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "U"; write_idx = write_idx + 1; 
                end

                3'b100: begin 
                    message_buffer[write_idx] = "M"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "U"; write_idx = write_idx + 1; 
                end

                default: begin 
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1; 
                end
            endcase

            // Append Number Data
            message_buffer[write_idx] = numData + "0";
            write_idx = write_idx + 1;

            // Append '-' separator
            message_buffer[write_idx] = "-"; 
            write_idx = write_idx + 1;
			 end 
			 
			 if (message_type == 3'b000) begin


				// only if message_type == SLM
            // Append Color Data
            case (colorData)
                2'b00: begin 
                    message_buffer[write_idx] = "I"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "M"; write_idx = write_idx + 1; 
                end

                2'b01: begin 
                    message_buffer[write_idx] = "I"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1; 
                end

                2'b10: begin 
                    message_buffer[write_idx] = "A"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "S"; write_idx = write_idx + 1; 
                end

                default: begin 
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1;
                    message_buffer[write_idx] = "X"; write_idx = write_idx + 1; 
                end
            endcase
				
            // Append '-' separator
            message_buffer[write_idx] = "-"; 
            write_idx = write_idx + 1;
			end 

            // Append '#' End Character
            message_buffer[write_idx] = "#";
            write_idx = write_idx + 1;

            // Indicate that message is ready
            message_ready <= 1;
        end
    end

    // Output one byte at a time
    always @(posedge clk) begin
        if (message_ready) begin
            message_byte <= message_buffer[read_index];
        end
    end

endmodule