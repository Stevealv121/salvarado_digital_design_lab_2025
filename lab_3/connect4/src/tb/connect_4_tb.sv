`timescale 1ns/1ps

module connect_4_tb();
  // Señales para conectar al DUT
  logic clk;
  logic rst;
  logic [2:0] player1_move;
  logic [2:0] player2_move;
  logic player1_start;
  logic player2_start;
  logic [1:0] game_state;
  logic [5:0][6:0] board;
  logic [3:0] turn_timer;
  logic [1:0] current_player;
  
  // Instancia del módulo bajo prueba (DUT)
  connect4 dut(
    .clk(clk),
    .rst(rst),
    .player1_move(player1_move),
    .player2_move(player2_move),
    .player1_start(player1_start),
    .player2_start(player2_start),
    .game_state(game_state),
    .board(board),
    .turn_timer(turn_timer),
    .current_player(current_player)
  );
  
  // Generación de reloj
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  // Variables para el testbench
  int wait_cycles;
  logic [2:0] last_move_row;
  logic board_display_enable = 1; // Para controlar la visualización del tablero
  
  // Función para mostrar el tablero en la consola
  function void display_board(logic [5:0][6:0] game_board);
    if (board_display_enable) begin
      $display("\n--- TABLERO ACTUAL ---");
      for (int i = 0; i < 6; i++) begin
        $write("| ");
        for (int j = 0; j < 7; j++) begin
          case (game_board[i][j])
            0: $write("  | ");
            1: $write("X | ");
            2: $write("O | ");
            default: $write("? | ");
          endcase
        end
        $display("");
      end
      $display("-------------------");
      $display("  1   2   3   4   5   6   7  ");
      $display("");
    end
  endfunction
  
  // Tarea para hacer un movimiento
  task make_move(input logic [1:0] player, input logic [2:0] column);
    $display("Jugador %0d intenta mover en columna %0d+1", player, column);
    wait (current_player == player);
    if (player == 1)
      player1_move = column;
    else
      player2_move = column;
      
    @(posedge clk); // Esperar un ciclo para registrar el movimiento
    
    // Resetear movimiento después de un ciclo para simular un pulso
    if (player == 1)
      player1_move = 0;
    else
      player2_move = 0;
      
    // Esperar hasta que cambie el turno o termine el juego
    wait(current_player != player || game_state != 2'b01);
    
    display_board(board);
    
    // Mostrar resultado del movimiento
    if (game_state == 2'b10)
      $display("¡Jugador 1 ha ganado!");
    else if (game_state == 2'b11)
      $display("¡Jugador 2 ha ganado!");
      
  endtask
  
  // Tarea para esperar ciclos de reloj
  task wait_clocks(input int cycles);
    repeat(cycles) @(posedge clk);
  endtask
  
  // Tarea para esperar que el temporizador expire
  task wait_timer_expires();
    wait(turn_timer == 1);
    wait_clocks(2); // Dar tiempo para la expiración completa
    $display("¡El temporizador ha expirado!");
  endtask
  
  // Secuencia de prueba principal
  initial begin
    // Inicialización
    rst = 1;
    player1_move = 0;
    player2_move = 0;
    player1_start = 0;
    player2_start = 0;
    wait_cycles = 0;
    
    wait_clocks(5);
    rst = 0;
    
    // Test 1: Inicio del juego por jugador 1
    $display("TEST 1: Inicio del juego por Jugador 1");
    player1_start = 1;
    wait_clocks(2);
    player1_start = 0;
    wait_clocks(2);
    
    // Verificar que estamos en estado de juego y turno del jugador 1
    if (game_state != 2'b01 || current_player != 2'b01)
      $display("ERROR: El juego no se inició correctamente");
    else
      $display("Juego iniciado correctamente. Turno del jugador 1");
    
    // Test 2: Jugada simple alternando turnos
    $display("\nTEST 2: Alternancia de turnos simple");
    make_move(1, 2); // Jugador 1 en columna 3
    make_move(2, 3); // Jugador 2 en columna 4
    make_move(1, 2); // Jugador 1 en columna 3
    make_move(2, 3); // Jugador 2 en columna 4
    
    // Test 3: Probar expiración del temporizador
    //$display("\nTEST 3: Expiración del temporizador");
    //$display("Esperando que expire el temporizador del jugador 1...");
    //wait_timer_expires();
    
    // El movimiento aleatorio debería haberse realizado
    //wait_clocks(5); // Dar tiempo para procesamiento
    //display_board(board);
    
    // Test 4: Forzar una victoria horizontal del jugador 1
    $display("\nTEST 4: Victoria horizontal del jugador 1");
    // Reset del juego
    rst = 1;
    wait_clocks(2);
    rst = 0;
    player1_start = 1;
    wait_clocks(2);
    player1_start = 0;
    wait_clocks(2);
    
    // Crear una victoria horizontal (4 en fila)
    make_move(1, 1); // Jugador 1 en columna 1
    make_move(2, 7); // Jugador 2 en columna 7
    make_move(1, 2); // Jugador 1 en columna 2
    make_move(2, 7); // Jugador 2 en columna 7
    make_move(1, 3); // Jugador 1 en columna 3
    make_move(2, 6); // Jugador 2 en columna 6
    make_move(1, 4); // Jugador 1 en columna 4 - Debería ganar
    
    if (game_state == 2'b10)
      $display("TEST EXITOSO: Jugador 1 ganó con 4 en fila horizontal");
    else
      $display("ERROR: No se detectó la victoria horizontal");
    
    // Test 5: Forzar una victoria vertical del jugador 2
    $display("\nTEST 5: Victoria vertical del jugador 2");
    // Reset del juego
    rst = 1;
    wait_clocks(2);
    rst = 0;
    player2_start = 1;
    wait_clocks(2);
    player2_start = 0;
    wait_clocks(2);
    
    // Crear una victoria vertical (4 en fila)
    make_move(2, 3); // Jugador 2 en columna 3
    make_move(1, 4); // Jugador 1 en columna 4
    make_move(2, 3); // Jugador 2 en columna 3
    make_move(1, 4); // Jugador 1 en columna 4
    make_move(2, 3); // Jugador 2 en columna 3
    make_move(1, 4); // Jugador 1 en columna 4
    make_move(2, 3); // Jugador 2 en columna 3 - Debería ganar
    
    if (game_state == 2'b11)
      $display("TEST EXITOSO: Jugador 2 ganó con 4 en fila vertical");
    else
      $display("ERROR: No se detectó la victoria vertical");
    
    // Test 6: Probar movimiento inválido
    $display("\n=====================");
    $display("TEST 6: Movimiento en columna llena");
    $display("=====================");
    // Reset del juego
    rst = 1;
    wait_clocks(2);
    rst = 0;
    player1_start = 1;
    wait_clocks(2);
    player1_start = 0;
    wait_clocks(2);
    
    // Llenar una columna
    make_move(1, 1);
    make_move(2, 1);
    make_move(1, 1);
    make_move(2, 1);
    make_move(1, 1);
    make_move(2, 1); // La columna 1 está llena
    
    // Intentar mover en una columna llena
    $display("Intentando mover en columna llena...");
    player1_move = 1;
    wait_clocks(2);
    player1_move = 0;
    
    // Esperar a que el sistema procese el movimiento inválido
    wait_clocks(10);
    
    // Verificar que no se haya colocado la ficha
    if (board[0][1] == 1)
      $display("ERROR: Se colocó ficha en columna llena");
    else
      $display("TEST EXITOSO: No se permitió movimiento en columna llena");
    
    // Test 7: Victoria diagonal
    $display("\n=====================");
    $display("TEST 7: Victoria diagonal");
    $display("=====================");
    // Reset del juego
    rst = 1;
    wait_clocks(2);
    rst = 0;
    player1_start = 1;
    wait_clocks(2);
    player1_start = 0;
    wait_clocks(2);
    
    // Crear una victoria diagonal ascendente
    make_move(1, 1); // J1
    make_move(2, 2); // J2
    make_move(1, 2); // J1
    make_move(2, 3); // J2
    make_move(1, 3); // J1
    make_move(2, 4); // J2
    make_move(1, 3); // J1
    make_move(2, 4); // J2
    make_move(1, 4); // J1
    make_move(2, 5); // J2
    make_move(1, 4); // J1 - debería ganar con diagonal
    
    if (game_state == 2'b10)
      $display("TEST EXITOSO: Jugador 1 ganó con diagonal");
    else
      $display("ERROR: No se detectó la victoria diagonal");
    
    // Test 8: Empate (tablero lleno)
    $display("\n=====================");
    $display("TEST 8: Empate - Tablero lleno");
    $display("=====================");
    // Reset del juego
    rst = 1;
    wait_clocks(2);
    rst = 0;
    player1_start = 1;
    wait_clocks(2);
    player1_start = 0;
    wait_clocks(2);
    
    // Llenar el tablero sin crear 4 en línea
    // Patrón alternado que no permite victorias
    for (int col = 0; col < 7; col++) begin
      for (int row = 5; row >= 0; row--) begin
        if ((col + row) % 2 == 0)
          make_move(1, col);
        else
          make_move(2, col);
      end
    end
    
    if (game_state == 2'b00 && dut.is_board_full(board))
      $display("TEST EXITOSO: Se detectó empate con tablero lleno");
    else
      $display("ERROR: No se detectó el empate con tablero lleno");
    
    // Finalización
    $display("\n=====================");
    $display("TODAS LAS PRUEBAS COMPLETADAS");
    $display("=====================");
    $finish;
  end
  
  // Monitoreo del estado del juego
  always @(posedge clk) begin
    if (game_state == 2'b10)
      $display("¡Jugador 1 ha ganado el juego!");
    else if (game_state == 2'b11)
      $display("¡Jugador 2 ha ganado el juego!");
    else if (game_state == 2'b00 && dut.is_board_full(board))
      $display("¡El juego ha terminado en empate!");
  end
endmodule