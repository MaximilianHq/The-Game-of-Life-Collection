// -- Reset Synchronizer --
// Asynchronously asserts the reset signal
// Synchronously deasserts the reset signal
// Consists of two flips flops in series
// One flop receives VDD at its D input
// The second flops receives the first flop's output (Q)
// as its D input. The output of the second flop is the reset
// signal, which should be routed to other modules.
module reset_synchronizer (
  input        i_clk,
  input        i_rst_n,
  output logic o_rst_n
  );

  logic Q; // First FF output

  always_ff @ (posedge i_clk or negedge i_rst_n) begin : FirstFF
    if (~i_rst_n) begin
       Q <= '0;
    end else begin
       Q <= '1; // Tie input to VDD
    end
  end : FirstFF

  always_ff @ (posedge i_clk or negedge i_rst_n) begin : SecondFF
    if (~i_rst_n) begin
       o_rst_n <= '0;
    end else begin
       o_rst_n <= Q; 
    end
  end : SecondFF

endmodule