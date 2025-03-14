module world_FSM(
    input wire clk_3125,
    // Inputs to write to csl queue
    // input wire [1:0] csl_reg_pos,
    input wire [2:0] csl_reg_data,
    input wire csl_reg_write_en,
    input wire msgType,
);
    // Declare the array (register) to store 3-bit elements
    reg [2:0] csl_queue [3:0];  // 4 elements of 3 bits each
    reg [1:0] write_pos = 2'b0;        // Position counter (0 to 3)

    // Always block for writing to array
    always @(posedge clk_3125) begin
        if (msgType && csl_reg_write_en) begin
            csl_queue[write_pos] <= csl_reg_data;
            write_pos <= write_pos + 1;
        end
    end
endmodule