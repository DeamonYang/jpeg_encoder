`timescale 1ns/1ps
/*pe 计算单元 用于计算  M*A  其中M为权重  数据结果从y输出*/
module pe_inv#(
		parameter Y_WIDTH = 32,
		parameter W_WIDTH = 16,
		parameter X_WIDTH = 8
	)(
		input								rst_n_i	,
		input								clk_i	,
		input signed[Y_WIDTH-1:0]			in_y_i	,
		input [X_WIDTH-1:0]					in_x_i	,
		input [W_WIDTH-1:0]					in_w_i	,
		output reg signed [Y_WIDTH-1:0]		out_y_o	,
		output reg signed [X_WIDTH-1:0]		out_x_o
	);
	
	wire signed[Y_WIDTH-1:0] w_in_w_i;
	wire signed[Y_WIDTH-1:0] w_in_x_i;
	
	/*extend sign bit*/
	assign w_in_w_i = {{(Y_WIDTH-W_WIDTH){in_w_i[W_WIDTH-1]}},in_w_i};
	assign w_in_x_i = {{(Y_WIDTH-X_WIDTH){in_x_i[X_WIDTH-1]}},in_x_i};
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		out_y_o <= {Y_WIDTH{1'b0}};
	else
		out_y_o <= in_y_i + w_in_w_i*w_in_x_i;
		
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		out_x_o <= {X_WIDTH{1'b0}};
	else
		out_x_o <= in_x_i;
endmodule


