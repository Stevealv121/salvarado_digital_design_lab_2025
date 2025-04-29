`timescale 1ns/1ps

module tb_place_random_move();

  // Parámetros
  logic clk;
  logic rst;
  logic start;
  logic [5:0][6:0] board_in;
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
    board_in = '0;

    // Reset inicial
    #10;
    rst = 0;

    // --- CASO 1: Tablero vacío ---
    // Todas las columnas deben ser válidas

    #10;
    start = 1;
    #10;
    start = 0;

    // Esperar a que done se active
    wait (done == 1);
    $display("Random column selected (empty board): %0d", random_col);

    // --- CASO 2: Tablero con columnas llenas parcialmente ---
    // Llenamos parcialmente algunas columnas (por ejemplo, columna 0 y 3 llenas en la fila 0)
    board_in[0][0] = 1; // Columna 0 llena
    board_in[0][3] = 1; // Columna 3 llena

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
    // Llenamos todas las columnas excepto la columna 6
    for (int col = 0; col < 6; col++) begin
      board_in[0][col] = 1; // Solo columna 6 queda libre
    end

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

    // Terminar la simulación
    #20;
    $finish;
  end

endmodule
