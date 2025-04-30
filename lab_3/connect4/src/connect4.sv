module connect4(
  input logic clk,
  input logic rst,
  input logic [2:0] player1_move,
  input logic [2:0] player2_move,
  input logic player1_start,
  input logic player2_start,
  output logic [1:0] game_state,
  output logic [1:0] board[5:0][6:0],
  output logic [3:0] turn_timer,
  output logic [1:0] current_player,
  output logic debug_win_signal,
  output logic [2:0] debug_last_row,
  output logic [2:0] debug_last_col
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

  // Module instantiations
  move_validator validator(
    .column(validated_column),
    .board(game_board),
    .valid(move_valid),
    .empty_row(move_row)  // Directly outputs to move_row
  );

  win_detector win_check(
    .board(game_board),
    .last_move_row(last_move_row),
    .last_move_col(last_move_col),
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
    end else begin
      current_state <= next_state;
      current_player <= next_player;
      move_column <= next_move_column;
      
      // Update validation signals
      if (current_state == PLAYER1_TURN || current_state == PLAYER2_TURN) begin
        validated_column <= next_move_column;
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
        end

        PROCESS_MOVE: begin
          if (move_valid) begin
            game_board[move_row][move_column] <= current_player;
            last_move_row <= move_row;
            last_move_col <= move_column;
            random_start <= 0;
            $display("Placed %b at [%0d,%0d]", current_player, move_row, move_column);
          end else if (timer_expired && random_done) begin
            game_board[move_row][random_col] <= current_player;
            last_move_row <= move_row;
            last_move_col <= random_col;
            random_start <= 0;
            $display("Placed random %b at [%0d,%0d]", current_player, move_row, random_col);
          end else if (timer_expired) begin
            random_start <= 1;
          end
        end

        default: begin end
      endcase

      // Win detection registration
      if (current_state == CHECK_WIN) begin
        win_detected <= player_wins;
        if (player_wins) begin
          winner <= current_player;
        end
      end
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

    case (current_state)
      INIT: next_state = START_SCREEN;

      START_SCREEN: begin
        if (player1_start || player2_start) begin
          next_state = player1_start ? PLAYER1_TURN : PLAYER2_TURN;
          next_player = player1_start ? 2'b01 : 2'b10;
        end
      end

      PLAYER1_TURN: begin
        timer_enable = 1;
        if (player1_move != 0) begin
          next_move_column = player1_move;
          next_state = PROCESS_MOVE;
        end else if (timer_expired) begin
          next_state = PROCESS_MOVE;
        end
      end

      PLAYER2_TURN: begin
        timer_enable = 1;
        if (player2_move != 0) begin
          next_move_column = player2_move;
          next_state = PROCESS_MOVE;
        end else if (timer_expired) begin
          next_state = PROCESS_MOVE;
        end
      end

      PROCESS_MOVE: begin
        timer_reset = 1;
        if (validation_ready && (move_valid || (timer_expired && random_done))) begin
          next_state = CHECK_WIN;
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
                     (win_detected ? winner : 2'b00) :
                     (current_state == START_SCREEN) ? 2'b00 : 2'b01;
  
  // Debug assignments
  assign debug_win_signal = player_wins;
  assign debug_last_row = last_move_row;
  assign debug_last_col = last_move_col;
endmodule