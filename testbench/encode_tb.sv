`timescale 1ns/1ps

`define MEM 1

module encode_tb;
	
	parameter 	PIC_PIX_IN_WIDTH = 8;
	parameter 	PIC_ENC_OUT_WIDTH = 32;

`ifdef MEM	
	parameter[15:0]	PIC_WIDTH = 16'd744;
	parameter[15:0]	PIC_HEIGHT = 16'd1080;
`else
	parameter[15:0]	PIC_WIDTH  = 16'd64;
	parameter[15:0]	PIC_HEIGHT = 16'd64;
`endif	
	parameter PIC_LEN_W = PIC_WIDTH;
	parameter PIC_LEN_H = PIC_HEIGHT;
	
	reg[7:0]						pic_data[PIC_HEIGHT-1:0][PIC_WIDTH-1:0];
	reg[7:0]						pict[7:0][7:0];
	reg								rst_n_i	;
	reg								clk_i	;
	reg								clk_x8_i;
	reg								pic_frame_i;
	reg								pic_blk_go_i;
	reg[PIC_PIX_IN_WIDTH*8-1:0]		pic_data_in_i;
	integer							fp;
	integer							fres;
	integer							sv_fp;
	integer 						times;
	
	wire[PIC_ENC_OUT_WIDTH-1:0]		pic_encode_seq_o;
	wire							pic_encode_valid_o;
	
	
	
	reg[7:0] test_pix_data[64] = '{232,184,163,205,250,255,255,255,67,67,67,67,112,226,255,255,67,67,67,67,67,95,223,255,67,67,67,67,67,67,119,241,67,67,67,67,67,67,67,160,106,80,67,67,67,67,67,71,248,134,67,67,67,67,67,67,248,134,67,67,67,67,67,67};

	reg[7:0] peg_header[328] = '{
	8'hFF, 8'hD8, 8'hFF, 8'hE0, 8'h00, 8'h10, 8'h4A, 8'h46, 8'h49, 8'h46, 8'h00, 8'h01, 8'h01, 8'h00, 8'h00, 8'h01, 
	8'h00, 8'h01, 8'h00, 8'h00, 8'hFF, 8'hDB, 8'h00, 8'h43, 8'h00, 8'h10, 8'h0B, 8'h0C, 8'h0E, 8'h0C, 8'h0A, 8'h10, 
	8'h0E, 8'h0D, 8'h0E, 8'h12, 8'h11, 8'h10, 8'h13, 8'h18, 8'h28, 8'h1A, 8'h18, 8'h16, 8'h16, 8'h18, 8'h31, 8'h23, 
	8'h25, 8'h1D, 8'h28, 8'h3A, 8'h33, 8'h3D, 8'h3C, 8'h39, 8'h33, 8'h38, 8'h37, 8'h40, 8'h48, 8'h5C, 8'h4E, 8'h40, 
	8'h44, 8'h57, 8'h45, 8'h37, 8'h38, 8'h50, 8'h6D, 8'h51, 8'h57, 8'h5F, 8'h62, 8'h67, 8'h68, 8'h67, 8'h3E, 8'h4D, 
	8'h71, 8'h79, 8'h70, 8'h64, 8'h78, 8'h5C, 8'h65, 8'h67, 8'h63, 8'hFF, 8'hC0, 8'h00, 8'h0B, 8'h08, PIC_HEIGHT[15:8], PIC_HEIGHT[7:0], 
	PIC_WIDTH[15:8],PIC_WIDTH[7:0], 8'h01, 8'h01, 8'h11, 8'h00, 8'hFF, 8'hC4, 8'h00, 8'h1F, 8'h00, 8'h00, 8'h01, 8'h05, 8'h01, 8'h01, 
	8'h01, 8'h01, 8'h01, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 
	8'h05, 8'h06, 8'h07, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'hFF, 8'hC4, 8'h00, 8'hB5, 8'h10, 8'h00, 8'h02, 8'h01, 8'h03, 
	8'h03, 8'h02, 8'h04, 8'h03, 8'h05, 8'h05, 8'h04, 8'h04, 8'h00, 8'h00, 8'h01, 8'h7D, 8'h01, 8'h02, 8'h03, 8'h00, 
	8'h04, 8'h11, 8'h05, 8'h12, 8'h21, 8'h31, 8'h41, 8'h06, 8'h13, 8'h51, 8'h61, 8'h07, 8'h22, 8'h71, 8'h14, 8'h32, 
	8'h81, 8'h91, 8'hA1, 8'h08, 8'h23, 8'h42, 8'hB1, 8'hC1, 8'h15, 8'h52, 8'hD1, 8'hF0, 8'h24, 8'h33, 8'h62, 8'h72, 
	8'h82, 8'h09, 8'h0A, 8'h16, 8'h17, 8'h18, 8'h19, 8'h1A, 8'h25, 8'h26, 8'h27, 8'h28, 8'h29, 8'h2A, 8'h34, 8'h35, 
	8'h36, 8'h37, 8'h38, 8'h39, 8'h3A, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48, 8'h49, 8'h4A, 8'h53, 8'h54, 8'h55, 
	8'h56, 8'h57, 8'h58, 8'h59, 8'h5A, 8'h63, 8'h64, 8'h65, 8'h66, 8'h67, 8'h68, 8'h69, 8'h6A, 8'h73, 8'h74, 8'h75, 
	8'h76, 8'h77, 8'h78, 8'h79, 8'h7A, 8'h83, 8'h84, 8'h85, 8'h86, 8'h87, 8'h88, 8'h89, 8'h8A, 8'h92, 8'h93, 8'h94, 
	8'h95, 8'h96, 8'h97, 8'h98, 8'h99, 8'h9A, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA6, 8'hA7, 8'hA8, 8'hA9, 8'hAA, 8'hB2, 
	8'hB3, 8'hB4, 8'hB5, 8'hB6, 8'hB7, 8'hB8, 8'hB9, 8'hBA, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC6, 8'hC7, 8'hC8, 8'hC9, 
	8'hCA, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7, 8'hD8, 8'hD9, 8'hDA, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 
	8'hE7, 8'hE8, 8'hE9, 8'hEA, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF6, 8'hF7, 8'hF8, 8'hF9, 8'hFA, 8'hFF, 8'hDA, 
	8'h00, 8'h08, 8'h01, 8'h01, 8'h00, 8'h00, 8'h3F, 8'h00};

	encode #(
		.PIC_PIX_IN_WIDTH(PIC_PIX_IN_WIDTH),
		.PIC_ENC_OUT_WIDTH(PIC_ENC_OUT_WIDTH)
	)encode_u0(
		.rst_n_i		(rst_n_i		),
		.clk_i			(clk_i			),
		.clk_x8_i		(clk_x8_i		),
		.pic_frame_i	(pic_frame_i	),
		.pic_blk_go_i	(pic_blk_go_i	),
		.pic_data_in_i	(pic_data_in_i	),
		.pic_encode_seq_o(pic_encode_seq_o),
		.pic_encode_valid_o(pic_encode_valid_o)
		
	);
	
	
	task read_data();
	
	endtask
	
	reg[31:0]		pic_cnt;	
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		pic_cnt <= 'd0;
		sv_fp = $fopen("sv_data_encode.jpg","wb");
		for(int i = 0;i < 328;i ++)begin
			$fwrite(sv_fp,"%c",peg_header[i]);
		end
	end else if(pic_encode_valid_o)begin
		$display("%h",pic_encode_seq_o);
		$fwrite(sv_fp,"%c",pic_encode_seq_o[31:24]);
		$fwrite(sv_fp,"%c",pic_encode_seq_o[23:16]);
		$fwrite(sv_fp,"%c",pic_encode_seq_o[15:8]);
		$fwrite(sv_fp,"%c",pic_encode_seq_o[7:0]);
		pic_cnt <= pic_cnt + 1'b1;
		
//		$fwrite(sv_fp,"%c",pic_encode_seq_o[31:24]);
//		if(pic_encode_seq_o[31:24] == 8'hff)
//			$fwrite(sv_fp,"%c",8'h00);
//
//		$fwrite(sv_fp,"%c",pic_encode_seq_o[23:16]);
//		if(pic_encode_seq_o[23:16] == 8'hff)
//			$fwrite(sv_fp,"%c",8'h00);
//		
//		$fwrite(sv_fp,"%c",pic_encode_seq_o[15:8]);
//		if(pic_encode_seq_o[15:8] == 8'hff)
//			$fwrite(sv_fp,"%c",8'h00);
//	
//		$fwrite(sv_fp,"%c",pic_encode_seq_o[7:0]);
//		if(pic_encode_seq_o[7:0] == 8'hff)
//			$fwrite(sv_fp,"%c",8'h00);
	end	
	
	
	initial begin
		rst_n_i = 0;
		clk_i = 0;
		clk_x8_i = 1;
		pic_blk_go_i = 0;
		pic_frame_i = 0;
		times = 0;
		fp = $fopen("pic_data_gray.data","r");
		//fp = $fopen("ac_code_rom.mif", "r");
		//fp = $readmemh("pic_data_gray.data",pic_data);
		if(fp == 0)begin
			$display("open file error %d! ",fp);
			$finish;
		end else begin
			$display("open file success!");
			
		end
		
		#500;
		@(posedge clk_i)
		rst_n_i = 1;
		#500;
		@(posedge clk_i)
		
		
//		pic_data[0][0] = $fgetc(fp);
		
		for(int i = 0;i < PIC_HEIGHT;i ++)begin
			for(int j = 0;j < PIC_WIDTH;j ++)begin
				pic_data[i][j] = $fgetc(fp);
			end
		end
//		$display("data read ok %h",pic_data[0][0]);
		$fclose(fp);
		
		
		
		for(int i = 0;i < PIC_LEN_H;i = i + 8)begin
			for(int j = 0;j < PIC_LEN_W;j= j + 8)begin
				
				/*read 8*8data */
				for(int k = 0;k < 8;k ++)begin
					for(int l = 0;l < 8;l ++)begin
						pict[k][l] = pic_data[i + k][j + l];
					end
				end
				
				for(int m = 0; m < 8;m++)begin
					times ++;
					@(posedge clk_i)
					pic_data_in_i <= {pict[7][m],pict[6][m],pict[5][m],pict[4][m],pict[3][m],pict[2][m],pict[1][m],pict[0][m]};
					if(m==0)begin
						pic_blk_go_i = 1;
					end else begin
						pic_blk_go_i = 0;
					end
					
					if(m == 0 && i == 0 && j == 0)
						pic_frame_i = 1;
					else
						pic_frame_i = 0;
				end
				
				
			end
		end
		
		

//		for(int i = 0;i < 8;i ++)begin
//			@(posedge clk_i)
//			pic_frame_i = 0;
//			pic_data_in_i <= {test_pix_data[i+7*8],
//							test_pix_data[i+6*8],
//							test_pix_data[i+5*8],
//							test_pix_data[i+4*8],
//							test_pix_data[i+3*8],
//							test_pix_data[i+2*8],
//							test_pix_data[i+1*8],
//							test_pix_data[i+0*8]};
//			if(i == 0)begin
//				pic_blk_go_i = 1;
//				pic_frame_i = 1;
//			end else begin
//				pic_blk_go_i = 0;
//				pic_frame_i = 0;
//			end	
//		end

//		for(int i = 0;i < 8;i ++)begin
//			@(posedge clk_i)
//			pic_frame_i = 0;
//			pic_data_in_i <= {test_pix_data[i+7*8],
//							test_pix_data[i+6*8],
//							test_pix_data[i+5*8],
//							test_pix_data[i+4*8],
//							test_pix_data[i+3*8],
//							test_pix_data[i+2*8],
//							test_pix_data[i+1*8],
//							test_pix_data[i+0*8]};
//			if(i == 0)begin
//				pic_blk_go_i = 1;
//				//pic_frame_i = 1;
//			end else begin
//				pic_blk_go_i = 0;
//				pic_frame_i = 0;
//			end	
//		end		
// 68 
		
		repeat(500)@(posedge clk_i);
		
		#1000;
		$fwrite(sv_fp,"%s",16'hFFD9);
		$display("pic_proc %d",times);
		//$finish;
		$fclose(sv_fp);
//		$stop;
		$finish;
		
		
	end

	always #5 clk_x8_i = ~clk_x8_i;
	always #40 clk_i = ~clk_i;


	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,encode_tb,"+all");
	end

endmodule


