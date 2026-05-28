/*
  Module: alu_advanced
  Description: 8-bit ALU supporting arithmetic, logic, shift, rotate, and comparison operations.

  Author: Prottay Mazumder
*/

module alu_advanced (

    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] opcode,
    input  carry_in,

    output reg [7:0] result,
    output reg [7:0] result_high,

    output carry_flag,
    output zero_flag,
    output sign_flag,
    output overflow_flag,
    output parity_flag,
    output equal_flag
);

    wire [8:0] add_result;
    wire [8:0] sub_result;
    wire [7:0] inc_result;
    wire [7:0] dec_result;
    wire [15:0] mul_result;

    wire [7:0] and_result;
    wire [7:0] or_result;
    wire [7:0] xor_result;
    wire [7:0] not_result;
    wire [7:0] nand_result;

    wire [7:0] shl_result;
    wire [7:0] shr_result;
    wire [7:0] rol_result;
    wire [7:0] ror_result;

    wire [7:0] abs_result;

    reg [7:0] mux_result;
    wire carry_out_temp;
    wire overflow_temp;

    // Arithmetic
    assign add_result = A + B + carry_in;
    assign sub_result = A - B - carry_in;
    assign inc_result = A + 1;
    assign dec_result = A - 1;
    assign mul_result = A * B;

    // Logic
    assign and_result  = A & B;
    assign or_result   = A | B;
    assign xor_result  = A ^ B;
    assign not_result  = ~A;
    assign nand_result = ~(A & B);

    // Shift / Rotate
    assign shl_result = A << 1;
    assign shr_result = A >> 1;
    assign rol_result = {A[6:0], carry_in};
    assign ror_result = {carry_in, A[7:1]};

    // Special
    assign abs_result = A[7] ? (~A + 1) : A;

    always @(*) begin
        case (opcode)
            4'b0000: mux_result = add_result[7:0];
            4'b0001: mux_result = sub_result[7:0];
            4'b0010: mux_result = inc_result;
            4'b0011: mux_result = dec_result;
            4'b0100: mux_result = mul_result[7:0];
            4'b0101: mux_result = and_result;
            4'b0110: mux_result = or_result;
            4'b0111: mux_result = xor_result;
            4'b1000: mux_result = not_result;
            4'b1001: mux_result = nand_result;
            4'b1010: mux_result = shl_result;
            4'b1011: mux_result = shr_result;
            4'b1100: mux_result = rol_result;
            4'b1101: mux_result = ror_result;
            4'b1110: mux_result = 8'b00000000;
            4'b1111: mux_result = abs_result;
            default: mux_result = 8'b00000000;
        endcase
    end

    always @(*) begin
        result = mux_result;
    end

    always @(*) begin
        if (opcode == 4'b0100)
            result_high = mul_result[15:8];
        else
            result_high = 8'b00000000;
    end

    // Flags
    assign carry_out_temp =
        (opcode == 4'b0000) ? add_result[8] :
        (opcode == 4'b0001) ? sub_result[8] :
        (opcode == 4'b0010) ? inc_result[7] :
        (opcode == 4'b0011) ? (~dec_result[7]) :
        (opcode == 4'b0100) ? (mul_result[15:8] != 8'b0) :
        (opcode == 4'b1010) ? A[7] :
        (opcode == 4'b1011) ? A[0] :
        (opcode == 4'b1100) ? A[7] :
        (opcode == 4'b1101) ? A[0] :
        1'b0;

    assign carry_flag = carry_out_temp;

    assign zero_flag =
        (opcode == 4'b1110) ? (A == B) :
        (mux_result == 8'b00000000);

    assign sign_flag = mux_result[7];

    assign overflow_temp =
        (opcode == 4'b0000) ? ((A[7] == B[7]) && (A[7] != mux_result[7])) :
        (opcode == 4'b0001) ? ((A[7] != B[7]) && (A[7] != mux_result[7])) :
        (opcode == 4'b0010) ? (inc_result[7] != A[7]) :
        (opcode == 4'b0011) ? (dec_result[7] != A[7]) :
        1'b0;

    assign overflow_flag = overflow_temp;

    wire [7:0] parity_xor_1 = mux_result[7:0] ^ mux_result[6:0];
    wire [6:0] parity_xor_2 = parity_xor_1[6:0] ^ parity_xor_1[5:0];
    wire [5:0] parity_xor_3 = parity_xor_2[5:0] ^ parity_xor_2[4:0];
    wire [4:0] parity_xor_4 = parity_xor_3[4:0] ^ parity_xor_3[3:0];
    wire [3:0] parity_xor_5 = parity_xor_4[3:0] ^ parity_xor_4[2:0];
    wire [2:0] parity_xor_6 = parity_xor_5[2:0] ^ parity_xor_5[1:0];
    wire [1:0] parity_xor_7 = parity_xor_6[1:0] ^ parity_xor_6[0];

    assign parity_flag = ~parity_xor_7[0];

    assign equal_flag = (A == B);

endmodule
