module ed25519 (
    input i_clk,
    input i_rst,
    
    input i_in_valid,
    input [63:0] i_in_data,

    input i_out_ready,

    output o_out_valid,
    output [63:0] o_out_data,

    output o_in_ready
);
///////////////////////////////////////////////////////////////////////////////////////////////////
// Local Parameter & Declaration & Assignment /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//== Localparam =================================
localparam IDLE = 3'd0;
localparam INPUT = 3'd1;
localparam PROCCESS = 3'd2;
localparam OUTPUT = 3'd3;
localparam FINISH = 3'd4;

//== Declare ====================================
integer i;

reg [2:0] state_cur;
reg [2:0] state_next;

reg [3:0] counter_16;
reg counter_16_c;
reg counter_16_zero_c;
reg M_c;
reg x_p_c;
reg y_p_c;

reg o_in_ready_w;
reg o_in_ready_r;
reg o_out_valid_w;
reg o_out_valid_r;
reg [63:0] o_out_data_w;
reg [63:0] o_out_data_r;

reg [63:0] M_r[0:3];
reg [63:0] x_p_r[0:3];
reg [63:0] y_p_r[0:3];

wire [255:0] M;
wire [255:0] x_p;
wire [255:0] y_p;



//== Assign =====================================
assign o_in_ready  = o_in_ready_r;
assign o_out_valid = o_out_valid_r;

assign o_out_data  = o_out_data_r;

assign M = {M_r[0], M_r[1], M_r[2], M_r[3]};
assign x_p = {x_p_r[0], x_p_r[1], x_p_r[2], x_p_r[3]};
assign y_p = {y_p_r[0], y_p_r[1], y_p_r[2], y_p_r[3]};



///////////////////////////////////////////////////////////////////////////////////////////////////
// Control Unit(FSM) //////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//== NL =========================================
always @(*) begin
    state_next = 0;
    case (state_cur)
        IDLE: state_next = INPUT;
        INPUT: begin
            state_next = INPUT;
            if(counter_16 == 11) state_next = PROCCESS;
        end
        PROCCESS: state_next = OUTPUT;
        OUTPUT: begin
            state_next = OUTPUT;
            if(counter_16 == 7) state_next = FINISH;
        end
    endcase
end

//== OL =========================================
always @(*) begin
    counter_16_c      = 0;
    counter_16_zero_c = 0;
    o_in_ready_w      = 1;

    M_c   = 0;
    x_p_c = 0;
    y_p_c = 0;

    case (state_cur)
        INPUT: begin
            if(i_in_valid) counter_16_c = 1;

            if(counter_16 < 4) M_c = 1;
            else if(counter_16 < 8) x_p_c = 1;
            else if(counter_16 < 12) y_p_c = 1;
        end
        PROCCESS: begin
            counter_16_zero_c = 1;
        end
        OUTPUT: begin
            if(i_out_ready) counter_16_c = 1;
        end
    endcase
end

//== SL =========================================
always @(posedge i_clk) begin
    if  (i_rst) state_cur <= 0;
    else state_cur        <= state_next;
end

//== Counter ====================================
always @(posedge i_clk) begin
    if  (i_rst) counter_16 <= 0;
    else if(counter_16_c == 1) begin
        counter_16 <= counter_16 + 1;
    end
    else if(counter_16_zero_c == 1) begin // down to zero
        counter_16 <= 0;
    end
end


//== Control signal without FSM =================
always @(*) begin
    
end

///////////////////////////////////////////////////////////////////////////////////////////////////
// Combinational Circuit //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
always @(*) begin

end

wire [255:0] mul_test;
Mul test(.x(x_p), .y(y_p), .result(mul_test));

///////////////////////////////////////////////////////////////////////////////////////////////////
// Sequential Circuit /////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk) begin
    if(i_rst) begin
        o_in_ready_r  <= 0;
        o_out_valid_r <= 0;

        o_out_data_r  <= 0;

        for(i=0; i<4; i=i+1) begin
            M_r[i] <= 0;
            x_p_r[i] <= 0;
            y_p_r[i] <= 0;
        end
    end
    else begin
        o_in_ready_r <= o_in_ready_w;
        o_out_valid_r <= o_out_valid_w;

        o_out_data_r <= o_out_data_w;

        if(M_c) M_r[counter_16[1:0]] <= i_in_data;
        if(x_p_c) x_p_r[counter_16[1:0]] <= i_in_data;
        if(y_p_c) y_p_r[counter_16[1:0]] <= i_in_data;
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////
endmodule