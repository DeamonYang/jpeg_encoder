/*脉动阵列单个单元*/
module pe#(
		parameter Y_WIDTH = 8,
		parameter W_WIDTH = 16,
		parameter X_WIDTH = 32
	)(
		input								rst_n_i	,
		input								clk_i	,
		input [Y_WIDTH-1:0]			in_y_i	,
		input [X_WIDTH-1:0]			in_x_i	,
		input [W_WIDTH-1:0]			in_w_i	,
		output reg signed [Y_WIDTH-1:0]		out_y_o	,
		output reg signed [X_WIDTH-1:0]		out_x_o
	);
	
	wire[X_WIDTH-1:0] w_in_w_i;
	wire[X_WIDTH-1:0] w_in_y_i;
	
	assign w_in_w_i = {{(X_WIDTH-W_WIDTH){in_w_i[W_WIDTH-1]}},in_w_i};
	assign w_in_y_i = {{(X_WIDTH-Y_WIDTH){in_y_i[Y_WIDTH-1]}},in_y_i};
	
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		out_y_o <= {Y_WIDTH{1'b0}};
	else
		out_y_o <= in_y_i;
		
	always@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		out_x_o <= {X_WIDTH{1'b0}};
	else
		out_x_o <= in_x_i + w_in_w_i*w_in_y_i;
endmodule

