/*
	This file is part of avgai.

	avgai is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	avgai is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with avgai.  If not, see <http://www.gnu.org/licenses/>.

	Copyright Dakota Fisher 2014
*/

module avgai(input clk, reset, input [9:0] SW,
					output reg [9:0] LEDG,
					output [3:0] VGA_R, VGA_G, VGA_B, output VGA_VS, VGA_HS,
					inout [31:0] GPIO_1);
	wire [5:0] inData = {GPIO_1[13],GPIO_1[11],GPIO_1[9],GPIO_1[7],GPIO_1[5],GPIO_1[3]};
	wire inDataClk = GPIO_1[1];

	wire ready;
	wire wAck;
	assign GPIO_1[0] = ready;

	wire [15:0] SRAM_data;
	wire [7:0] INT_X, INT_Y, SRAM_X, SRAM_Y;
	wire [11:0] SRAM_out;
	wire [11:0] VGA_Data;
	wire [9:0] hNeed, vNeed;
	vgaControl(clk, reset_, VGA_VS, VGA_HS, need, hNeed, vNeed);
	
	wire [11:0] wDbg;

	comm_int(clk, 0, inDataClk, inData, INT_X, INT_Y, SRAM_data, write);

	wire SRAM_read = need;
	wire SRAM_write = !SRAM_read & write;
	assign ready = !write | wAck;
	assign SRAM_X = SRAM_read ? hNeed >> 2 : INT_X;
	assign SRAM_Y = SRAM_read ? vNeed >> 2 : INT_Y;

	reg needBuf;
	always @(posedge clk) needBuf <= need;
	assign {VGA_R, VGA_G, VGA_B} = VGA_Data;
	assign VGA_Data = needBuf ? SRAM_out : 0;

	SRAM(clk, SRAM_read, SRAM_write, SRAM_X, SRAM_Y, SRAM_data >> 4, SRAM_out, wAck, wDbg);
	clkDiv(clk, divClk);

	// Debugging LEDs
	always @* begin
		LEDG[9] = inDataClk;
		LEDG[8] = ready;
		LEDG[7] = write;
		LEDG[5:0] = inData;
	end
endmodule