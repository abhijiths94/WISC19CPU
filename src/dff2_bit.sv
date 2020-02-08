module dff2_bit (q, d, wen, clk, rst);

    output         [1:0]q; //DFF output
    input          [1:0]d; //DFF input
    input 	   	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            [1:0]state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule
