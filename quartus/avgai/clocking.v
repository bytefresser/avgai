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

module debounce(input clk, but, output reg debounced);
	reg [9:0] debTimer;
	always @(posedge clk) begin
		if (debounced == but)
			debTimer <= 0;
		else if (debTimer != -10'b1)
			debTimer <= debTimer+1;
		else if (debTimer == -10'b1)
			debounced <= but;
	end
endmodule

module clkDiv(input clk, output divClk);
	parameter n = 25;
	reg [n-1:0] count = 0;
	assign divClk = count[n-1];
	
	always @(posedge clk)
		count <= count + 1;
endmodule
