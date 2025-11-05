//======================================================================
// Testbench cho FP8_multiplier (E4M3)
//======================================================================
`timescale 1ns / 1ps

module testbench_mul_behavioral;

    // --- Tín hi?u (Signals) ---
    reg  [7:0] a_tb;       // ??u vào A
    reg  [7:0] b_tb;       // ??u vào B
    wire [7:0] product_tb; // ??u ra (Product)

    // Th?i gian tr? gi?a các ca ki?m th?
    localparam T = 10;
    
    // --- Kh?i t?o DUT (Instantiate DUT) ---
    // (DUT = Device Under Test)
    FP8_multiplier_behavioral dut (
        .a(a_tb),
        .b(b_tb),
        .product(product_tb)
    );

    // --- Lu?ng Test (Test Flow) ---
    initial begin
        $display("-------------------------------------------------");
        $display("B?t ??u Testbench cho FP8_multiplier_behavioral (E4M3)...");
        $display("??nh d?ng: S-EEEE-MMM (Bias = 7)");
        $display("-------------------------------------------------");

        // B?t ??u dump waveform (tùy ch?n)
        $dumpfile("tb_FP8_multiplier_behavioral.vcd");
        $dumpvars(0, testbench_mul_behavioral);

        // Kh?i t?o
        a_tb = 8'b0;
        b_tb = 8'b0;
        #T;

        // --- CÁC CA KI?M TH? ---

        // Ca 1: 6.0 * 3.5
        // A = 6.0 = 0_1001_100 (S=0, E=9 (raw=2), M=100)
        // B = 3.5 = 0_1000_110 (S=0, E=8 (raw=1), M=110)
        // K?t qu? toán h?c mong ??i = 21.0.
        // Do làm tròn/c?t b?t trong E4M3, k?t qu? g?n nh?t là 20.0
        // 20.0 = 10100.0_2 = 1.010_2 * 2^4
        // Mong ??i: S=0, E=4+7=11 (1011), M=010 -> 0_1011_010
        $display("\n[Test 1] 6.0 * 3.5 = 20.0 (Mong ??i 01011010)");
        run_test(8'b01001100, 8'b01000110);

        // Ca 2: Phép nhân v?i 0
        // A = 0.0 = 0_0000_000
        // B = 3.5 = 0_1000_110
        // Mong ??i: 0.0 -> 0_0000_000
        $display("\n[Test 2] 0.0 * 3.5 = 0.0 (Mong ??i 00000000)");
        run_test(8'b00000000, 8'b01000110);

        // Ca 3: D??ng * Âm
        // A = 2.0 = 0_1000_000 (S=0, E=8 (raw=1), M=000)
        // B = -3.5 = 1_1000_110 (S=1, E=8 (raw=1), M=110)
        // K?t qu? mong ??i = -7.0
        // -7.0 = -111.0_2 = -1.110_2 * 2^2
        // Mong ??i: S=1, E=2+7=9 (1001), M=110 -> 1_1001_110
        $display("\n[Test 3] 2.0 * -3.5 = -7.0 (Mong ??i 11001110)");
        run_test(8'b01000000, 8'b11000110);
        
        // Ca 4: Âm * Âm
        // A = -2.0 = 1_1000_000
        // B = -3.5 = 1_1000_110
        // K?t qu? mong ??i = 7.0
        // 7.0 = 111.0_2 = 1.110_2 * 2^2
        // Mong ??i: S=0, E=2+7=9 (1001), M=110 -> 0_1001_110
        $display("\n[Test 4] -2.0 * -3.5 = 7.0 (Mong ??i 01001110)");
        run_test(8'b11000000, 8'b11000110);

        // Ca 5: Phép nhân c?n Chu?n hóa (Normalization)
        // A = 1.5 = 0_0111_100 (S=0, E=7 (raw=0), M=100 -> 1.100)
        // B = 1.5 = 0_0111_100
        // Tích Mantissa: 1.100 * 1.100 = 10.0100 -> C?n d?ch ph?i & t?ng E
        // K?t qu? = 2.25 = 10.01_2 = 1.001_2 * 2^1
        // Mong ??i: S=0, E=1+7=8 (1000), M=001 -> 0_1000_001
        $display("\n[Test 5] 1.5 * 1.5 = 2.25 (Mong ??i 01000001)");
        run_test(8'b00111100, 8'b00111100);

        // Ca 6: Phép nhân KHÔNG c?n Chu?n hóa
        // A = 1.0 = 0_0111_000
        // B = 1.5 = 0_0111_100
        // Tích Mantissa: 1.000 * 1.100 = 1.100000 -> KHÔNG c?n d?ch
        // K?t qu? = 1.5 = 1.1_2 = 1.100_2 * 2^0
        // Mong ??i: S=0, E=0+7=7 (0111), M=100 -> 0_0111_100
        $display("\n[Test 6] 1.0 * 1.5 = 1.5 (Mong ??i 00111100)");
        run_test(8'b00111000, 8'b00111100);
        
        $display("\n-------------------------------------------------");
        $display("Testbench Hoàn thành.");
        $display("-------------------------------------------------");
        $finish;
    end

    // --- Tác v? (Task) tr? giúp ?? ch?y test ---
    task run_test(input [7:0] test_a, input [7:0] test_b);
    begin
        // 1. Áp d?ng tín hi?u ??u vào
        a_tb = test_a;
        b_tb = test_b;

        // 2. Ch? ?? tr? t? h?p (combinational delay)
        #T;

        // 3. Hi?n th? k?t qu?
        $display("   Inputs:  A=%b, B=%b", a_tb, b_tb);
        $display("   Output:  Product=%b", product_tb);
    end
    endtask

endmodule