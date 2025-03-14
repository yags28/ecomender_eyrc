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

    reg [7:0] message_buffer_15B [0:14]; // Internal memory array

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            message_ready <= 0;
        end else if (write_enable) begin
            // Message Type (SLM, RPM, etc.)
            case (message_type)
                3'b000: begin
                    message_buffer_15B[0] <= "S";
                    message_buffer_15B[1] <= "L";
                    message_buffer_15B[2] <= "M";
                end
                3'b001: begin
                    message_buffer_15B[0] <= "R";
                    message_buffer_15B[1] <= "P";
                    message_buffer_15B[2] <= "M";
                end
                3'b010: begin
                    message_buffer_15B[0] <= "R";
                    message_buffer_15B[1] <= "D";
                    message_buffer_15B[2] <= "M";
                end
                3'b011: begin
                    message_buffer_15B[0] <= "E";
                    message_buffer_15B[1] <= "N";
                    message_buffer_15B[2] <= "D";
                end
                3'b100: begin
                    message_buffer_15B[0] <= "D";
                    message_buffer_15B[1] <= "B";
                    message_buffer_15B[2] <= "G";
                end
                default: begin
                    message_buffer_15B[0] <= "X";
                    message_buffer_15B[1] <= "X";
                    message_buffer_15B[2] <= "X";
                end
            endcase

            message_buffer_15B[3] <= "-";

            // Location (PSU, FSU, WSU, SU, MU)
            case (location)
                3'b000: begin
                    message_buffer_15B[4] <= "P";
                    message_buffer_15B[5] <= "S";
                    message_buffer_15B[6] <= "U";
                end
                3'b001: begin
                    message_buffer_15B[4] <= "F";
                    message_buffer_15B[5] <= "S";
                    message_buffer_15B[6] <= "U";
                end
                3'b010: begin
                    message_buffer_15B[4] <= "W";
                    message_buffer_15B[5] <= "S";
                    message_buffer_15B[6] <= "U";
                end
                3'b011: begin
                    message_buffer_15B[4] <= "S";
                    message_buffer_15B[5] <= "U";
                    message_buffer_15B[6] <= " ";
                end
                3'b100: begin
                    message_buffer_15B[4] <= "M";
                    message_buffer_15B[5] <= "U";
                    message_buffer_15B[6] <= " ";
                end
                default: begin
                    message_buffer_15B[4] <= "X";
                    message_buffer_15B[5] <= "X";
                    message_buffer_15B[6] <= "X";
                end
            endcase

            // Number Data
            message_buffer_15B[7] <= numData + "0";
				message_buffer_15B[8] <= "-";
            // Color Data
            case (colorData)
                2'b00: begin
                    message_buffer_15B[9] <= "I";
                    message_buffer_15B[10] <= "M";
                end // IM
                2'b01: begin
                    message_buffer_15B[9] <= "I";
                    message_buffer_15B[10] <= "S";
                end // IS
                2'b10: begin
                    message_buffer_15B[9] <= "A";
                    message_buffer_15B[10] <= "S";
                end // AS
                default: begin
                    message_buffer_15B[9] <= "X";
                    message_buffer_15B[10] <= "X";
                end
            endcase

            // End characters
//            message_buffer_15B[10] <= "*";
            message_buffer_15B[11] <= "#";
//            message_buffer_15B[12] <= "-";
//            message_buffer_15B[13] <= " ";
//            message_buffer_15B[14] <= " ";

            message_ready <= 1;
        end
    end

    // Output one byte at a time
    always @(posedge clk) begin
        if (message_ready) begin
            message_byte <= message_buffer_15B[read_index];
        end
    end

endmodule
