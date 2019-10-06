`timescale 1ns/1ps
/***************************************************************************************
*@Description	: Zig-zag the data with ping-pang buffer
*@Other			: Parallel input and serial output
*@Author		: Deamonyang
*@E-mail		: deamonyang@foxmail.com
****************************************************************************************/
module zigzag #(
		parameter ZIG_IN_WIDTH 		= 16,
		parameter ZIG_OUT_WIDTH	 	= 16
	)(
		input 								clk_i		,
		input								clk_x8_i	,
		input								rst_n_i		,
		input								zig_go_i	,	//Attention: *zig_go_i* can lasts ONE clock cycle ONLY
		input	  [ZIG_IN_WIDTH*8 - 1:0]	zig_in_i	, 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		output reg[ZIG_OUT_WIDTH - 1:0]		zig_out_o	, 	//output serial data order: a00 a01 ... a07 a10 a11 ... a77  
		output 								zig_done
	);
	
	reg[2:0]				buf_idx_cnt;
	reg						buf_idx;
	reg[5:0]				buf_idx_cnt_x8;
	reg						buf_cnt_last;
	reg[ZIG_IN_WIDTH-1:0]	zag_buf_a[7:0][7:0];
	reg[ZIG_IN_WIDTH-1:0]	zag_buf_b[7:0][7:0];
	reg						idx_ch_en;
	reg[1:0]				r_zig_done;
	reg						r_buf_idx;
	wire					edge_buf_idx;
	
	wire[ZIG_IN_WIDTH-1:0]	img_in[7:0];
	
//	assign zig_done = r_zig_done[1];
	assign edge_buf_idx = ((~r_buf_idx)&buf_idx)|((~buf_idx)&r_buf_idx);
	assign zig_done = edge_buf_idx;
	//remap input data
	generate
		genvar i;
		for(i = 0; i < 8; i = i + 1)begin
			assign img_in[7-i] = zig_in_i[ZIG_IN_WIDTH*i + ZIG_IN_WIDTH - 1 :ZIG_IN_WIDTH*i];
		end
	endgenerate
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		buf_idx_cnt <= 3'd7;
	else if(zig_go_i || (buf_idx_cnt != 3'd7))
		buf_idx_cnt <= buf_idx_cnt + 1'b1;
	else
		buf_idx_cnt <= buf_idx_cnt;
		
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		idx_ch_en <= 1'b0;
	else if(zig_go_i)
		idx_ch_en <= 1'b1;
	else if(buf_idx_cnt == 3'd7)
		idx_ch_en <= 1'b0;
	 
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		buf_idx <= 1'b0;
	else if((buf_idx_cnt == 3'd7) & idx_ch_en)
		buf_idx <= ~buf_idx;
	else
		buf_idx <= buf_idx;
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		r_buf_idx <= 1'd0;
	else
		r_buf_idx <= buf_idx;
	
	//ziazag order
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		zag_buf_a<= zag_buf_a;
	else if(buf_idx)begin
		zag_buf_a <= zag_buf_a;
		case(buf_idx_cnt)
			0:begin {zag_buf_a[0][0], zag_buf_a[0][1], zag_buf_a[0][5], zag_buf_a[0][6], zag_buf_a[1][6], zag_buf_a[1][7], zag_buf_a[3][3], zag_buf_a[3][4]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			1:begin {zag_buf_a[0][2], zag_buf_a[0][4], zag_buf_a[0][7], zag_buf_a[1][5], zag_buf_a[2][0], zag_buf_a[3][2], zag_buf_a[3][5], zag_buf_a[5][2]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			2:begin {zag_buf_a[0][3], zag_buf_a[1][0], zag_buf_a[1][4], zag_buf_a[2][1], zag_buf_a[3][1], zag_buf_a[3][6], zag_buf_a[5][1], zag_buf_a[5][3]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			3:begin {zag_buf_a[1][1], zag_buf_a[1][3], zag_buf_a[2][2], zag_buf_a[3][0], zag_buf_a[3][7], zag_buf_a[5][0], zag_buf_a[5][4], zag_buf_a[6][5]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			4:begin {zag_buf_a[1][2], zag_buf_a[2][3], zag_buf_a[2][7], zag_buf_a[4][0], zag_buf_a[4][7], zag_buf_a[5][5], zag_buf_a[6][4], zag_buf_a[6][6]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			5:begin {zag_buf_a[2][4], zag_buf_a[2][6], zag_buf_a[4][1], zag_buf_a[4][6], zag_buf_a[5][6], zag_buf_a[6][3], zag_buf_a[6][7], zag_buf_a[7][4]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			6:begin {zag_buf_a[2][5], zag_buf_a[4][2], zag_buf_a[4][5], zag_buf_a[5][7], zag_buf_a[6][2], zag_buf_a[7][0], zag_buf_a[7][3], zag_buf_a[7][5]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			7:begin {zag_buf_a[4][3], zag_buf_a[4][4], zag_buf_a[6][0], zag_buf_a[6][1], zag_buf_a[7][1], zag_buf_a[7][2], zag_buf_a[7][6], zag_buf_a[7][7]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
		endcase
	end

	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		zag_buf_b<= zag_buf_b;
	else if(~buf_idx)begin
		zag_buf_b <= zag_buf_b;
		case(buf_idx_cnt)
			0:begin {zag_buf_b[0][0], zag_buf_b[0][1], zag_buf_b[0][5], zag_buf_b[0][6], zag_buf_b[1][6], zag_buf_b[1][7], zag_buf_b[3][3], zag_buf_b[3][4]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			1:begin {zag_buf_b[0][2], zag_buf_b[0][4], zag_buf_b[0][7], zag_buf_b[1][5], zag_buf_b[2][0], zag_buf_b[3][2], zag_buf_b[3][5], zag_buf_b[5][2]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			2:begin {zag_buf_b[0][3], zag_buf_b[1][0], zag_buf_b[1][4], zag_buf_b[2][1], zag_buf_b[3][1], zag_buf_b[3][6], zag_buf_b[5][1], zag_buf_b[5][3]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			3:begin {zag_buf_b[1][1], zag_buf_b[1][3], zag_buf_b[2][2], zag_buf_b[3][0], zag_buf_b[3][7], zag_buf_b[5][0], zag_buf_b[5][4], zag_buf_b[6][5]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			4:begin {zag_buf_b[1][2], zag_buf_b[2][3], zag_buf_b[2][7], zag_buf_b[4][0], zag_buf_b[4][7], zag_buf_b[5][5], zag_buf_b[6][4], zag_buf_b[6][6]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			5:begin {zag_buf_b[2][4], zag_buf_b[2][6], zag_buf_b[4][1], zag_buf_b[4][6], zag_buf_b[5][6], zag_buf_b[6][3], zag_buf_b[6][7], zag_buf_b[7][4]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			6:begin {zag_buf_b[2][5], zag_buf_b[4][2], zag_buf_b[4][5], zag_buf_b[5][7], zag_buf_b[6][2], zag_buf_b[7][0], zag_buf_b[7][3], zag_buf_b[7][5]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
			7:begin {zag_buf_b[4][3], zag_buf_b[4][4], zag_buf_b[6][0], zag_buf_b[6][1], zag_buf_b[7][1], zag_buf_b[7][2], zag_buf_b[7][6], zag_buf_b[7][7]} <= {img_in[7],img_in[6],img_in[5],img_in[4],img_in[3],img_in[2],img_in[1],img_in[0]};end
		endcase
	end

	/*output data*/
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		buf_idx_cnt_x8 <= 6'd0;
	else if(zig_done || (buf_idx_cnt_x8 != 6'd0))// || buf_cnt_last)
		buf_idx_cnt_x8 <= buf_idx_cnt_x8 + 1'b1;
	else
		buf_idx_cnt_x8 <= buf_idx_cnt_x8;
//	
//	always@(posedge clk_x8_i or negedge rst_n_i)
//	if(!rst_n_i)
//		buf_cnt_last <= 1'b0;
//	else if (zig_go_i)
//		buf_cnt_last <= 1'b1;
//	else if(r_zig_done[0])
//		buf_cnt_last <= 1'b0;
//	else
//		buf_cnt_last <= buf_cnt_last;
//		
//	
//	//output new frame data (8x8) flag	
//	always@(posedge clk_x8_i or negedge rst_n_i)
//	if(!rst_n_i)
//		r_zig_done[0] <= 1'b0;
//	else if((buf_idx_cnt_x8 == 6'd63) & buf_cnt_last)
//		r_zig_done[0] <= 1'b1;
//	else
//		r_zig_done[0] <= 1'b0;
		
//	always@(posedge clk_x8_i or negedge rst_n_i)
//	if(!rst_n_i)
//		r_zig_done[1] <= 1'b1;
//	else 
//		r_zig_done[1] <= r_zig_done[0];
	
	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		zig_out_o <= 'd0;
	else if(buf_idx)begin
		zig_out_o <= zag_buf_b[buf_idx_cnt_x8[5:3]][buf_idx_cnt_x8[2:0]];
	end else begin
		zig_out_o <= zag_buf_a[buf_idx_cnt_x8[5:3]][buf_idx_cnt_x8[2:0]];
	end
	
	

endmodule












