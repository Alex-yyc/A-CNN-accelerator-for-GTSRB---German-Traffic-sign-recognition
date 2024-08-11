module m_alu (
    input [`RegBus] in1, in2,
    input [5:0]ALUop,

    output logic [`RegBus] result
);

    logic [64:0]mul_reg;
    wire signed [`RegBus] signed_in1, signed_in2;
    assign signed_in1 = in1;
    assign signed_in2 = in2;

    // alu result
    always_comb begin 
        unique case (ALUop)
            `ALU_MUL:    result = mul_reg[31:0];
            `ALU_MULH:   result = mul_reg[63:32];
            `ALU_MULHSU: result = mul_reg[63:32];
            `ALU_MULHU:  result = mul_reg[63:32];
            default:     result = 32'd0;

        endcase
    end

    // mul reg
    always_comb begin
        unique case (ALUop)
            `ALU_MUL:    mul_reg = signed_in1 * signed_in2;
            `ALU_MULH:   mul_reg = signed_in1 * signed_in2;
            `ALU_MULHSU: mul_reg = signed_in1 * $signed({1'b0, signed_in2});
            `ALU_MULHU:  mul_reg = in1 * in2;
            default:     mul_reg = 65'd0;
        endcase
    end

    
endmodule
