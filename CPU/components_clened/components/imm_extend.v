
// imm_extend.v - logic for sign extension
module imm_extend (
    input  [31:7]     instr,
    input  [ 2:0]     immsrc, //3 bit control signal
    output reg [31:0] immext
//	 
);

always @(*) begin
    

immext = (immsrc == 3'b000) ? {{20{instr[31]}}, instr[31:20]} :         // I-type
                (immsrc == 3'b001) ? {{20{instr[31]}}, instr[31:25], instr[11:7]} : // S-type (stores)
                (immsrc == 3'b010) ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} : // B-type (branches)
                (immsrc == 3'b011) ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} : // J-type (jal)
                (immsrc == 3'b100) ? {instr[31:12], 12'b0} :                      // U-type
                32'b0; // Default to 0 for undefined cases
					 
					 end

endmodule