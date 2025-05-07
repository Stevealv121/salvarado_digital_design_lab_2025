`timescale 1ns/1ps

module tb_move_validator;

  // Entradas
  logic [2:0] column;
  logic [1:0] board[5:0][6:0];

  // Salidas
  logic valid;
  logic [2:0] empty_row;

  // DUT
  move_validator dut (
    .column(column),
    .board(board),
    .valid(valid),
    .empty_row(empty_row)
  );

  // Procedimiento de prueba
  initial begin
    // Limpiar tablero
    for (int i = 0; i < 6; i++)
      for (int j = 0; j < 7; j++)
        board[i][j] = 2'b00;

    // --- CASO 1: Columna vacia (columna 2) ---
    column = 3'd2;
    #1;
    $display("Caso 1 - Columna vacia:");
    $display("  Valid: %0d, Empty row: %0d (esperado: 5)", valid, empty_row);

    // --- CASO 2: Columna parcialmente llena (jugador 1 en fila 5 y 4) ---
    board[5][1] = 2'b01;
    board[4][1] = 2'b10;
    column = 3'd1;
    #1;
    $display("Caso 2 - Columna parcialmente llena:");
    $display("  Valid: %0d, Empty row: %0d (esperado: 3)", valid, empty_row);

    // --- CASO 3: Columna totalmente llena (columna 0) ---
    for (int i = 0; i < 6; i++)
      board[i][0] = 2'b01;
    column = 3'd0;
    #1;
    $display("Caso 3 - Columna llena:");
    $display("  Valid: %0d (esperado: 0)", valid);

    // --- CASO 4: Columna fuera de rango (columna 7) ---
    column = 3'd7; // invalido
    #1;
    $display("Caso 4 - Columna invalida (fuera de rango):");
    $display("  Valid: %0d (esperado: 0)", valid);

    $finish;
  end

endmodule
