// трансронированный КИХ - фильтр

module Fir_F 
#(
  parameter int I_WIDTH = 16,
  parameter int COEF_WIDTH = 16,
  parameter int COEF_SUM = 10,
  parameter int MULT_WIDTH = I_WIDTH + COEF_WIDTH, 
  parameter int O_WIDTH = MULT_WIDTH + COEF_SUM - 1
)
(
  input logic Clk,
  input logic Rst,
  input logic signed [I_WIDTH-1:0] i_data,
  input logic [COEF_SUM*32-1:0] coefs,  
  output logic signed [O_WIDTH-1:0] o_data 
);

  genvar i;
  generate
    for (i = 0; i < COEF_SUM; i = i + 1) begin : block
      reg signed [MULT_WIDTH+i-1:0] r;
      logic signed [MULT_WIDTH+i-1:0] adder;
      logic signed [MULT_WIDTH-1:0] m;
      logic signed [COEF_WIDTH-1:0] Coef;
      
      assign Coef = coefs[i*32 +: COEF_WIDTH]; 

      if (i == 0) begin
        always_comb begin : M0
          m = i_data * Coef;
        end
      
        always_ff @(posedge Clk) begin : R0
          if (Rst) r <= '0;
          else r <= m;  
        end
      end
      else begin
        always_comb begin : Mi
          m = i_data * Coef;
          adder = m + block[i-1].r; 
        end

        always_ff @(posedge Clk) begin : Ri
          if (Rst) r <= '0;
          else r <= adder;
        end
      end
    end
  endgenerate

  assign o_data = block[COEF_SUM-1].r;
endmodule