
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,
    input [3:0]   ALUControl,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    input         funct7b5
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCimm;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [1:0]  PCsel_jalr;

// jalr_W signal generation
assign PCsel_jalr = {(Instr[6:0] == 7'd103),PCSrc};

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
// mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCint);
// mux2 #(32)     pcJALRmux(PCint, ALUResult, jalr_w, PCNext);
mux4 #(32)     resultmux_o(PCPlus4, PCTarget, ALUResult, ALUResult, PCsel_jalr, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);

// Result MUX logic
mux4 #(32)     resultmux(ALUResult, ReadData, PCPlus4, PCimm, ResultSrc, Result);

// PC immediate MUX logic
mux2 #(32)     PCimmMux(PCTarget, ImmExt, funct7b5, PCimm);

// Assignments
assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule