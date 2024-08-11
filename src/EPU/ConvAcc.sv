`include "EPU/Conv_3x3_nonpadding.sv"
`include "EPU/Fully.sv"
`include "EPU/Max_pool_nonpadding.sv"
`include "EPU/Conv_bus_switcher.sv"
`include "Interface/sp_ram_intf.sv"

module ConvAcc (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [ 3:0] mode,
    input  logic [31:0] w8,
    output logic        finish,

    sp_ram_intf.compute param_intf,
    sp_ram_intf.compute bias_intf,
    sp_ram_intf.compute weight_intf,
    sp_ram_intf.compute input_intf,
    sp_ram_intf.compute output_intf
);

    // // For 3x3 conv unit
    // sp_ram_intf param_conv_3x3_intf ();
    // sp_ram_intf bias_conv_3x3_intf ();
    // sp_ram_intf weight_conv_3x3_intf ();
    // sp_ram_intf input_conv_3x3_intf ();
    // sp_ram_intf output_conv_3x3_intf ();
    // logic finish_conv_3x3, start_conv_3x3;
    // logic gated_conv_3x3_clk;

    // // For 1x1 conv unit
    // sp_ram_intf param_conv_1x1_intf ();
    // sp_ram_intf bias_conv_1x1_intf ();
    // sp_ram_intf weight_conv_1x1_intf ();
    // sp_ram_intf input_conv_1x1_intf ();
    // sp_ram_intf output_conv_1x1_intf ();
    // logic finish_conv_1x1, start_conv_1x1;
    // logic gated_conv_1x1_clk;

    // // For max pooling unit  
    // sp_ram_intf param_maxpool_intf ();
    // sp_ram_intf bias_maxpool_intf ();
    // sp_ram_intf weight_maxpool_intf ();
    // sp_ram_intf input_maxpool_intf ();
    // sp_ram_intf output_maxpool_intf ();
    // logic finish_maxpool, start_maxpool;
    // logic gated_maxpool_clk;

    // For 3x3 conv unit
    sp_ram_intf param_conv_intf ();
    sp_ram_intf bias_conv_intf ();
    sp_ram_intf weight_conv_intf ();
    sp_ram_intf input_conv_intf ();
    sp_ram_intf output_conv_intf ();
    logic finish_conv, start_conv;
    logic gated_conv_clk;

    // For max pooling unit  
    sp_ram_intf param_maxpool_intf ();
    sp_ram_intf bias_maxpool_intf ();
    sp_ram_intf weight_maxpool_intf ();
    sp_ram_intf input_maxpool_intf ();
    sp_ram_intf output_maxpool_intf ();
    logic finish_maxpool, start_maxpool;
    logic gated_maxpool_clk;

    // For fc unit  
    sp_ram_intf param_fc_intf ();
    sp_ram_intf bias_fc_intf ();
    sp_ram_intf weight_fc_intf ();
    sp_ram_intf input_fc_intf ();
    sp_ram_intf output_fc_intf ();
    logic finish_fc, start_fc;
    logic gated_fc_clk;


    Conv_bus_switcher i_Conv_bus_switcher (
        .mode(mode),
        // External
        .clk(clk),
        .param_o(param_intf),
        .bias_o(bias_intf),
        .weight_o(weight_intf),
        .input_o(input_intf),
        .output_o(output_intf),
        // For 3x3 conv unit
        .gated_conv_3x3_clk(gated_conv_clk),
        .param_conv_3x3_i(param_conv_intf),
        .bias_conv_3x3_i(bias_conv_intf),
        .weight_conv_3x3_i(weight_conv_intf),
        .input_conv_3x3_i(input_conv_intf),
        .output_conv_3x3_i(output_conv_intf),

        // // For 1x1 conv unit
        // .gated_conv_1x1_clk(gated_conv_1x1_clk),
        // .param_conv_1x1_i(param_conv_1x1_intf),
        // .bias_conv_1x1_i(bias_conv_1x1_intf),
        // .weight_conv_1x1_i(weight_conv_1x1_intf),
        // .input_conv_1x1_i(input_conv_1x1_intf),
        // .output_conv_1x1_i(output_conv_1x1_intf),

        // For max pooling unit
        .gated_maxpool_clk(gated_maxpool_clk),
        .param_maxpool_i(param_maxpool_intf),
        .bias_maxpool_i(bias_maxpool_intf),
        .weight_maxpool_i(weight_maxpool_intf),
        .input_maxpool_i(input_maxpool_intf),
        .output_maxpool_i(output_maxpool_intf),

        // For fc unit
        .gated_fc_clk(gated_fc_clk),
        .param_fc_i(param_fc_intf),
        .bias_fc_i(bias_fc_intf),
        .weight_fc_i(weight_fc_intf),
        .input_fc_i(input_fc_intf),
        .output_fc_i(output_fc_intf)
    );

    // start
    // assign start_conv_1x1 = mode[`CONV_1x1_MODE] & start;
    assign start_conv = mode[`CONV_3x3_MODE] & start;
    assign start_maxpool  = mode[`MAX_POOL_MODE] & start;
    assign start_fc  = mode[`FC_MODE] & start;

    // finish
    always_comb begin
        unique case (1'b1)
        mode[`CONV_3x3_MODE]: finish = finish_conv;
        mode[`MAX_POOL_MODE]: finish = finish_maxpool;
        mode[`FC_MODE]: finish = finish_fc;
        mode[`IDLE_MODE]:     finish = 1'b0;
        endcase
    end

    // Conv_1x1 i_Conv_1x1 (
    //     .rstn(~rst),
    //     .clk(clk),  // gated_conv_1x1_clk
    //     .w8(w8),
    //     .start(start_conv_1x1),
    //     .finish(finish_conv_1x1),
    //     .param_intf(param_conv_1x1_intf),
    //     .bias_intf(bias_conv_1x1_intf),
    //     .weight_intf(weight_conv_1x1_intf),
    //     .input_intf(input_conv_1x1_intf),
    //     .output_intf(output_conv_1x1_intf)
    // );

    Conv_3x3_nonpadding Conv_3x3_nonpadding (  // *********modify/
        .clk(clk),  // gated_conv_3x3_clk
        .rstn(~rst),
        .w8(w8),
        .start(start_conv),
        .finish(finish_conv),
        .param_intf(param_conv_intf),
        .bias_intf(bias_conv_intf),
        .weight_intf(weight_conv_intf),
        .input_intf(input_conv_intf),
        .output_intf(output_conv_intf)
    );

    Max_pool_nonpadding Max_pool_nonpadding (
        .clk(clk),  // gated_maxpool_clk
        .rstn(~rst),
        .start(start_maxpool),
        .finish(finish_maxpool),
        .param_intf(param_maxpool_intf),
        .bias_intf(bias_maxpool_intf),
        .weight_intf(weight_maxpool_intf),
        .input_intf(input_maxpool_intf),
        .output_intf(output_maxpool_intf)
    );

    FullyConnected FullyConnected(
        .clk(clk),
        .rstn(~rst),
        .start(start_fc),
        .finish(finish_fc),

        .param_intf(param_fc_intf),
        .bias_intf(bias_fc_intf),   //w32
        .weight_intf(weight_fc_intf), //
        .input_intf(input_fc_intf),
        .output_intf(output_fc_intf)
    );

endmodule
