`include "ConvAcc.svh"

module Max_pool_nonpadding (
    input        clk,
    input        rstn,
    input        start,
    output logic finish,

    sp_ram_intf.compute param_intf,
    sp_ram_intf.compute bias_intf,
    sp_ram_intf.compute weight_intf,
    sp_ram_intf.compute input_intf,
    sp_ram_intf.compute output_intf
);
    logic [31:0] num_row, num_channel, kernel_size;
    logic [10:0] num_input;
    logic [7:0] max;
    logic [10:0] counter;
    logic [4:0] row_counter,col_counter,ch_counter;

    assign num_input = (kernel_size * kernel_size);

    typedef enum logic [2:0] { 
        idle_state = 3'h0,
        load_parameter_state = 3'h1,
        load_input_state = 3'h2,
        write_state = 3'h3,
        finish_state = 3'h4
    } pooling_state_t;

    pooling_state_t pooling_state, next_state;

    //*********************************************//
    //load parameter
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) param_intf.addr <= 32'b0;
        else if ((pooling_state == load_parameter_state)) begin
            if (counter == 11'h3) param_intf.addr <= 32'b0;
            else param_intf.addr <= param_intf.addr + 3'h1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            num_row <= 32'b0;
            num_channel <= 32'b0;
            kernel_size <= 32'h0;
        end 
        else if ((pooling_state == load_parameter_state)) begin
            case (counter)
                11'h1: num_row <= param_intf.R_data;
                11'h2: num_channel <= param_intf.R_data;
                11'h3: kernel_size <= param_intf.R_data;
            endcase
        end
    end
    //load parameter
    //*********************************************//
    //*********************************************//
    //load input
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) input_intf.addr <= 32'b0;
        else if(pooling_state == finish_state) input_intf.addr <= 32'b0;
        else if (pooling_state == load_input_state) begin
            case (counter)
            11'h0: input_intf.addr <= input_intf.addr + 32'b1;
            11'h1: input_intf.addr <= input_intf.addr + num_row - 32'b1;
            11'h2: input_intf.addr <= input_intf.addr + 32'b1;
            11'h3: begin
                if (col_counter == ((num_row >> 1) - 32'b1))begin
                    if(num_row[0] == 1)begin
                        if((row_counter + 1 > (num_row >> 1) - 1) && (col_counter + 1 > (num_row >> 1) - 1))  input_intf.addr <= input_intf.addr + num_row + 32'd2;
                        else if(col_counter + 1 > (num_row >> 1) - 1) input_intf.addr <= input_intf.addr + 32'd2;
                        else input_intf.addr <= input_intf.addr + 32'b1;
                    end
                    else input_intf.addr <= input_intf.addr + 32'b1;
                end
                else input_intf.addr <= input_intf.addr - num_row + 32'b1;
            end
            endcase
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) max <= 8'b0;
        else if (pooling_state == load_input_state) begin
            case (counter)
                11'h0: max <= input_intf.R_data;
                default: max <= (input_intf.R_data > max)? input_intf.R_data : max;
            endcase
        end
    end
    //load input
    //*********************************************//
    //*********************************************//
    //write output
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) output_intf.addr <= 32'b0;
        else if(pooling_state == finish_state) output_intf.addr <= 32'b0;
        else if (pooling_state == write_state)
        output_intf.addr <= output_intf.addr + 32'b1;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) output_intf.W_req <= `WRITE_DIS;
        else if ((pooling_state == load_input_state) && (counter == num_input))
        output_intf.W_req <= `WRITE_ENB;
        else output_intf.W_req <= `WRITE_DIS;
    end
    //write output
    //*********************************************//

    //*********************************************//
    //counter
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) counter <= 11'b0;
        else if (pooling_state == load_parameter_state) begin
            if (counter == 11'h3) counter <= 11'b0;
            else counter <= counter + 11'b1;
        end 
        else if (pooling_state == load_input_state) begin
            if (counter == num_input) counter <= 11'b0;
            else counter <= counter + 11'b1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) col_counter <= 5'b0;
        else if ((pooling_state == write_state)) begin
            if (col_counter == ((num_row >> 1) - 32'b1)) col_counter <= 5'b0;
            else col_counter <= col_counter + 5'b1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) row_counter <= 5'b0;
        else if ((pooling_state == write_state)) begin
            if ((col_counter == ((num_row >> 1) - 32'b1)) && (row_counter == ((num_row >> 1) - 32'b1))) row_counter <= 5'b0;
            else if(col_counter == ((num_row >> 1) - 32'b1)) row_counter <= row_counter + 5'b1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) ch_counter <= 5'b0;
        else if ((pooling_state == write_state)) begin
            if ((ch_counter == num_channel - 1) && (col_counter == ((num_row >> 1) - 32'b1)) && (row_counter == ((num_row >> 1) - 32'b1))) ch_counter <= 5'b0;
            else if((col_counter == ((num_row >> 1) - 32'b1)) && (row_counter == ((num_row >> 1) - 32'b1))) ch_counter <= ch_counter + 5'b1;
        end
    end
    //counter
    //*********************************************//
    
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) pooling_state <= idle_state;
        else pooling_state <= next_state;
    end

    always_comb begin
        case (pooling_state)
            idle_state: begin
                if (start) next_state = load_parameter_state;
                else next_state = idle_state;
            end
            load_parameter_state: begin
                if (counter == 11'h3) next_state = load_input_state;
                else next_state = load_parameter_state;
            end
            load_input_state: begin
                if (counter == num_input) next_state = write_state;
                else next_state = load_input_state;
            end
            write_state: begin
                if ((row_counter == (num_row >> 1) - 1)&&(col_counter == (num_row >> 1) - 1)&&(ch_counter == num_channel - 1)) next_state = finish_state;
                else next_state = load_input_state;
            end
            default: begin
                next_state = idle_state;
            end
        endcase
    end

    // Param
    assign param_intf.W_req = `WRITE_DIS;
    assign param_intf.W_data = 32'b0;
    assign param_intf.oe = 1'b1;
    // Bias
    assign bias_intf.cs = 1'b0;
    assign bias_intf.addr = 32'b0;
    assign bias_intf.W_req = `WRITE_DIS;
    assign bias_intf.W_data = 32'b0;
    assign bias_intf.oe = 1'b1;
    // Weight
    assign weight_intf.cs = 1'b0;
    assign weight_intf.addr = 32'b0;
    assign weight_intf.W_req = `WRITE_DIS;
    assign weight_intf.W_data = 32'b0;
    assign weight_intf.oe = 1'b1;
    // Input 
    assign input_intf.W_req = `WRITE_DIS;
    assign input_intf.W_data = 16'b0;
    assign input_intf.oe = 1'b1;
    // Output
    assign output_intf.W_data = {24'h0, max};
    assign output_intf.oe = 1'b1;

    always_comb begin
        case (pooling_state)
            idle_state: begin
                param_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            load_parameter_state: begin
                param_intf.cs = 1'b1;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            load_input_state: begin
                param_intf.cs = 1'b0;
                input_intf.cs = 1'b1;
                output_intf.cs = 1'b0;
                finish = 1'b0;
            end
            write_state: begin
                param_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b1;
                finish = 1'b0;
            end
            default: begin
                param_intf.cs = 1'b0;
                input_intf.cs = 1'b0;
                output_intf.cs = 1'b0;
                finish = 1'b1;
            end
        endcase
    end

endmodule