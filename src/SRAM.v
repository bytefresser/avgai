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

module SRAM(input clk, read, write, 
				input [7:0] X, Y, input [11:0] DATIN,
				output [11:0] DATOUT, output reg wAck,
				output reg [11:0] wDbg);
	parameter W = 200, H = 150;
	reg [11:0] mem[W*H-1:0];
	reg [11:0] DATOUTINV;

	// Can't just assign directly to DATOUT, synthesizer is stupid as all hell
	assign DATOUT = ~DATOUTINV;
	// I invert output here so that the starting output is white instead of black
	// The same is done at the input, so that the output correctly reflects the input
	// You can get any starting color (or any starting screen) by XORing the output
	// at both ends with the desirable value

	always @(posedge clk) begin
		if (read)
			DATOUTINV <= mem[Y*W + X];
		else if (write) begin
			mem[Y*W + X] <= ~DATIN;
			wDbg <= DATIN;
			wAck <= 1;
		end else
			wAck <= 0;
	end
endmodule