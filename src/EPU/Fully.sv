`include "ConvAcc.svh"

module FullyConnected
(
    input               clk,
    input               rstn,
    input               start,
    output logic        finish,

    sp_ram_intf.compute param_intf,
    sp_ram_intf.compute bias_intf,   //w32
    sp_ram_intf.compute weight_intf, //w32
    sp_ram_intf.compute input_intf,
    sp_ram_intf.compute output_intf
);

    logic [6:0] counter, num_output_ch;
    logic [9:0] row_counter, num_input_ch;

    //bias
    logic signed [31:0] bias [127:0];

    //weight
    logic signed [15:0] weight[127:0];

    //data array
    logic signed [7:0] data;

    //partial sum
    logic signed [31:0] partial_sum[127:0];
    logic signed [31:0] sum[127:0];

    logic [15:0] output_rdata;
    logic [15:0] output_wdata;


    typedef enum logic [2:0] { 
        idle_state = 3'h0,
        load_parameter_state = 3'h1,
        add_bias_state = 3'h2,
        load_weight_state = 3'h3,
        load_input_state = 3'h4,
        calculate_state = 3'h5,
        write_state = 3'h6,
        finish_state = 3'h7
    } fully_state_t;

    fully_state_t fully_state,next_state;

    // Param
    assign param_intf.W_req = `WRITE_DIS;
    assign param_intf.W_data = 32'b0;
    assign param_intf.oe = 1'b1;
    // Bias
    assign bias_intf.W_req = `WRITE_DIS;
    assign bias_intf.W_data = 32'b0;
    assign bias_intf.oe = 1'b1;
    // Weight
    assign weight_intf.W_req = `WRITE_DIS;
    assign weight_intf.W_data = 32'b0;
        // assign weight_rdata = weight_intf.R_data; //w16
    assign weight_intf.oe = 1'b1;
    // Input 
    assign input_intf.W_req = `WRITE_DIS;
    assign input_intf.W_data = 16'b0;
        // assign input_rdata = input_intf.R_data[15:0];
    assign input_intf.oe = 1'b1;
    // Output
    assign output_rdata = output_intf.R_data[15:0];
    // assign output_intf.W_data = {16'h0, output_wdata};
    assign output_intf.oe = 1'b1;

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) fully_state <= idle_state;
        else fully_state <= next_state;
    end

    always_comb begin
        case (fully_state)
        idle_state: begin
            if (start) next_state = load_parameter_state;
            else next_state = idle_state;
        end
        load_parameter_state: begin
            if (counter == 4'd2) next_state = load_input_state;
            else next_state = load_parameter_state;
        end
        load_input_state: begin
            next_state = load_weight_state;
        end
        load_weight_state: begin
            if (counter == num_output_ch) next_state = calculate_state;
            else next_state = load_weight_state;
        end
        add_bias_state: begin
            next_state = write_state;
        end
        calculate_state: begin
            if((row_counter == num_input_ch-10'd1))
                next_state = add_bias_state;
            else
                next_state = load_input_state;
        end
        write_state: begin
            if (counter == (num_output_ch)) next_state = finish_state;
            else next_state = write_state;
        end
        default: begin
            next_state = idle_state;
        end
        endcase
    end

    //*********************************************//
    //load parameter
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) param_intf.addr <= 32'b0;
        else if(fully_state == finish_state) param_intf.addr <= 32'b0;
        else if ((fully_state == load_parameter_state)) begin
            if (counter == 4'h2) param_intf.addr <= 32'b0;
            else param_intf.addr <= param_intf.addr + 32'b1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            num_input_ch <= 10'b0;
            num_output_ch <= 7'b0;
        end 
        else if ((fully_state == load_parameter_state)) begin
            case (counter)
                4'h1: num_input_ch <= param_intf.R_data[9:0];
                4'h2: num_output_ch <= param_intf.R_data[6:0];
            endcase
        end
    end
    //load parameter
    //*********************************************//

    //*********************************************//
    //load input
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) input_intf.addr <= 32'b0;
        else if(fully_state == finish_state) input_intf.addr <= 32'b0;
        else if ((fully_state == load_input_state)) begin
            input_intf.addr <= input_intf.addr + 32'b1;
        end
        else input_intf.addr <= input_intf.addr;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            data <= 8'b0;
        end 
        else if ((fully_state == load_input_state)) begin
            data <= input_intf.R_data[7:0];
        end
    end
    //load input
    //*********************************************//

    //*********************************************//
    //load weight
    // 120*576
    // always_ff @(posedge clk or negedge rstn) begin
    //     if (~rstn) weight_intf.addr <= 32'b0;
    //     else if ((fully_state == load_weight_state)) begin
    //         if(counter == ((num_output_ch >> 1) -1))    weight_intf.addr <= row_counter + 32'd1;
    //         else if (counter != (num_output_ch >> 1))
    //             weight_intf.addr <= weight_intf.addr + num_input_ch;
    //         else    weight_intf.addr <= weight_intf.addr;
    //     end
    //     else weight_intf.addr <= weight_intf.addr;
    // end
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) weight_intf.addr <= 32'b0;
        else if(fully_state == finish_state) weight_intf.addr <= 32'b0;
        else if ((fully_state == load_weight_state) && (counter != num_output_ch)) begin
            weight_intf.addr <= weight_intf.addr + 32'd1;
        end
        else weight_intf.addr <= weight_intf.addr;
    end
    integer k;
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            // generate
            for(k = 0; k < 128; k=k+1) 
                weight[k] <= 8'd0;
            // endgenerate
        end 
        else if ((fully_state == load_weight_state)) begin
            weight[(counter-7'd1)] <= weight_intf.R_data[15:0];
        end
    end
    //load weight
    //*********************************************//
    integer j;
    //*********************************************//
    // calculate
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            // generate
            for(j = 0; j < 128; j=j+1) begin
                partial_sum[j] <= 32'b0;
            end
            // endgenerate
        end else if (fully_state == calculate_state) begin
            // generate
            for(integer i = 0; i < 128; i=i+1) begin
                partial_sum[i] <= $signed((partial_sum[i]) + (data * weight[i]));
            end
            // endgenerate
        end
    end
    // calculate
    //*********************************************//
    //load bias
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) bias_intf.addr <= 32'b0;
        else if(fully_state == finish_state) bias_intf.addr <= 32'b0;
        else if ((fully_state == load_weight_state) & (row_counter==num_input_ch-10'd1)) begin
            bias_intf.addr <= bias_intf.addr + 32'b1;
        end
        else bias_intf.addr <= bias_intf.addr;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            // generate
            for(integer i = 0; i < 128; i=i+1) begin
                bias[i] <= 16'd0;
            end
            // endgenerate
        end 
        else if ((fully_state == load_weight_state)& (row_counter==num_input_ch-10'd1)&(counter <= (num_output_ch>>10'd1))) begin
            bias[((counter-7'd1)<<7'b1)] <= $signed({bias_intf.R_data[31:16], 5'b0});
            bias[((counter-7'd1)<<7'b1)+7'b1] <= $signed({bias_intf.R_data[15:0], 5'b0});
        end
    end
    //load bias
    //*********************************************//
    // add bias
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            // generate
            for(integer i = 0; i < 128; i=i+1) begin
                sum[i] <= 32'b0;
            end
            // endgenerate
        end else if (fully_state == add_bias_state) begin
            // generate
            for(integer i = 0; i < 128; i=i+1) begin
                sum[i] <= $signed(partial_sum[i] + bias[i]);
            end
            // endgenerate
        end
    end
    // add bias
    //*********************************************//

    // write addr
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) output_intf.addr <= 32'b0;
        else if(fully_state == finish_state) output_intf.addr <= 32'b0;
        else if ((fully_state == write_state)&&(counter != 0)) begin
            output_intf.addr <= output_intf.addr + 32'b1;
        end
        else output_intf.addr <= output_intf.addr;
    end
    // write addr
    //*********************************************//

    //*********************************************//
    // write output
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) output_wdata <= 16'b0;
        else if(fully_state == finish_state) output_wdata <= 16'b0;
        else if(fully_state == write_state) begin
            if(sum[counter][31])begin
                if(~&sum[counter][31:25])   output_intf.W_data <= {8'b0, 8'h80};
                else output_intf.W_data <= {1'b1, sum[counter][24:10]};
            end
            else begin
                if (|sum[counter][31:25]) output_intf.W_data <= 16'h7f;
                else output_intf.W_data <= {1'b0, sum[counter][24:10]};
            end
            // output_intf.W_data <= {8'b0, 1'b0, sum[counter][16:10]};
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) output_intf.W_req <= `WRITE_DIS;
        else if (fully_state == add_bias_state | fully_state == write_state) begin
            output_intf.W_req <= `WRITE_ENB;
        end 
        else output_intf.W_req <= `WRITE_DIS;
    end
    // write output
    //*********************************************//
    
    //*********************************************//
    //counter 
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            counter <= 7'b0;
            row_counter <= 10'b0;
        end
        else begin
            case(fully_state)
                load_parameter_state: begin
                    if(counter==7'd2)  counter <= 7'd0;
                    else counter <= counter + 7'd1;
                    row_counter <= row_counter;
                end
                load_weight_state: begin
                    if(counter==(num_output_ch))  counter <= 7'd0;
                    else counter <= counter + 7'd1;
                    row_counter <= row_counter;
                end
                write_state: begin
                    if(counter==(num_output_ch))  counter <= 7'd0;
                    else counter <= counter + 7'd1;
                    row_counter <= row_counter;
                end
                calculate_state: begin
                    counter <= 7'd0;
                    if(row_counter == num_input_ch-10'd1) row_counter <= 10'd0;
                    else row_counter <= row_counter + 10'd1;
                end
                default: begin
                    counter <= 7'd0;
                    row_counter <= row_counter;
                end
            endcase
        end
    end
    //counter 
    //*********************************************//

    always_comb begin
        case (fully_state)
            idle_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            load_parameter_state: begin
                param_intf.cs = 1'b1;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            add_bias_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            load_weight_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b1;
                weight_intf.cs = 1'b1;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            load_input_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b1;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            calculate_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b1;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            write_state: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b1;
                finish = 1'b0;
            end
            default: begin
                param_intf.cs = 1'b0;
                bias_intf.cs = 1'b0;
                weight_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b1;
            end
        endcase
  end

endmodule
