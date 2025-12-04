module multiplier (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);
    wire [7:0] p0, p1, p2, p3;
    wire [7:0] pp0, pp1;
    
    assign p0 = (b[0]) ? {4'b0, a} : 8'b0;
    assign p1 = (b[1]) ? ({4'b0, a} << 1) : 8'b0;
    assign p2 = (b[2]) ? ({4'b0, a} << 2) : 8'b0;
    assign p3 = (b[3]) ? ({4'b0, a} << 3) : 8'b0;
    
    assign pp0 = p0 + p1;
    assign pp1 = p2 + p3;
    
    assign product = pp0 + pp1;
endmodule