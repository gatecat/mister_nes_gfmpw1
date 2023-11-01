module ram_wrapper #(
	parameter WIDTH = 8,
	parameter WORDS = 2048,
	localparam ADDR_BITS = $clog2(WORDS-1)
) (
	input wire clock,
	input wire [ADDR_BITS-1:0] address,
	input wire wren,
	input wire [WIDTH-1:0] write_data,
	output wire [WIDTH-1:0] read_data
);

	localparam W = (WIDTH+7)/8;
	localparam H = (2**ADDR_BITS)/512;

	wire [8*W-1:0] wd_ext = write_data;

	wire [8*W-1:0] sram_out[0:H-1];

	reg [ADDR_BITS-1:0] a_reg;
	always @(posedge clock) begin
		// match RAM latency
		a_reg <= address;
	end

	generate
		genvar x, y;
		for (y = 0; y < H; y++) begin : ay
			wire sel = (address[ADDR_BITS-1:9] == y);
			for (x = 0; x < W; x++) begin : ax
				gf180mcu_fd_ip_sram__sram512x8m8wm1 sram_i(
					.CLK(clock),
					.CEN(1'b1),
					.GWN(wren && sel),
					.WEN(8'hFF),
					.A(address[8:0]),
					.D(wd_ext[8*x +: 8]),
					.Q(sram_out[y][8*x +: 8])
				);
			end
		end
	endgenerate

	assign read_data = sram_out[a_reg[ADDR_BITS-1:9]];

endmodule
