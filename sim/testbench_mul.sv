`timescale 1ns / 1ps

//======================================================================
// Testbench cho FP8_multiplier (Tu?n t? / FSM)
//======================================================================
module testbench_mul;

    // --- 1. Tham s? và Tín hi?u ---
    
    // ??nh ngh?a chu k? clock (10ns = 100MHz)
    localparam CLK_PERIOD = 10;

    // Tín hi?u (reg) ?? lái (drive) các ??u vào c?a DUT
    reg         clk;
    reg         rst_n;
    reg         start_mul;
    reg  [7:0]  a_tb;
    reg  [7:0]  b_tb;

    // Tín hi?u (wire) ?? b?t (capture) các ??u ra c?a DUT
    wire        done_mul;
    wire [7:0]  product;

    // --- 2. Kh?i t?o Module (DUT) ---
    // (DUT = Device Under Test)
    FP8_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_mul(start_mul),
        .a(a_tb),
        .b(b_tb),
        .done_mul(done_mul),
        .product(product)
    );

    // --- 3. T?o Xung nh?p (Clock Generator) ---
    // Luôn luôn ch?y, t?o xung nh?p 100MHz
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // --- 4. Tác v? (Task) Test - Giúp code s?ch h?n ---
    // Tác v? này t? ??ng hóa quy trình "start -> wait -> check"
    task run_test;
        input [7:0] test_a;
        input [7:0] test_b;
        input [7:0] expected_product;

        begin
            // 1. ??t ??u vào
            a_tb = test_a;
            b_tb = test_b;
            
            // 2. G?i tín hi?u 'start' trong 1 chu k?
            start_mul = 1'b1;
            @(posedge clk); // Ch? 1 xung nh?p
            start_mul = 1'b0;
            
            // 3. CH? cho ??n khi DUT báo 'done'
            //    (N?u DUT b? k?t, simulation s? treo ? ?ây - ?ây là 1 cách debug)
            @(posedge done_mul);
            
            // 4. ??c k?t qu? và so sánh
            $display("---------------------------------");
            $display("Input A:    %b", test_a);
            $display("Input B:    %b", test_b);
            $display("Expected:   %b", expected_product);
            $display("Got:        %b", product);
            
            if (product === expected_product) begin
                $display("Result:     PASS");
            end else begin
                $display("Result:     FAIL");
            end
            
            // Ch? 1 chút tr??c khi b?t ??u test ti?p theo
            @(posedge clk);
        end
    endtask

    // --- 5. Lu?ng Test chính (Test Sequence) ---
    initial begin
        // 1. Kh?i t?o và Reset
        $display("--- B?t ??u Testbench ---");
        rst_n = 1'b0;     // Kích ho?t Reset (active-low)
        start_mul = 1'b0;
        a_tb = 8'd0;
        b_tb = 8'd0;
        
        // Gi? Reset trong 2 chu k?
        #(CLK_PERIOD * 2); 
        rst_n = 1'b1;     // Nh? Reset
        @(posedge clk);
        $display("--- H? th?ng ?ã Reset ---");

        // --- B?t ??u ch?y các ca ki?m th? ---

        // Ca 1: 6.0 * 3.5 = 20.0 (Dùng logic ?ã s?a l?i)
        // A = 0_1001_100, B = 0_1000_110, Expected = 0_1011_010 (20.0)
//        run_test(8'b01001100, 8'b01000110, 8'b01011010);

        // Ca 2: -2.0 * 3.5 = -7.0
        // A = 1_1000_000, B = 0_1000_110, Expected = 1_1001_110 (-7.0)
        run_test(8'b11000000, 8'b01000110, 8'b11001110);
        
        // Ca 3: -2.0 * -3.5 = 7.0
        // A = 1_1000_000, B = 1_1000_110, Expected = 0_1001_110 (7.0)
        run_test(8'b11000000, 8'b11000110, 8'b01001110);

        // Ca 4: 0.0 * 3.5 = 0.0 (X? lý tr??ng h?p ??c bi?t Zero)
        // A = 0_0000_000, B = 0_1000_110, Expected = 0_0000_000 (0.0)
        run_test(8'b00000000, 8'b01000110, 8'b00000000);
        
        // Ca 5: 3.5 * 0.0 = 0.0 (X? lý tr??ng h?p ??c bi?t Zero)
        // A = 0_1000_110, B = 0_0000_000, Expected = 0_0000_000 (0.0)
        run_test(8'b01000110, 8'b00000000, 8'b00000000);

        // --- K?t thúc ---
        $display("---------------------------------");
        $display("--- Testbench Hoàn thành ---");
        $finish;
    end

endmodule