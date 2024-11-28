module Mul (
    input [254:0] x,
    input [254:0] y,
    output [254:0] result
);
wire [254:0] MM_x_y;
    MM MM1(.x(x), .y(y), .result(MM_x_y));
    MM MM2(.x(MM_x_y), .y(255'd361), .result(result));
endmodule