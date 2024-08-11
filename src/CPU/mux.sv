module mux_2to1(
	input [31:0]i1,i2,
	input sel,
	output logic [31:0]result
);
    assign result = (sel) ? i2 : i1;

endmodule

module mux_3to1(
	input [31:0]i1,
	input [31:0]i2,
	input [31:0]i3,
	input [1:0]sel,
	output logic [31:0]result
);
    always_comb begin
        unique case(sel)
            2'b00 : result = i1;
            2'b01 : result = i2;
            2'b10 : result = i3;
            default: result = 32'd0;
        endcase
    end
endmodule

module mux_5to1(
	input [31:0]i1,
	input [31:0]i2,
	input [31:0]i3,
	input [31:0]i4,
	input [31:0]i5,
	input [2:0]sel,
	output logic [31:0]result
);
	always_comb begin
		unique case(sel)
			3'd0 : result = i1;
			3'd1 : result = i2;
			3'd2 : result = i3;
			3'd3 : result = i4;
			3'd4 : result = i5;
			default : result = 32'd0;
		endcase
	end
endmodule

module mux_3to1_csr(
    input [31:0]i1,  //EX
	input [31:0]i2,  //MEM
	input [31:0]i3,  //WB
	input [1:0] sel,
    input [11:0] CSR_imm,
	output logic [31:0]result
);
    // csr imm
    parameter MSTATUS = 12'h300; 
    parameter MIE     = 12'h304;
    parameter MTVEC   = 12'h305;
    parameter MEPC    = 12'h341;
    parameter MIP     = 12'h344;

    always_comb begin
        unique case (sel)
            2'd0 : begin
                result = i1;
            end
            2'd1 : begin
                unique case (CSR_imm)
                    MSTATUS : result = {19'd0,i2[12:11],3'd0,i2[7],3'd0,i2[3],3'd0};
                    MIE     : result = {20'd0,i2[11],11'd0};
                    MTVEC   : result = 32'h0001_0000;
                    MEPC    : result = i2;
                    MIP     : result = i1;//{20'd0,i2[11],3'd0,i2[7],7'd0};//?
                    default : result = 32'd0;
                endcase
            end
            2'd2 : begin
                unique case (CSR_imm)
                    MSTATUS : result = {19'd0,i3[12:11],3'd0,i3[7],3'd0,i3[3],3'd0};
                    MIE     : result = {20'd0,i3[11],11'd0};
                    MTVEC   : result = 32'h0001_0000;
                    MEPC    : result = i3;
                    MIP     : result = i1; //{20'd0,i3[11],3'd0,i3[7],7'd0};//?
                    default : result = 32'd0;
                endcase
            end
            default: result = 32'd0;
        endcase
    end
    
endmodule
