module IF_ID (
    input clk, rst,
    input hazard_stall,
    input MemStall,
    input flush,

    input [`InstBus]pc4_i,
    input [`InstBus]pc_i,
    input [`InstBus]inst_i,

    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pc_o,
    output logic [`InstBus]inst_o
);

	logic stall;  
	assign stall = hazard_stall | MemStall;

	logic [`InstBus] REG32[2], inst_reg;

   	always_comb begin
		pc_o = REG32[0];
		pc4_o = REG32[1];
		inst_o = inst_reg;
	end

	always_ff @(posedge clk or posedge rst) begin
		if(rst)        REG32[0] <= 32'd0;
		else if(stall) REG32[0] <= REG32[0];
		else if(flush) REG32[0] <= 32'd0; 
		else           REG32[0] <= pc_i;
	end
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst)        REG32[1] <= 32'd0;
		else if(stall) REG32[1] <= REG32[1];
		else if(flush) REG32[1] <= 32'd0; 
		else           REG32[1] <= pc4_i;
	end

	always_ff @(posedge clk or posedge rst) begin
		if(rst)        inst_reg <= 32'd0;
		else if(stall) inst_reg <= inst_reg;
		else if(flush) inst_reg <= 32'd0; 
		else           inst_reg <= inst_i;
	end

	

endmodule



