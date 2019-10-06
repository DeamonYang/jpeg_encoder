`timescale 1ns/1ps
/***************************************************************************************
*@Description	: Encoder top module
*@Other			: This module is designed for grayscale images
*@Author		: Deamonyang
*@E-mail		: deamonyang@foxmail.com
****************************************************************************************/
module encode_huff #(
		parameter 	PIC_PIX_IN_WIDTH = 8,//input pixel data width
		parameter	PIC_ENC_OUT_WIDTH = 32
	)(
		input								rst_n_i	,
		input								clk_i	,
		input								clk_x8_i,
		input								pic_frame_i,
		
		input								pic_qut_done_i,
		input[16*8-1:0]						pic_qut_data_i, //input data order {a7x,a6x,a5x,...,a1x,a0x}
		
		output[PIC_ENC_OUT_WIDTH-1:0]		pic_encode_seq_o,
		output								pic_encode_valid_o
		
	);
	
	parameter DCT_PIX_OUT_WIDTH 	= 32;
	parameter QUT_PIX_OUT_WIDTH 	= 16;
	parameter DC_PIX_OUT_WIDTH		= 20;
	parameter ZIG_PIX_OUT_WIDTH 	= 16;
	parameter FIND_PIX_OUT_WIDTH 	= 16;
	parameter RLE_PIX_OUT_WIDTH 	= 20;
	parameter AC_PIX_OUT_WIDTH		= 32;
	parameter ASS_OUT_WIDTH			= 32;
	

	wire[DCT_PIX_OUT_WIDTH*8 - 1:0]	wv_dct_data_out;
	wire							w_dct_done;
	
	wire[QUT_PIX_OUT_WIDTH*8 - 1:0]	wv_qut_data_out;
	wire							w_qut_done;
	
	wire[ZIG_PIX_OUT_WIDTH   - 1:0]	wv_zig_data_out;
	wire							w_zig_done;

	wire[4:0]						wv_dc_len;
	wire[DC_PIX_OUT_WIDTH-1:0]		wv_dc_seq_out;
	wire							w_dc_done;

	wire[5:0]						wv_find_data_len;//index of last none zero data
	wire[FIND_PIX_OUT_WIDTH-1:0]	wv_find_data_out;
	wire							w_find_data_done;

	wire[RLE_PIX_OUT_WIDTH-1:0]		wv_rle_data_out;	//{zero_len[3:0],amp_len[3:0],am_data[11:0]}
	wire							w_rle_data_valid;	//output data is valid
	wire							w_rle_data_done;		//start to output data. Hight is valid
	wire							w_rle_data_last;

	wire							w_ac_valid; 	
	wire[AC_PIX_OUT_WIDTH-1:0]		wv_ac_seq_out;//{amp_code,ac_code}
	wire[4:0]						wv_ac_seq_len;
	wire							w_ac_done;	
	wire							w_ac_last;


	wire[ASS_OUT_WIDTH-1:0]			wv_seq_out;	
	wire							w_seq_valid;	
	wire							w_seq_done;	
	wire							w_seq_last;
	wire[ASS_OUT_WIDTH-1:0]			w_seq_left;

	assign wv_qut_data_out = pic_qut_data_i;
	assign w_qut_done = pic_qut_done_i;
//	dct8x8#(
//		.PIXEL_WIDTH 	(PIC_PIX_IN_WIDTH),
//		.PIX_OUT_WIDTH	(DCT_PIX_OUT_WIDTH)
//	)dct8x8_u0(
//		.clk_i		(clk_i			),
//		.rst_n_i	(rst_n_i		),
//		.dct_go_i	(pic_blk_go_i	),	//Attention: *dct_go_i* can lasts ONE clock cycle ONLY
//		.data_in_i	(pic_data_in_i	), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
//		.data_out_o	(wv_dct_data_out), 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
//		.dct_done	(w_dct_done		)	
//	);
//
//
//	qutification #(
//		.PIXEL_WIDTH 	(DCT_PIX_OUT_WIDTH),
//		.PIX_OUT_WIDTH	(QUT_PIX_OUT_WIDTH)
//	)qutification_u0(
//		.clk_i		(clk_i			),
//		.rst_n_i	(rst_n_i		),
//		.qut_go_i	(w_dct_done		),	//Attention: *qut_go_i* can lasts ONE clock cycle ONLY
//		.data_in_i	(wv_dct_data_out), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
//		.data_out_o	(wv_qut_data_out), 	//output data order {ax7,ax6,ax5,...,ax1,ax0}	
//		.qut_done	(w_qut_done		)
//	);
	
	zigzag #(
		.ZIG_IN_WIDTH 	(QUT_PIX_OUT_WIDTH),
		.ZIG_OUT_WIDTH	(ZIG_PIX_OUT_WIDTH)
	)zigzag_u0(
		.clk_i		(clk_i			),
		.clk_x8_i	(clk_x8_i		),
		.rst_n_i	(rst_n_i		),
		.zig_go_i	(w_qut_done		),	//Attention: *zig_go_i* can lasts ONE clock cycle ONLY
		.zig_in_i	(wv_qut_data_out), 	//input data order {a7x,a6x,a5x,...,a1x,a0x}
		.zig_out_o	(wv_zig_data_out), 	//output serial data order: a00 a01 ... a07 a10 a11 ... a77  
		.zig_done	(w_zig_done		)
	);

	ac_find_last#(		
		.FIND_IN_WIDTH 	(ZIG_PIX_OUT_WIDTH),
		.FIND_OUT_WIDTH (FIND_PIX_OUT_WIDTH	)
	)ac_find_last_u0(
		.clk_x8_i		(clk_x8_i		),
		.rst_n_i		(rst_n_i		),
		.find_data_go_i	(w_zig_done		),//block data start
		.find_data_in_i	(wv_zig_data_out),// abs(ac_data_in_i) < 1024
		
		.find_data_len_o(wv_find_data_len),//index of last none zero data
		.find_data_out_o(wv_find_data_out),
		.find_data_done_o(w_find_data_done)
	);
	

	dc_huff_encod#(
		.DC_IN_WIDTH 	(FIND_PIX_OUT_WIDTH	),
		.DC_OUT_WIDTH	(DC_PIX_OUT_WIDTH	)
	)dc_huff_encod_u0(
		.clk_i		(clk_i				),
		.clk_x8_i	(clk_x8_i			),
		.rst_n_i	(rst_n_i			),
		.dc_go_i	(w_find_data_done	),//block data start
		.dc_frame_i	(pic_frame_i		),//a new picture start
		.dc_in_i	(wv_find_data_out	), 	
		.dc_len_o	(wv_dc_len			), 	
		.dc_seq_o	(wv_dc_seq_out		),
		.dc_done_o	(w_dc_done			)
	);


	ac_rle#(		
		.RLE_IN_WIDTH 	(FIND_PIX_OUT_WIDTH),
		.RLE_OUT_WIDTH 	(RLE_PIX_OUT_WIDTH)
	)ac_rle_u0(
		.clk_i				(clk_i				),
		.clk_x8_i			(clk_x8_i			),
		.rst_n_i			(rst_n_i			),
			
		.rle_data_go_i		(w_find_data_done	),//block data start
		.rle_data_in_i		(wv_find_data_out	),//abs(ac_data_in_i) < 1024
		.rle_data_len_i		(wv_find_data_len	),
		
		.rle_data_out_o		(wv_rle_data_out	),	//{zero_len[3:0],amp_len[3:0],am_data[11:0]}
		.rle_data_valid_o	(w_rle_data_valid	),	//output data is valid
		.rle_data_done_o	(w_rle_data_done	),		//start to output data. Hight is valid
		.rle_data_last_o	(w_rle_data_last	)
	);
	
	
	ac_huff_encod#(
		.AC_IN_WIDTH 	(RLE_PIX_OUT_WIDTH	),
		.AC_OUT_WIDTH 	(AC_PIX_OUT_WIDTH	)
	)ac_huff_encod_u0(
		.clk_x8_i		(clk_x8_i			),
		.rst_n_i		(rst_n_i			),
		.pic_frame_i	(pic_frame_i		),
		.ac_data_go_i	(w_rle_data_done	),//block data start
		.ac_data_valid_i(w_rle_data_valid	),
		.ac_data_in_i	(wv_rle_data_out	),// abs(ac_data_in_i) < 1024 {zrlen[3:0],len[3:0],amp[11:0]}
		.ac_data_last_i	(w_rle_data_last	),

		.ac_valid_o		(w_ac_valid			), 	
		.ac_seq_o		(wv_ac_seq_out		),//{amp_code,ac_code}
		.ac_seq_len_o	(wv_ac_seq_len		),
		.ac_done_o		(w_ac_done			),
		.ac_last_o		(w_ac_last			)
	);

	ac_assemble#(
		.DC_IN_WIDTH   (DC_PIX_OUT_WIDTH	),
		.AC_IN_WIDTH   (AC_PIX_OUT_WIDTH	),
		.SEQ_OUT_WIDTH (ASS_OUT_WIDTH		)
	)ac_assemble_u0(
		.clk_x8_i		(clk_x8_i		),
		.rst_n_i		(rst_n_i		),	
		.ac_valid_i		(w_ac_valid		), 	
		.ac_seq_i		(wv_ac_seq_out	),//{amp_code,ac_code}
		.ac_seq_len_i	(wv_ac_seq_len	),
		.ac_go_i		(w_ac_done		),
		.ac_last_i		(w_ac_last		),
		.dc_len_i		(wv_dc_len		), 	
		.dc_seq_i		(wv_dc_seq_out	),
		.dc_go_i		(w_dc_done		),
		.seq_out_o		(wv_seq_out		),
		.seq_valid_o	(w_seq_valid	),
		.seq_done_o		(w_seq_done		),
		.seq_last_o		(w_seq_last		),
		.seq_left_o		(w_seq_left		)
	);

	assign pic_encode_seq_o = wv_seq_out;
	assign pic_encode_valid_o = w_seq_valid;
	
endmodule


