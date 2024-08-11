module alu (
    input [`RegBus] in1, in2,
    input [5:0]ALUop,

    output logic [`RegBus] result,
    output logic zero_flag
);

    // logic [64:0]mul_reg;

    wire signed [`RegBus] signed_in1, signed_in2;
    assign signed_in1 = in1;
    assign signed_in2 = in2;

    // alu result
    always_comb begin 
        unique case (ALUop)
            `ALU_ADD:    result = in1 + in2;
            `ALU_SUB:    result = in1 - in2;
            `ALU_SLL:    result = in1 << in2[4:0];
            `ALU_SLT:    result = (signed_in1 < signed_in2) ? 32'd1 : 32'd0;
            `ALU_SLTU:   result = (in1 < in2) ? 32'd1 : 32'd0;
            `ALU_XOR:    result = in1 ^ in2;
            `ALU_SRL:    result = in1 >> in2[4:0];
            `ALU_SRA:    result = signed_in1 >>> in2[4:0]; 
            `ALU_OR:     result = in1 | in2;
            `ALU_AND:    result = in1 & in2;
            // `ALU_MUL:    result = mul_reg[31:0];
            // `ALU_MULH:   result = mul_reg[63:32];
            // `ALU_MULHSU: result = mul_reg[63:32];
            // `ALU_MULHU:  result = mul_reg[63:32];
            default:     result = 32'd0;

        endcase
    end

    // // mul reg
    // always_comb begin
    //     unique case (ALUop)
    //         `ALU_MUL:    mul_reg = $signed(in1) * $signed(in2);
    //         `ALU_MULH:   mul_reg = $signed(in1) * $signed(in2);
    //         `ALU_MULHSU: mul_reg = $signed(in1) * $signed({1'b0, in2});
    //         `ALU_MULHU:  mul_reg = $unsigned(in1) * $unsigned(in2);
    //         default:     mul_reg = 65'd0;
    //     endcase
    // end

    // zero flag for branch Inst
    always_comb begin 
        unique case (ALUop)
            `ALU_BEQ:   zero_flag = (in1 == in2) ? 1'b1 : 1'b0;
            `ALU_BNE:   zero_flag = (in1 != in2) ? 1'b1 : 1'b0;
            `ALU_BLT:   zero_flag = (signed_in1 < signed_in2) ?  1'b1 : 1'b0;
            `ALU_BGE:   zero_flag = (signed_in1 >= signed_in2) ?  1'b1 : 1'b0;
            `ALU_BLTU:  zero_flag = (in1 < in2) ?  1'b1 : 1'b0;
            `ALU_BGEU:  zero_flag = (in1 >= in2) ?  1'b1 : 1'b0;
            default:    zero_flag = 1'b0;
        endcase
    end

endmodule
