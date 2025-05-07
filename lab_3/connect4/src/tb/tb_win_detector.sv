module tb_win_detector;

  // Señales de prueba
  logic [1:0] board[5:0][6:0];
  logic [2:0] last_move_row;
  logic [2:0] last_move_col;
  logic [1:0] player;
  logic win;

  // Instanciamos el módulo bajo prueba (DUT)
  win_detector dut (
    .board(board),
    .last_move_row(last_move_row),
    .last_move_col(last_move_col),
    .player(player),
    .win(win)
  );

  // Tarea para limpiar el tablero
  task clear_board();
    for (int i = 0; i < 6; i++)
      for (int j = 0; j < 7; j++)
        board[i][j] = 0;
  endtask

  // Tarea para imprimir el resultado
  task print_result(string test_name);
    $display("%s: %s", test_name, win ? "WIN DETECTED ✅" : "NO WIN ❌");
  endtask

  initial begin
    // Test 1: Victoria horizontal
    clear_board();
    player = 2;
    board[2][1] = player;
    board[2][2] = player;
    board[2][3] = player;
    board[2][4] = player;
    last_move_row = 2;
    last_move_col = 4;
    #1;
    print_result("Test 1 - Horizontal");

    // Test 2: Victoria vertical
    clear_board();
    player = 1;
    board[1][3] = player;
    board[2][3] = player;
    board[3][3] = player;
    board[4][3] = player;
    last_move_row = 4;
    last_move_col = 3;
    #1;
    print_result("Test 2 - Vertical");

    // Test 3: Victoria diagonal
    clear_board();
    player = 2;
    board[0][0] = player;
    board[1][1] = player;
    board[2][2] = player;
    board[3][3] = player;
    last_move_row = 3;
    last_move_col = 3;
    #1;
    print_result("Test 3 - Diagonal");

    // Test 4: Victoria diagonal /
    clear_board();
    player = 1;
    board[3][0] = player;
    board[2][1] = player;
    board[1][2] = player;
    board[0][3] = player;
    last_move_row = 0;
    last_move_col = 3;
    #1;
    print_result("Test 4 - Diagonal /");

    // Test 5: Sin victoria
    clear_board();
    player = 1;
    board[0][0] = player;
    board[0][1] = player;
    board[0][2] = player;
    last_move_row = 0;
    last_move_col = 2;
    #1;
    print_result("Test 5 - No Win");

    $finish;
  end

endmodule
