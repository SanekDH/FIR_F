module testbench_FIR();

    reg tb_clk;
    logic Rst;
    
    initial tb_clk = 0;
    
    always #20 tb_clk = ~tb_clk;

    parameter int I_WIDTH = 16;
    parameter int COEF_WIDTH = 16;
    parameter int COEF_SUM = 29;
    parameter int MULT_WIDTH = I_WIDTH + COEF_WIDTH;
    parameter int O_WIDTH  = MULT_WIDTH + COEF_SUM - 1;

    real PI = 3.14159265358979323846;
    real last_time = 0;
    real current_time = 0;
    real angle = 0;
    real frequency = 100;
    integer freq_x100kHz = 0;
    
    logic signed [15:0] sin16;

    // фунуция синуса
    function real sin;
      input x;
        real x;
        real x1, y, y2, y3, y5, y7, sum, sign;
        begin
          sign = 1.0;
          x1 = x;
            
            if (x1 < 0) begin
              x1 = -x1;
              sign = -1.0;
            end
            
            while (x1 > PI / 2.0) begin
              x1 = x1 - PI;
              sign = -1.0 * sign;
            end
            
            y = x1 * 2 / PI;
            y2 = y * y;
            y3 = y * y2;
            y5 = y3 * y2;
            y7 = y5 * y2;
            
            sum = 1.570794 * y - 0.645962 * y3 + 0.079692 * y5 - 0.004681712 * y7;
            sin = sign * sum;
        end
    endfunction

    task set_freq;
      input f;
      real f;
      begin
        frequency = f;
        freq_x100kHz = f / 100000.0;
      end
    endtask

    always @(posedge tb_clk) begin
      current_time = $realtime;
      angle = angle + (current_time - last_time) * 2 * PI * frequency / 1000000000.0;
        
      while (angle > PI * 2.0) begin
        angle = angle - PI * 2.0;
      end
        
      sin16 = 32000 * sin(angle);
      last_time = current_time;
    end

    //low-pass filter
    logic [O_WIDTH-1:0] o_Data = '0;
    
    Fir_F #(
      .I_WIDTH(I_WIDTH),
      .COEF_WIDTH(COEF_WIDTH),
      .COEF_SUM(COEF_SUM),
      .MULT_WIDTH(MULT_WIDTH),
      .O_WIDTH(O_WIDTH)
    ) DUT (
      .Clk(tb_clk),
      .Rst(Rst),
      .i_data(sin16),
      .coefs({
          32'd367,
             32'd623,
             32'd882,
             32'd924,
             32'd614,
            -32'd57,
            -32'd918,
            -32'd1632,
            -32'd1800,
            -32'd1126,
             32'd438,
             32'd2620,
             32'd4880,
             32'd6581,
             32'd7212,
             32'd6581,
             32'd4880,
             32'd2620,
             32'd438,
            -32'd1126,
            -32'd1800,
            -32'd1632,
            -32'd918,
            -32'd57,
             32'd614,
             32'd924,
             32'd882,
             32'd623,
             32'd367
        }),
      .o_data(o_Data)
    );

    integer i;
    real f;

    initial begin
      repeat(20) @(posedge tb_clk);
      Rst <= 1'b1;
      repeat(20) @(posedge tb_clk);
      Rst <= 1'b0;
      f = 100000;
      for (i = 0; i < 4000; i = i + 1) begin
        set_freq(f);
        #800;
        f = f + 1000;
      end
      $finish;
    end

endmodule