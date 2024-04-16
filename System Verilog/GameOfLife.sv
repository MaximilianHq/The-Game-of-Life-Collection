typedef enum logic [1:0] {
	NEUTRAL,
	CLAN1,
	CLAN2
} coalition;

typedef enum logic [1:0] {
	dead,
	alive
} condition;

typedef struct {
	condition state;
	coalition clan;
} entity;

parameter DIVIDE_DISPLAY_V = 20;	//one twentieth of the display
parameter DIVIDE_DISPLAY_H = 20; //one twentieth of the display
parameter GRIDWIDTH = 32;
parameter GRIDHEIGHT = 24;

// -- VGA Controller Physical Validation --
// Instantiate the VGA controller module for physical validation.
// (The controller has not been written yet)
// The module displays three different colors to the display,
// which can be modified by the onboard slide switches.
// Note that not all colors can be chosen.

module VGA_PRIMA (
	input entity cells[GRIDHEIGHT][GRIDWIDTH],
	input 			      MAX10_CLK1_50, // 50 MHz clock - PIN_P11
	input logic 			rst_sync,   // Push button  - PIN_A7
	output logic [3:0] VGA_R,  // VGA Red Data   - PIN_AA1, V1, Y2, Y1
	output logic [3:0] VGA_G,  // VGA Green Data - PIN_W1, T2, R2, R1
	output logic [3:0] VGA_B,  // VGA Blue Data  - PIN_P1, T1, P4, N2
	output logic       VGA_HS, // VGA hsync - PIN_N3
	output logic       VGA_VS  // VGA vsync - PIN_N1
);


	// -- Variables --
	logic rst_n;              // Synchronized asynchronous reset
	// Pixel clock generator output
	logic pixel_clock;
	// Sync pulse generator connections
	logic hblank_n;
	logic vblank_n;
	logic blank_n;
	// Local use
	logic [9:0] pixel_count; // Count pixel to divide display into thirds
	logic [8:0] lines;			// Count number of lines
	logic [3:0] rgb [2:0];   // Colors to be displayed Red = MSB, Blue = LSB. 4-bit colors.

	// -- Continuous assignments --
	// Drive color output low if either blank signal is active. Otherwise, display color.
	assign blank_n = hblank_n & vblank_n;   
	assign VGA_R = blank_n ? (rgb[2]) : (4'h0);
	assign VGA_G = blank_n ? (rgb[1]) : (4'h0);
	assign VGA_B = blank_n ? (rgb[0]) : (4'h0);

	// -- Instantiations --
	reset_synchronizer    rsync (.i_clk(MAX10_CLK1_50), .i_rst_n(rst_sync), .o_rst_n(rst_n));
	pixel_clock_generator pcg   (.i_clk(MAX10_CLK1_50), .i_rst_n(rst_n), .o_clk(pixel_clock));
	sync_pulse_generator  spg   (.i_clk(pixel_clock), .i_rst_n(rst_n), .o_hsync_n(VGA_HS),
										 .o_vsync_n(VGA_VS), .o_hblank_n(hblank_n), .o_vblank_n(vblank_n));

	always_comb begin
		for(int i=0; i<GRIDHEIGHT; i=i+1) begin
			if (lines <= (i+1)*DIVIDE_DISPLAY_H) begin
				for(int j=0; j<GRIDWIDTH; j=j+1) begin
					if (pixel_count < (j+1)*DIVIDE_DISPLAY_V) begin
						if(cells[i][j].state == dead) begin
							rgb[2] = {1'h1,1'h1,1'h1,1'h1};
							rgb[1] = {1'h1,1'h1,1'h1,1'h1};
							rgb[0] = {1'h1,1'h1,1'h1,1'h1};
						end else begin
							rgb[2] = {1'h0,1'h0,1'h0,1'h0};
							rgb[1] = {1'h0,1'h0,1'h0,1'h0};
							rgb[0] = {1'h0,1'h0,1'h0,1'h0};
						end
						break; // exit the j for loop
					end
				end
				break; // exit the i for loop
			end
		end
	end

	 // -- Sequential logic --
	// Count the number of pixels. Reset each new line.
	always_ff @ (posedge pixel_clock or negedge rst_n) begin : PixelCount
		if (~rst_n) begin
			pixel_count <= '0;
		end else if (blank_n) begin // Not blanking display
			pixel_count <= pixel_count + 10'd1;
		end else begin
			pixel_count <= '0;
		end // else
	end : PixelCount

	// Count the number of lines. Reset after whole visible display is done.
	always_ff @ (negedge blank_n or negedge rst_n) begin
		if(~rst_n) begin
			lines <= '0;
		end else if(lines == 9'd479)begin
			lines <= '0;
		end else begin
			lines <= lines + 9'd1;
		end
	end

endmodule


module seed_generator(
    input logic clk,
    output entity rand_colony[GRIDHEIGHT][GRIDWIDTH]
);

	logic [GRIDWIDTH-1:0] seed = 7;

	always @(posedge clk) begin
		for (int i=0; i<GRIDHEIGHT; i=i+1) begin : row
			seed = seed * 1664525 + 1013904223;
			for (int j=0; j<GRIDWIDTH; j=j+1) begin : col
				rand_colony[i][j].state = condition'(seed[j]);
				rand_colony[i][j].clan = NEUTRAL;
			end
		end
	end

endmodule

module Cell(
    input logic clk,
    input logic rst_n,
    input logic [7:0] neighbors,
    input entity default_state,
    output entity data
);

	entity nextstate;
	int population; 

	// sum neighbors alive
	assign population = neighbors[0] +
							  neighbors[1] +
							  neighbors[2] +
							  neighbors[3] +
							  neighbors[4] +
							  neighbors[5] +
							  neighbors[6] +
							  neighbors[7];
	
	always_ff @(posedge clk or negedge rst_n or posedge rst_def) begin
		if (~rst_n) begin
			nextstate <= default_state;
		end
		else if (rst_def) begin
			nextstate.state <= alive;
			nextstate.clan <= NEUTRAL;
		end else begin

			// Apply Game of Life rules
			if (data.state == alive) begin
				 // Cell is alive
				 if (population < 2 || population > 3) begin
					  // Overcrowding or loneliness, cell dies
					  nextstate.state <= dead;
				 end
			end else begin
				 // Cell is dead
				 if (population == 3) begin
					  // Exactly 3 neighbors, cell becomes alive
					  nextstate.state <= alive;
				 end
			end
			
			// tmp
			nextstate.clan <= NEUTRAL;
		end
		data <= nextstate;
	end


endmodule

module GameOfLife (
	input              MAX10_CLK1_50, // 50 MHz clock - PIN_P11
	input logic [1:0]  KEY,   // Push button  - PIN_A7
	input logic [9:0] SW,
	output logic [3:0] VGA_R,  // VGA Red Data   - PIN_AA1, V1, Y2, Y1
	output logic [3:0] VGA_G,  // VGA Green Data - PIN_W1, T2, R2, R1
	output logic [3:0] VGA_B,  // VGA Blue Data  - PIN_P1, T1, P4, N2
	output logic       VGA_HS, // VGA hsync - PIN_N3
	output logic       VGA_VS  // VGA vsync - PIN_N1
);
	
	entity cells[GRIDHEIGHT][GRIDWIDTH];
	logic gol_clk;
	logic rst_sync;
	logic rst_n;
	logic rst_def;
	
	assign rst_sync = KEY[0];
	assign rst_n = KEY[1];
	assign rst_def = SW[0];
	
	clock_div gol_clock(
		.clk(MAX10_CLK1_50), 
		.clk_1hz(gol_clk)
	);
	
	// generate random default state
	entity rand_colony[GRIDHEIGHT][GRIDWIDTH];
	
	seed_generator rand_bit(
		.clk(rst_sync),
		.rand_colony(rand_colony)
	);
	

	genvar i, j;
	generate		
		for (i=0; i<GRIDHEIGHT; i=i+1) begin : row
			for (j=0; j<GRIDWIDTH; j=j+1) begin : col
				logic [7:0] neighbors;
				
				// validate positions
				always_comb begin
					if (i-1 >= 0 && j-1 >= 0)
						neighbors[0] = cells[i-1][j-1].state;
					if (i-1 >= 0)
						neighbors[1] = cells[i-1][j].state;
					if (i-1 >= 0 && j+1 < GRIDWIDTH)
						neighbors[2] = cells[i-1][j+1].state;
					if (j-1 >=0)
						neighbors[3] = cells[i][j-1].state;
					if (j+1 < GRIDWIDTH)
						neighbors[4] = cells[i][j+1].state;
					if (i+1 < GRIDHEIGHT && j-1 >= 0)
						neighbors[5] = cells[i+1][j-1].state;
					if (i+1 < GRIDHEIGHT)
						neighbors[6] = cells[i+1][j].state;
					if (i+1 < GRIDHEIGHT && j+1 < GRIDWIDTH)
						neighbors[7] = cells[i+1][j+1].state;
				end
				
				Cell cell_inst(.clk(gol_clk), .rst_n(rst_n), .neighbors(neighbors), .default_state(rand_colony[i][j]), .data(cells[i][j]));
			end
		end
	endgenerate
	
	VGA_PRIMA (
		.cells(cells),
		.MAX10_CLK1_50(MAX10_CLK1_50),
		.rst_sync(rst_sync),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS)
	);
	
endmodule
