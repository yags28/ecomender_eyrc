module led_controller(
    input wire clk,
    input wire rst,
    input wire [2:0] stable_color,  // 3-bit stable color input
	 input wire [1:0] address,       // Address to control where to store the color
    input wire msgType,
    output reg [2:0] led1,
    output reg [2:0] led2,
    output reg [2:0] led3,
    output reg [3:0] led4
);

//reg [1:0] color_count;  // Keeps track of how many colors have been assigned
reg [8:0] store_color;
integer i;

always @(posedge clk or posedge rst) begin
		if(rst) begin 
			store_color <= 9'b0;
		end
     else if (stable_color != 3'b000) begin  // Ignore white (3'b000)
        case (address)
            2'b00: store_color[2:0]   <= stable_color;  // Store in first 3 bits
            2'b01: store_color[5:3]   <= stable_color;  // Store in next 3 bits
            2'b10: store_color[8:6]   <= stable_color;  // Store in last 3 bits
            default: store_color[8:0] <= 8'b0;  // Do nothing if an invalid address
        endcase 
    end
end

// Combinational logic for LEDs
always @(*) begin
	if (rst) begin
        led1 = 3'b000;
        led2 = 3'b000;
        led3 = 3'b000;
    end else begin
    led1 = store_color[2:0];  // First 3 bits control LED1
    led2 = store_color[5:3];  // Next 3 bits control LED2
    led3 = store_color[8:6];  // Last 3 bits control LED3
	 end
end

// LED4 message reception logic (unchanged)
reg [24:0] msg_counter;
reg msg_active;

always @(posedge clk) begin
    if (msgType) begin
        msg_active <= 1;
        msg_counter <= 0;
    end
    if (msg_active) begin
        led4 <= 3'b110;
        msg_counter <= msg_counter + 1;
        if (msg_counter >= 25_000_000) begin
            led4 <= 3'b000;
            msg_active <= 0;
        end
    end else begin
        led4 <= 3'b000;
    end
end

endmodule
