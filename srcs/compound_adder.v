module compound_adder (
    input wire [3:0] x,
    input wire [3:0] y,
    output wire [4:0] w,    
    output wire [4:0] wp1   
);
 
    assign w   = {1'b0, x} + {1'b0, y};
    assign wp1 = {1'b0, x} + {1'b0, y} + 1'b1;

endmodule