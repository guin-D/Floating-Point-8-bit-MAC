module multiplier (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    wire [7:0] p0, p1, p2, p3;
    wire [7:0] pp0, pp1;
    
    assign p0 = {4'b0, a} & {8{b[0]}};
    assign p1 = ({4'b0, a} & {8{b[1]}}) << 1;
    assign p2 = ({4'b0, a} & {8{b[2]}}) << 2;
    assign p3 = ({4'b0, a} & {8{b[3]}}) << 3;
    
    assign pp0 = p0 + p1;
    assign pp1 = p2 + p3;
    
    assign product = pp0 + pp1;
endmodule