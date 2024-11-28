module MM (
    input [254:0] x,
    input [254:0] y,

    output [254:0] result
);
//localparam R = `TWO_POW_255;
localparam q = `TWO_POW_255 - 255'd19;

reg signed [509:0] x_y; 
reg signed [254:0] minus_q_inv_mod_R;     // mod
reg signed [254:0] minus_x_y_q_inv_mod_R; // mod
reg signed [509:0] minus_x_y_q_inv_mod_R_q;  
reg signed [509:0] t_numerator;       

assign result = t_numerator >>> 255;

always @(*) begin
    x_y                     = x * y;                      // 510bits(1st multipier)
    minus_q_inv_mod_R       = -`q_inv;                    // 255bits
    minus_x_y_q_inv_mod_R   = x_y * minus_q_inv_mod_R;    // 255bits(2nd multipier)
    minus_x_y_q_inv_mod_R_q = minus_x_y_q_inv_mod_R * q;  // 510bits(3rd multipier)

    t_numerator             = x_y + minus_q_inv_mod_R;
end

endmodule