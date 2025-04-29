module place_random_move (
  input logic clk,
  input logic rst,
  input logic start,
  input logic [1:0] board_in[5:0][6:0] ,  // Tablero 6x7 con 2 bits por celda
  output logic [2:0] random_col,        // Columna aleatoria válida
  output logic done
);

  // LFSR para generar números pseudoaleatorios de 7 bits (0-6)
  logic [6:0] lfsr;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      lfsr <= 7'b0000001;
    end else begin
      lfsr <= {lfsr[5:0], lfsr[6] ^ lfsr[5]};
    end
  end

  // Estados
  typedef enum logic [1:0] {IDLE, FIND_VALID, FINISH} state_t;
  state_t current_state, next_state;

  // Bitmask de columnas válidas
  logic [6:0] valid_columns;

  // Determinar columnas válidas (casilla superior vacía)
  always_comb begin
    valid_columns = 7'b0;
    for (int col = 0; col < 7; col++) begin
      if (board_in[0][col] == 2'b00) begin
        valid_columns[col] = 1'b1;
      end
    end
  end

  // Máquina de estados
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state <= IDLE;
      random_col <= 0;
      done <= 0;
    end else begin
      current_state <= next_state;

      case (current_state)
        FIND_VALID: begin
          if (valid_columns[lfsr[2:0]]) begin
            random_col <= lfsr[2:0];
            done <= 1'b1;
          end
        end

        FINISH: begin
          done <= 1'b0;
        end
      endcase
    end
  end

  // Transiciones de estados
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (start) next_state = FIND_VALID;
      end

      FIND_VALID: begin
        if (valid_columns[lfsr[2:0]]) begin
          next_state = FINISH;
        end else begin
          next_state = FIND_VALID;
        end
      end

      FINISH: next_state = IDLE;
    endcase
  end

endmodule
