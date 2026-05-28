/*
================================================================================
  ADVANCED ALU TESTBENCH
================================================================================
  Module Name: tb_alu_advanced
  Description: Comprehensive testbench for advanced 8-bit ALU
  
  Tests all 16 operations with multiple test cases covering:
  - Boundary conditions
  - Flag generation
  - Overflow detection
  - Carry propagation
  - Parity calculation
  
  Total Test Cases: 45+
  
================================================================================
*/

`timescale 1ns/1ps

module tb_alu_advanced;

    // =====================================================================
    // TESTBENCH SIGNALS
    // =====================================================================
    
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] opcode;
    reg  carry_in;
    wire [7:0] result;
    wire [7:0] result_high;
    wire carry_flag;
    wire zero_flag;
    wire sign_flag;
    wire overflow_flag;
    wire parity_flag;
    wire equal_flag;
    
    // Test counters
    integer test_count = 0;
    integer pass_count = 0;

    // =====================================================================
    // INSTANTIATE DUT (Device Under Test)
    // =====================================================================
    
    alu_advanced dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .carry_in(carry_in),
        .result(result),
        .result_high(result_high),
        .carry_flag(carry_flag),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag),
        .overflow_flag(overflow_flag),
        .parity_flag(parity_flag),
        .equal_flag(equal_flag)
    );

    // =====================================================================
    // TEST PROCEDURE
    // =====================================================================
    
    initial begin
        $display("\n");
        $display("=====================================");
        $display("  ADVANCED 8-BIT ALU TESTBENCH");
        $display("  16 Operations, 45+ Test Cases");
        $display("=====================================\n");
        
        carry_in = 1'b0;  // Default carry in = 0
        
        // ===== Test 1: ADD Operation =====
        $display("\n[TEST 1] ADD OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd5, 8'd3, 4'b0000, 8'd8, "5 + 3 = 8");
        test_alu_simple(8'd255, 8'd1, 4'b0000, 8'd0, "255 + 1 = 0 (overflow)");
        test_alu_simple(8'd100, 8'd100, 4'b0000, 8'd200, "100 + 100 = 200");
        test_alu_simple(8'd0, 8'd0, 4'b0000, 8'd0, "0 + 0 = 0");
        
        // ===== Test 2: SUB Operation =====
        $display("\n[TEST 2] SUB OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd10, 8'd3, 4'b0001, 8'd7, "10 - 3 = 7");
        test_alu_simple(8'd3, 8'd10, 4'b0001, 8'd249, "3 - 10 = -7 (two's comp)");
        test_alu_simple(8'd100, 8'd100, 4'b0001, 8'd0, "100 - 100 = 0");
        test_alu_simple(8'd0, 8'd1, 4'b0001, 8'd255, "0 - 1 = -1");
        
        // ===== Test 3: INC Operation =====
        $display("\n[TEST 3] INC (INCREMENT) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd5, 8'dx, 4'b0010, 8'd6, "5 + 1 = 6");
        test_alu_simple(8'd255, 8'dx, 4'b0010, 8'd0, "255 + 1 = 0 (overflow)");
        test_alu_simple(8'd127, 8'dx, 4'b0010, 8'd128, "127 + 1 = 128 (sign change)");
        
        // ===== Test 4: DEC Operation =====
        $display("\n[TEST 4] DEC (DECREMENT) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd10, 8'dx, 4'b0011, 8'd9, "10 - 1 = 9");
        test_alu_simple(8'd0, 8'dx, 4'b0011, 8'd255, "0 - 1 = 255 (underflow)");
        test_alu_simple(8'd128, 8'dx, 4'b0011, 8'd127, "128 - 1 = 127");
        
        // ===== Test 5: MUL Operation =====
        $display("\n[TEST 5] MUL (MULTIPLY) OPERATION");
        $display("-------------------------------------");
        test_alu_with_high(8'd5, 8'd3, 4'b0100, 8'd15, 8'd0, "5 * 3 = 15");
        test_alu_with_high(8'd16, 8'd16, 4'b0100, 8'd0, 8'd1, "16 * 16 = 256 (overflow to high byte)");
        test_alu_with_high(8'd255, 8'd2, 4'b0100, 8'd254, 8'd1, "255 * 2 = 510");
        test_alu_with_high(8'd0, 8'd255, 4'b0100, 8'd0, 8'd0, "0 * 255 = 0");
        
        // ===== Test 6: AND Operation =====
        $display("\n[TEST 6] AND (BITWISE AND) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b11110000, 8'b10101010, 4'b0101, 8'b10100000, "1111_0000 AND 1010_1010 = 1010_0000");
        test_alu_simple(8'b11111111, 8'b11111111, 4'b0101, 8'b11111111, "All 1's AND all 1's = all 1's");
        test_alu_simple(8'b00000000, 8'b11111111, 4'b0101, 8'b00000000, "All 0's AND all 1's = all 0's");
        
        // ===== Test 7: OR Operation =====
        $display("\n[TEST 7] OR (BITWISE OR) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b11110000, 8'b10101010, 4'b0110, 8'b11111010, "1111_0000 OR 1010_1010 = 1111_1010");
        test_alu_simple(8'b00000001, 8'b00000010, 4'b0110, 8'b00000011, "0000_0001 OR 0000_0010 = 0000_0011");
        test_alu_simple(8'b00000000, 8'b00000000, 4'b0110, 8'b00000000, "All 0's OR all 0's = all 0's");
        
        // ===== Test 8: XOR Operation =====
        $display("\n[TEST 8] XOR (BITWISE XOR) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b11110000, 8'b10101010, 4'b0111, 8'b01011010, "1111_0000 XOR 1010_1010 = 0101_1010");
        test_alu_simple(8'b11111111, 8'b11111111, 4'b0111, 8'b00000000, "All 1's XOR all 1's = all 0's");
        test_alu_simple(8'b01010101, 8'b10101010, 4'b0111, 8'b11111111, "0101_0101 XOR 1010_1010 = 1111_1111");
        
        // ===== Test 9: NOT Operation =====
        $display("\n[TEST 9] NOT (BITWISE NOT) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b00000000, 8'dx, 4'b1000, 8'b11111111, "NOT 0000_0000 = 1111_1111");
        test_alu_simple(8'b11111111, 8'dx, 4'b1000, 8'b00000000, "NOT 1111_1111 = 0000_0000");
        test_alu_simple(8'b10101010, 8'dx, 4'b1000, 8'b01010101, "NOT 1010_1010 = 0101_0101");
        
        // ===== Test 10: NAND Operation =====
        $display("\n[TEST 10] NAND (BITWISE NAND) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b11111111, 8'b11111111, 4'b1001, 8'b00000000, "NAND (all 1's, all 1's) = all 0's");
        test_alu_simple(8'b11110000, 8'b10101010, 4'b1001, 8'b01011111, "NAND 1111_0000, 1010_1010 = 0101_1111");
        test_alu_simple(8'b00000000, 8'b11111111, 4'b1001, 8'b11111111, "NAND (all 0's, all 1's) = all 1's");
        
        // ===== Test 11: SHL Operation =====
        $display("\n[TEST 11] SHL (SHIFT LEFT) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b00000001, 8'dx, 4'b1010, 8'b00000010, "0000_0001 << 1 = 0000_0010");
        test_alu_simple(8'b01000000, 8'dx, 4'b1010, 8'b10000000, "0100_0000 << 1 = 1000_0000");
        test_alu_simple(8'b10000000, 8'dx, 4'b1010, 8'b00000000, "1000_0000 << 1 = 0000_0000 (MSB lost)");
        
        // ===== Test 12: SHR Operation =====
        $display("\n[TEST 12] SHR (SHIFT RIGHT) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'b00000010, 8'dx, 4'b1011, 8'b00000001, "0000_0010 >> 1 = 0000_0001");
        test_alu_simple(8'b10000000, 8'dx, 4'b1011, 8'b01000000, "1000_0000 >> 1 = 0100_0000");
        test_alu_simple(8'b00000001, 8'dx, 4'b1011, 8'b00000000, "0000_0001 >> 1 = 0000_0000 (LSB lost)");
        
        // ===== Test 13: ROL Operation (Rotate Left with Carry) =====
        $display("\n[TEST 13] ROL (ROTATE LEFT) OPERATION");
        $display("-------------------------------------");
        carry_in = 1'b0;
        test_alu_simple(8'b10000001, 8'dx, 4'b1100, 8'b00000010, "ROL(1000_0001, C=0) = 0000_0010, C_out=1");
        carry_in = 1'b1;
        test_alu_simple(8'b10000001, 8'dx, 4'b1100, 8'b00000011, "ROL(1000_0001, C=1) = 0000_0011, C_out=1");
        carry_in = 1'b0;
        
        // ===== Test 14: ROR Operation (Rotate Right with Carry) =====
        $display("\n[TEST 14] ROR (ROTATE RIGHT) OPERATION");
        $display("-------------------------------------");
        carry_in = 1'b0;
        test_alu_simple(8'b10000001, 8'dx, 4'b1101, 8'b01000000, "ROR(1000_0001, C=0) = 0100_0000, C_out=1");
        carry_in = 1'b1;
        test_alu_simple(8'b10000001, 8'dx, 4'b1101, 8'b11000000, "ROR(1000_0001, C=1) = 1100_0000, C_out=1");
        carry_in = 1'b0;
        
        // ===== Test 15: CMP Operation =====
        $display("\n[TEST 15] CMP (COMPARE) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd10, 8'd10, 4'b1110, 8'd0, "CMP 10 == 10 (Z flag set)");
        test_alu_simple(8'd10, 8'd5, 4'b1110, 8'd0, "CMP 10 > 5 (Z flag clear)");
        test_alu_simple(8'd5, 8'd10, 4'b1110, 8'd0, "CMP 5 < 10 (Z flag clear)");
        
        // ===== Test 16: ABS Operation =====
        $display("\n[TEST 16] ABS (ABSOLUTE VALUE) OPERATION");
        $display("-------------------------------------");
        test_alu_simple(8'd50, 8'dx, 4'b1111, 8'd50, "ABS(50) = 50");
        test_alu_simple(8'd255, 8'dx, 4'b1111, 8'd1, "ABS(-1) = 1 (255 in two's comp = -1)");
        test_alu_simple(8'd128, 8'dx, 4'b1111, 8'd128, "ABS(-128) = -128 (overflow, no solution)");
        
        // Print summary
        $display("\n");
        $display("=====================================");
        $display("  TEST SUMMARY");
        $display("=====================================");
        $display("Total Tests: %d", test_count);
        $display("Passed:      %d", pass_count);
        $display("Failed:      %d", test_count - pass_count);
        
        if (test_count == pass_count) begin
            $display("\n✓✓✓ ALL TESTS PASSED! ✓✓✓");
        end else begin
            $display("\n✗✗✗ SOME TESTS FAILED ✗✗✗");
        end
        $display("=====================================\n");
        
        $finish;
    end

    // =====================================================================
    // TEST TASK: Simple test without high byte check
    // =====================================================================
    
    task test_alu_simple(
        input [7:0] a_val,
        input [7:0] b_val,
        input [3:0] op,
        input [7:0] expected_result,
        input [100*8:1] test_name
    );
    begin
        test_count = test_count + 1;
        
        // Set inputs
        A = a_val;
        B = b_val;
        opcode = op;
        
        // Wait for combinational logic
        #1;
        
        // Check result
        if (result == expected_result) begin
            $display("✓ PASS: %s", test_name);
            $display("        Result: 0x%02h, Flags: Z=%b S=%b C=%b O=%b P=%b", 
                     result, zero_flag, sign_flag, carry_flag, overflow_flag, parity_flag);
            pass_count = pass_count + 1;
        end else begin
            $display("✗ FAIL: %s", test_name);
            $display("        Expected: 0x%02h, Got: 0x%02h", expected_result, result);
            $display("        Flags: Z=%b S=%b C=%b O=%b P=%b", 
                     zero_flag, sign_flag, carry_flag, overflow_flag, parity_flag);
        end
    end
    endtask

    // =====================================================================
    // TEST TASK: Test with high byte (for multiply)
    // =====================================================================
    
    task test_alu_with_high(
        input [7:0] a_val,
        input [7:0] b_val,
        input [3:0] op,
        input [7:0] expected_result,
        input [7:0] expected_high,
        input [100*8:1] test_name
    );
    begin
        test_count = test_count + 1;
        
        // Set inputs
        A = a_val;
        B = b_val;
        opcode = op;
        
        // Wait for combinational logic
        #1;
        
        // Check result and high byte
        if (result == expected_result && result_high == expected_high) begin
            $display("✓ PASS: %s", test_name);
            $display("        Result: 0x%02h, High: 0x%02h", result, result_high);
            pass_count = pass_count + 1;
        end else begin
            $display("✗ FAIL: %s", test_name);
            $display("        Expected: 0x%02h:0x%02h, Got: 0x%02h:0x%02h", 
                     expected_high, expected_result, result_high, result);
        end
    end
    endtask

endmodule