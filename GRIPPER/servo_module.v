module gripper (
    input wire clk,                    // Main clock
	 input wire clk_out_s,
    input wire reset,
    input wire obstacle_detected,      // Trigger from the IR sensor module
    input wire start_grip,             // Trigger from UART module
    input wire pick_mode,              // 1 = Pick, 0 = Place
    output reg sarm_pwm,               // PWM for Servo Arm
    output reg sclaw_pwm,              // PWM for Servo Claw
    output reg pick_done,              // Pick operation completed
    output reg place_done,             // Place operation completed
    output reg [3:0] state,            // FSM state
    output reg pick_start,             // Start Pick State
    output reg place_start             // Start Place State
);

// Parameters for Servo Timing
reg signed [31:0] sarm_angle;          // Arm Servo Angle
reg signed [31:0] sclaw_angle;         // Claw Servo Angle
reg [19:0] timer;                      // PWM Timer
reg [7:0] pwm_step;                    // Increment Step
reg grip_active;                      // Indicates an ongoing operation

// FSM States
localparam IDLE = 4'd0,
           PICK_OPEN = 4'd1,
           PICK_LOWER = 4'd2,
           PICK_CLOSE = 4'd3,
           PICK_LIFT = 4'd4,
           PLACE_LOWER = 4'd5,
           PLACE_OPEN = 4'd6,
           PLACE_LIFT = 4'd7,
           PLACE_CLOSE = 4'd8;

// Servo Timing Parameters (50Hz PWM: 20ms period)
localparam signed SLOPE = 32'd556;
localparam MIN_VALUE = 32'd10000;
localparam MAX_VALUE = 32'd170000;

// Initial Conditions
initial begin
    sarm_angle = -90;
    sclaw_angle = 0;
    timer = 0;
    pwm_step = 5;
    state = IDLE;
    pick_done = 0;
    place_done = 0;
    grip_active = 0;
    pick_start = 0;
    place_start = 0;
end

// Function to Convert Degrees to PWM
function [19:0] convert_to_pwm_threshold;
    input signed [31:0] degrees;
    reg signed [31:0] clamped_deg;
    reg [31:0] pulse_counts;
    begin
        clamped_deg = (degrees < -90) ? -90 :
                      (degrees >  90) ?  90 : degrees;
        pulse_counts = MIN_VALUE + (clamped_deg + 90) * SLOPE;
        if (pulse_counts < MIN_VALUE) pulse_counts = MIN_VALUE;
        else if (pulse_counts > MAX_VALUE) pulse_counts = MAX_VALUE;
        convert_to_pwm_threshold = pulse_counts[19:0];
    end
endfunction

// FSM Logic (Runs at 50Hz)
always @(posedge clk_out_s or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        sarm_angle <= -90;
        sclaw_angle <= 0;
        pick_done <= 0;
        place_done <= 0;
        grip_active <= 0;
        pick_start <= 0;
        place_start <= 0;
    end else begin
        pick_done <= 0;
        place_done <= 0;

        pick_start <= start_grip && obstacle_detected && pick_mode;
        place_start <= start_grip && !pick_mode;

        case (state)
            IDLE: begin
                if (pick_start) begin
                    grip_active <= 1;
                    state <= PICK_OPEN;
                end else if (place_start) begin
                    grip_active <= 1;
                    state <= PLACE_LOWER;
                end
            end

            PICK_OPEN: begin
                sclaw_angle <= 0;
                state <= PICK_LOWER;
            end

            PICK_LOWER: begin
                if (sarm_angle < 30) 
                    sarm_angle <= sarm_angle + pwm_step;
                else 
                    state <= PICK_CLOSE;
            end

            PICK_CLOSE: begin
                sclaw_angle <= 15;
                state <= PICK_LIFT;
            end

            PICK_LIFT: begin
                if (sarm_angle > -90) 
                    sarm_angle <= sarm_angle - pwm_step;
                else begin
                    pick_done <= 1;
                    grip_active <= 0;
                    state <= IDLE;
                end
            end

            PLACE_LOWER: begin
                if (sarm_angle < 30) 
                    sarm_angle <= sarm_angle + pwm_step;
                else 
                    state <= PLACE_OPEN;
            end

            PLACE_OPEN: begin
                sclaw_angle <= 0;
                state <= PLACE_LIFT;
            end

            PLACE_LIFT: begin
                if (sarm_angle > -90) 
                    sarm_angle <= sarm_angle - pwm_step;
                else 
                    state <= PLACE_CLOSE;
            end

            PLACE_CLOSE: begin
                sclaw_angle <= 15;
                place_done <= 1;
                grip_active <= 0;
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

// PWM Generation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        sarm_pwm <= 0;
        sclaw_pwm <= 0;
        timer <= 0;
    end else begin
        timer <= (timer >= 999999) ? 0 : timer + 1;
        sarm_pwm <= (timer < convert_to_pwm_threshold(sarm_angle));
        sclaw_pwm <= (timer < convert_to_pwm_threshold(sclaw_angle));
    end
end
  
endmodule

