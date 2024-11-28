module Adder (
    input [254:0] x,
    input [254:0] y,
    input add,
    output [254:0] result
);

localparam q = `TWO_POW_255 - 255'd19;

reg [255:0] opr_temp_result;

always @(*) begin
    if(add) begin //add
        opr_temp_result = x + y;
        if  (opr_temp_result < q) result = opr_temp_result;
        else result                      = opr_temp_result - q;
    end

    else begin //sub
        opr_temp_result = x - y;
        if  (x >= y) result  = opr_temp_result;
        else result          = opr_temp_result + q;
    end
end

endmodule