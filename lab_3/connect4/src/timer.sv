module timer(
  input logic clk,
  input logic reset,
  input logic enable,
  output logic expired,
  output logic [3:0] count
);
  logic [23:0] counter; // Para contar 10 segundos a 50MHz
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      count <= 10;
    end else if (enable) begin
      if (counter == 24'd50_000_000) begin // 1 segundo
        counter <= 0;
        if (count > 0)
          count <= count - 1;
      end else begin
        counter <= counter + 1;
      end
    end
  end
  
  assign expired = (count == 0);
endmodule