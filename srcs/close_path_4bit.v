module close_path_4bit (
    input wire [3:0] fraca_c,
    input wire [3:0] fracb_c,
    input wire [3:0] exp_large,
    input wire one_d,
    
    output wire [3:0] frac_ans_close,
    output wire [3:0] exp_ans_close
);

    wire [3:0] a, b_aligned;
    wire guard;
    wire [3:0] x, y;
    
    wire [4:0] w, wp1;
    wire cout, msb, lsb;
    
    wire [1:0] dlop;
    wire y_corr;
    
    wire [2:0] shift_amt;
    
    wire sel_nearest;
    wire [4:0] sum_raw;
    wire [3:0] rounded_val;
    
    wire bshin;
    wire [4:0] shift_in_reg;
    wire [4:0] shifted_res;
    
    wire need_extra_shift;
    wire result_is_zero;
    wire [3:0] final_frac;
    wire [3:0] final_exp;

    assign a = fraca_c;
    assign b_aligned = (one_d) ? {1'b0, fracb_c[3:1]} : fracb_c;
    assign guard     = (one_d) ? fracb_c[0] : 1'b0;

    assign x = a;
    assign y = ~b_aligned;

    compound_adder u_compound (
        .x(x), .y(y), .w(w), .wp1(wp1)
    );

    lop u_lop (
        .a(a), .b(b_aligned), 
        .d(dlop), .y(y_corr)
    );

    assign cout = w[4];
    assign lsb  = w[0]; 
    assign msb  = w[3];

    wire sel_pos = (~guard) | (guard & lsb);
    
    assign sel_nearest = cout ? sel_pos : 1'b0; 

    assign sum_raw = (sel_nearest) ? wp1 : w;

    assign rounded_val = (sum_raw[4]) ? sum_raw[3:0] : ~sum_raw[3:0];

    assign shift_amt = {1'b0, dlop} + {2'b00, y_corr};

    assign bshin = sum_raw[4] & guard; 
    
    assign shift_in_reg = {rounded_val, bshin};

    assign shifted_res = shift_in_reg << shift_amt;

    assign result_is_zero = (shifted_res == 5'b00000);

    assign need_extra_shift = ~shifted_res[4] & ~result_is_zero;

    assign final_frac = result_is_zero ? 4'b0000 : 
                        (need_extra_shift ? {shifted_res[3:0], 1'b0} : shifted_res[4:1]);

    assign final_exp = result_is_zero ? 4'b0000 : 
                       (exp_large - {1'b0, shift_amt} - {3'b000, need_extra_shift});

    assign frac_ans_close = final_frac;
    assign exp_ans_close  = final_exp;

endmodule