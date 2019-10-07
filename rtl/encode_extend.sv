`timescale 1ns/1ps

module encode_extend#(
		parameter	PIC_PIX_IN_WIDTH = 32
	)(
		input								rst_n_i,
		input								clk_x8_i,
		input[PIC_PIX_IN_WIDTH-1:0]			pic_data_in_i,
		input								pic_data_in_valid_i,
		output logic[PIC_PIX_IN_WIDTH-1:0]	pic_data_out_o,
		output logic						pic_data_out_valid_o
	);

	logic[7:0]						wv_pic_data_in[3:0];
	logic[3:0]						case_idx;
	logic[4:0]						data_len;
	logic[PIC_PIX_IN_WIDTH*2-1:0]	data_buf;
	logic							data_in_valid;
	logic[8:0]						as_data_len;
	logic[PIC_PIX_IN_WIDTH*4-1:0]	as_data_buf;
	

	assign wv_pic_data_in[0] = pic_data_in_i[7:0];
	assign wv_pic_data_in[1] = pic_data_in_i[15:8];
	assign wv_pic_data_in[2] = pic_data_in_i[23:16];
	assign wv_pic_data_in[3] = pic_data_in_i[31:24];

	assign case_idx = {wv_pic_data_in[3]==8'hFF,wv_pic_data_in[2] == 8'hff,wv_pic_data_in[1]==8'hff, wv_pic_data_in[0]==8'hff};

	/*extend data '0xff' with '0xff00'*/
	always_ff@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		data_buf <= 'd0;
		data_len <= 'd0;
	end else case(case_idx)
		4'b0000:begin data_len<=5'd4; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],		wv_pic_data_in[1],		wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*4){1'b0}}};end
		4'b0001:begin data_len<=5'd5; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],		wv_pic_data_in[1],		wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*5){1'b0}}};end
		4'b0010:begin data_len<=5'd5; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],		wv_pic_data_in[1],8'h00,wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*5){1'b0}}};end
		4'b0011:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],		wv_pic_data_in[1],8'h00,wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b0100:begin data_len<=5'd5; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],8'h00,wv_pic_data_in[1],		wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*5){1'b0}}};end
		4'b0101:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],8'h00,wv_pic_data_in[1],		wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b0110:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],8'h00,wv_pic_data_in[1],8'h00,wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b0111:begin data_len<=5'd7; data_buf <= {wv_pic_data_in[3],		wv_pic_data_in[2],8'h00,wv_pic_data_in[1],8'h00,wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*7){1'b0}}};end
		4'b1000:begin data_len<=5'd5; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],		wv_pic_data_in[1],		wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*5){1'b0}}};end
		4'b1001:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],		wv_pic_data_in[1],		wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b1010:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],		wv_pic_data_in[1],8'h00,wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b1011:begin data_len<=5'd7; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],		wv_pic_data_in[1],8'h00,wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*7){1'b0}}};end
		4'b1100:begin data_len<=5'd6; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],8'h00,wv_pic_data_in[1],		wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*6){1'b0}}};end
		4'b1101:begin data_len<=5'd7; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],8'h00,wv_pic_data_in[1],		wv_pic_data_in[0],8'h00	,{(PIC_PIX_IN_WIDTH*2-8*7){1'b0}}};end
		4'b1110:begin data_len<=5'd7; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],8'h00,wv_pic_data_in[1],8'h00,wv_pic_data_in[0]		,{(PIC_PIX_IN_WIDTH*2-8*7){1'b0}}};end
		4'b1111:begin data_len<=5'd8; data_buf <= {wv_pic_data_in[3],8'h00,	wv_pic_data_in[2],8'h00,wv_pic_data_in[1],8'h00,wv_pic_data_in[0],8'h00	};end
	endcase
		
	/*assemble data*/
	always@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)
		data_in_valid <= 1'b0;
	else if(pic_data_in_valid_i)
		data_in_valid <= 1'b1;
	else
		data_in_valid <= 1'b0;


	always_ff@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		as_data_buf <= 'd0;
		as_data_len <= 'd0;
	end else if(data_in_valid)begin
		as_data_buf <= as_data_buf | {{data_buf,{PIC_PIX_IN_WIDTH*2{1'b0}}}>>(as_data_len<<3)};
		as_data_len <= as_data_len + data_len;
	end else if(as_data_len >= PIC_PIX_IN_WIDTH/8)begin
		as_data_buf <= {as_data_buf[PIC_PIX_IN_WIDTH*3-1:0],{PIC_PIX_IN_WIDTH{1'b0}}};
		as_data_len <= as_data_len - PIC_PIX_IN_WIDTH/8;
	end else begin
		as_data_len <= as_data_len;
		as_data_buf <= as_data_buf;
	end
	
	always_ff@(posedge clk_x8_i or negedge rst_n_i)
	if(!rst_n_i)begin
		pic_data_out_o <= 'd0;
		pic_data_out_valid_o <= 'd0;
	end else if(as_data_len >= PIC_PIX_IN_WIDTH/8)begin
		pic_data_out_o <= as_data_buf[PIC_PIX_IN_WIDTH*4-1:PIC_PIX_IN_WIDTH*3];
		pic_data_out_valid_o <= 1'b1;
	end else begin
		pic_data_out_o <= pic_data_out_o;
		pic_data_out_valid_o <= 1'b0;
	end

endmodule

