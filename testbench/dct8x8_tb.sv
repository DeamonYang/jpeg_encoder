`timescale 1ns/1ps

module dct8x8_tb;

	parameter PIXEL_WIDTH = 8;
	parameter PIX_OUT_WIDTH = 32;

	reg 							clk_i		;
	reg								rst_n_i		;
	reg								dct_go_i	;
	reg[PIXEL_WIDTH*8 - 1:0]		data_in_i	;
	wire[PIX_OUT_WIDTH*8 - 1:0]		data_out_o	;
	wire							dct_done	;


	dct8x8#(
		.PIXEL_WIDTH 	(PIXEL_WIDTH),
		.PIX_OUT_WIDTH	(PIX_OUT_WIDTH)
	)inst(
		.clk_i		(clk_i		),
		.rst_n_i	(rst_n_i	),
		.dct_go_i	(dct_go_i	),
		.data_in_i	(data_in_i	),
		.data_out_o	(data_out_o	),
		.dct_done	(dct_done	)
	);
	
	
	initial begin
		rst_n_i = 0;
		data_in_i = 64'd0;//{{8'd1},{8'd2},{8'd3},{8'd4},{8'd5},{8'd6},{8'd7},{8'd8}};
		clk_i = 0;
		dct_go_i = 0;
		#1000;
		rst_n_i = 1;
		//dct_go_i = 1;
		dct_go_i = 0;
		#10;
		
		#20 data_in_i = 64'h3C202213413D5420;
		dct_go_i = 1;
		#20 data_in_i = 64'h274E3D1D442D530C;
		dct_go_i = 0;
		#20 data_in_i = 64'h5C2F1309402E1A5E;
		#20 data_in_i = 64'h00044A3A5F423D41;
		#20 data_in_i = 64'h2E121844154D3A30;
		#20 data_in_i = 64'h2A485C3747233640;
		#20 data_in_i = 64'h2E2F1B2B18425736;
		#20 data_in_i = 64'h4D0F4D400C2A1A41;
		
		#20 data_in_i = 64'h3C202213413D5420;
		dct_go_i = 1;
		#20 data_in_i = 64'h274E3D1D442D530C;
		dct_go_i = 0;
		#20 data_in_i = 64'h5C2F1309402E1A5E;
		#20 data_in_i = 64'h00044A3A5F423D41;
		#20 data_in_i = 64'h2E121844154D3A30;
		#20 data_in_i = 64'h2A485C3747233640;
		#20 data_in_i = 64'h2E2F1B2B18425736;
		#20 data_in_i = 64'h4D0F4D400C2A1A41;
		
		
		#20 data_in_i = 64'h3C202213413D5420;
		dct_go_i = 1;
		#20 data_in_i = 64'h274E3D1D442D530C;
		dct_go_i = 0;
		#20 data_in_i = 64'h5C2F1309402E1A5E;
		#20 data_in_i = 64'h00044A3A5F423D41;
		#20 data_in_i = 64'h2E121844154D3A30;
		#20 data_in_i = 64'h2A485C3747233640;
		#20 data_in_i = 64'h2E2F1B2B18425736;
		#20 data_in_i = 64'h4D0F4D400C2A1A41;
		
		
		
		
		#10000;
		$stop;
		//$finish;
	end

	always #10 clk_i = ~clk_i;
	
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,dct8x8_tb,"+all");
	end

endmodule
