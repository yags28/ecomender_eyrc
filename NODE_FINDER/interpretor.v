module interpretor (
    input wire [1:0] current_unit,
    input wire msgType,
    input wire node_select,
    input wire [2:0] data,
    output reg [5:0] node_id
);

always @(*) begin
    if (msgType) begin //csl message
        case (data)
            3'd0, 3'd2: node_id <= 5'd10;
            3'd1: node_id <= 5'd18;
            default: node_id <= 6'b111111;
        endcase
    end
    else begin  // sam message
        if(node_select) begin //bottom locations
            case (data)
                3'd1: node_id <= 5'd9;       // MU1 
                3'd2: node_id <= 5'd8;       // MU2    
                3'd3: node_id <= 5'd7;       // MU3    
                3'd5: node_id <= 5'd5;       // SU1    
                3'd6: node_id <= 5'd4;       // SU2    
                3'd7: node_id <= 5'd3;       // SU3    
                default: node_id <= 6'b111111;
            endcase
        end
        else begin      // the position only PSU FSU WSU
            case(current_unit)
                2'b00: begin        // PSU
                    case (data)
                        3'd0: node_id <= 5'd27;       // PSU1
                        3'd1: node_id <= 5'd29;       // PSU2
                        3'd2: node_id <= 5'd31;       // PSU3
                        default: node_id <= 6'b111111;
                    endcase
                    end       
                2'b01: begin        // WSU
                    case (data)
                        3'd0: node_id <= 5'd17;       // WSU1
                        3'd1: node_id <= 5'd15;       // WSU2
                        3'd2: node_id <= 5'd13;       // WSU3
                        default: node_id <= 6'b111111;
                    endcase
                    end       
                2'b10: begin        // FSU
                    case (data)
                        3'd0: node_id <= 5'd25;       // FSU1
                        3'd1: node_id <= 5'd22;       // FSU2
                        3'd2: node_id <= 5'd20;       // FSU3
                        default: node_id <= 6'b111111;
                    endcase
                    end       
                default: node_id <= 6'b111111;
            endcase
        end
    end
end

endmodule