module mem_arb(i_cache_busy, d_cache_busy, en_i_cache, en_d_cache);

	input i_cache_busy, d_cache_busy;
	output en_i_cache, en_d_cache;

	wire simul = i_cache_busy & d_cache_busy;

	assign en_i_cache = simul ? 1 : i_cache_busy;
	assign en_d_cache = simul ? 0 : d_cache_busy;

endmodule
