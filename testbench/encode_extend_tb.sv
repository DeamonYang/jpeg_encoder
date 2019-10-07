`timescale 1ns/1ps

module encode_extend_tb;
	parameter PIC_PIX_IN_WIDTH = 32;


	logic								rst_n_i;
	logic								clk_x8_i;
	logic[PIC_PIX_IN_WIDTH-1:0]			pic_data_in_i;
	logic								pic_data_in_valid_i;
	logic[PIC_PIX_IN_WIDTH-1:0]			pic_data_out_o;
	logic								pic_data_out_valid_o;
	
	encode_extend#(
		.PIC_PIX_IN_WIDTH(PIC_PIX_IN_WIDTH)
	)encode_extend_u0(
		.rst_n_i				(rst_n_i			),
		.clk_x8_i				(clk_x8_i			),
		.pic_data_in_i			(pic_data_in_i		),
		.pic_data_in_valid_i	(pic_data_in_valid_i),
		.pic_data_out_o			(pic_data_out_o		),
		.pic_data_out_valid_o	(pic_data_out_valid_o)
	);

	initial begin
		rst_n_i = 0;
		pic_data_in_i = 32'd0;//{{8'd1},{8'd2},{8'd3},{8'd4},{8'd5},{8'd6},{8'd7},{8'd8}};
		pic_data_in_valid_i = 0;
		clk_x8_i = 0;
		#1000;
		rst_n_i = 1;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h43FF_1237;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h123E_14FF;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h4516_FF17;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h561E_561F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h3426_5627;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h232E_FF2F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h3536_3437;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h263E_363F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'hFF06_5777;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'hFFFF_877F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h1216_4517;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h891E_781F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h7426_FFF7;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h362E_472F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'hFFFF_FFFF;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
		repeat(2)@(posedge clk_x8_i); pic_data_in_i <= 32'h933E_863F;pic_data_in_valid_i  <= 1;@(posedge clk_x8_i);pic_data_in_valid_i  <= 0;
	
		
		#50;
		$finish;
	end
	
	always@(posedge clk_x8_i)
	if(pic_data_out_valid_o)
		$display("%x",pic_data_out_o);



	always #10	clk_x8_i = ~clk_x8_i;
	
	
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,encode_extend_tb,"+all");
	end



endmodule

