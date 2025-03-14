module clock_scaler(
	input clk_50M,
	output reg clk_3125K,
	output reg clk_1M,
	output reg clk_50H
);

	// Counter registers for each clock
    reg [3:0] counter_3125K = 0;    // Divide by 16 for 3.125MHz
    reg [5:0] counter_1M = 0;       // Divide by 50 for 1MHz
    reg [19:0] counter_50H = 0;     // Divide by 1,000,000 for 50Hz
	
    // Initialize all clock outputs to 0
    initial begin
        clk_3125K = 0;
        clk_1M = 0;
        clk_50H = 0;
    end

    // 3.125MHz clock generation (50MHz/16 = 3.125MHz)
    always @(posedge clk_50M) begin
        if (counter_3125K == 7) begin
            counter_3125K <= 0;
            clk_3125K <= ~clk_3125K;
        end else begin
            counter_3125K <= counter_3125K + 1;
        end
    end

    // 1MHz clock generation (50MHz/50 = 1MHz)
    always @(posedge clk_50M) begin
        if (counter_1M == 24) begin
            counter_1M <= 0;
            clk_1M <= ~clk_1M;
        end else begin
            counter_1M <= counter_1M + 1;
        end
    end

    // 50Hz clock generation (50MHz/1,000,000 = 50Hz)
    always @(posedge clk_50M) begin
        if (counter_50H == 499999) begin
            counter_50H <= 0;
            clk_50H <= ~clk_50H;
        end else begin
            counter_50H <= counter_50H + 1;
        end
    end

endmodule