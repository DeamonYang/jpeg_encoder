`timescale 1ns/1ps

module dc_huff_encod_tb;

		parameter DC_IN_WIDTH 		= 16;
		parameter DC_OUT_WIDTH		= 23;
		
		
	reg 							clk_i		;
	reg 							clk_x8_i	;
	reg								rst_n_i		;
	reg								dc_go_i		;
	reg								dc_frame_i	;
	reg	[DC_IN_WIDTH*8 - 1:0]		dc_in_i		;
	wire[4:0]						dc_len_o	;
	wire[DC_OUT_WIDTH-1:0]			dc_seq_o	;
	wire							dc_done_o	;
		

	dc_huff_encod#(
		.DC_IN_WIDTH (DC_IN_WIDTH ),
		.DC_OUT_WIDTH(DC_OUT_WIDTH)
	)dc_huff_encod_ist_u0(
		.clk_i		(clk_i		),
		.clk_x8_i	(clk_x8_i	),
		.rst_n_i	(rst_n_i	)	,
		.dc_go_i	(dc_go_i	)	,//block data start
		.dc_frame_i	(dc_frame_i	),//a new picture start
		.dc_in_i	(dc_in_i	)	, 	
		.dc_len_o	(dc_len_o	), 	
		.dc_seq_o	(dc_seq_o	),
		.dc_done_o	(dc_done_o	)
	);
	
	initial begin
		rst_n_i = 0; 
		clk_i = 1;
		clk_x8_i = 1;
		dc_go_i = 0;
		dc_frame_i = 0;
		dc_in_i = 0;
		#100;
		rst_n_i = 1;

		#100;
		@(posedge clk_i) dc_in_i = 22	;dc_frame_i = 1;dc_go_i = 1;@(posedge clk_i) dc_frame_i = 0 ;dc_go_i = 0   ; #100;
		@(posedge clk_i); dc_in_i = 29	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		@(posedge clk_i); dc_in_i = 37	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		@(posedge clk_i); dc_in_i = 46	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;		
		@(posedge clk_i); dc_in_i = 56	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		@(posedge clk_i); dc_in_i = 67	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;		
		@(posedge clk_i); dc_in_i = 79	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		@(posedge clk_i); dc_in_i = 92	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;		
		@(posedge clk_i); dc_in_i = 106	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		@(posedge clk_i); dc_in_i = 121	;dc_frame_i = 0;dc_go_i = 1;@(posedge clk_i)dc_go_i = 0;
		
		
		#500;
		//$stop;
		$finish;
	end
	
	
	
	always #40 	clk_i = ~clk_i;
	always #5	clk_x8_i = ~clk_x8_i;
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,dc_huff_encod_tb,"+all");
	end
	
endmodule

