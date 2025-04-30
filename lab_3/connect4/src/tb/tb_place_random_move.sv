`timescale 1ns/1ps 

module tb_place_random_move();

  // Señales
  logic clk;
  logic rst;
  logic start;
  logic [1:0] board_in[5:0][6:0];  // Tablero modificado con 2 bits por celda
  logic [2:0] random_col;
  logic done;

  // Instanciar el módulo bajo prueba (DUT)
  place_random_move dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .board_in(board_in),
    .random_col(random_col),
    .done(done)
  );

  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Procedimiento de prueba
  initial begin
    // Inicialización
    rst = 1;
    start = 0;

    // Limpiar tablero (todo vacío = 2'b00)
    for (int i = 0; i < 6; i++) begin
      for (int j = 0; j < 7; j++) begin
        board_in[i][j] = 2'b00;
      end
    end

    // Reset inicial
    #10;
    rst = 0;

    // --- CASO 1: Tablero vacío ---
    #10;
    start = 1;
    #10;
    start = 0;

    // Esperar a que done se active
    wait (done == 1);
    $display("Random column selected (empty board): %0d", random_col);

    // --- CASO 2: Tablero parcialmente lleno ---
    // Llenamos fila superior de columna 0 y 3 (ya no deberían ser válidas)
    board_in[0][0] = 2'b01; // Jugador 1
    board_in[0][3] = 2'b10; // Jugador 2

    #20;
    start = 1;
    #10;
    start = 0;

    wait (done == 1);
    $display("Random column selected (partially filled board): %0d", random_col);
    if (random_col == 0 || random_col == 3) begin
      $display("ERROR: Selected a full column! Test failed.");
    end else begin
      $display("SUCCESS: Selected a valid column.");
    end

    // --- CASO 3: Tablero casi lleno ---
    // Todas las columnas llenas excepto columna 6
    for (int col = 0; col < 6; col++) begin
      board_in[0][col] = 2'b01; // Jugador 1
    end
    board_in[0][6] = 2'b00; // Columna 6 libre

    #20;
    start = 1;
    #10;
    start = 0;

    wait (done == 1);
    $display("Random column selected (only column 6 available): %0d", random_col);
    if (random_col != 6) begin
      $display("ERROR: Should have selected column 6! Test failed.");
    end else begin
      $display("SUCCESS: Correctly selected column 6.");
    end

    #20;
    $finish;
  end

endmodule
