module alu(
    input logic [3:0] a,
    input logic [3:0] b,
    input logic [1:0] opcode,
    output logic [3:0] result,
    output logic is_negative,
    output logic overflow,
    output logic div_by_zero
);
    logic [7:0] temp;
    
    always_comb begin
        // Default outputs
        result = 4'b0;
        is_negative = 1'b0;
        overflow = 1'b0;
        div_by_zero = 1'b0;
        temp = 8'b0;
        
        case(opcode)
            2'b00: {overflow, result} = a + b;  // Addition
            
            2'b01: begin  // Subtraction
                if (a >= b) begin
                    result = a - b;
                end else begin
                    result = b - a;
                    is_negative = 1'b1;
                end
            end
            
            2'b10: begin  // Multiplication
                temp = a * b;
                result = temp[3:0];
                overflow = |temp[7:4];
            end
            
            2'b11: begin  // Division
                if (b == 0) begin
                    div_by_zero = 1'b1;
                end else begin
                    result = a / b;
                end
            end
        endcase
    end
endmodule