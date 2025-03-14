module ir_sensor (
    input wire clk,                   // Main clock
    input wire reset,                 // Reset signal
    input wire ir_input,              // IR sensor input (active high when obstacle detected)
    output reg obstacle_detected      // Signal to indicate an obstacle is detected
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        obstacle_detected <= 0;
    end else begin
        obstacle_detected <= ir_input; // Pass the IR input as obstacle detection signal
    end
end

endmodule