// -- Sync Pulse Generator --
// For a VGA 640x480 resolution with a 60 Hz refresh rate
// Generate the HSync and VSync pulses, and a blanking
// signal that can be used to force RGB data to display black.
// The timing begins with the hysnc and vsync active (pulled low).
module sync_pulse_generator (
  input        i_clk,      // Input clock (pixel clock)
  input        i_rst_n,    // Asynchronous reset - active low
  output logic o_hsync_n,  // Horizontal sync pulse - active low
  output logic o_vsync_n,  // Vertical sync pulse - active low
  output logic o_hblank_n, // Blanking signal for RGB data - active low
  output logic o_vblank_n  // Blanking signal for RGB data - active low
  );

  // -- Local constants --
  // Visible frame dimensions
  localparam VISIBLE_WIDTH  = 10'd640;
  localparam VISIBLE_HEIGHT = 10'd480;
  // Horizontal timing signal widths
  localparam H_FRONT_PORCH_WIDTH = 10'd16;
  localparam H_SYNC_PULSE_WIDTH  = 10'd96;
  localparam H_BACK_PORCH_WIDTH  = 10'd48;

//  localparam H_FRONT_PORCH_WIDTH = 10'd57;
//  localparam H_SYNC_PULSE_WIDTH  = 10'd96;
//  localparam H_BACK_PORCH_WIDTH  = 10'd170;
  
  // Vertical timing signal widths
  localparam V_FRONT_PORCH_WIDTH = 10'd11;
  localparam V_SYNC_PULSE_WIDTH  = 10'd2;
  localparam V_BACK_PORCH_WIDTH  = 10'd31;
  // Total line width
  localparam LINE_WIDTH = VISIBLE_WIDTH + H_FRONT_PORCH_WIDTH
                        + H_SYNC_PULSE_WIDTH + H_BACK_PORCH_WIDTH;
  // Total frame height
  localparam FRAME_HEIGHT = VISIBLE_HEIGHT + V_FRONT_PORCH_WIDTH
                        + V_SYNC_PULSE_WIDTH + V_BACK_PORCH_WIDTH;
  // 10-bit one to increment the counters
  localparam ONE = 10'd1;

  // -- Local variables -- 
  logic [9:0] pixel_count, next_pixel_count;
  logic [9:0] line_count, next_line_count;

  // -- Continuous assignments -- 
  assign next_pixel_count = pixel_count + ONE;
  assign next_line_count  = line_count + ONE;

  // -- Sequential logic --
  // Counter to count the number of pixels displayed
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : PixelCount
    if (~i_rst_n) begin
      pixel_count <= '0;
    end else begin
      if (next_pixel_count == LINE_WIDTH) begin
        pixel_count <= '0;
      end else begin
        pixel_count <= next_pixel_count; 
      end // else
    end // else
  end : PixelCount

  // Counter to count the number of lines displayed
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : LineCount
    if (~i_rst_n) begin
      line_count <= '0;
    end else if (next_pixel_count == LINE_WIDTH) begin
	  if (next_line_count == FRAME_HEIGHT) begin
        line_count <= '0;
      end else begin 
        line_count <= next_line_count;
      end // else
    end // else if (next_pixel_count == LINE_WIDTH)
  end : LineCount

  // Generate hsync pulse - start with the sync pulse
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : HSyncPulse
    if (~i_rst_n) begin
      o_hsync_n <= '0; 
    end else begin
      if (next_pixel_count == H_SYNC_PULSE_WIDTH) begin
        o_hsync_n <= '1;
      end else if (next_pixel_count == LINE_WIDTH) begin
        o_hsync_n <= '0;
      end // else if (~|next_pixel_count)     
    end // else
  end : HSyncPulse  

  // Generate vsync pulse - start with the sync pulse
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : VSyncPulse
    if (~i_rst_n) begin
      o_vsync_n <= '0;
    end else if (next_pixel_count == LINE_WIDTH) begin
      if (next_line_count == V_SYNC_PULSE_WIDTH) begin
        o_vsync_n <= '1;
      end else if (next_line_count == FRAME_HEIGHT) begin
        o_vsync_n <= '0;
      end // else if (next_line_count == FRAME_HEIGHT)
    end // else if (next_pixel_count == LINE_WIDTH)
  end : VSyncPulse  

  // Generate horizontal blanking signal
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : HorizontalBlankPulse
    if (~i_rst_n) begin
      o_hblank_n <= '0;
    end else if (next_pixel_count == H_SYNC_PULSE_WIDTH + H_BACK_PORCH_WIDTH) begin
      o_hblank_n <= '1;
    end else if (next_pixel_count == LINE_WIDTH - H_FRONT_PORCH_WIDTH) begin
      o_hblank_n <= '0;
    end // else if (next_pixel_count == LINE_WIDTH - H_FRONT_PORCH_WIDTH)
  end : HorizontalBlankPulse 

  // Generate vertical blanking signal
  always_ff @ (posedge i_clk or negedge i_rst_n) begin : VerticalBlankPulse
    if (~i_rst_n) begin
      o_vblank_n <= '0;
    end else if (next_pixel_count == LINE_WIDTH) begin
      if (next_line_count == V_SYNC_PULSE_WIDTH + V_BACK_PORCH_WIDTH) begin
        o_vblank_n <= '1;
      end else if (next_line_count == FRAME_HEIGHT - V_FRONT_PORCH_WIDTH) begin
        o_vblank_n <= '0;
      end // else if (next_line_count == FRAME_HEIGHT - V_FRONT_PORCH_WIDTH)
    end // else if (next_pixel_count == LINE_WIDTH)
  end : VerticalBlankPulse 

endmodule

// -- Pixel Clock Generator --
// For a VGA 640x480 resolution with a 60 Hz refresh rate,
// the standard pixel clock is 25.175 MHz.
// The DE10-Lite FPGA onboard 50 MHz clock can be divided down
// by two to easily get 25 MHz, which is close enough to 25.175 MHz.
module pixel_clock_generator (
  input        i_clk,   // FPGA 50 MHz clock
  input        i_rst_n, // Synchronous reset - active low
  output logic o_clk    // 25 MHz output clock
  );

  always_ff @ (posedge i_clk or negedge i_rst_n) begin : FreqDiv
    if (~i_rst_n) begin
      o_clk <= '0;
    end // if (~i_rst_n)
    else begin
      o_clk <= ~o_clk;
    end // else
  end : FreqDiv

endmodule