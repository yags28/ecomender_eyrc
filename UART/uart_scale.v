module uart_scale (
    input clk,
    output reg clk_out
);

// Declaring registers
reg [2:0] s_clk_counter = 0;

// For ADC Module 50Mhz to 3.125Mhz
always @(posedge clk) begin
    if (!s_clk_counter) begin
	 clk_out = ~clk_out;
	 end
    s_clk_counter = s_clk_counter + 1'b1;
end

endmodule