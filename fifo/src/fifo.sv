// ********************************************
// 
//  参数化的单输入单输出fifo
//  fifo full时无法写入,数据丢失
// 
// ********************************************

module fifo 
#(
    parameter DEPTH,
    parameter WIDTH
) (
    input                       clk,
    input                       reset,

    input                       in_vld_i,
    input [WIDTH-1:0]           in_data_i,

    input                       read_i,

    output                      out_vld_o,
    output [WIDTH-1:0]          out_data_o,

    output                      full_o,
    output                      empty_o,

    input endend
);
    
    reg  [WIDTH-1:0]            mem[DEPTH-1:0];

    reg  [$clog2(DEPTH):0]      rd_ptr;
    reg  [$clog2(DEPTH):0]      wr_ptr;

    wire [$clog2(DEPTH)-1:0]    rd_index;
    wire [$clog2(DEPTH)-1:0]    wr_index;

    wire [$clog2(DEPTH):0]      nxt_rd_ptr;
    wire [$clog2(DEPTH):0]      nxt_wr_ptr;


    // 读写指针变化
    assign nxt_rd_ptr[$clog2(DEPTH)]     = (rd_ptr[$clog2(DEPTH)-1:0] == (DEPTH - 1)) ? ~rd_ptr[$clog2(DEPTH)]
                                                                                      :  rd_ptr[$clog2(DEPTH)];

    assign nxt_rd_ptr[$clog2(DEPTH)-1:0] = (rd_ptr[$clog2(DEPTH)-1:0] == (DEPTH - 1)) ? 0
                                                                                      : rd_ptr[$clog2(DEPTH)-1:0] +1; 

    assign nxt_wr_ptr[$clog2(DEPTH)]     = (wr_ptr[$clog2(DEPTH)-1:0] == (DEPTH - 1)) ? ~wr_ptr[$clog2(DEPTH)]
                                                                                      :  wr_ptr[$clog2(DEPTH)];

    assign nxt_wr_ptr[$clog2(DEPTH)-1:0] = (wr_ptr[$clog2(DEPTH)-1:0] == (DEPTH - 1)) ? 0
                                                                                      : wr_ptr[$clog2(DEPTH)-1:0] +1; 

    always @(posedge clk) begin
        if(reset)begin
            rd_ptr <= 'd0;
            wr_ptr <= 'd0;
        end
        else begin
            
            if(in_vld_i & ~full_o)begin
                wr_ptr <=  nxt_wr_ptr;
            end
            else begin
                wr_ptr <=  wr_ptr;
            end
            
            if(out_vld_o)begin
                rd_ptr <= nxt_rd_ptr;
            end
            else begin
                rd_ptr <= rd_ptr;
            end
        end
    end


    // 数据写入
    always @(posedge clk) begin
        if (reset) begin
            mem[0] <= 'd0;
        end
        else 
        if(in_vld_i & ~full_o)begin
            mem[wr_index] <= in_data_i;
        end
    end


    assign empty_o      =  rd_ptr == wr_ptr;
    assign full_o       =  (rd_ptr[$clog2(DEPTH)-1:0] == wr_ptr[$clog2(DEPTH)-1:0]) 
                        && (rd_ptr[$clog2(DEPTH)] != wr_ptr[$clog2(DEPTH)]);

    assign wr_index     = wr_ptr[$clog2(DEPTH)-1:0];
    assign rd_index     = rd_ptr[$clog2(DEPTH)-1:0];

    assign out_vld_o    =  read_i & ~empty_o;
    assign out_data_o   =  mem[rd_index];


endmodule
