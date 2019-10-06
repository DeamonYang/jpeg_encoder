`timescale 1ns/1ps
/***************************************************************************************
*@Description	: Data mergence module
*@Other			: Output sequence: [DC_seq, AC_seq.....]
*@Author		: Deamonyang
*@E-mail		: deamonyang@foxmail.com
****************************************************************************************/
module ac_assemble#(
		parameter DC_IN_WIDTH 		= 20,
		parameter AC_IN_WIDTH 		= 32,
		parameter SEQ_OUT_WIDTH 	= 32
	)(
		input							clk_x8_i	,
		input							rst_n_i		,
	
			
		input							ac_valid_i	, 	
		input[AC_IN_WIDTH-1:0]			ac_seq_i	,//{amp_code,ac_code}
		input[4:0]						ac_seq_len_i,
		input							ac_go_i		,
		input							ac_last_i	,
	
		input[4:0]						dc_len_i	, 	
		input[DC_IN_WIDTH-1:0]			dc_seq_i	,
		input							dc_go_i		,
		
		output reg[SEQ_OUT_WIDTH-1:0]	seq_out_o	,
		output reg						seq_valid_o	,
		output reg						seq_done_o	,
		output reg						seq_last_o	,
		output wire[SEQ_OUT_WIDTH-1:0]	seq_left_o	
	);
	
	reg[SEQ_OUT_WIDTH-1:0]		data_buf;
	wire[SEQ_OUT_WIDTH-1:0]		data_mask[SEQ_OUT_WIDTH-1:0];
	wire[32:0]					seq_bus;
	reg[5:0]					add_idx;
	
	wire[5:0]					per_add;
	
	assign per_add = dc_go_i?(add_idx + dc_len_i):(add_idx + ac_seq_len_i);
	assign seq_bus = (dc_go_i)?({'d0,dc_seq_i}):(ac_seq_i);
	assign seq_left_o = data_buf;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		seq_last_o <= 1'b0;
	else
		seq_last_o <= ac_last_i;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		seq_done_o <= 1'b0;
	else
		seq_done_o <= ac_go_i;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		add_idx <= 6'd0;
	else if((~ac_valid_i)&(~dc_go_i))
		add_idx <= add_idx;
	else if(per_add < 32)
		add_idx <= per_add;
	else
		add_idx <= per_add - 6'd32;
		
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		data_buf <= 'd0;
	else if((~ac_valid_i)&(~dc_go_i))
		data_buf <= data_buf;
	else if(per_add < 32)
		data_buf <= ((data_buf&data_mask[add_idx-1])| (seq_bus<<(32-per_add)));
	else 
		data_buf <= (seq_bus<<(32+(32-per_add)));

	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		seq_out_o <= 32'd0;
	else if((~ac_valid_i)&(~dc_go_i))
		seq_out_o <= seq_out_o;
	else if(per_add >= 32)
		seq_out_o <= (data_buf&data_mask[add_idx-1])|(seq_bus>>(per_add-32));
	else
		seq_out_o <= seq_out_o;
		
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		seq_valid_o <= 1'b0;
	else if((~ac_valid_i)&(~dc_go_i))
		seq_valid_o <= 1'b0;
	else if(per_add >=32)
		seq_valid_o <= 1'b1;
	else
		seq_valid_o <= 1'b0;
	
	generate 
		genvar i;
		for(i = 0;i < 32;i ++)begin:mask
			assign data_mask[i] = {{(i+1){1'b1}},{(31-i){1'b0}}};
		end
	endgenerate
	
		
endmodule 








