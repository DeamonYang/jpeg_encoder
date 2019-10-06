`timescale 1ns/1ps

module ac_huff_encode_tb;
	
	parameter AC_IN_WIDTH 		= 20;
	parameter AC_OUT_WIDTH 		= 37;
	parameter DATA_LEN 			= 29;
	
	parameter RLE_IN_WIDTH 		= 16;
	parameter RLE_OUT_WIDTH 	= 20;

	reg								clk_x8_i		;
	reg								rst_n_i			;
	reg								ac_data_go_i	;//block data start
	reg								ac_data_valid_i	;
	reg[AC_IN_WIDTH-1:0]			ac_data_in_i	;// abs(ac_data_in_i) < 1024 
		
	wire							ac_valid_o		;
	wire[AC_OUT_WIDTH-1:0]			ac_seq_o		;
	wire[4:0]						ac_seq_len_o	;
	wire							ac_done_o		;
	
	reg 							clk_i			;
	reg								rle_data_go_i	;//block data start
	reg[RLE_IN_WIDTH-1:0]			rle_data_in_i	;//abs(ac_data_in_i) < 1024
	reg[5:0]						rle_data_len_i	;
	wire[RLE_OUT_WIDTH-1:0]			rle_data_out_o	;		//{zero_len[3:0],amp_len[3:0],am_data[11:0]}
	wire							rle_data_valid_o;	//output data is valid
	wire							rle_data_done_o	;			//start to output data. Hight is valid
	
	
	
	

	//{zrlen[3:0],len[3:0],amp[11:0]}
	reg signed[RLE_IN_WIDTH-1:0] data_test[DATA_LEN-1:0] = '{35,7,0,0,0,-6,-2,0,0,-9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8};


	ac_rle#(		
		.RLE_IN_WIDTH (RLE_IN_WIDTH ),
		.RLE_OUT_WIDTH(RLE_OUT_WIDTH)
	)ac_rle_u0(
		.clk_i				(clk_i				),
		.clk_x8_i			(clk_x8_i			),
		.rst_n_i			(rst_n_i			),
		.rle_data_go_i		(rle_data_go_i		),	//block data start
		.rle_data_in_i		(rle_data_in_i		),	//abs(ac_data_in_i) < 1024
		.rle_data_len_i		(rle_data_len_i		),
		.rle_data_out_o		(rle_data_out_o		),	//{zero_len[3:0],amp_len[3:0],am_data[11:0]}
		.rle_data_valid_o	(rle_data_valid_o	),	//output data is valid
		.rle_data_done_o	(rle_data_done_o	)	//start to output data. Hight is valid
	);





	ac_huff_encod#(
		.AC_IN_WIDTH (AC_IN_WIDTH ),
		.AC_OUT_WIDTH(AC_OUT_WIDTH)
	)ac_huff_encod_u0(
		.clk_x8_i		(clk_x8_i		),
		.rst_n_i		(rst_n_i		),
		
		.ac_data_go_i	(rle_data_done_o),//block data start
		.ac_data_valid_i(rle_data_valid_o),
		.ac_data_in_i	(rle_data_out_o	),// abs(ac_data_in_i) < 1024 
		
		.ac_valid_o		(ac_valid_o		), 	
		.ac_seq_o		(ac_seq_o		),
		.ac_seq_len_o	(ac_seq_len_o	),
		.ac_done_o		(ac_done_o		) 	
	);

	initial begin
		rst_n_i = 0;
		clk_x8_i = 0;
		rle_data_go_i <= 1'b0;
		#500;
		rst_n_i = 1;
		
		repeat(10)@(posedge clk_x8_i);
		rle_data_go_i <= 1'b1;
		rle_data_len_i = 29;
		for(int i = 0;i < DATA_LEN;i ++)begin
			@(posedge clk_x8_i)
			rle_data_go_i <= 1'b0;
			if(rst_n_i)begin
				rle_data_in_i <= data_test[DATA_LEN-i];
			end
		end	
		#500;
		//$stop;
		$finish;
	end

	
	always #5	clk_x8_i = ~clk_x8_i;
	always #40	clk_i = ~clk_i;
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,ac_huff_encode_tb,"+all");
	end



endmodule

