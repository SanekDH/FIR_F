module FIR_F  
#(
  parameter inout_width = 8
)
(
  input logic [inout_width-1:0] InputData,
  output logic [inout_width*2-1:0] OutputData,
  input logic Clk,
  input logic Rst
);
  localparam logic [inout_width-1:0] h0 = 8'd1;
  localparam logic [inout_width-1:0] h1 = 8'd2;
  localparam logic [inout_width-1:0] h2 = 8'd1;

  logic [inout_width-1:0] delay1;
  logic [inout_width-1:0] delay2;
  
  logic [inout_width-1:0] MultResult1;
  logic [inout_width-1:0] MultResult2;
  logic [inout_width-1:0] MultResult3;

  assign OutputData = MultResult1 + MultResult2 + MultResult3;

  always_ff @(posedge Clk) begin
    if (!Rst) begin
      delay1 <= 0;
      delay2 <= 0;
    end else begin
      delay1 <= InputData;
      delay2 <= delay1;
    end
  end 

  always_ff @(posedge Clk) begin 
    if (!Rst) begin
      MultResult1 <= 0;
      MultResult2 <= 0;
      MultResult3 <= 0;
    end else begin
      MultResult1 <= InputData * h0;
      MultResult2 <= delay1 * h1;
      MultResult3 <= delay2 * h2;
    end
  end 
endmodule