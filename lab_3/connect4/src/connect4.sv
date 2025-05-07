module connect4(
  input logic clk,
  input logic rst,
  input logic [2:0] player1_move,
  input logic [2:0] player2_move,
  input logic player1_move_valid,
  input logic player2_move_valid,
  input logic player1_start,
  input logic player2_start,
  output logic [1:0] game_state,
  output logic [1:0] board[5:0][6:0],
  output logic [3:0] turn_timer,
  output logic [1:0] current_player,
  output logic debug_win_signal,
  output logic [2:0] debug_last_row,
  output logic [2:0] debug_last_col,
  output logic [2:0] win_positions_row[0:3],
  output logic [2:0] win_positions_col[0:3],
  output logic [1:0] win_type
);

  typedef enum logic [3:0] {
    INIT, 
    START_SCREEN,
    PLAYER1_TURN,
    PLAYER2_TURN,
    PROCESS_MOVE,
    GENERATE_RANDOM_MOVE,
    CHECK_WIN,
    GAME_OVER
  } state_t;

  state_t current_state, next_state;

  // Game board and movement signals
  logic [1:0] game_board[5:0][6:0];
  logic move_valid;
  logic [2:0] move_column;
  logic [2:0] move_row;
  
  // Validation signals
  logic [2:0] validated_column;
  logic validation_ready;
  
  // Win detection and timing
  logic player_wins;
  logic timer_expired;
  logic [3:0] timer_count;
  logic timer_reset;
  logic timer_enable;
  
  // Player and game control
  logic random_start;
  logic random_done;
  logic [2:0] random_col;
  logic [1:0] next_player;
  logic [2:0] next_move_column;
  
  // Registered game state
  logic win_detected;
  logic [1:0] winner;
  logic [2:0] last_move_row;
  logic [2:0] last_move_col;

  // Flag para indicar si estamos usando movimiento aleatorio
  logic using_random_move;
  logic next_using_random_move;
  
  // Señales para la línea ganadora
  logic [2:0] winning_positions_row[0:3];
  logic [2:0] winning_positions_col[0:3];
  logic [1:0] winning_type;

  // Module instantiations
  move_validator validator(
    .column(validated_column),
    .board(game_board),
    .valid(move_valid),
    .empty_row(move_row)
  );

  win_detector win_check(
    .board(game_board),
    .last_move_row(last_move_row),
    .last_move_col(last_move_col),
    .player(current_player),
    .win(player_wins),
    .win_positions_row(winning_positions_row),
    .win_positions_col(winning_positions_col),
    .win_type(winning_type)
  );

  // reset global al timer_reset
  // para asegurar que el timer se reinicie también cuando se resetea el juego
  logic effective_timer_reset;
  assign effective_timer_reset = timer_reset || rst;
  
  timer timer_module(
    .clk(clk),
    .reset(effective_timer_reset),
    .enable(timer_enable),
    .expired(timer_expired),
    .count(timer_count)
  );

  place_random_move random_move(
    .clk(clk),
    .rst(rst),
    .start(random_start),
    .board_in(game_board),
    .random_col(random_col),
    .done(random_done)
  );

  function automatic logic is_board_full(input logic [1:0] board[5:0][6:0]);
    is_board_full = 1'b1;
    for (int col = 0; col < 7; col++) begin
      if (board[0][col] == 2'b00) begin
        is_board_full = 1'b0;
        break;
      end
    end
  endfunction

  // Sequential logic
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state <= INIT;
      game_board <= '{default:0};
      current_player <= 2'b01;
      move_column <= 0;
      win_detected <= 0;
      winner <= 0;
      last_move_row <= 0;
      last_move_col <= 0;
      validated_column <= 0;
      validation_ready <= 0;
      using_random_move <= 0;
      random_start <= 0;
      
      // Inicializar posiciones ganadoras
      for (int i = 0; i < 4; i++) begin
        win_positions_row[i] <= 0;
        win_positions_col[i] <= 0;
      end
      win_type <= 2'b00;
    end else begin
      current_state <= next_state;
      current_player <= next_player;
      move_column <= next_move_column;
      using_random_move <= next_using_random_move;
      
      // Update validation signals
      if (current_state == PLAYER1_TURN || current_state == PLAYER2_TURN) begin
        validated_column <= next_move_column;
        validation_ready <= 1;
      end else if (current_state == GENERATE_RANDOM_MOVE && random_done) begin
        validated_column <= random_col;
        validation_ready <= 1;
      end else begin
        validation_ready <= 0;
      end

      // Board updates and move registration
      case (current_state)
        INIT: begin
          game_board <= '{default:0};
          current_player <= player1_start ? 2'b01 : 2'b10;
          random_start <= 0;
          win_detected <= 0;
          
          // Inicializar posiciones ganadoras
          for (int i = 0; i < 4; i++) begin
            win_positions_row[i] <= 0;
            win_positions_col[i] <= 0;
          end
          win_type <= 2'b00;
        end

        GENERATE_RANDOM_MOVE: begin
          if (random_start == 1'b0) begin
            random_start <= 1'b1;
          end
          
          if (random_done) begin
            random_start <= 1'b0;
          end
        end

        PROCESS_MOVE: begin
          if (move_valid) begin
            if (using_random_move) begin
              game_board[move_row][random_col] <= current_player;
              last_move_row <= move_row;
              last_move_col <= random_col;
              $display("Placed random %b at [%0d,%0d]", current_player, move_row, random_col);
            end else begin
              game_board[move_row][move_column] <= current_player;
              last_move_row <= move_row;
              last_move_col <= move_column;
              $display("Placed %b at [%0d,%0d]", current_player, move_row, move_column);
            end
          end
        end

        CHECK_WIN: begin
          if (player_wins) begin
            // Si hay victoria, guardar las posiciones ganadoras
            win_detected <= 1;
            winner <= current_player;
            
            // Copiar las posiciones ganadoras
            for (int i = 0; i < 4; i++) begin
              win_positions_row[i] <= winning_positions_row[i];
              win_positions_col[i] <= winning_positions_col[i];
            end
            win_type <= winning_type;
          end
        end

        default: begin end
      endcase
    end
  end

  // Combinational state logic
  always_comb begin
    // Default values
    next_state = current_state;
    timer_reset = 0;
    timer_enable = 0;
    next_player = current_player;
    next_move_column = move_column;
    next_using_random_move = using_random_move;

    case (current_state)
      INIT: begin
        timer_reset = 1;
        next_state = START_SCREEN;
        next_using_random_move = 0;
      end

      START_SCREEN: begin
        timer_reset = 1;
        if (player1_start || player2_start) begin
          next_state = player1_start ? PLAYER1_TURN : PLAYER2_TURN;
          next_player = player1_start ? 2'b01 : 2'b10;
        end
        next_using_random_move = 0;
      end

      PLAYER1_TURN: begin
        timer_enable = 1;
        next_using_random_move = 0;
        if (player1_move_valid) begin
          next_move_column = player1_move;
          next_state = PROCESS_MOVE;
        end else if (timer_expired) begin
          next_state = GENERATE_RANDOM_MOVE;
          next_using_random_move = 1;
        end
      end

      PLAYER2_TURN: begin
        timer_enable = 1;
        next_using_random_move = 0;
        if (player2_move_valid) begin
          next_move_column = player2_move;
          next_state = PROCESS_MOVE;
        end else if (timer_expired) begin
          next_state = GENERATE_RANDOM_MOVE;
          next_using_random_move = 1;
        end
      end

      GENERATE_RANDOM_MOVE: begin
        if (random_done) begin
          next_state = PROCESS_MOVE;
        end
      end

      PROCESS_MOVE: begin
        timer_reset = 1;
        if (validation_ready && move_valid) begin
          next_state = CHECK_WIN;
        end else if (!move_valid && using_random_move) begin
          // Si el movimiento aleatorio no es válido, volvemos a intentar
          next_state = GENERATE_RANDOM_MOVE;
        end
      end

      CHECK_WIN: begin
        if (timer_count > 1) begin  // Wait 2 cycles
          if (player_wins) begin
            next_state = GAME_OVER;
          end else if (is_board_full(game_board)) begin
            next_state = GAME_OVER;
          end else begin
            next_player = (current_player == 2'b01) ? 2'b10 : 2'b01;
            next_state = (next_player == 2'b01) ? PLAYER1_TURN : PLAYER2_TURN;
          end
        end
      end

      GAME_OVER: begin
        // Stay in this state until reset
      end
    endcase
  end

  // Output assignments
  assign board = game_board;
  assign turn_timer = timer_count;
  assign game_state = (current_state == GAME_OVER) ? 
                     (win_detected ? 2'b10 : 2'b11) :
                     (current_state == START_SCREEN) ? 2'b00 : 2'b01;
  
  // Debug assignments
  assign debug_win_signal = player_wins;
  assign debug_last_row = last_move_row;
  assign debug_last_col = last_move_col;
endmodule