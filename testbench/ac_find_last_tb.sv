`timescale 1ns/1ps

module ac_find_last_tb;

	parameter FIND_IN_WIDTH 		= 16;
	parameter FIND_OUT_WIDTH 		= 16;
	reg								clk_x8_i		;
	reg								rst_n_i			;
	reg								find_data_go_i	;//block data start
	reg[FIND_IN_WIDTH-1:0]			find_data_in_i	;// abs(ac_data_in_i) < 1024
	wire[5:0]						find_data_len_o	;//index of last none zero data
	wire[FIND_OUT_WIDTH-1:0]		find_data_out_o	;//
	wire 							find_data_done_o;//
	
	bit[FIND_IN_WIDTH-1:0] data_test[29] = '{35,7,0,0,0,-6,-2,0,0,-9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8};

	ac_find_last#(		
		.FIND_IN_WIDTH (FIND_IN_WIDTH ),
		.FIND_OUT_WIDTH(FIND_OUT_WIDTH)
	)ac_find_last_u0(
		.clk_x8_i			(clk_x8_i			),
		.rst_n_i			(rst_n_i			),
		.find_data_go_i		(find_data_go_i		),//block data start
		.find_data_in_i		(find_data_in_i		),// abs(ac_data_in_i) < 1024
		.find_data_len_o	(find_data_len_o	),//index of last none zero data
		.find_data_out_o	(find_data_out_o	),//
		.find_data_done_o	(find_data_done_o	) //
	);

	initial begin
		rst_n_i = 0;
		clk_x8_i = 0;
		find_data_go_i <= 1'b0;
		#1000;
		rst_n_i = 1;
		@(posedge clk_x8_i);
		find_data_go_i <= 1'b1;
		for(int i = 0;i < 64;i ++)begin
			@(posedge clk_x8_i)
			find_data_go_i <= 1'b0;
			if(rst_n_i)begin
				if(i < 29)
					find_data_in_i <= data_test[i];
				else
					find_data_in_i <= 16'd0;
			end
		end	

		@(posedge clk_x8_i);
		find_data_go_i <= 1'b1;
		for(int i = 0;i < 64;i ++)begin
			@(posedge clk_x8_i)
			find_data_go_i <= 1'b0;
			if(rst_n_i)begin
				if(i < 29)
					find_data_in_i <= data_test[i];
				else
					find_data_in_i <= 16'd0;
			end
		end	
		
		
		#5000;
		//$stop;
		$finish;
	end

	always #5	clk_x8_i = ~clk_x8_i;
	
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,ac_find_last_tb,"+all");
	end

endmodule

