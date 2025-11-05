module FP8_multiplier_behavioral (
    input  [7:0] a,
    input  [7:0] b,
    
    output reg [7:0] product
);

    wire       sign_a, sign_b, sign_p;
    wire [3:0] exponent_a, exponent_b, exponent_p;
    wire [2:0] mantissa_a, mantissa_b, mantissa_p;
    
    wire [3:0] sum_e;
    wire [3:0] mul_a, mul_b;
    wire [7:0] mul_product;
    wire       comp;
    
    wire       is_a_nan, is_b_nan;
    wire       is_a_inf, is_b_inf;
    wire       is_a_zer, is_b_zer;
    wire       is_p_nan, is_p_inf, is_p_zer;
    
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
    
    assign is_a_nan = (exponent_a == 4'b1111) && (mantissa_a != 3'b000);
    assign is_b_nan = (exponent_b == 4'b1111) && (mantissa_b != 3'b000);
    
    assign is_a_inf = (exponent_a == 4'b1111) && (mantissa_a == 3'b000);
    assign is_b_inf = (exponent_b == 4'b1111) && (mantissa_b == 3'b000);
    
    assign is_a_zer = (exponent_a == 4'b0000);
    assign is_a_zer = (exponent_a == 4'b0000);
    
    assign is_p_nan = (is_a_nan || is_b_nan) 
                      || (is_a_inf && is_b_zer)
                      || (is_a_zer && is_b_inf);
    assign is_p_inf = is_a_inf || is_b_inf;
    assign is_p_zer = is_a_zer || is_b_zer;
    
    assign comp = (mul_product[7] == 1'b1) ? 1 : 0;
    
    assign sign_p = sign_a ^ sign_b;
    assign exponent_p = sum_e + 4'b1001 + comp;
    assign mantissa_p = (mul_product == 0) ? 3'b000 :
                        (mul_product[7] == 1'b1) ? mul_product[6:4] : mul_product[5:3];

    always @*
    begin
        if (is_p_nan) 
            product = 8'bzzzzzzzz;
        else if (is_p_inf)
            product = {sign_p, 7'b1111000};
        else if (is_p_zer)
            product = {sign_p, 7'b0000000};
        else 
            product = {sign_p, exponent_p, mantissa_p};
    end
    
endmodule