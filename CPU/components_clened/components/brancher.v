//brancher.v

module brancher (
	input				branch, jump, zero,
	input [2:0]		funct3,
	output		pcsrc
);


assign pcsrc = (funct3[2] ^ funct3[0]) ?((branch & ~zero) | jump) : ((branch & zero) | jump);


endmodule