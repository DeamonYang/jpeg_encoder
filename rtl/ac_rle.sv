`timescale 1ns/1ps
/***************************************************************************************
*@Description	: Zero run-length encoding with assumptuon: abs(ac_data_in_i) < 1024
*@Other			: Output data format: {zero_len[3:0],am_data[11:0]}
*@Author		: Deamonyang
*@E-mail		: deamonyang@foxmail.com
****************************************************************************************/
module ac_rle#(		
		parameter RLE_IN_WIDTH 		= 16,
		parameter RLE_OUT_WIDTH 	= 20
	)(
		input 								clk_i		,
		input								clk_x8_i	,
		input								rst_n_i		,
		
		input								rle_data_go_i,//block data start
		input[RLE_IN_WIDTH-1:0]				rle_data_in_i,//abs(ac_data_in_i) < 1024
		input[5:0]							rle_data_len_i,
		
		output reg[RLE_OUT_WIDTH-1:0]		rle_data_out_o,		//{zero_len[3:0],amp_len[3:0],am_data[11:0]}
		output reg							rle_data_valid_o,	//output data is valid
		output reg							rle_data_done_o,		//start to output data. Hight is valid
		output reg							rle_data_last_o
	);

	reg[3:0]					zro_cnt;
	reg[5:0]					data_cnt;
	reg[5:0]					rv_rle_data_len_i;
	reg							r_rle_en;
//	reg							rle_data_valid;
	wire						rle_en;
	reg[10:0]					data_mask[10:0];
	wire[10:0]					data_mask_all;
	wire[10:0]					wv_data; 
	wire[10:0]					abs_data;
	reg[3:0]					amp_len;
	reg[RLE_OUT_WIDTH-5:0]		rle_data_out;		//{zero_len[3:0],am_data[11:0]}
	reg							rle_data_valid;	//output data is valid
	reg							rle_data_done;
	reg							rle_data_go;
	
	wire[3:0]					wv_zero_len;
	wire[11:0]					wv_am_data;
	

	assign wv_zero_len = rle_data_out[RLE_IN_WIDTH-1:RLE_IN_WIDTH-4];
	assign wv_am_data = rle_data_out[RLE_IN_WIDTH-5:0];
	
	assign rle_en = ((data_cnt <= rv_rle_data_len_i)&&(data_cnt!=0))?1'b1:1'b0;
	//assign rle_data_done = rle_data_go_i;
	//assign rle_data_valid = (r_rle_en & rle_data_valid);
	assign wv_data = rle_data_in_i[10:0];
	assign abs_data = (rle_data_in_i[10])?(~(rle_data_in_i[10:0] - 1'b1)):rle_data_in_i[10:0];
	
	assign data_mask_all = data_mask[0]|data_mask[1]|data_mask[2]|data_mask[3]|data_mask[4]|data_mask[5]|data_mask[6]|data_mask[7]|data_mask[8]|data_mask[9]|data_mask[10];
	
//	assign rle_data_valid_o = r_rle_en & rle_data_valid;
	
	generate 
		genvar i;
		for(i = 0; i < 11; i ++)begin:mask_u
			always@(posedge clk_x8_i or negedge rst_n_i)
			if(!rst_n_i)
				data_mask[i] <= 'd0;
			else if(abs_data[i])
				data_mask[i] <= {{(10-i){1'b0}},{(i+1){1'b1}}};
			else
				data_mask[i] <= 'd0;
		end
	endgenerate


	always@(*)
	begin
		amp_len <= 4'd0;
		case(data_mask_all)
			16'd0				:begin	amp_len <= 4'd00; end
			16'b1		    	:begin  amp_len <= 4'd01; end
			16'b11		    	:begin  amp_len <= 4'd02; end
			16'b111		    	:begin  amp_len <= 4'd03; end
			16'b1111			:begin  amp_len <= 4'd04; end
			16'b1111_1			:begin  amp_len <= 4'd05; end
			16'b1111_11			:begin  amp_len <= 4'd06; end
			16'b1111_111		:begin  amp_len <= 4'd07; end
			16'b1111_1111		:begin  amp_len <= 4'd08; end
			16'b1111_1111_1		:begin  amp_len <= 4'd09; end
			16'b1111_1111_11	:begin  amp_len <= 4'd10; end		
		endcase
	end

	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_go <= 1'b0;
	else
		rle_data_go <= rle_data_go_i;
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		r_rle_en <= 1'b0;
	else if(rle_data_go | (data_cnt != 0))
		r_rle_en <= rle_en;

	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		data_cnt <= 6'd0;
	else if(rle_data_go || (data_cnt != 0))
		data_cnt <= data_cnt + 1'b1;
	else
		data_cnt <= data_cnt;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rv_rle_data_len_i <= 6'd0;
	else if(rle_data_go)
		rv_rle_data_len_i <= rle_data_len_i;
	else if(~rle_en)
		rv_rle_data_len_i <= 6'd0;
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		zro_cnt <= 4'd0;
	else if(rle_data_go || (rle_data_in_i != 'd0))//the first data is DC code
		zro_cnt <= 4'd0;
	else if(rle_data_in_i == 0)
		zro_cnt <= zro_cnt + 1'b1;
	else
		zro_cnt <= zro_cnt;
	
	always_ff@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		rle_data_out <= 'd0;
		rle_data_valid <= 1'b0;
	end else if((data_cnt == 0)||(~rle_en))begin
		rle_data_out <= 'd0;
		rle_data_valid <= 1'b0;
	end else begin
		if(rle_data_in_i != 'd0)begin
			rle_data_out <= {zro_cnt,rle_data_in_i[11:0]};
			rle_data_valid <= 1'b1;
		end else if(zro_cnt == 4'd15)begin
			rle_data_out <= {zro_cnt,rle_data_in_i[11:0]};
			rle_data_valid <= 1'b1;
		end else begin
			rle_data_out <= 'd0;
			rle_data_valid <= 1'b0;
		end
	end


	/*encoding*/
//	always_ff@(posedge clk_x8_i or negedge rst_n_i)
//	if(!rst_n_i)begin
//		rle_data_out <= 'd0;
//		rle_data_valid <= 1'b0;
//	end else if((data_cnt == 0)||(~rle_en))begin
//		rle_data_out <= 'd0;
//		rle_data_valid <= 1'b0;
//	end else begin
//		if(data_cnt == rle_data_len_i)begin
//			rle_data_out <= {4'd0,12'd0};
//			rle_data_valid <= 1'b1;
//		end else if(rle_data_in_i != 'd0)begin
//			rle_data_out <= {zro_cnt,rle_data_in_i[11:0]};
//			rle_data_valid <= 1'b1;
//		end else if(zro_cnt == 4'd15)begin
//			rle_data_out <= {zro_cnt,rle_data_in_i[11:0]};
//			rle_data_valid <= 1'b1;
//		end else begin
//			rle_data_out <= 'd0;
//			rle_data_valid <= 1'b0;
//		end
//	end


	/*output data reg*/
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_out_o <= {RLE_OUT_WIDTH{1'b0}};
	else 
		rle_data_out_o <= {wv_zero_len,amp_len[3:0],wv_am_data};
		//rle_data_out_o <= {rle_data_out[RLE_IN_WIDTH-1:RLE_IN_WIDTH-4],amp_len[3:0],rle_data_out[RLE_IN_WIDTH-5:0]};

	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_valid_o <= 1'b0;
	else if(r_rle_en & rle_data_valid & (data_cnt != 6'd1))
		rle_data_valid_o <= 1'b1;
//	else if((data_cnt == 6'd1)&&(rv_rle_data_len_i == 'd0))
//		rle_data_valid_o <= 1'b1;
	else
		rle_data_valid_o <= 1'b0;

	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_done <= 1'b0;
	else
		rle_data_done <= rle_data_go;
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_done_o <= 1'b0;
	else
		rle_data_done_o <= rle_data_go;//rle_data_done;
		
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		rle_data_last_o <= 1'b0;
	else if(data_cnt == 6'd62)
		rle_data_last_o <= 1'b1;
	else
		rle_data_last_o <= 1'b0;
	
endmodule


















