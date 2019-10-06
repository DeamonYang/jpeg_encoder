`timescale 1ns/1ps

module qutification #(
		parameter PIXEL_WIDTH 		= 32,
		parameter PIX_OUT_WIDTH	 	= 16
	)(
		input 								clk_i		,
		input								rst_n_i		,
		input								qut_go_i	,	//Attention: *qut_go_i* can lasts ONE clock cycle ONLY
		input[PIXEL_WIDTH*8 - 1:0]			data_in_i	, 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		output reg[PIX_OUT_WIDTH*8 - 1:0]	data_out_o	, 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	x = 0,1,2,3,4,5,6,7
		output reg							qut_done
	);
	
	parameter DIV_VAL = 65536;
	
	reg signed[31:0] 			qtb[7:0][7:0];
	reg [2:0]					idx_cnt;
	reg signed[31:0]			qut_res[7:0];
	wire signed[31:0]			wv_in[7:0];
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		qut_done <= 1'b0;
	else 
		qut_done <= qut_go_i;
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		idx_cnt <= 3'd7;
	else if(qut_go_i || (idx_cnt!=3'd7))
		idx_cnt <= idx_cnt + 1'b1;


	localparam ED_BIT = PIX_OUT_WIDTH-1;
		 
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		data_out_o <= 'd0;
	else
		data_out_o <= {qut_res[7][ED_BIT:0],qut_res[6][ED_BIT:0],qut_res[5][ED_BIT:0],qut_res[4][ED_BIT:0],qut_res[3][ED_BIT:0],qut_res[2][ED_BIT:0],qut_res[1][ED_BIT:0],qut_res[0][ED_BIT:0]};
		//data_out_o <= {qut_res[7][ED_BIT:16],qut_res[6][ED_BIT:16],qut_res[5][ED_BIT:16],qut_res[4][ED_BIT:16],qut_res[3][ED_BIT:16],qut_res[5][ED_BIT:16],qut_res[6][ED_BIT:16],qut_res[7][ED_BIT:16]};
		//data_out_o <= {qut_res[7][23:16],qut_res[6][23:16],qut_res[5][23:16],qut_res[4][23:16],qut_res[3][23:16],qut_res[2][23:16],qut_res[1][23:16],qut_res[0][ED_BIT:16]};
		//data_out_o <= {qut_res[7][ED_BIT:16],qut_res[6][ED_BIT:16],qut_res[5][ED_BIT:16],qut_res[4][ED_BIT:16],qut_res[3][ED_BIT:16],qut_res[2][ED_BIT:16],qut_res[1][ED_BIT:16],qut_res[0][ED_BIT:16]};
	
	generate
		genvar i;
		for(i = 0;i < 8;i = i + 1)begin :input_data_u
			assign wv_in[i] = data_in_i[i*PIXEL_WIDTH + PIXEL_WIDTH-1:i*PIXEL_WIDTH];
		end
	endgenerate
	
	
	always@(*)begin
		case(idx_cnt)
			3'd0:begin qut_res[7:0] = {wv_in[7]/qtb[0][7], wv_in[6]/qtb[0][6], wv_in[5]/qtb[0][5], wv_in[4]/qtb[0][4], wv_in[3]/qtb[0][3], wv_in[2]/qtb[0][2], wv_in[1]/qtb[0][1], wv_in[0]/qtb[0][0]};end
			3'd1:begin qut_res[7:0] = {wv_in[7]/qtb[1][7], wv_in[6]/qtb[1][6], wv_in[5]/qtb[1][5], wv_in[4]/qtb[1][4], wv_in[3]/qtb[1][3], wv_in[2]/qtb[1][2], wv_in[1]/qtb[1][1], wv_in[0]/qtb[1][0]};end
			3'd2:begin qut_res[7:0] = {wv_in[7]/qtb[2][7], wv_in[6]/qtb[2][6], wv_in[5]/qtb[2][5], wv_in[4]/qtb[2][4], wv_in[3]/qtb[2][3], wv_in[2]/qtb[2][2], wv_in[1]/qtb[2][1], wv_in[0]/qtb[2][0]};end
			3'd3:begin qut_res[7:0] = {wv_in[7]/qtb[3][7], wv_in[6]/qtb[3][6], wv_in[5]/qtb[3][5], wv_in[4]/qtb[3][4], wv_in[3]/qtb[3][3], wv_in[2]/qtb[3][2], wv_in[1]/qtb[3][1], wv_in[0]/qtb[3][0]};end
			3'd4:begin qut_res[7:0] = {wv_in[7]/qtb[4][7], wv_in[6]/qtb[4][6], wv_in[5]/qtb[4][5], wv_in[4]/qtb[4][4], wv_in[3]/qtb[4][3], wv_in[2]/qtb[4][2], wv_in[1]/qtb[4][1], wv_in[0]/qtb[4][0]};end
			3'd5:begin qut_res[7:0] = {wv_in[7]/qtb[5][7], wv_in[6]/qtb[5][6], wv_in[5]/qtb[5][5], wv_in[4]/qtb[5][4], wv_in[3]/qtb[5][3], wv_in[2]/qtb[5][2], wv_in[1]/qtb[5][1], wv_in[0]/qtb[5][0]};end
			3'd6:begin qut_res[7:0] = {wv_in[7]/qtb[6][7], wv_in[6]/qtb[6][6], wv_in[5]/qtb[6][5], wv_in[4]/qtb[6][4], wv_in[3]/qtb[6][3], wv_in[2]/qtb[6][2], wv_in[1]/qtb[6][1], wv_in[0]/qtb[6][0]};end
			3'd7:begin qut_res[7:0] = {wv_in[7]/qtb[7][7], wv_in[6]/qtb[7][6], wv_in[5]/qtb[7][5], wv_in[4]/qtb[7][4], wv_in[3]/qtb[7][3], wv_in[2]/qtb[7][2], wv_in[1]/qtb[7][1], wv_in[0]/qtb[7][0]};end
		endcase
	end

	
	always@(posedge clk_i)
	begin
		qtb[0][0] <= 16 * DIV_VAL;qtb[0][1] <= 11*DIV_VAL;qtb[0][2] <= 10*DIV_VAL;qtb[0][3] <= 16*DIV_VAL;qtb[0][4] <= 24 *DIV_VAL;qtb[0][5] <= 40 *DIV_VAL;qtb[0][6] <= 51 *DIV_VAL;qtb[0][7] <= 61 *DIV_VAL;
		qtb[1][0] <= 12 * DIV_VAL;qtb[1][1] <= 12*DIV_VAL;qtb[1][2] <= 14*DIV_VAL;qtb[1][3] <= 19*DIV_VAL;qtb[1][4] <= 26 *DIV_VAL;qtb[1][5] <= 58 *DIV_VAL;qtb[1][6] <= 60 *DIV_VAL;qtb[1][7] <= 55 *DIV_VAL;
		qtb[2][0] <= 14 * DIV_VAL;qtb[2][1] <= 13*DIV_VAL;qtb[2][2] <= 16*DIV_VAL;qtb[2][3] <= 24*DIV_VAL;qtb[2][4] <= 40 *DIV_VAL;qtb[2][5] <= 57 *DIV_VAL;qtb[2][6] <= 69 *DIV_VAL;qtb[2][7] <= 56 *DIV_VAL;
		qtb[3][0] <= 14 * DIV_VAL;qtb[3][1] <= 17*DIV_VAL;qtb[3][2] <= 22*DIV_VAL;qtb[3][3] <= 29*DIV_VAL;qtb[3][4] <= 51 *DIV_VAL;qtb[3][5] <= 87 *DIV_VAL;qtb[3][6] <= 80 *DIV_VAL;qtb[3][7] <= 62 *DIV_VAL;
		qtb[4][0] <= 18 * DIV_VAL;qtb[4][1] <= 22*DIV_VAL;qtb[4][2] <= 37*DIV_VAL;qtb[4][3] <= 56*DIV_VAL;qtb[4][4] <= 68 *DIV_VAL;qtb[4][5] <= 109*DIV_VAL;qtb[4][6] <= 103*DIV_VAL;qtb[4][7] <= 77 *DIV_VAL;
		qtb[5][0] <= 24 * DIV_VAL;qtb[5][1] <= 35*DIV_VAL;qtb[5][2] <= 55*DIV_VAL;qtb[5][3] <= 64*DIV_VAL;qtb[5][4] <= 81 *DIV_VAL;qtb[5][5] <= 104*DIV_VAL;qtb[5][6] <= 113*DIV_VAL;qtb[5][7] <= 92 *DIV_VAL;
		qtb[6][0] <= 49 * DIV_VAL;qtb[6][1] <= 64*DIV_VAL;qtb[6][2] <= 78*DIV_VAL;qtb[6][3] <= 87*DIV_VAL;qtb[6][4] <= 103*DIV_VAL;qtb[6][5] <= 121*DIV_VAL;qtb[6][6] <= 120*DIV_VAL;qtb[6][7] <= 101*DIV_VAL;
		qtb[7][0] <= 72 * DIV_VAL;qtb[7][1] <= 92*DIV_VAL;qtb[7][2] <= 95*DIV_VAL;qtb[7][3] <= 98*DIV_VAL;qtb[7][4] <= 112*DIV_VAL;qtb[7][5] <= 100*DIV_VAL;qtb[7][6] <= 103*DIV_VAL;qtb[7][7] <= 99 *DIV_VAL;
	end




endmodule
