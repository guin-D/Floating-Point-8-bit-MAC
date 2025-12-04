`timescale 1ns/1ps

module tb_fp8_mac();

reg         clk;
reg         rst_n;
reg         start;
reg  [7:0]  a;
reg  [7:0]  b;

wire        done;
wire [7:0]  acc_out;

FP8_MAC DUT (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .a(a),
    .b(b),
    .done(done),
    .acc_out(acc_out)
);

always #5 clk = ~clk;

task do_mac;
    input [7:0] _a;
    input [7:0] _b;
begin
    @(posedge clk);
    a     = _a;
    b     = _b;
    start = 1;

    @(posedge clk);
    start = 0;

    wait(done);        
    @(posedge clk);     

    $display("MAC: a=%b b=%b  -> ACC=%b", _a, _b, acc_out);
end
endtask

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_fp8_mac);

    clk   = 0;
    rst_n = 0;
    start = 0;
    a     = 0;
    b     = 0;


    repeat(3) @(posedge clk);
    rst_n = 1;

    // ================================
    // TEST 1: acc = acc_o + FP8_mul(1.0 * 2.0) 
    // (acc_o = 0; acc = 2.0)
    // ================================
    // Sign | Exp | Man
    //  0   | 0111 | 000  ==> 1.0
    //  0   | 1000 | 000  ==> 2.0
    do_mac(8'b0_0111_000, 8'b0_1000_000);

    // ================================
    // TEST 2: acc = acc_o + FP8_mul(3.0 * 0.5) 
    // (acc_o = 2.0; acc = 3.5)
    // ================================
    //  0 | 1000 | 100
    //  0 | 0110 | 000
    do_mac(8'b0_1000_100, 8'b0_0110_000);

    // ================================
    // TEST 3: acc = acc_o + FP8_mul(4.0 * 4.0) 
    // (acc_o = 3.5; acc = 20.0)
    // ================================
    //  0 | 1001 | 000
    do_mac(8'b0_1001_000, 8'b0_1001_000);

    $display("\nFinal ACC = %b", acc_out);
    $finish;
end

endmodule
