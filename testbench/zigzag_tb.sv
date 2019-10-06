`timescale 1ns/1ps

module zigzag_tb;

	parameter PIXEL_WIDTH = 8;
	parameter PIX_OUT_WIDTH = 32;
	parameter QUF_OUT_WIDTH = 16;
	
	parameter ZIG_IN_WIDTH 		= 16;
	parameter ZIG_OUT_WIDTH	 	= 16;
	
	parameter QUT_IN_WIDTH 		= 32;
	parameter QUT_OUT_WIDTH	 	= 16;

	reg 							clk_i		;
	reg								clk_x8_i	;
	reg								rst_n_i		;
	reg								dct_go_i	;
	reg[PIXEL_WIDTH*8 - 1:0]		data_in_i	;
	wire[PIX_OUT_WIDTH*8 - 1:0]		data_out_o	;
	wire							dct_done	;
	

	reg								qut_go_i	;	//Attention: *qut_go_i* can lasts ONE clock cycle ONLY
	reg[QUT_IN_WIDTH*8 - 1:0]		qdata_in_i	; 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
	wire[QUT_OUT_WIDTH*8 - 1:0]		qdata_out_o	; 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
	wire							qut_done	;	
	
	
	reg								zig_go_i	;
	reg[ZIG_IN_WIDTH*8 - 1:0]		zig_in_i	;
	wire[ZIG_OUT_WIDTH - 1:0]		zig_out_o	; 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
	wire							zig_done	;
	
//`define 	SYS_TEST
	
	
`ifdef SYS_TEST
	
	


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

	qutification #(
		.PIXEL_WIDTH 	(QUT_IN_WIDTH),
		.PIX_OUT_WIDTH	(QUT_OUT_WIDTH)
	)insu2(
		.clk_i		(clk_i		),
		.rst_n_i	(rst_n_i	)	,
		.qut_go_i	(dct_done	),	//Attention: *qut_go_i* can lasts ONE clock cycle ONLY
		.data_in_i	(data_out_o	), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		.data_out_o	(qdata_out_o), 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
		.qut_done	(qut_done	)	
	);
	
	zigzag #(
		.ZIG_IN_WIDTH (ZIG_IN_WIDTH ),
		.ZIG_OUT_WIDTH(ZIG_OUT_WIDTH)
	)zigzag_ins_u0(
		.clk_i		(clk_i),
		.rst_n_i	(rst_n_i)	,
		.zig_go_i	(qut_done),	//Attention: *zig_go_i* can lasts ONE clock cycle ONLY
		.zig_in_i	(qdata_out_o), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		.zig_out_o	(zig_out_o), 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
		.zig_done	(zig_done) 
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

		#500;
		$stop;
		//$finish;
	end	

`else

	
	
	zigzag #(
		.ZIG_IN_WIDTH (ZIG_IN_WIDTH ),
		.ZIG_OUT_WIDTH(ZIG_OUT_WIDTH)
	)zigzag_ins_u0(
		.clk_i		(clk_i),
		.clk_x8_i	(clk_x8_i),
		.rst_n_i	(rst_n_i)	,
		.zig_go_i	(zig_go_i),	//Attention: *zig_go_i* can lasts ONE clock cycle ONLY
		.zig_in_i	(zig_in_i), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		.zig_out_o	(zig_out_o), 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
		.zig_done	(zig_done) 
	);
	
	

	

	initial begin
		rst_n_i = 0;
		data_in_i = 64'd0;//{{8'd1},{8'd2},{8'd3},{8'd4},{8'd5},{8'd6},{8'd7},{8'd8}};
		clk_i = 0;
		dct_go_i = 0;
		zig_go_i = 0;
		clk_x8_i = 0;
		#1000;
		rst_n_i = 1;
		//dct_go_i = 1;
//		@(posedge clk_i)
		@(posedge clk_i) zig_in_i = 128'h_0000_0001_0002_0003_0004_0005_0006_0007; zig_go_i = 1;
		@(posedge clk_i) zig_in_i = 128'h_0008_0009_000A_000B_000C_000D_000E_000F; zig_go_i = 0;
		@(posedge clk_i) zig_in_i = 128'h_0010_0011_0012_0013_0014_0015_0016_0017;
		@(posedge clk_i) zig_in_i = 128'h_0018_0019_001A_001B_001C_001D_001E_001F;
		@(posedge clk_i) zig_in_i = 128'h_0020_0021_0022_0023_0024_0025_0026_0027;
		@(posedge clk_i) zig_in_i = 128'h_0028_0029_002A_002B_002C_002D_002E_002F;
		@(posedge clk_i) zig_in_i = 128'h_0030_0031_0032_0033_0034_0035_0036_0037;
		@(posedge clk_i) zig_in_i = 128'h_0038_0039_003A_003B_003C_003D_003E_003F;
		@(posedge clk_i) zig_in_i = 128'h_0000_0001_0002_0003_0004_0005_0006_0007; zig_go_i = 1;
		@(posedge clk_i) zig_in_i = 128'h_0008_0009_000A_000B_000C_000D_000E_000F; zig_go_i = 0;
		@(posedge clk_i) zig_in_i = 128'h_0010_0011_0012_0013_0014_0015_0016_0017;
		@(posedge clk_i) zig_in_i = 128'h_0018_0019_001A_001B_001C_001D_001E_001F;
		@(posedge clk_i) zig_in_i = 128'h_0020_0021_0022_0023_0024_0025_0026_0027;
		@(posedge clk_i) zig_in_i = 128'h_0028_0029_002A_002B_002C_002D_002E_002F;
		@(posedge clk_i) zig_in_i = 128'h_0030_0031_0032_0033_0034_0035_0036_0037;
		@(posedge clk_i) zig_in_i = 128'h_0038_0039_003A_003B_003C_003D_003E_003F;
//		@(posedge clk_i) zig_in_i = 128'h_0000_0001_0002_0003_0004_0005_0006_0007; zig_go_i = 1;
//		@(posedge clk_i) zig_in_i = 128'h_0008_0009_000A_000B_000C_000D_000E_000F; zig_go_i = 0;
//		@(posedge clk_i) zig_in_i = 128'h_0010_0011_0012_0013_0014_0015_0016_0017;
//		@(posedge clk_i) zig_in_i = 128'h_0018_0019_001A_001B_001C_001D_001E_001F;
//		@(posedge clk_i) zig_in_i = 128'h_0020_0021_0022_0023_0024_0025_0026_0027;
//		@(posedge clk_i) zig_in_i = 128'h_0028_0029_002A_002B_002C_002D_002E_002F;
//		@(posedge clk_i) zig_in_i = 128'h_0030_0031_0032_0033_0034_0035_0036_0037;
//		@(posedge clk_i) zig_in_i = 128'h_0038_0039_003A_003B_003C_003D_003E_003F;		
		
		#5000;
		//$stop;
		$finish;
	end










`endif




	always #40 	clk_i = ~clk_i;
	always #5	clk_x8_i = ~clk_x8_i;
	
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,zigzag_tb,"+all");
	end



endmodule

