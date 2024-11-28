module Add_Sub (
    input [254:0] x,
    input [254:0] y,
    input add,
    output reg [254:0] result
);


// reg [254:0] opr_temp_result;

// always @(*) begin
//     if(add) begin //add
//         opr_temp_result = x + y;
//         if  (opr_temp_result < `q) result = opr_temp_result;
//         else result                      = opr_temp_result - `q;
//     end

//     else begin //sub
//         opr_temp_result = x - y;
//         if  (x >= y) result  = opr_temp_result;
//         else result          = opr_temp_result + `q;
//     end
// end

// // simplified adder
reg [254:0] yq;
reg [254:0] yy;
always @(*) begin
    yq = y - `q;

    if (add) begin
        yy = (x < -yq) ? y: yq;
    end else begin
        yy = (x >= y) ? -y: -yq;
    end

    result = x + yy;
end

endmodule