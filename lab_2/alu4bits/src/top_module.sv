module top_module(
    input logic CLOCK_50,
    input logic [9:0] SW,
    input logic [2:0] KEY,    // KEY[0]=mode, KEY[1]=calculate, KEY[2]=AC
    output logic [6:0] HEX3,  // Operand A
    output logic [6:0] HEX2,  // Operand B
    output logic [6:0] HEX1,  // Negative sign
    output logic [6:0] HEX0,  // Result magnitude
    output logic [9:0] LEDR
);
    // Internal registers
    logic [3:0] operand_a = 4'b0;
    logic [3:0] operand_b = 4'b0;
    logic [3:0] operation = 4'b0;
    logic [3:0] result_mag = 4'b0;
    logic result_valid = 0;
    logic mode = 0;
    logic is_negative = 0;
    
    // Debounced keys
    logic key0_pressed, key1_pressed, key2_pressed;
    debounce db_key0(CLOCK_50, ~KEY[0], key0_pressed);
    debounce db_key1(CLOCK_50, ~KEY[1], key1_pressed);
    debounce db_key2(CLOCK_50, ~KEY[2], key2_pressed);
    
    // Control logic
    always_ff @(posedge CLOCK_50) begin
        // All Clear (highest priority)
        if (key2_pressed) begin
            operand_a <= 4'b0;
            operand_b <= 4'b0;
            operation <= 4'b0;
            result_mag <= 4'b0;
            result_valid <= 0;
            mode <= 0;
            is_negative <= 0;
        end
        else begin
            // Mode toggle
            if (key0_pressed) begin
                mode <= ~mode;
                result_valid <= 0;
            end
            
            // Number input
            if (~mode) begin
                operand_a <= SW[7:4];
                operand_b <= SW[3:0];
            end 
            // Operation selection
            else begin
                operation <= SW[3:0];
            end
            
            // Calculation
            if (key1_pressed && mode) begin
                case(operation)
                    4'b0000: begin  // Addition
                        result_mag <= operand_a + operand_b;
                        is_negative <= 0;
                    end
                    4'b0001: begin  // Subtraction
                        if (operand_a >= operand_b) begin
                            result_mag <= operand_a - operand_b;
                            is_negative <= 0;
                        end else begin
                            result_mag <= operand_b - operand_a;
                            is_negative <= 1;
                        end
                    end
                    default: begin
                        result_mag <= 4'b0;
                        is_negative <= 0;
                    end
                endcase
                result_valid <= 1;
            end
        end
    end
    
    // LED indicators
    assign LEDR[9] = mode;
    assign LEDR[4] = is_negative & result_valid;
    assign LEDR[3:0] = operation;
    
    // Operand displays
    bin_to_bcd_decoder disp_a(
        .bin_number(operand_a),
        .bcd_number(HEX3)
    );
    
    bin_to_bcd_decoder disp_b(
        .bin_number(operand_b),
        .bcd_number(HEX2)
    );
    
    // Negative sign (only when result is negative and valid)
    assign HEX1 = (is_negative & result_valid) ? 7'b0111111 : 7'b1111111;
    
    // Result display (blank when no valid result)
    bin_to_bcd_decoder disp_res(
        .bin_number(result_valid ? result_mag : 4'b1111),
        .bcd_number(HEX0)
    );
endmodule