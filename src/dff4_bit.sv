module dff4_bit (q, d, wen, clk, rst);

    output         [3:0]q; //DFF output
    input          [3:0]d; //DFF input
    input 	   	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            [3:0]state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule
