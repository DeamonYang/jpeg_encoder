`timescale 1ns/1ps
/*余弦变换计算单元 流水设计 数据延迟24个cycle 8Bytes/cycle*/

module dct8x8#(
		parameter PIXEL_WIDTH 		= 8,
		parameter PIX_OUT_WIDTH	 	= 32
	)(
		input 								clk_i		,
		input								rst_n_i		,
		input								dct_go_i	,	//Attention: *dct_go_i* can lasts ONE clock cycle ONLY
		input [PIXEL_WIDTH*8 - 1:0]			data_in_i	, 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		output reg[PIX_OUT_WIDTH*8 - 1:0]	data_out_o	, 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
		output reg							dct_done	
	);
	
	parameter MTX_DEM = 8;
	parameter W_WIDTH = 16;
	parameter O_WIDTH = PIX_OUT_WIDTH;
	parameter PIX_OFFSET = 'd128;
	
	reg signed[15:0] 		dctmtx[7:0][7:0];
	reg signed[15:0] 		dctmtx_tr[7:0][7:0];
	
	
	reg[4:0] 				ctl_cnt[2:0];
	reg[1:0] 				ctl_cnt_idx;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
	wire[1:0]				wv_ctl_cnt_idx;
	reg						r_clc_go;
	reg						r_mux_cnt_go;
	reg						r_dct_go;
	
	/*input reg stage  Registers are redundant and need compiler optimization */
	reg signed[PIXEL_WIDTH - 1:0] 	in_data_stage_reg[7:0][7:0]; //input data order {a7x,a6x,a5x,...,a1x,a0x}

	/*output reg stage  Registers are redundant and need compiler optimization */
	reg[O_WIDTH - 1:0] 		out_data_stage_reg[7:0][7:0]; //output data order {ax7,ax6,ax5,...,ax1,ax0}	

	reg[3:0]				mux_cnt;

	
	wire signed[O_WIDTH-1:0]		wv_y[MTX_DEM-1:0][MTX_DEM:0];
	wire signed[O_WIDTH-1:0]		wv_x[MTX_DEM:0][MTX_DEM-1:0];
	wire signed[W_WIDTH-1:0]		wv_w[MTX_DEM-1:0][MTX_DEM-1:0];
	
	
	//in_data_stage_reg[r][0];
	wire signed[PIXEL_WIDTH-1:0]	wv_x_L[MTX_DEM-1:0][MTX_DEM:0]; //8bits
	wire signed[O_WIDTH-1:0]		wv_y_L[MTX_DEM:0][MTX_DEM-1:0]; //32bits
	wire signed[W_WIDTH-1:0]		wv_w_L[MTX_DEM-1:0][MTX_DEM-1:0];
	
	reg[O_WIDTH-1:0]		sed_data_vector[MTX_DEM-1:0];
	
	assign wv_ctl_cnt_idx = (r_clc_go)?ctl_cnt_idx:2'd3;
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		ctl_cnt_idx <= 2'd0;
	else if(r_clc_go)begin
		if(ctl_cnt_idx < 2'd2)
			ctl_cnt_idx <= ctl_cnt_idx + 1'b1;
		else
			ctl_cnt_idx <= 2'd0;
	end else
		ctl_cnt_idx <= ctl_cnt_idx;
	
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		r_dct_go <= 1'b0;
	else
		r_dct_go <= dct_go_i;
	
		
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		r_clc_go <= 1'b0;
	else
		r_clc_go <= dct_go_i;//r_dct_go;
	 
	generate
		genvar ci;
		for(ci = 0;ci < 3; ci = ci + 1)begin:ctl_cnt_ins
			always@(posedge clk_i or negedge rst_n_i)
			if(!rst_n_i)
				ctl_cnt[ci] <= 5'd0;
			else if(wv_ctl_cnt_idx == ci)
				ctl_cnt[ci] <= ctl_cnt[ci] + 1'b1;
			else if((ctl_cnt[ci] != 5'd0) && (ctl_cnt[ci] < 5'd23))
				ctl_cnt[ci] <= ctl_cnt[ci] + 1'b1;
			else
				ctl_cnt[ci] <= 5'd0;
		end
	endgenerate
	
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		dct_done <= 1'b0;
	else if((ctl_cnt[0]==5'd22) || (ctl_cnt[1]==5'd22) || (ctl_cnt[2]==5'd22))
		dct_done <= 1'b1;
	else
		dct_done <= 1'b0;
	
	
	/*output data array alignment*/
	generate
		genvar oi,oj;
		for(oi = 0;oi < 7; oi = oi + 1)begin:out_stg
			always@(posedge clk_i or negedge rst_n_i)
			if(!rst_n_i)
				out_data_stage_reg[oi][7-oi] <= 32'd0;
			else
				out_data_stage_reg[oi][7-oi:0] <= {wv_x[8][oi],out_data_stage_reg[oi][7-oi:1]};
		end
	endgenerate
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		out_data_stage_reg[7][0] <= 32'd0;
	else
		out_data_stage_reg[7][0] <= wv_x[8][7];

	
	
	/*input data delay n cycle*/
	generate 
		genvar ii , jj;
		for(ii = 1;ii < 8;ii = ii + 1)begin :ins_stag
			always@(posedge clk_i or negedge rst_n_i)
			if(!rst_n_i)begin
				in_data_stage_reg[ii][ii] <= 'd0;
			end else
				in_data_stage_reg[ii][ii:0] <= {data_in_i[ii*PIXEL_WIDTH + PIXEL_WIDTH -1 :PIXEL_WIDTH*ii],in_data_stage_reg[ii][ii:1]} ;		
		end
	endgenerate
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		in_data_stage_reg[0][0] <= {PIXEL_WIDTH{1'b0}};
	else
		in_data_stage_reg[0][0] <= data_in_i[PIXEL_WIDTH -1 :0];
	


	/*insert pe array*/
	generate 
		genvar i , j;
		for(i = 0;i < 8;i = i + 1)begin :sa
			for(j = 0;j < 8;j = j + 1)begin :ssa 
				pe#(
					.Y_WIDTH(O_WIDTH),
					.W_WIDTH(W_WIDTH),
					.X_WIDTH(O_WIDTH)
					)pe_inst(
					.rst_n_i(rst_n_i),
					.clk_i(clk_i),
					.in_y_i(wv_y[i][j]),
					.in_x_i(wv_x[i][j]),
					.in_w_i(wv_w[i][j]),
					.out_y_o(wv_y[i][j+1]),
					.out_x_o(wv_x[i+1][j]));
			end	
		end
	endgenerate
	
	/*input weight information*/
	generate 
		genvar k,l;
		for(k = 0;k < 8;k = k + 1)begin :dctmtx_tr_weight
			for(l = 0;l <8;l = l + 1)begin:u
				assign wv_w[k][l] = dctmtx_tr[k][l];
			end
		end
	endgenerate
	
	/*input pixel data remap*/
	generate 
		genvar r;
		for(r = 0;r < 8;r = r + 1)begin :assi_inp_data
			assign wv_x[0][r] = {(PIXEL_WIDTH*2-1){1'b0}};
			assign wv_y[r][0] = sed_data_vector[7-r];//wv_y_L[8][r];//in_data_stage_reg[r][0];
		end
	endgenerate
	
	/*data output reg*/
	generate 
		genvar m;
		for(m = 0;m < 8;m = m + 1)begin :outdata
			always@(*)
				data_out_o[m*32 + 31:m*32] = out_data_stage_reg[m][0];//wv_x[8][m];
		end
	endgenerate
		
	
	/************************M*A*******************************/

	/*input pixel data remap*/
	generate 
		genvar lr;
		for(lr = 0;lr < 8;lr = lr + 1)begin :inp_stag
			assign wv_y_L[0][lr] = {(O_WIDTH-1){1'b0}};
			assign wv_x_L[lr][0] = in_data_stage_reg[lr][0] - PIX_OFFSET;
		end
	endgenerate
	
	
		/*insert pe array*/
	generate 
		genvar li , lj;
		for(li = 0;li < 8;li = li + 1)begin :L_mult
			for(lj = 0;lj < 8;lj = lj + 1)begin :u
				pe_inv#(
					.Y_WIDTH(O_WIDTH),
					.W_WIDTH(W_WIDTH),
					.X_WIDTH(PIXEL_WIDTH)
					)pe_inst(
					.rst_n_i(rst_n_i),
					.clk_i(clk_i),
					
					.in_y_i(wv_y_L[li][lj]),
					.in_x_i(wv_x_L[li][lj]),
					.in_w_i(wv_w_L[li][lj]),
					.out_y_o(wv_y_L[li+1][lj]),
					.out_x_o(wv_x_L[li][lj+1]));
			end	
		end
	endgenerate
	
	
	
	/*input weight information*/
	generate 
		genvar lk,ll;
		for(lk = 0;lk < 8;lk = lk + 1)begin :assi_weight
			for(ll = 0;ll <8;ll = ll + 1)begin:u
				assign wv_w_L[lk][ll] = dctmtx[ll][lk];
			end
		end
	endgenerate
	
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		r_mux_cnt_go <= 1'b0;
	else if((ctl_cnt[0]==5'd7) || (ctl_cnt[1]==5'd7) || (ctl_cnt[2]==5'd7))
		r_mux_cnt_go <= 1'b1;
	else
		r_mux_cnt_go <= 1'b0;
		
	/*data mux*/
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		mux_cnt <= 4'd0;
	else if(r_mux_cnt_go)
		mux_cnt <= 4'd1;
	else if(mux_cnt!= 4'd0)
		mux_cnt <= mux_cnt + 1'b1;

	
	always@(*)begin
		case(mux_cnt[2:0])
			0:	begin sed_data_vector<= {wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1]}; end
			1:	begin sed_data_vector<= {wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2]}; end
			2:	begin sed_data_vector<= {wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3]}; end
			3:	begin sed_data_vector<= {wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4]}; end
			4:	begin sed_data_vector<= {wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5]}; end
			5:	begin sed_data_vector<= {wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6]}; end
			6:	begin sed_data_vector<= {wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0],wv_y_L[8][7]}; end
			7:	begin sed_data_vector<= {wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1],wv_y_L[8][0]}; end
			default:begin sed_data_vector<= {wv_y_L[8][0],wv_y_L[8][7],wv_y_L[8][6],wv_y_L[8][5],wv_y_L[8][4],wv_y_L[8][3],wv_y_L[8][2],wv_y_L[8][1]}; end
		endcase
	end
	

	always@(posedge clk_i)
	begin
		dctmtx_tr[0][0] <= 91; dctmtx_tr[0][1] <=  126; dctmtx_tr[0][2] <=  118; dctmtx_tr[0][3] <=  106; dctmtx_tr[0][4] <=  91; dctmtx_tr[0][5] <=   71; dctmtx_tr[0][6] <=   49; dctmtx_tr[0][7] <=   25;
        dctmtx_tr[1][0] <= 91; dctmtx_tr[1][1] <=  106; dctmtx_tr[1][2] <=   49; dctmtx_tr[1][3] <=  -25; dctmtx_tr[1][4] <= -91; dctmtx_tr[1][5] <= -126; dctmtx_tr[1][6] <= -118; dctmtx_tr[1][7] <=  -71;
        dctmtx_tr[2][0] <= 91; dctmtx_tr[2][1] <=   71; dctmtx_tr[2][2] <=  -49; dctmtx_tr[2][3] <= -126; dctmtx_tr[2][4] <= -91; dctmtx_tr[2][5] <=   25; dctmtx_tr[2][6] <=  118; dctmtx_tr[2][7] <=  106;
        dctmtx_tr[3][0] <= 91; dctmtx_tr[3][1] <=   25; dctmtx_tr[3][2] <= -118; dctmtx_tr[3][3] <=  -71; dctmtx_tr[3][4] <=  91; dctmtx_tr[3][5] <=  106; dctmtx_tr[3][6] <=  -49; dctmtx_tr[3][7] <= -126;
        dctmtx_tr[4][0] <= 91; dctmtx_tr[4][1] <=  -25; dctmtx_tr[4][2] <= -118; dctmtx_tr[4][3] <=   71; dctmtx_tr[4][4] <=  91; dctmtx_tr[4][5] <= -106; dctmtx_tr[4][6] <=  -49; dctmtx_tr[4][7] <=  126;
        dctmtx_tr[5][0] <= 91; dctmtx_tr[5][1] <=  -71; dctmtx_tr[5][2] <=  -49; dctmtx_tr[5][3] <=  126; dctmtx_tr[5][4] <= -91; dctmtx_tr[5][5] <=  -25; dctmtx_tr[5][6] <=  118; dctmtx_tr[5][7] <= -106;
        dctmtx_tr[6][0] <= 91; dctmtx_tr[6][1] <= -106; dctmtx_tr[6][2] <=   49; dctmtx_tr[6][3] <=   25; dctmtx_tr[6][4] <= -91; dctmtx_tr[6][5] <=  126; dctmtx_tr[6][6] <= -118; dctmtx_tr[6][7] <=   71;
        dctmtx_tr[7][0] <= 91; dctmtx_tr[7][1] <= -126; dctmtx_tr[7][2] <=  118; dctmtx_tr[7][3] <= -106; dctmtx_tr[7][4] <=  91; dctmtx_tr[7][5] <=  -71; dctmtx_tr[7][6] <=   49; dctmtx_tr[7][7] <=  -25;
	end
	
	
	always@(posedge clk_i)
	begin
		dctmtx[0][0] <= 91 ;   dctmtx[0][1] <=   91 ;   dctmtx[0][2] <=  91 ;   dctmtx[0][3] <=  91 ;   dctmtx[0][4] <=  91 ;   dctmtx[0][5] <=  91 ;   dctmtx[0][6] <=  91 ;   dctmtx[0][7] <=   91;
        dctmtx[1][0] <= 126;   dctmtx[1][1] <=   106;   dctmtx[1][2] <=   71;   dctmtx[1][3] <=   25;   dctmtx[1][4] <=  -25;   dctmtx[1][5] <=  -71;   dctmtx[1][6] <= -106;   dctmtx[1][7] <=  -126;
        dctmtx[2][0] <= 118;   dctmtx[2][1] <=    49;   dctmtx[2][2] <=  -49;   dctmtx[2][3] <= -118;   dctmtx[2][4] <= -118;   dctmtx[2][5] <=  -49;   dctmtx[2][6] <=   49;   dctmtx[2][7] <=   118;
        dctmtx[3][0] <= 106;   dctmtx[3][1] <=   -25;   dctmtx[3][2] <= -126;   dctmtx[3][3] <=  -71;   dctmtx[3][4] <=   71;   dctmtx[3][5] <=  126;   dctmtx[3][6] <=   25;   dctmtx[3][7] <=  -106;
        dctmtx[4][0] <=  91;   dctmtx[4][1] <=   -91;   dctmtx[4][2] <=  -91;   dctmtx[4][3] <=   91;   dctmtx[4][4] <=   91;   dctmtx[4][5] <=  -91;   dctmtx[4][6] <=  -91;   dctmtx[4][7] <=    91;
        dctmtx[5][0] <=  71;   dctmtx[5][1] <=  -126;   dctmtx[5][2] <=   25;   dctmtx[5][3] <=  106;   dctmtx[5][4] <= -106;   dctmtx[5][5] <=  -25;   dctmtx[5][6] <=  126;   dctmtx[5][7] <=   -71;
        dctmtx[6][0] <=  49;   dctmtx[6][1] <=  -118;   dctmtx[6][2] <=  118;   dctmtx[6][3] <=  -49;   dctmtx[6][4] <=  -49;   dctmtx[6][5] <=  118;   dctmtx[6][6] <= -118;   dctmtx[6][7] <=    49;
        dctmtx[7][0] <=  25;   dctmtx[7][1] <=   -71;   dctmtx[7][2] <=  106;   dctmtx[7][3] <= -126;   dctmtx[7][4] <=  126;   dctmtx[7][5] <= -106;   dctmtx[7][6] <=   71;   dctmtx[7][7] <=   -25;
	end
	
	
endmodule
