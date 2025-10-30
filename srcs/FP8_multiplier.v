module FP8_multiplier (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] product
);

    wire       sign_a, sign_b, sign_p;
    wire [3:0] exponent_a, exponent_b, exponent_p;
    wire [2:0] mantissa_a, mantissa_b, mantissa_p;
    
    wire [3:0] sum_e;
    wire [3:0] mul_a, mul_b;
    wire [7:0] mul_product;
    wire       comp;
    
    assign sign_a = a[7];
    assign sign_b = b[7];
    assign exponent_a = a[6:3];
    assign exponent_b = b[6:3];
    assign mantissa_a = a[2:0];
    assign mantissa_b = b[2:0];
    
    assign sum_e = exponent_a + exponent_b;
    
    assign mul_a = {1'b1, mantissa_a};
    assign mul_b = {1'b1, mantissa_b};
    
    multiplier mul_module (
        .a(mul_a),
        .b(mul_b),
        .product(mul_product)
    );
    
    assign comp = (mul_product[7] == 1'b1) ? 1 : 0;
    
    assign sign_p = sign_a ^ sign_b;
    assign exponent_p = sum_e + 4'b1001 + comp;
    assign mantissa_p = (mul_product == 0) ? 0 :
                        (mul_product[7] == 1'b1) ? mul_product[6:4] : mul_product[5:3];

    assign product = {sign_p, exponent_p, mantissa_p};
    
endmodule