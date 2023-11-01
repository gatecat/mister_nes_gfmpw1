module sram_control(
    input clock, reset,
    output reg cart_ready,
    // NES side
    output reg [7:0] mapper,
    input [20:0] nes_address,
    input prg_sel, chr_sel, ram_sel, uart_sel,
    input nes_rd_en, nes_wr_en,
    input [7:0] nes_wd,
    output [7:0] nes_rd,
    // SRAM side
    output reg sram_rdn, sram_wdn,
    output sram_cen, sram_bus_oen,
    output [3:0] sram_adrh,
    output reg [1:0] sram_ale,
    output reg [7:0] sram_wda,
    input [7:0] sram_rd
);
    reg init_read; // read mapper number from final byte
    // SRAM organisation: 512kB PRG, 256KB CHR, 256KB SRAM
    assign sram_adrh = init_read ? 4'b1111 :
                       uart_sel ? nes_address[19:16] : // programming mode
                       ram_sel ? {2'b11, nes_address[17:16]} : 
                       chr_sel ? {2'b10, nes_address[17:16]} :
                       {1'b0, nes_address[18:16]};


    reg [7:0] nes_rd_lat;
    reg cen_reg, bus_oen_reg;
    reg [1:0] state;



    always @(posedge clock) begin
        if (reset) begin
            state <= 1'b0;
            init_read <= 1'b1;
            cart_ready <= 1'b0;
            mapper <= 8'b0;
            sram_rdn <= 1'b1;
            sram_wdn <= 1'b1;
            sram_ale <= 2'b00;
            cen_reg <= 1'b1;
            bus_oen_reg <= 1'b0;
            sram_wda <= 8'b0;
        end else begin
            case (state)
                2'h0: if (nes_rd_en || nes_wr_en) begin
                    sram_wda <= nes_address[15:8];
                    sram_ale <= 2'b10;
                    state <= 2'h1;
                    cen_reg <= 1'b0;
                end else begin
                    sram_rdn <= 1'b1;
                    sram_wdn <= 1'b1;
                    cen_reg <= 1'b1;
                    bus_oen_reg <= 1'b0;
                    sram_ale <= 2'b00;
                end
                2'h1: begin
                    sram_wda <= nes_address[7:0];
                    sram_ale <= 2'b01;
                    state <= 2'h2;
                end
                2'h2: begin
                    sram_ale <= 2'b00;
                    if (nes_rd_en) begin
                        sram_rdn <= 1'b0;
                        bus_oen_reg <= 1'b1;
                    end
                    if (nes_wr_en) begin
                        sram_wdn <= 1'b0;
                        sram_wda <= nes_wd;
                    end
                    state <= 2'h3;
                end
                2'h3: begin
                    nes_rd_lat <= sram_rd;
                    // defaults
                    sram_rdn <= 1'b1;
                    sram_wdn <= 1'b1;
                    cen_reg <= 1'b1;
                    bus_oen_reg <= 1'b0;
                    sram_ale <= 2'b00;
                end
            endcase
        end
    end

    assign nes_rd = (state >= 2) ? sram_rd : nes_rd_lat;
    assign sram_cen = reset ? 1'b1 : cen_reg;
    assign sram_bus_oen = reset ? 1'b1 : bus_oen_reg;

endmodule
