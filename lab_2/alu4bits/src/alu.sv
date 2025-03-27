module alu(
    input logic [3:0] a,
    input logic [3:0] b,
    input logic [3:0] opcode,
    output logic [3:0] result,
    output logic is_negative
);
    always_comb begin
        is_negative = 1'b0;
        case(opcode)
            4'b0000: result = a + b;          // Addition
            4'b0001: begin                    // Subtraction
                if (a >= b) begin
                    result = a - b;
                end else begin
                    result = b - a;
                    is_negative = 1'b1;
                end
            end
            default: result = 4'b0;
        endcase
    end
endmodule