module program_counter (
    input clk, rst, 
    input flush,
    input hazard_stall,
    input MemStall,
    input [`InstBus]pc_new,
    output logic [`InstBus]pc_next
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)               pc_next <= 32'd0;
	    else if (MemStall || hazard_stall)  
                               pc_next <= pc_next;
        else if (flush)        pc_next <= pc_new;
        else                   pc_next <= pc_next + 32'd4;  
    end

endmodule
