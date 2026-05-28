/*
================================================================================
  ADVANCED 8-BIT ALU (Arithmetic Logic Unit)
================================================================================
  Module Name: alu_advanced
  Description: Feature-rich 8-bit ALU supporting arithmetic, logic, shift, and
               rotation operations with comprehensive flag outputs and overflow
               detection. Suitable for microprocessor design and embedded systems.
  
  Author: Prottay Mazumder
  Date: May 2026
  
  Total Operations: 16
  
  Arithmetic Operations:
  - 0000: ADD (Addition with carry)
  - 0001: SUB (Subtraction with borrow)
  - 0010: INC (Increment A by 1)
  - 0011: DEC (Decrement A by 1)
  - 0100: MUL (Multiply A * B, lower 8 bits) [*Note: 16-bit internal]
  
  Logic Operations:
  - 0101: AND (Bitwise AND)
  - 0110: OR  (Bitwise OR)
  - 0111: XOR (Bitwise XOR)
  - 1000: NOT (Bitwise NOT)
  - 1001: NAND (Bitwise NAND)
  
  Shift Operations:
  - 1010: SHL (Shift Left Logical)
  - 1011: SHR (Shift Right Logical)
  - 1100: ROL (Rotate Left with Carry)
  - 1101: ROR (Rotate Right with Carry)
  
  Comparison/Special:
  - 1110: CMP (Compare A vs B, sets flags only)
  - 1111: ABS (Absolute value of A, treat as signed)
  
================================================================================
*/

module alu_advanced (
    // =====================================================================
    // INPUT PORTS
    // =====================================================================
    input  [7:0] A,              // First operand (8-bit)
    input  [7:0] B,              // Second operand (8-bit)
    input  [3:0] opcode,         // Operation code (16 operations)
    input  carry_in,             // Carry input for extended arithmetic
    
    // =====================================================================
    // OUTPUT PORTS
    // =====================================================================
    output reg [7:0] result,     // Primary 8-bit result
    output reg [7:0] result_high, // High byte for multiply operation
    
    // Status Flags (CPU-like flags register)
    output carry_flag,           // Carry flag (C) - arithmetic carry/borrow
    output zero_flag,            // Zero flag (Z) - result is zero
    output sign_flag,            // Sign flag (S) - result is negative (bit 7)
    output overflow_flag,        // Overflow flag (V) - signed overflow
    output parity_flag,          // Parity flag (P) - even/odd parity of result
    
    // Additional Output
    output equal_flag            // Equal flag (for comparison)
);

    // =====================================================================
    // INTERNAL SIGNALS
    // =====================================================================
    
    wire [8:0] add_result;       // 9-bit for ADD (captures carry)
    wire [8:0] sub_result;       // 9-bit for SUB (captures borrow)
    wire [7:0] inc_result;       // Increment result
    wire [7:0] dec_result;       // Decrement result
    wire [15:0] mul_result;      // 16-bit multiply result
    
    wire [7:0] and_result;       // AND result
    wire [7:0] or_result;        // OR result
    wire [7:0] xor_result;       // XOR result
    wire [7:0] not_result;       // NOT result
    wire [7:0] nand_result;      // NAND result
    
    wire [7:0] shl_result;       // Shift Left Logical
    wire [7:0] shr_result;       // Shift Right Logical
    wire [7:0] rol_result;       // Rotate Left with Carry
    wire [7:0] ror_result;       // Rotate Right with Carry
    
    wire [7:0] abs_result;       // Absolute value result
    
    reg [7:0] mux_result;        // Result before flag calculation
    wire carry_out_temp;         // Temporary carry signal
    wire overflow_temp;          // Temporary overflow signal
    
    // =====================================================================
    // ARITHMETIC OPERATIONS
    // =====================================================================
    
    // ADD: A + B + carry_in
    assign add_result = A + B + carry_in;
    
    // SUB: A - B - carry_in (subtraction with borrow)
    assign sub_result = A - B - carry_in;
    
    // INC: A + 1
    assign inc_result = A + 1;
    
    // DEC: A - 1
    assign dec_result = A - 1;
    
    // MUL: A * B (16-bit result, we take lower 8 bits as result, upper 8 as result_high)
    assign mul_result = A * B;

    // =====================================================================
    // LOGIC OPERATIONS
    // =====================================================================
    
    // AND: Bitwise AND
    assign and_result = A & B;
    
    // OR: Bitwise OR
    assign or_result = A | B;
    
    // XOR: Bitwise XOR
    assign xor_result = A ^ B;
    
    // NOT: Bitwise complement
    assign not_result = ~A;
    
    // NAND: NOT(AND)
    assign nand_result = ~(A & B);

    // =====================================================================
    // SHIFT OPERATIONS
    // =====================================================================
    
    // SHL: Shift Left Logical by 1 (LSB = 0, MSB goes to carry)
    assign shl_result = A << 1;
    
    // SHR: Shift Right Logical by 1 (MSB = 0, LSB goes to carry)
    assign shr_result = A >> 1;
    
    // ROL: Rotate Left with Carry (MSB wraps to LSB, passes through carry)
    //      Result: [A[6:0], carry_in]
    //      carry_out: A[7]
    assign rol_result = {A[6:0], carry_in};
    
    // ROR: Rotate Right with Carry (LSB wraps to MSB, passes through carry)
    //      Result: [carry_in, A[7:1]]
    //      carry_out: A[0]
    assign ror_result = {carry_in, A[7:1]};

    // =====================================================================
    // SPECIAL OPERATIONS
    // =====================================================================
    
    // ABS: Absolute Value (if A[7]=1, return -A, else return A)
    assign abs_result = A[7] ? (~A + 1) : A;  // Two's complement for negative

    // =====================================================================
    // MAIN OPERATION MULTIPLEXER (16 operations)
    // =====================================================================
    
    always @(*) begin
        case (opcode)
            4'b0000: begin
                mux_result = add_result[7:0];    // ADD
            end
            4'b0001: begin
                mux_result = sub_result[7:0];    // SUB
            end
            4'b0010: begin
                mux_result = inc_result;         // INC
            end
            4'b0011: begin
                mux_result = dec_result;         // DEC
            end
            4'b0100: begin
                mux_result = mul_result[7:0];    // MUL (lower 8 bits)
            end
            4'b0101: begin
                mux_result = and_result;         // AND
            end
            4'b0110: begin
                mux_result = or_result;          // OR
            end
            4'b0111: begin
                mux_result = xor_result;         // XOR
            end
            4'b1000: begin
                mux_result = not_result;         // NOT
            end
            4'b1001: begin
                mux_result = nand_result;        // NAND
            end
            4'b1010: begin
                mux_result = shl_result;         // SHL
            end
            4'b1011: begin
                mux_result = shr_result;         // SHR
            end
            4'b1100: begin
                mux_result = rol_result;         // ROL (Rotate Left)
            end
            4'b1101: begin
                mux_result = ror_result;         // ROR (Rotate Right)
            end
            4'b1110: begin
                mux_result = 8'b00000000;        // CMP (comparison, result not used)
            end
            4'b1111: begin
                mux_result = abs_result;         // ABS (Absolute value)
            end
            default: begin
                mux_result = 8'b00000000;
            end
        endcase
    end

    // Assign result
    always @(*) begin
        result = mux_result;
    end
    
    // For multiply, output high byte
    always @(*) begin
        if (opcode == 4'b0100)
            result_high = mul_result[15:8];
        else
            result_high = 8'b00000000;
    end

    // =====================================================================
    // CARRY FLAG LOGIC
    // =====================================================================
    
    assign carry_out_temp = 
        (opcode == 4'b0000) ? add_result[8] :                    // ADD carry
        (opcode == 4'b0001) ? sub_result[8] :                    // SUB borrow
        (opcode == 4'b0010) ? inc_result[7] :                    // INC overflow to bit 7
        (opcode == 4'b0011) ? (~dec_result[7]) :                 // DEC underflow
        (opcode == 4'b0100) ? (mul_result[15:8] != 8'b0) :       // MUL overflow
        (opcode == 4'b1010) ? A[7] :                             // SHL: MSB goes to carry
        (opcode == 4'b1011) ? A[0] :                             // SHR: LSB goes to carry
        (opcode == 4'b1100) ? A[7] :                             // ROL: MSB goes to carry
        (opcode == 4'b1101) ? A[0] :                             // ROR: LSB goes to carry
        1'b0;
    
    assign carry_flag = carry_out_temp;

    // =====================================================================
    // ZERO FLAG LOGIC
    // =====================================================================
    
    // Zero flag asserts when result is 0 (for CMP, compares A with B)
    assign zero_flag = (opcode == 4'b1110) ? (A == B) : (mux_result == 8'b00000000);

    // =====================================================================
    // SIGN FLAG LOGIC (MSB of result - indicates negative for signed numbers)
    // =====================================================================
    
    assign sign_flag = mux_result[7];

    // =====================================================================
    // OVERFLOW FLAG LOGIC (Signed arithmetic overflow)
    // =====================================================================
    
    assign overflow_temp = 
        (opcode == 4'b0000) ? ((A[7] == B[7]) && (A[7] != mux_result[7])) :  // ADD overflow
        (opcode == 4'b0001) ? ((A[7] != B[7]) && (A[7] != mux_result[7])) :  // SUB overflow
        (opcode == 4'b0010) ? (inc_result[7] != A[7]) :                      // INC overflow
        (opcode == 4'b0011) ? (dec_result[7] != A[7]) :                      // DEC overflow
        1'b0;
    
    assign overflow_flag = overflow_temp;

    // =====================================================================
    // PARITY FLAG LOGIC (Even parity of result)
    // =====================================================================
    
    // Parity is 1 if result has even number of 1's
    wire [7:0] parity_xor_1 = mux_result[7:0] ^ mux_result[6:0];
    wire [6:0] parity_xor_2 = parity_xor_1[6:0] ^ parity_xor_1[5:0];
    wire [5:0] parity_xor_3 = parity_xor_2[5:0] ^ parity_xor_2[4:0];
    wire [4:0] parity_xor_4 = parity_xor_3[4:0] ^ parity_xor_3[3:0];
    wire [3:0] parity_xor_5 = parity_xor_4[3:0] ^ parity_xor_4[2:0];
    wire [2:0] parity_xor_6 = parity_xor_5[2:0] ^ parity_xor_5[1:0];
    wire [1:0] parity_xor_7 = parity_xor_6[1:0] ^ parity_xor_6[0];
    
    assign parity_flag = ~parity_xor_7[0];  // Inverted XOR chain for even parity

    // =====================================================================
    // EQUAL FLAG LOGIC (for comparisons)
    // =====================================================================
    
    assign equal_flag = (A == B) ? 1'b1 : 1'b0;

endmodule

