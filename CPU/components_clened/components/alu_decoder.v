
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000; // addition
        2'b01: begin
            case (funct3)
                // meant for branching instructions
                3'b000, 3'b001: ALUControl = 4'b0001; // beq, bne
                3'b100, 3'b101: ALUControl = 4'b0101; // blt, bge
                3'b110, 3'b111: ALUControl = 4'b0110; // bltu, bgeu
                default: ALUControl = 4'bxxxx; // ???
            endcase
        end
        2'b10: begin
            case (funct3) // R-type or I-type ALU
                3'b000: ALUControl = (funct7b5 & opb5) ? 4'b0001 : 4'b0000; // sub or add, addi
                3'b001: ALUControl = 4'b1000; // SLLI (Shift Left Logical Immediate)
                3'b010: ALUControl = 4'b0101; // slt, slti
                3'b011: ALUControl = 4'b0110; // SLTIU (unsigned comparison)
                3'b100: ALUControl = 4'b0100; // XOR
                3'b101: ALUControl = funct7b5 ? 4'b1001 : 4'b0111; // SRAI or SRLI
                3'b110: ALUControl = 4'b0011; // or, ori
                3'b111: ALUControl = 4'b0010; // and, andi
                default: ALUControl = 4'bxxxx; // ???
            endcase
        end
        default: ALUControl = 4'bxxxx; // ???
    endcase
end

endmodule