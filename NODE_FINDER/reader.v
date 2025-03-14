module reader(
    input clk,
    input msg_received,
    output reg msgType,
    output reg done,
    //message handle
    input [7:0] message_char,
    output reg [4:0] message_pos,
    //reg write
    output reg [1:0] reg_pos,
    output reg [2:0] reg_data,
    output reg reg_write_en
);

    localparam [2:0] IDLE = 3'b000;
    localparam [2:0] READ = 3'b001;
    localparam [2:0] DONE = 3'b010;
    localparam [4:0] MAX_MESSAGE_POS = 5'd23;
    
    reg [2:0] current_state, next_state;

    initial begin
        current_state = IDLE;
        next_state = IDLE;
		  msgType = 0;
		  
    end

    always @(posedge clk) begin
        current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE: begin
                if(msg_received) begin
                    next_state = READ;
                end
                else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                if(message_pos == MAX_MESSAGE_POS || message_char == 8'h23) begin
                    next_state = DONE;
                end
                else begin
                    next_state = READ;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    reg temp_msb;
    always @(posedge clk) begin
        case(current_state)
            IDLE: begin
                message_pos = 5'b00000;
                reg_pos = 2'b00;
                reg_data = 3'b000;
                reg_write_en = 0;
                done = 0;
					 if(msg_received) begin
                    msgType=0 ;
                end
//					 msgType = 0;
					 
            end
            READ: begin
                done = 0;
                case (message_pos) 
                    5'b00000: begin
                        reg_write_en = 0;
                        case(message_char)
                            8'h43 : msgType = 1;    //msg is csl
                            8'h53 : msgType = 0;    //msg is sam
                            default: msgType = 0;
                        endcase
                    end
                    5'b00100: begin
                        // since msgType is an output we might get error for deciding logic upon it. we can make it an internal reg and then use wire as output that points out from that reg. and use the internal reg here.
                        if (msgType) begin // only csl will get here
                        reg_write_en = 1; 
                        reg_pos = 2'd0;
                            case(message_char)
                                8'h50 : reg_data = 3'd0;    //node is P
                                8'h57 : reg_data = 3'd1;    //node is W
                                8'h46 : reg_data = 3'd2;    //node is F
                                default: reg_data = 3'd3;   //error
                            endcase
                        end
                    end
                    5'd6, 5'd12, 5'd18: begin
                        reg_write_en = 0;
                        if(!msgType) begin // only sam will get here
                            case(message_char)
                                8'h4D : temp_msb = 0;
                                8'h53 : temp_msb = 1;
                                default: temp_msb = 0;   //also for case 8'h58
                            endcase
                        end
                    end
                    5'd8: begin
                        if(!msgType) begin // only sam will get here
                        reg_pos = 2'd0;
                        reg_write_en = 1;
                            case(message_char)
                                8'h31 : begin // 1
                                    reg_data = {temp_msb, 2'd1};
                                end
                                8'h32 : begin // 2
                                    reg_data = {temp_msb, 2'd2};
                                end
                                8'h33 : begin // 3
                                    reg_data = {temp_msb, 2'd3};
                                end
                                default: begin 
                                    reg_data = 3'b000;
                                end   //error
                            endcase
                        end
                    end
                    5'd14: begin
                        if(!msgType) begin // only sam will get here
                        reg_pos = 2'd1;
                        reg_write_en = 1;
                            case(message_char)
                                8'h31 : begin // 1
                                    reg_data = {temp_msb, 2'd1};
                                end
                                8'h32 : begin // 2
                                    reg_data = {temp_msb, 2'd2};
                                end
                                8'h33 : begin // 3
                                    reg_data = {temp_msb, 2'd3};
                                end
                                default: begin 
                                    reg_data = 3'b000;
                                end   //error
                            endcase
                        end
                    end
                    5'd20: begin
                        if(!msgType) begin // only sam will get here
                        reg_pos = 2'd2;
                        reg_write_en = 1;
                            case(message_char)
                                8'h31 : begin // 1
                                    reg_data = {temp_msb, 2'd1};
                                end
                                8'h32 : begin // 2
                                    reg_data = {temp_msb, 2'd2};
                                end
                                8'h33 : begin // 3
                                    reg_data = {temp_msb, 2'd3};
                                end
                                default: begin 
                                    reg_data = 3'b000;
                                end   //error
                            endcase
                        end
                    end
                    default: begin
                        reg_write_en = 0;
								end
                endcase
                message_pos = message_pos + 1;
            end
            DONE: begin
                done = 1;
					 message_pos = 5'b00000;
                reg_pos = 2'b00;
                reg_data = 3'b000;
                reg_write_en = 0;
					 temp_msb = 0;
				//	 msgType = 0;
            end
        endcase
    end
endmodule
