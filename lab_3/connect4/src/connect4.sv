module connect4(
  input logic clk,
  input logic rst,
  input logic [2:0] player1_move,  // Columna seleccionada por jugador 1 (FPGA)
  input logic [2:0] player2_move,  // Columna seleccionada por jugador 2 (Arduino)
  input logic player1_start,       // Jugador 1 inicia
  input logic player2_start,       // Jugador 2 inicia
  output logic [1:0] game_state,   // 00: inicio, 01: jugando, 10: jugador1 gana, 11: jugador2 gana
  output logic [5:0][6:0] board,   // Tablero 6x7 (filas x columnas)
  output logic [3:0] turn_timer,   // Tiempo restante del turno
  output logic [1:0] current_player // Jugador actual (1 o 2)
);

  typedef enum logic [3:0] {
    INIT, 
    START_SCREEN,
    PLAYER1_TURN,
    PLAYER2_TURN,
    PROCESS_MOVE,
    CHECK_WIN,
    GAME_OVER
  } state_t;
  
  state_t current_state, next_state;
  
  // Tablero de juego (0: vacío, 1: jugador1, 2: jugador2)
  logic [5:0][6:0] game_board;
  
  // Señales de control
  logic move_valid;
  logic [2:0] move_column;
  logic [2:0] move_row;
  logic player_wins;
  logic timer_expired;
  logic [3:0] timer_count;
  logic timer_reset;
  logic timer_enable;
  
    // Señales para el módulo random
  logic random_start;
  logic random_done;
  logic [2:0] random_col;
  
  logic [1:0] next_player;
  logic [2:0] next_move_column;
  
  // Módulos instanciados
  move_validator validator(
    .column(move_column),
    .board(game_board),
    .valid(move_valid),
    .empty_row(move_row)
  );
  
  win_detector win_check(
    .board(game_board),
    .last_move_row(move_row),
    .last_move_col(move_column),
    .player(current_player),
    .win(player_wins)
  );
  
  timer timer_module(
    .clk(clk),
    .reset(timer_reset),
    .enable(timer_enable),
    .expired(timer_expired),
    .count(timer_count)
  );
  
    // Instancia del módulo place_random_ficha
  place_random_move random_move (
    .clk(clk),
    .rst(rst),
    .start(random_start),
    .board_in(game_board),
    .random_col(random_col),
    .done(random_done)
  );
  
	function automatic logic is_board_full(input logic [5:0][6:0] board);
	  is_board_full = 1'b1; // Asumir inicialmente que está lleno
	  for (int col = 0; col < 7; col++) begin
		 if (board[0][col] == 0) begin // Si la primera fila (fila 0) de alguna columna está vacía
			is_board_full = 1'b0;
			break;
		 end
	  end
	endfunction

  
  // Lógica de estado
  always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    current_state <= INIT;
    game_board <= '{default:0};
    current_player <= 0;
    move_column <= 0;
  end else begin
    current_state <= next_state;
    current_player <= next_player;
    move_column <= next_move_column;
    
    case (current_state)
      INIT: begin
        game_board <= '{default:0};
        current_player <= player1_start ? 1 : 2;
        random_start <= 0;
      end
      
      PROCESS_MOVE: begin
        if (move_valid) begin
          game_board[move_row][move_column] <= current_player;
          random_start <= 0;
        end else if (timer_expired) begin
          if (random_done) begin
            game_board[move_row][random_col] <= current_player;
            random_start <= 0;
          end else begin
            random_start <= 1;
          end
        end
      end
      
      default: begin
        // No action for other states
      end
    endcase
  end
end

  
  // Lógica de transición de estados
  always_comb begin
  next_state = current_state;
  timer_reset = 0;
  timer_enable = 0;
  next_player = current_player;
  next_move_column = (current_player == 1) ? player1_move : player2_move;
  
  case (current_state)
    INIT: begin
      next_state = START_SCREEN;
    end
    
    START_SCREEN: begin
      if (player1_start || player2_start) 
        next_state = (player1_start) ? PLAYER1_TURN : PLAYER2_TURN;
    end

    PLAYER1_TURN: begin
      timer_enable = 1;
      if (player1_move != 0 || timer_expired)
        next_state = PROCESS_MOVE;
    end

    PLAYER2_TURN: begin
      timer_enable = 1;
      if (player2_move != 0 || timer_expired)
        next_state = PROCESS_MOVE;
    end

    PROCESS_MOVE: begin
      timer_reset = 1;
      if (move_valid || (timer_expired && random_done))
        next_state = CHECK_WIN;
    end

    CHECK_WIN: begin
      if (player_wins)
        next_state = GAME_OVER;
      else if (is_board_full(game_board))
        next_state = GAME_OVER;
      else begin
        next_player = (current_player == 1) ? 2 : 1;
        next_state = (next_player == 1) ? PLAYER1_TURN : PLAYER2_TURN;
      end
    end

    GAME_OVER: begin
      // Esperar reset o reinicio
    end
  endcase
end

  
  // Asignaciones de salida
  assign board = game_board;
  assign turn_timer = timer_count;
  assign game_state = (current_state == GAME_OVER) ? 
                     (player_wins ? current_player : 2'b00) : 
                     (current_state == START_SCREEN) ? 2'b00 : 2'b01;
endmodule