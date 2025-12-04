module float_adder_8bit_top (
    input wire [7:0] opa, 
    input wire [7:0] opb, 
    output reg [7:0] add, 
    output reg overflow,
    output reg underflow,
    input wire clk,
);

    reg [7:0] opa_r, opb_r;
    always @(posedge clk) begin
        opa_r <= opa;
        opb_r <= opb;
    end

    wire sign_a = opa_r[7];
    wire sign_b = opb_r[7];
    wire [3:0] exp_a = opa_r[6:3];
    wire [3:0] exp_b = opb_r[6:3];
    wire [3:0] frac_a = { (|exp_a), opa_r[2:0] };
    wire [3:0] frac_b = { (|exp_b), opb_r[2:0] };

    wire swap;
    wire [3:0] d_raw;
    
    ediff_module u_ediff (
        .e1(exp_a), .e2(exp_b), 
        .sign(swap), .ab_diff(d_raw)
    );

    wire [3:0] exp_large = (swap) ? exp_b : exp_a;
    wire [3:0] fraca_c   = (swap) ? frac_b : frac_a; 
    wire [3:0] fracb_c   = (swap) ? frac_a : frac_b; 
    wire sign_large      = (swap) ? sign_b : sign_a;

    wire sub = sign_a ^ sign_b;
    wire is_close = sub & (d_raw <= 4'd1);

    wire [3:0] frac_far, frac_close;
    wire [3:0] exp_far, exp_close;

    far_path_4bit u_far (
        .fraca_c(fraca_c), .fracb_c(fracb_c), .exp_large(exp_large), 
        .d(d_raw), .sub(sub), 
        .frac_ans_far(frac_far), .exp_ans_far(exp_far)
    );

    close_path_4bit u_close (
        .fraca_c(fraca_c), .fracb_c(fracb_c), .exp_large(exp_large), 
        .one_d(d_raw[0]), 
        .frac_ans_close(frac_close), .exp_ans_close(exp_close)
    );

    wire [3:0] m_fin = (is_close) ? frac_close : frac_far;
    wire [3:0] e_fin = (is_close) ? exp_close  : exp_far;

    always @(posedge clk) begin
        add <= {sign_large, e_fin, m_fin[2:0]};
        overflow <= (e_fin == 4'b1111);
        underflow <= (e_fin == 0);
    end

endmodule