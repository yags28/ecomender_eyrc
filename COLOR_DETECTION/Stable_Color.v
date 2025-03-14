module Stable_Color(
input clk,
input rst,
input [2:0] color_current,
output reg [2:0] color_prev
);


reg[2:0] temp1_color,temp2_color;

initial begin 
color_prev <= 2'b00;
temp1_color <= 2'b00;
temp2_color <= 2'b00;

end

// New color recording logic with white color prevention
always @(posedge clk) begin

		if(rst)begin
			color_prev <= 2'b00;
			temp1_color <= 2'b00;
			temp2_color <= 2'b00;
		end

		if((temp2_color == temp1_color == color_current) && temp2_color != 2'b00) begin
			color_prev <= temp2_color;
		end
	end
	
	
endmodule
