`timescale 1ns/1ps


module dc_huff_encod#(
		parameter DC_IN_WIDTH 		= 16,
		parameter DC_OUT_WIDTH		= 20
	)(
		input 								clk_i		,
		input								clk_x8_i	,
		input								rst_n_i		,
		input								dc_go_i		,//block data start
		input								dc_frame_i	,//a new picture start
		input  [DC_IN_WIDTH - 1:0]			dc_in_i		, 	
		output reg[4:0]						dc_len_o	, 	
		output reg[DC_OUT_WIDTH-1:0]		dc_seq_o	,
		output reg							dc_done_o	
	);

	reg[DC_IN_WIDTH-1:0]		dc_previous;
	reg							new_frame_en;
	wire[DC_IN_WIDTH-1:0]		dc_data; 
	reg [DC_IN_WIDTH-1:0]		abs_dc_data;
	reg [10:0]					len_mask[10:0];
	wire [10:0]					len_mask_res;
	reg[DC_OUT_WIDTH-1:0]		reg_dc_seq;
	reg[DC_IN_WIDTH-1:0]		pcm_data;
	reg reg_out_done;
	reg							reg_dc_go;
	wire						w_dc_go_posedge;
	wire						dc_go_posedge;
	reg[DC_IN_WIDTH-1:0]		wv_pcm_data;
	
	reg[4:0]					stg_dc_len; 	
	reg[DC_OUT_WIDTH-1:0]		stg_dc_seq;
	reg[1:0]					stg_dc_done;
	
	
	
	assign dc_data = dc_in_i[DC_IN_WIDTH-1 :0];
	assign len_mask_res = len_mask[0]|len_mask[1]|len_mask[2]|len_mask[3]|len_mask[4]|len_mask[5]|len_mask[6]|len_mask[7];
	//assign dc_seq_o = reg_dc_seq;
	assign dc_go_posedge = ((reg_dc_go)&(~dc_go_i));
	
	assign 	wv_pcm_data = (pcm_data[DC_IN_WIDTH-1])?(~(~pcm_data + 1'b1)):pcm_data;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		{dc_seq_o,stg_dc_seq} <= 'd0;
	else
		{dc_seq_o,stg_dc_seq} <= {stg_dc_seq,reg_dc_seq};
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		reg_dc_go <= 1'b0;
	else
		reg_dc_go <= dc_go_i;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		reg_out_done <= 'd0;
	else
		reg_out_done <= dc_go_posedge;//dc_go_i;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		{dc_done_o,stg_dc_done} <= 'd0;
	else
		{dc_done_o,stg_dc_done} <= {stg_dc_done,reg_out_done};
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		dc_len_o <= 'd0;
	else
		dc_len_o <= stg_dc_len;

	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		dc_len_o <= 'd0;
		reg_dc_seq <= 'd0;
	end else begin
		case(len_mask_res)
			11'b0				:begin stg_dc_len = 5'd2 ; reg_dc_seq = {2'd  0					 }; end
			11'b1				:begin stg_dc_len = 5'd4 ; reg_dc_seq = {3'd  2,wv_pcm_data[ 0:0]}; end
			11'b11				:begin stg_dc_len = 5'd5 ; reg_dc_seq = {3'd  3,wv_pcm_data[ 1:0]}; end
			11'b111				:begin stg_dc_len = 5'd6 ; reg_dc_seq = {3'd  4,wv_pcm_data[ 2:0]}; end
			11'b1111			:begin stg_dc_len = 5'd7 ; reg_dc_seq = {3'd  5,wv_pcm_data[ 3:0]}; end
			11'b1_1111			:begin stg_dc_len = 5'd8 ; reg_dc_seq = {3'd  6,wv_pcm_data[ 4:0]}; end
			11'b11_1111			:begin stg_dc_len = 5'd10; reg_dc_seq = {4'd 14,wv_pcm_data[ 5:0]}; end
			11'b111_1111		:begin stg_dc_len = 5'd12; reg_dc_seq = {5'd 30,wv_pcm_data[ 6:0]}; end
			11'b1111_1111		:begin stg_dc_len = 5'd14; reg_dc_seq = {6'd 62,wv_pcm_data[ 7:0]}; end
			11'b1_1111_1111		:begin stg_dc_len = 5'd16; reg_dc_seq = {7'd126,wv_pcm_data[ 8:0]}; end
			11'b11_1111_1111	:begin stg_dc_len = 5'd18; reg_dc_seq = {8'd254,wv_pcm_data[ 9:0]}; end
			11'b111_1111_1111	:begin stg_dc_len = 5'd20; reg_dc_seq = {9'd510,wv_pcm_data[10:0]}; end
			default:begin reg_dc_seq <= 20'd0; stg_dc_len <= 5'd0; end
		endcase
	end
	
	generate 
		genvar i;
		for(i = 0;i < 11;i = i + 1)begin:mask_u
			//always@(posedge clk_i or negedge rst_n_i)
			always@(*)
			if(!rst_n_i)
				len_mask[i] <= 11'd0;
			else if(abs_dc_data[i])
				len_mask[i] <= {(i+1){1'b1}};
			else
				len_mask[i] <= 11'd0;
		end
	endgenerate
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		new_frame_en <= 1'b1;
	else if(dc_frame_i)
		new_frame_en <= 1'b1;
	else if(dc_go_posedge)
		new_frame_en <= 1'b0;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		dc_previous <= 'd0;
	else if(dc_go_posedge)
		dc_previous <= dc_data;
	else
		dc_previous <= dc_previous;

	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
	   pcm_data <= 'd0;
	else if(dc_go_posedge)begin
		if(dc_frame_i)//(new_frame_en)
			pcm_data = dc_data;
		else
			pcm_data = dc_data - dc_previous;
	end else
		pcm_data = pcm_data;
	
	
	always@(*)
	if(pcm_data[DC_IN_WIDTH-1])begin
		abs_dc_data = ~pcm_data + 1'b1;
	end else begin
		abs_dc_data = pcm_data;
	end
	
endmodule










