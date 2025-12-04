module FP8_MAC (
input  wire        clk,
input  wire        rst_n,
input  wire        start,
input  wire [7:0]  a,
input  wire [7:0]  b,
output reg         done,
output wire [7:0]  acc_out
);

reg [7:0] acc_reg;

assign acc_out = acc_reg;

wire        mul_done;
wire [7:0]  mul_product;

FP8_multiplier u_mul (
    .clk(clk),
    .rst_n(rst_n),
    .start_mul(start),
    .a(a),
    .b(b),
    .done_mul(mul_done),
    .product(mul_product)
);

wire [7:0] add_result;
wire       overflow, underflow;

float_adder_8bit_top u_add (
    .clk(clk),
//    .rst_n(rst_n),
    .opa(acc_reg),
    .opb(mul_product),
    .add(add_result),
    .overflow(overflow),
    .underflow(underflow)
);

localparam IDLE  = 2'd0,
           WAITM = 2'd1,
           UPDATE= 2'd2;

reg [1:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    next_state = state;
    case(state)
        IDLE:
            if (start) next_state = WAITM;

        WAITM:
            if (mul_done) next_state = UPDATE;

        UPDATE:
            next_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc_reg <= 8'b0;
        done <= 0;
    end else begin
        done <= 0;

        case(state)
            UPDATE: begin
                acc_reg <= add_result;
                done <= 1;
            end
        endcase
    end
end
endmodule