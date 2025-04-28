module place_random_move (
  input logic clk,
  input logic rst,
  input logic start,
  input logic [5:0][6:0] board_in,  // Tablero 6x7
  output logic [2:0] random_col,    // Columna aleatoria válida
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

  // Variables temporales
  logic [6:0] valid_columns; // Bitmask de columnas válidas

  // Determinar columnas válidas (con espacio disponible)
  always_comb begin
    valid_columns = 7'b0;
    for (int col = 0; col < 7; col++) begin
      if (board_in[0][col] == 0) begin // Si la fila superior está vacía
        valid_columns[col] = 1'b1;
      end
    end
  end

  // Lógica de estado
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

  // Lógica de transición de estados
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
          next_state = FIND_VALID; // Sigue buscando
        end
      end
      
      FINISH: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule
