module FP8_multiplier (
    input       clk, rst_n,
    input       start_mul,
    input [7:0] a,
    input [7:0] b,
    
    output reg       done_mul,
    output reg [7:0] product
);
    
    reg       sign_a, sign_b, sign_p;
    reg [3:0] exponent_a, exponent_b, exponent_p;
    reg [2:0] mantissa_a, mantissa_b, mantissa_p;
    
    reg special_flag;
    reg m_overflow_flag;
    reg e_overflow_flag;
    reg nan_flag, inf_flag, zer_flag;
    
    reg [4:0] sum_e;
    reg [3:0] mul_a, mul_b;
    reg [7:0] mul_product;
    reg [7:0] mul_product_temp;
    reg [4:0] sum_e_check;
    
    typedef enum logic [3:0] {
        idle,
        check_special,
        special_case,
        case_check,
        normal_case,
        add_e,
        mul_m,
        check_m_overflow,
        right_shift,
        check_e_overflow,
        sem_calculate, 
        normal_result,
        nan_result,
        inf_result,
        zer_result,
        done   
    } state_t;
    
    state_t current_state;
    state_t next_state;
    
    multiplier mul_module (
        .a(mul_a),
        .b(mul_b),
        .product(mul_product)
    );
    
    always @(posedge clk, negedge rst_n)
    begin 
        if(~rst_n)
            current_state <= idle;
        else
            current_state <= next_state;
    end
    
    always @*
    begin
        case (current_state)
            idle:
                if (start_mul)
                    next_state = check_special;
            check_special:
                if (special_flag)
                    next_state = special_case;
                else 
                    next_state = normal_case;
            special_case:
                    next_state = case_check;
            case_check:
                if (nan_flag)
                    next_state = nan_result;
                else if (inf_flag) 
                    next_state = inf_result;
                else if (zer_flag)
                    next_state = zer_result;
                else
                    next_state = nan_result;
            normal_case:
                    next_state = add_e;
            add_e:
                    next_state = mul_m;
            mul_m:
                    next_state = check_m_overflow;
            check_m_overflow:
                if (m_overflow_flag)
                    next_state = right_shift;
                else
                    next_state = sem_calculate;
            right_shift:
                    next_state = check_e_overflow;
            check_e_overflow:
                if (e_overflow_flag) 
                    next_state = inf_result;
                else 
                    next_state = sem_calculate;
            sem_calculate:
                    next_state = normal_result;
            normal_result:
                    next_state = done;
            nan_result:
                    next_state = done;
            inf_result:
                    next_state = done;
            zer_result:
                    next_state = done;
        endcase
    end
    
    always @*
    begin
        case (current_state)
            check_special:
                if (exponent_a == 4'b1111 || exponent_b == 4'b1111 ||
                    exponent_a == 4'b0000 || exponent_b == 4'b0000)
                    special_flag = 1;
                else
                    special_flag = 0;
            normal_case:
            begin
                sign_a = a[7];
                sign_b = b[7];
                exponent_a = a[6:3];
                exponent_b = b[6:3];
                mantissa_a = a[2:0];
                mantissa_b = b[2:0];
            end
            add_e:
                sum_e = exponent_a + exponent_b - 3'b111;
            mul_m:
            begin
                mul_a = {1'b1, mantissa_a};
                mul_b = {1'b1, mantissa_b};
            end
            check_m_overflow:
            begin
                m_overflow_flag = mul_product[7];
                sum_e_check = sum_e;
                mul_product_temp = mul_product;
            end
            right_shift:
            begin
                mul_product_temp = {1'b1, mul_product_temp[7:1]};
                sum_e_check = sum_e + 1;
            end
            check_e_overflow:
                e_overflow_flag = (sum_e_check > 14) ? 1 : 0;
            sem_calculate:
            begin
                sign_p = sign_a ^ sign_b;
                exponent_p = sum_e_check[3:0];
                mantissa_p = mul_product_temp[5:3];
            end
            normal_result:
                product = {sign_p, exponent_p, mantissa_p};
            nan_result:
                product = 8'bzzzzzzzz;
            inf_result:
                product = {sign_p, 7'b1111000};
            zer_result:
                product = {sign_p, 7'b0000000};
            done:
                done_mul = 1;
        endcase
    end
    
endmodule