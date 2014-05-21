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

// Grabs the binary commands/packets of data
module comm_receiver(clk, reset, port, out, write);
	parameter inSize = 6, outSize = 32;

	input clk, reset;
	input [inSize-1:0] port; // Input port

	output reg [outSize-1:0] out = 0; // Packet output
	output reg write = 0;

	reg [outSize/inSize:0] received = 0;
	reg clear = 0;
	reg valid = 1;

	always @(posedge clk) begin
		write = 0;

		if (reset) begin
			out <= 0;
			received <= 0;
			clear <= 0;
			valid <= 1;
		end else if (received < (outSize/inSize + 1)) begin
			out <= (out << inSize) | port;
			received <= received+1;
		end else if (port) begin
			valid <= 0;
		end else begin
			if (valid)
				write = 1;
			received <= 0;
			valid <= 1;
		end
	end
endmodule

// Interprets packets of data into commands
module comm_int(input clk, reset, read, input [5:0] part,
					output [7:0] X, Y, output [15:0] dataOut,
					output write);
	debounce(clk, read, rClk);
	comm_receiver(reset ? clk : rClk, reset, part, {X, Y, dataOut}, write);
endmodule