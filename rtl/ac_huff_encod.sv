`timescale 1ns/1ps

module ac_huff_encod#(
		parameter AC_IN_WIDTH 		= 20,
		parameter AC_OUT_WIDTH 		= 32
	)(
		input								clk_x8_i		,
		input								rst_n_i			,
		input								pic_frame_i		,
		input								ac_data_go_i	,//block data start
		input								ac_data_valid_i	,
		input[AC_IN_WIDTH-1:0]				ac_data_in_i	,// abs(ac_data_in_i) < 1024 {zrlen[3:0],len[3:0],amp[11:0]}
		input								ac_data_last_i	,
		
		output reg							ac_valid_o		, 	
		output reg[AC_OUT_WIDTH-1:0]		ac_seq_o		,//{amp_code,ac_code}
		output reg[4:0]						ac_seq_len_o	,
		output reg							ac_done_o		,
		output reg							ac_last_o
	);
	
	reg[AC_IN_WIDTH-1:0]ac_data_in;
	reg					ac_valid;
	reg[1:0]			ac_done;
	wire[7:0]			idx_addr;
//	wire[3:0]			zero_len;
//	wire[3:0]			amp_len;
	wire[15:0]			wv_ac_code;
	wire[4:0]			wv_ac_len;
	wire[11:0]			wv_amp_data;
	wire[3:0]			wv_amp_len;
	wire[3:0]			wv_zero_len;
	reg[11:0]			rv_amp_huff;
	wire[11:0]			wv_abs_amp;
//	reg[3:0]			rv_ac_len;
	reg[3:0]			rv_amp_len;
	reg[11:0]			amp_data_mask[11:0];
	reg					r_last_en;
	
	assign wv_zero_len = ac_data_in_i[AC_IN_WIDTH-1:AC_IN_WIDTH-4];
//	assign amp_len	= ac_data_in_i[AC_IN_WIDTH-5:AC_IN_WIDTH-8];
	assign idx_addr = {wv_zero_len,wv_amp_len};
	assign wv_amp_data = ac_data_in_i[11:0];
	assign wv_amp_len = ac_data_in_i[AC_IN_WIDTH-5:AC_IN_WIDTH-8];
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		ac_last_o <= 1'b0;
	else
		ac_last_o <= ac_data_last_i;
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rv_amp_huff <= 'd0;
	else if(wv_amp_data[11])
		rv_amp_huff <= wv_amp_data-1'b1;
	else
		rv_amp_huff <= wv_amp_data;
	

	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rv_amp_len <= 'd0;
	else if(ac_data_valid_i)
		rv_amp_len <= wv_amp_len;
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		ac_data_in <= 'd0;
	else
		ac_data_in <= ac_data_in_i;	
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		{ac_valid_o,ac_valid} <= {1'b0,1'b0};
	else
		{ac_valid_o,ac_valid} <= {ac_valid|ac_data_last_i,ac_data_valid_i};
		
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		{ac_done_o,ac_done} <= 'd0;
	else
		{ac_done_o,ac_done} <= {ac_done,ac_data_go_i};		
		
		
	ac_code_rom ac_code_gen(
		.clka	(clk_x8_i),
		.addra	(idx_addr),
		.douta	(wv_ac_code)
		);

	ac_len_rom ac_len_gen(
		.clka(clk_x8_i),
		.addra(idx_addr),
		.douta(wv_ac_len)
		);
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		ac_seq_o <= 'd0;
	else if(~ac_data_last_i)
		ac_seq_o <= (({'d0,wv_ac_code}<<(rv_amp_len)) | {{'d0,rv_amp_huff}&amp_data_mask[rv_amp_len]});
	else
		ac_seq_o <= 'b1010;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		ac_seq_len_o <= 'd0;
	else if(~ac_data_last_i)
		ac_seq_len_o <= wv_ac_len+ rv_amp_len;
	else
		ac_seq_len_o <= 'd4;
		
	generate 
		genvar i;
		for(i = 0;i < 12; i = i + 1)begin:mask_u
			always@(posedge clk_x8_i or negedge rst_n_i)
			if(!rst_n_i)
				amp_data_mask[i] <= 'd0;
			else
				amp_data_mask[i] <= {'d0,{(i){1'b1}}};
		end
	endgenerate	
endmodule 








