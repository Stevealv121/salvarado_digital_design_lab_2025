module timer(
  input logic clk,
  input logic reset,
  input logic enable,
  output logic expired,
  output logic [3:0] count
);
  // Opción 1: Corregir el valor de comparación para 1 segundo exacto
  logic [25:0] counter; // Ampliado para soportar valores más grandes por seguridad
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      count <= 10;
    end else if (enable) begin
      if (counter == 26'd49_999_999) begin // Exactamente 1 segundo a 50MHz (50M-1)
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