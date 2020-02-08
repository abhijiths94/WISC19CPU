module dff3_bit (q, d, wen, clk, rst);

    output         [2:0]q; //DFF output
    input          [2:0]d; //DFF input
    input 	   	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            [2:0]state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule
