module clock_div(
input logic clk,
output logic clk_1hz
);

	logic [25:0]counter = 0;
	int time_to_wait;
	
	always_ff @(posedge clk) begin
		if(counter < 15000000) begin
			counter <= counter + 1;
			clk_1hz <= 0;
		end else begin
			clk_1hz <= 1;
			counter <= 0;
		end
	end
	
endmodule
