module register_file (
    input clk, rst,

    // read
    input [`RegAddrBus] raddr1_i,
    input [`RegAddrBus] raddr2_i,

    // write
    input RegWrite,
    input [`RegAddrBus] waddr_i,
    input [`RegBus] wdata_i,

    output logic [`RegBus] rdata1_o,
    output logic [`RegBus] rdata2_o
    
);
    //register_file size 32*32bit
    logic [`RegBus] RegFile[31:0];

    //x0 read only 0 
    parameter x0_Addr = 5'b00000;
    assign rdata1_o = (raddr1_i == x0_Addr) ? 32'd0 : (((raddr1_i == waddr_i) && (RegWrite == 1'b1)) ? wdata_i : RegFile[raddr1_i]);
    assign rdata2_o = (raddr2_i == x0_Addr) ? 32'd0 : (((raddr2_i == waddr_i) && (RegWrite == 1'b1)) ? wdata_i : RegFile[raddr2_i]);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            foreach(RegFile[i]) RegFile[i] <= 32'd0;
        end
        else if (RegWrite == 1'b1 && waddr_i != x0_Addr)
            RegFile[waddr_i] <= wdata_i;
        else 
            RegFile[waddr_i] <= RegFile[waddr_i];
    end    


endmodule
