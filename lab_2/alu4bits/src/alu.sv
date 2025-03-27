module alu(
    input logic [3:0] a,
    input logic [3:0] b,
    input logic [3:0] opcode,
    output logic [3:0] result,
    output logic overflow
);
    always_comb begin
        overflow = 1'b0;
        case(opcode)
            4'b0000: {overflow, result} = a + b;       // Addition
            4'b0001: result = a - b;                   // Subtraction
            4'b0010: {overflow, result} = a * b;       // Multiplication
            4'b0011: result = a & b;                   // AND
            4'b0100: result = a | b;                   // OR
            4'b0101: result = a ^ b;                   // XOR
            default: result = 4'b0000;
        endcase
    end
endmodule