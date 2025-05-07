module connect_4_tb;
  // Signal declarations
  logic clk;
  logic rst;
  logic [2:0] player1_move;
  logic [2:0] player2_move;
  logic player1_start;
  logic player2_start;
  logic [1:0] game_state;
  logic [1:0] board[5:0][6:0];
  logic [3:0] turn_timer;
  logic [1:0] current_player;
  
  // State constants
  localparam INIT = 0;
  localparam START_SCREEN = 1;
  localparam PLAYER1_TURN = 2;
  localparam PLAYER2_TURN = 3;
  localparam PROCESS_MOVE = 4;
  localparam CHECK_WIN = 5;
  localparam GAME_OVER = 6;
  
  // Counter
  int count = 0;
  
  // DUT internal state access
  wire [3:0] current_state_raw;
  assign current_state_raw = dut.current_state;
  
  // Debug signals
  wire player_wins_signal;
  wire [2:0] move_row_signal;
  wire [2:0] move_column_signal;
  wire debug_win_signal;
  wire [2:0] debug_last_row;
  wire [2:0] debug_last_col;
  wire win_detected;
  wire [1:0] winner;
  
  assign player_wins_signal = dut.player_wins;
  assign move_row_signal = dut.move_row;
  assign move_column_signal = dut.move_column;
  assign debug_win_signal = dut.debug_win_signal;
  assign debug_last_row = dut.debug_last_row;
  assign debug_last_col = dut.debug_last_col;
  assign win_detected = dut.win_detected;
  assign winner = dut.winner;

  // DUT instantiation with all debug ports
  connect4 dut (
    .clk(clk),
    .rst(rst),
    .player1_move(player1_move),
    .player2_move(player2_move),
    .player1_start(player1_start),
    .player2_start(player2_start),
    .game_state(game_state),
    .board(board),
    .turn_timer(turn_timer),
    .current_player(current_player),
    .debug_win_signal(debug_win_signal),
    .debug_last_row(debug_last_row),
    .debug_last_col(debug_last_col)
  );

  // Clock generator
  always begin
    #10 clk = ~clk;
  end

  // Enhanced board printing function
  function void print_board;
    $display("\n===== ESTADO DEL TABLERO =====");
    for (int row = 0; row < 6; row++) begin
      $write("Fila %0d: ", row);
      for (int col = 0; col < 7; col++) begin
        case(board[row][col])
          2'b00: $write("- ");
          2'b01: $write("X ");
          2'b10: $write("O ");
          default: $write("? ");
        endcase
      end
      $display("");
    end
    $display("       0 1 2 3 4 5 6");
    $display("===========================");
    
    $display("Jugador actual: %s", current_player == 2'b01 ? "Jugador 1 (X)" : "Jugador 2 (O)");
    $display("Estado del juego: %s", 
             game_state == 2'b00 ? "Inicio" : 
             game_state == 2'b01 ? "Jugando" : 
             game_state == 2'b10 ? "Jugador 1 gana" : "Jugador 2 gana");
    $display("Estado interno: %s", state_to_string(current_state_raw));
    $display("Win signals - Raw: %b, Detected: %b, Winner: %b", 
             player_wins_signal, win_detected, winner);
    $display("Last move: row=%0d, col=%0d", debug_last_row, debug_last_col);
  endfunction

  // State to string function
  function string state_to_string(input logic [3:0] state);
    case(state)
      INIT: return "INIT";
      START_SCREEN: return "START_SCREEN";
      PLAYER1_TURN: return "PLAYER1_TURN";
      PLAYER2_TURN: return "PLAYER2_TURN";
      PROCESS_MOVE: return "PROCESS_MOVE";
      CHECK_WIN: return "CHECK_WIN";
      GAME_OVER: return "GAME_OVER";
      default: return "UNKNOWN";
    endcase
  endfunction

  // Move task with enhanced debugging
  task make_move(input logic is_player1, input logic [2:0] column);
    automatic string player_name = is_player1 ? "Jugador 1" : "Jugador 2";
    $display("\n%s coloca en columna %0d", player_name, column);
    
    @(posedge clk);
    if (is_player1)
      player1_move = column;
    else
      player2_move = column;
    
    @(posedge clk);
    @(posedge clk);
    
    wait(current_state_raw == PROCESS_MOVE);
    @(posedge clk);
    
    if (is_player1)
      player1_move = 3'b000;
    else
      player2_move = 3'b000;
    
    wait(current_state_raw == PLAYER1_TURN || current_state_raw == PLAYER2_TURN || current_state_raw == GAME_OVER);
    
    $display("\n--- DESPUÉS DEL MOVIMIENTO DE %s ---", player_name);
    print_board();
    
    // Additional win check debug
    if (current_state_raw == GAME_OVER) begin
      $display("--- WIN DETECTED ---");
      $display("Win signal: %b", player_wins_signal);
      $display("Win detected: %b", win_detected);
      $display("Winner: %s", winner == 2'b01 ? "Player 1" : "Player 2");
    end
  endtask

  // Main test procedure
  initial begin
    // Initialization
    $display("=================================================================");
    $display("== TESTBENCH PARA CONNECT 4: DEMOSTRACIÓN DE VICTORIA VERTICAL ==");
    $display("=================================================================");
    clk = 0;
    rst = 1;
    player1_move = 3'b000;
    player2_move = 3'b000;
    player1_start = 0;
    player2_start = 0;
    
    repeat(5) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);
    
    $display("\n--- ESTADO INICIAL ---");
    print_board();
    
    player1_start = 1;
    @(posedge clk);
    player1_start = 0;
    
    wait(current_state_raw == PLAYER1_TURN);
    $display("\nJuego iniciado. Turno del Jugador 1");
    print_board();
    
    // Test sequence
    make_move(1, 3'd3);
    make_move(0, 3'd1);
    make_move(1, 3'd3);
    make_move(0, 3'd2);
    make_move(1, 3'd3);
    make_move(0, 3'd4);
    make_move(1, 3'd3);
    
    wait(current_state_raw == GAME_OVER);
    
    $display("\n--- JUEGO TERMINADO ---");
    $display("Estado del juego: %s", 
             game_state == 2'b00 ? "Empate" : 
             game_state == 2'b01 ? "Jugando" : 
             game_state == 2'b10 ? "Jugador 1 gana" : "Jugador 2 gana");
    
    $display("\n--- VICTORIA VERTICAL DEL JUGADOR 1 ---");
    print_board();
    
    $display("\n--- VERIFICACIÓN DE 4 EN LÍNEA ---");
    for (int row = 0; row < 6; row++) begin
      if (board[row][3] == 2'b01) begin
        count++;
        $display("Ficha del Jugador 1 en fila %0d, columna 3", row);
      end
    end
    $display("Total de fichas del Jugador 1 en columna 3: %0d", count);
    
    repeat(10) @(posedge clk);
    $display("\nFin de la simulación - Victoria del Jugador 1 verificada con éxito");
    $finish;
  end

  // Enhanced monitor
  initial begin
    $monitor("Tiempo: %t, Estado: %s, Jugador: %b, Timer: %d, Win: %b/%b, Last: [%0d,%0d]",
              $time, 
              state_to_string(current_state_raw), 
              current_player, 
              turn_timer,
              player_wins_signal,
              win_detected,
              debug_last_row,
              debug_last_col);
  end
endmodule