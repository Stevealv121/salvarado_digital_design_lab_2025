// Primero, necesitamos un módulo para convertir el timer de 4 bits (0-10) a BCD para los displays de 7 segmentos

module timer_to_display (
  input logic [3:0] timer_value,
  output logic [6:0] display_units,  // 7 segmentos para las unidades
  output logic [6:0] display_tens    // 7 segmentos para las decenas
);
  
  // Variables internas para la conversión BCD
  logic [3:0] units_digit;
  logic [3:0] tens_digit;
  
  // Función para convertir de binario a 7 segmentos (active low)
  function [6:0] segment_decode(input [3:0] digit);
    case (digit)
      4'd0: return 7'b1000000;  // 0
      4'd1: return 7'b1111001;  // 1
      4'd2: return 7'b0100100;  // 2
      4'd3: return 7'b0110000;  // 3
      4'd4: return 7'b0011001;  // 4
      4'd5: return 7'b0010010;  // 5
      4'd6: return 7'b0000010;  // 6
      4'd7: return 7'b1111000;  // 7
      4'd8: return 7'b0000000;  // 8
      4'd9: return 7'b0010000;  // 9
      default: return 7'b1111111;  // Apagado
    endcase
  endfunction
  
  // Convertir el valor del temporizador a decenas y unidades
  always_comb begin
    tens_digit = timer_value / 10;
    units_digit = timer_value % 10;
    
    // Decodificar para los displays de 7 segmentos
    display_units = segment_decode(units_digit);
    display_tens = segment_decode(tens_digit);
  end
  
endmodule