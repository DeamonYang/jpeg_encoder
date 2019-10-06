`timescale 1ns/1ps

module ac_rle_tb;

	parameter RLE_IN_WIDTH 		= 16;
	parameter RLE_OUT_WIDTH 	= 20;
	
	reg 						clk_i		;
	reg							clk_x8_i	;
	reg							rst_n_i		;
	reg							rle_data_go_i;//block data start
	reg[RLE_IN_WIDTH-1:0]		rle_data_in_i;// abs(ac_data_in_i) < 1024 
	reg[5:0]					rle_data_len_i;
	
	wire[RLE_OUT_WIDTH-1:0]		rle_data_out_o;		//{zero_len[3:0];am_data[11:0]}
	wire						rle_data_valid_o;	//输出数据有效
	wire 						rle_data_done_o;		//rle 数据开始输出
	
	//bit[RLE_IN_WIDTH-1:0] data_test[29] = '{35,7,0,0,0,-6,-2,0,0,-9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8};
	bit[RLE_IN_WIDTH-1:0] data_test[29] = '{35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};



	ac_rle#(		
		.RLE_IN_WIDTH (RLE_IN_WIDTH ),
		.RLE_OUT_WIDTH(RLE_OUT_WIDTH)
	)ac_rle_u0(
		.clk_i				(clk_i				),
		.clk_x8_i			(clk_x8_i			),
		.rst_n_i			(rst_n_i			),
		.rle_data_go_i		(rle_data_go_i		),//block data start
		.rle_data_in_i		(rle_data_in_i		),// abs(ac_data_in_i) < 1024 
		.rle_data_len_i		(rle_data_len_i		),
		.rle_data_out_o		(rle_data_out_o		),		//{zero_len[3:0],am_data[11:0]}
		.rle_data_valid_o	(rle_data_valid_o	),	//输出数据有效
		.rle_data_done_o	(rle_data_done_o	)			//rle 数据开始输出
	);

	initial begin
		rst_n_i = 0;
		clk_i = 0;
		clk_x8_i = 0;
		rle_data_go_i <= 1'b0;
		#1000;
		rst_n_i = 1;
		@(posedge clk_x8_i);
		rle_data_go_i <= 1'b1;
		rle_data_len_i = 1;
		for(int i = 0;i < 29;i ++)begin
			@(posedge clk_x8_i)
			rle_data_go_i <= 1'b0;
			if(rst_n_i)begin
				rle_data_in_i <= data_test[i];
			end
		end		
		
		#5000;
		//$stop;
		$finish;
	end

	
	always #40 	clk_i = ~clk_i;
	always #5	clk_x8_i = ~clk_x8_i;
	
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,ac_rle_tb,"+all");
	end



endmodule

