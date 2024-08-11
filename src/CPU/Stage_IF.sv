`include "CPU/program_counter.sv"

module Stage_IF (
    input clk, rst,

    input hazard_stall,
    input MemStall,
    input flush,

    input [`InstBus]pc_new, 
    
    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pc_o, 
    output logic [`InstAddrBus]inst_addr_o  //to IM

);

    logic [`InstBus] pc_wire, pc_reg;

    program_counter pc(.clk(clk), .rst(rst), .flush(flush), .MemStall(MemStall), .hazard_stall(hazard_stall), .pc_new(pc_new), .pc_next(pc_wire));
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) pc_reg <= 32'd0;
	    else if (hazard_stall || MemStall) pc_reg <= pc_reg;
        else if (flush) pc_reg <= 32'd0;
        else pc_reg <= pc_wire;
    end
	
    assign inst_addr_o = pc_reg;
    assign pc_o  = pc_reg;
    assign pc4_o = pc_reg + 32'd4;

endmodule
