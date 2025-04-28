module move_validator(
  input logic [2:0] column,
  input logic [5:0][6:0] board,
  output logic valid,
  output logic [2:0] empty_row
);
  always_comb begin
    valid = 0;
    empty_row = 0;
    
    if (column < 7) begin
      // Buscar la primera fila vacía en la columna seleccionada
      for (int i = 5; i >= 0; i--) begin
        if (board[i][column] == 0) begin
          valid = 1;
          empty_row = i;
          break;
        end
      end
    end
  end
endmodule
