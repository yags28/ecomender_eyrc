/*
//# Team ID:          3800
//# Theme:            ecomender bot
//# Author List:      manny, priyank, yagnesh, sohum 
//# Filename:         led controller
//# File Description: led1, 2, 3 are connected to the 3 leds on the bot and this file controlles the color according to the detected color and done flag
*/

module led_controller(
    input wire [1:0] color_current,
    input wire done,
    input wire clk,
    input wire [4:0] current_pos,
    input wire msg_rec,
    input wire place_done,
    output reg [3:0] led1,
    output reg [3:0] led2,
    output reg [3:0] led3,
    output reg [3:0] led4,
    input wire msgType
);

reg [24:0] counter;
reg [24:0] delay_counter;
reg blink_state;
reg [1:0] color_prev;
reg [1:0] temp1_color;
reg [1:0] temp2_color;
reg [24:0] msg_counter;
reg msg_active;

// New registers for tracking three colors
reg [1:0] first_color;
reg [1:0] second_color;
reg [1:0] third_color;
reg [1:0] color_count;
reg assignment_complete;  // New flag to indicate all colors are assigned

initial begin 
    color_prev = 2'b00;
    temp1_color = 2'b00;
    temp2_color = 2'b00;
    led1 = 3'b000;
    led2 = 3'b000;
    led3 = 3'b000;
    led4 = 3'b000;
    first_color = 2'b00;
    second_color = 2'b00;
    third_color = 2'b00;
    color_count = 2'b00;
    assignment_complete = 0;
end

// Modified color detection and LED display logic
always @(posedge clk) begin
    if (delay_counter == 4_000_000) begin
        temp2_color <= temp1_color;
        temp1_color <= color_current;
        delay_counter <= 0;
    end else begin
        delay_counter <= delay_counter + 1;
    end
end

// New color recording logic with white color prevention
always @(posedge clk) begin
    if(!assignment_complete && (temp2_color == temp1_color) && (temp1_color == color_current) && (temp2_color != 2'b00)) begin
        color_prev = temp2_color;
        
        // Record colors sequentially, skipping white
        case(color_count)
            2'b00: begin
                if(first_color == 2'b00 && color_prev != 2'b00) begin  /// temp2_color has been changed to color_prev
                    first_color <= color_prev;
                    color_count <= color_count + 1;
                end
            end
            2'b01: begin
                if(second_color == 2'b00 && color_prev != 2'b00 && color_prev != first_color) begin
                    second_color <= color_prev;
                    color_count <= color_count + 1;
                end
            end
            2'b10: begin
                if(third_color == 2'b00 && color_prev != 2'b00 && 
                   color_prev != first_color && color_prev != second_color) begin
                    third_color <= color_prev;
                    color_count <= color_count + 1;
                    assignment_complete <= 1;  // Set completion flag when all colors are assigned
                end
            end
        endcase
    end
end

// Modified LED display logic
always @(posedge clk) begin
    if (done) begin
        counter <= counter + 25'b1;
        if (counter == 24_000_000) begin
            blink_state <= ~blink_state;
            counter <= 0;
        end
        if (blink_state) begin
            led1 <= 3'b010;
            led2 <= 3'b010;
            led3 <= 3'b010;
        end else begin
            led1 <= 3'b000;
            led2 <= 3'b000;
            led3 <= 3'b000;
        end
    end 
    else begin
        counter <= 0;
        blink_state <= 0;
        
        // Only display colors if they're not white (2'b00)
        if(first_color != 2'b00) begin
            case(first_color)
                2'b01: led1 = 3'b100; // Red
                2'b10: led1 = 3'b010; // Green
                2'b11: led1 = 3'b001; // Blue
                default: led1 = 3'b000;
            endcase
        end
        
        if(second_color != 2'b00) begin
            case(second_color)
                2'b01: led2 = 3'b100;
                2'b10: led2 = 3'b010;
                2'b11: led2 = 3'b001;
                default: led2 = 3'b000;
            endcase
        end
        
        if(third_color != 2'b00) begin
            case(third_color)
                2'b01: led3 = 3'b100;
                2'b10: led3 = 3'b010;
                2'b11: led3 = 3'b001;
                default: led3 = 3'b000;
            endcase
        end
    end
end

// Keeping the original LED4 message reception logic unchanged
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