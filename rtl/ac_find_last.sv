`timescale 1ns/1ps
/***************************************************************************************
*@Description	: Find the index of last none zero data
*@Other			: This function is a FIFO structure
*@Author		: Deamonyang
*@E-mail		: deamonyang@foxmail.com
****************************************************************************************/
module ac_find_last#(		
		parameter FIND_IN_WIDTH 		= 16,
		parameter FIND_OUT_WIDTH 		= 16
	)(
		input								clk_x8_i	,
		input								rst_n_i		,
		
		input								find_data_go_i,//block data start
		input[FIND_IN_WIDTH-1:0]			find_data_in_i,// abs(ac_data_in_i) < 1024
		
		output reg[5:0]						find_data_len_o,//index of last none zero data
		output reg[FIND_OUT_WIDTH-1:0]		find_data_out_o,//
		output reg							find_data_done_o//
	);
	
	reg[FIND_IN_WIDTH-1:0]		data_buf[8*8];
	reg [5:0]					wr_idx;
	reg [5:0]					rd_idx;
	reg [5:0]					data_cnt;

	wire						rd_start;
	
	
	assign rd_start = (wr_idx == 6'd63);
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		find_data_done_o <= 1'b0;
	else if(wr_idx == 6'd62)
		find_data_done_o <= 1'b1;
	else
		find_data_done_o <= 1'b0;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		find_data_len_o <= 6'd0;
	else
		find_data_len_o <= data_cnt;
	
	/*generate write pointer*/
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		wr_idx <= 6'd63;
	else if(find_data_go_i || (wr_idx != 6'd63))
		wr_idx <= wr_idx + 1'b1;
	else
		wr_idx <= wr_idx;
		
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		data_cnt <= 6'd0;
	else if(wr_idx==0)
		data_cnt <= 6'd0;
	else if(find_data_in_i != {FIND_OUT_WIDTH{1'b0}})
		data_cnt <= wr_idx;
	else
		data_cnt <= data_cnt;
	
	/*generate read data pointer*/	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rd_idx <= 1'b0;
	else if(rd_start || (rd_idx != 6'd0))
		rd_idx <= rd_idx + 1'b1;
	else
		rd_idx <= rd_idx;
	
	/*save data to ram buffer*/
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		data_buf[0] <= 'd0;
	else
		data_buf[wr_idx] <= find_data_in_i;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		find_data_out_o <= 'd0;
	else
		find_data_out_o <= data_buf[rd_idx];	

endmodule
