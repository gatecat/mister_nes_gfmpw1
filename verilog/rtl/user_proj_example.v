// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module user_proj_example #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [63:0] la_data_in,
    output [63:0] la_data_out,
    input  [63:0] la_oenb,

    // IOs
    input  [BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    reg [31:0] sys_config;

    wire live_led;
    wire reset_btn;

    wire uart_tx, uart_rx;

    wire sram_rdn, sram_wdn, sram_cen, sram_bus_oen;
    wire [1:0] sram_ale;
    wire [3:0] sram_adrh;
    wire [7:0] sram_di, sram_do;

    wire [5:0] lcd_data;
    wire lcd_vs, lcd_hs, lcd_de, lcd_clk;

    wire audio_o;

    wire joy_strobe, joy_data, joy_clk;

    assign io_out[4:0] = 5'b0; // unused (caravel)
    assign io_out[5] = 1'b0; // uart_rx
    assign io_out[6] = uart_tx;
    assign io_out[8:7] = sram_ale;
    assign io_out[11:9] = {sram_rdn, sram_wdn, sram_cen};
    assign io_out[19:12] = sram_do;
    assign io_out[23:20] = sram_adrh;
    assign io_out[29:24] = lcd_data;
    assign io_out[33:30] = {lcd_hs, lcd_vs, lcd_de, lcd_clk};
    assign io_out[34] = audio_o;
    assign io_out[36:35] = {joy_clk, joy_strobe};
    assign io_out[37] = 1'b0; // joy data

    assign io_oeb[37] = 1'b1;
    assign io_oeb[36:20] = 17'b0;
    assign io_oeb[19:12] = {8{sram_bus_oen}};
    assign io_oeb[11:6] = 6'b0;
    assign io_oeb[5] = 1'b1;
    assign io_oeb[4:0] = 5'b0;

    // TODO
    assign wbs_ack_o = 1'b0;
    assign wbs_dat_o = 32'b0;
    assign irq = 3'b0;

endmodule


`default_nettype wire
