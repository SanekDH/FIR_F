module tb_FIR_F();
  
  parameter inout_width = 8;
  parameter CLK_PERIOD = 10;  
  
  logic [inout_width-1:0] InputData;
  logic [inout_width-1:0] OutputData;
  logic Clk;
  logic Rst;
  
  FIR_F #(.inout_width(inout_width))
  DUT (
    .InputData(InputData),
    .OutputData(OutputData),
    .Clk(Clk),
    .Rst(Rst)
  );
  
  initial begin
    Clk = 0;
    forever #(CLK_PERIOD/2) Clk = ~Clk;
  end
  
  initial begin
    Rst = 0;
    InputData = 0;
    
    repeat(5) @(posedge Clk);
    
    Rst = 1;
    @(posedge Clk);
    
    InputData = 8'd100;
    @(posedge Clk);
    InputData = 8'd0;  
    
    for(int i=0; i<6; i++) begin
      @(posedge Clk);
      get_expected_impulse_response(i);
    end
    
    gb(0, 0, 0);
    $finish;
  end
  
  function logic [inout_width*2-1:0] get_expected_impulse_response(int sample);
    logic [inout_width-1:0] sum;
    case(sample)
      0: sum = 100;                      
      1: sum = 200;                      
      2: sum = 100;                      
      default: sum = 0;            
    endcase
    return sum;
  endfunction
  
  initial begin
    $dumpfile("fir_filter.vcd");
    $dumpvars(0, tb_FIR_F);
  end
  
endmodule