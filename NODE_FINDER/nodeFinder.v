
module nodeFinder(
    input clk,
    input msg_received,
    //message handle
    input [7:0] message_char,
    output wire [4:0] message_pos,
    //travel related
    input wire travel_done,
    output wire run_done,
    output wire [5:0] node_id,
   // output wire [2:0] scan_state,
    output wire node_select,start_cpu,
    output wire [5:0] node_start,
	 output wire cpu_done,
	 output wire pick_mode,
	 input wire [3:0 ] curr_pos,
	 output wire [1:0] data_out,
	 output wire [3:0] dir_arr_len,
    input wire done,
    input wire msgType,
    input wire [1:0] reg_pos,
    input wire [2:0] reg_data,
    input wire reg_write_en
);

wire clk_slow;

Frequency_Scaling  #(.COUNTER_WIDTH(5), .MAX_COUNT(8)) fqs3_125hz (
    clk,
    clk_slow
);


// reader rdr (
//     .clk(clk_slow),
//     .msg_received(msg_received),
//     .msgType(msgType),
//     .done(done),
//     .message_char(message_char),
//     .message_pos(message_pos),
//     .reg_pos(reg_pos),
//     .reg_data(reg_data),
//     .reg_write_en(reg_write_en)
// );


ship_master smt (
    .clk(clk_slow),
    .read_done(done),
    .msgType(msgType),
    .reg_pos_in(reg_pos),
    .reg_data(reg_data),
    .reg_write_en(reg_write_en),
    .travel_done(travel_done),
    .run_done(run_done),
    .node_id(node_id),
    //.scan_state(scan_state),
    .node_select(node_select),
    .node_start(node_start),
    .start_cpu(start_cpu),
	 .pick_mode(pick_mode)
);



// Instantiate DUT
RISC_V_Wrapper uut (
        .clk(clk_slow),
        .rst(travel_done),
        .SP(node_start),				// {{26{0}}, node_start[5:0]}
        .EP(node_id),								//{{26{0}}, node_id[5:0]}
        .reset_internal(reset_internal),
        .start(start_cpu),
        .cpu_Result(),
        .cpu_WriteData(),
        .cpu_MemWrite(),
        .cpu_DataAdr(),
        .cpu_ReadData(),
        .cpu_PC(),
        .pos_in(curr_pos),
        .data_out(data_out),
        .dir_array_aggr(),
        .i(dir_arr_len),
        .cpu_done(cpu_done)
    );

endmodule