module FP8_multiplier (
    input        clk, 
    input        rst_n,
    input        start_mul,
    input [7:0]  a,
    input [7:0]  b,
    
    output reg        done_mul,
    output reg [7:0]  product
);
    
    localparam [3:0]
        IDLE             = 4'd0,
        CHECK_SPECIAL    = 4'd1,
        CALC             = 4'd2,
        NORMALIZE        = 4'd3,
        PACK_RESULT      = 4'd4,
        DONE             = 4'd5;
    
    reg [3:0] current_state, next_state;

    reg [7:0] a_reg, b_reg;
    reg [4:0] sum_e;
    reg [7:0] mul_product_reg;
    reg       sign_p;
    
    reg       is_special_case;

    wire sign_a = a_reg[7];
    wire sign_b = b_reg[7];
    wire [3:0] exp_a = a_reg[6:3];
    wire [3:0] exp_b = b_reg[6:3];
    wire [2:0] man_a = a_reg[2:0];
    wire [2:0] man_b = b_reg[2:0];

    wire is_a_zero = (exp_a == 0);
    wire is_b_zero = (exp_b == 0);
    wire is_a_inf  = (exp_a == 15) && (man_a == 0);
    wire is_b_inf  = (exp_b == 15) && (man_b == 0);
    wire is_a_nan  = (exp_a == 15) && (man_a != 0);
    wire is_b_nan  = (exp_b == 15) && (man_b != 0);
    
    wire is_special = is_a_nan | is_b_nan | is_a_inf | is_b_inf | is_a_zero | is_b_zero;

    wire [3:0] mul_op_a = {1'b1, man_a};
    wire [3:0] mul_op_b = {1'b1, man_b};
    wire [7:0] mul_res_wire;
    
    multiplier u_mul (
        .a(mul_op_a), .b(mul_op_b), .product(mul_res_wire)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            done_mul <= 1'b0;
            product <= 8'b0;
            a_reg <= 8'b0;
            b_reg <= 8'b0;
            sum_e <= 5'b0;
            mul_product_reg <= 8'b0;
            sign_p <= 1'b0;
            is_special_case <= 1'b0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                IDLE: begin
                    done_mul <= 1'b0;
                    is_special_case <= 1'b0;
                    if (start_mul) begin
                        a_reg <= a;
                        b_reg <= b;
                    end
                end
                
                CHECK_SPECIAL: begin
                    sign_p <= sign_a ^ sign_b;
                    
                    if (is_special) begin
                        is_special_case <= 1'b1;
                        
                        if (is_a_nan || is_b_nan) 
                            product <= 8'b1_1111_111;
                        else if (is_a_inf || is_b_inf) begin
                            if (is_a_zero || is_b_zero) 
                                product <= 8'b1_1111_111;
                            else 
                                product <= {sign_a ^ sign_b, 4'b1111, 3'b000};
                        end else if (is_a_zero || is_b_zero) begin
                            product <= {sign_a ^ sign_b, 4'b0000, 3'b000};
                        end
                    end
                end
                
                CALC: begin
                    sum_e <= {1'b0, exp_a} + {1'b0, exp_b} - 5'd7;
                    mul_product_reg <= mul_res_wire;
                end
                
                NORMALIZE: begin
                    if (mul_product_reg[7] == 1'b1) begin
                        sum_e <= sum_e + 5'd1;
                        mul_product_reg <= mul_product_reg >> 1;
                    end
                end
                
                PACK_RESULT: begin
                    if (sum_e >= 5'd15) begin
                        product <= {sign_p, 4'b1111, 3'b000};
                    end else if (sum_e[4] == 1'b1 || sum_e == 5'd0) begin
                        product <= {sign_p, 4'b0000, 3'b000};
                    end else begin
                        product <= {sign_p, sum_e[3:0], mul_product_reg[5:3]};
                    end
                end
                
                DONE: begin
                    done_mul <= 1'b1;
                end
                
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (start_mul) 
                    next_state = CHECK_SPECIAL;
            end
            
            CHECK_SPECIAL: begin
                if (is_special) 
                    next_state = DONE;
                else            
                    next_state = CALC;
            end
            
            CALC:        next_state = NORMALIZE;
            NORMALIZE:   next_state = PACK_RESULT;
            PACK_RESULT: next_state = DONE;
            
            DONE: begin
                if (!start_mul) 
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule