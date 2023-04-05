`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Charles Wang 
// 
// Create Date:    10/10/2014 
// Design Name: 	LCD1602
// Module Name:   LCD1602
// Project Name: 	LCD1602
// Target Devices: EP4CE6E22C8
// Tool versions: Quartus II 13.1 
// Description: 
//              
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//			
//////////////////////////////////////////////////////////////////////////////////
module LCD1602(sys_clk,sys_rst_n,lcd_rw,lcd_rs,lcd_en,lcd_data);

input sys_clk;//50MHz 总线时钟
input sys_rst_n;//异步复位,低电平有效

output lcd_rw;
output lcd_rs;
output lcd_en;
output [7:0]lcd_data;

reg lcd_rs;
//reg lcd_en;
reg [7:0]lcd_data;
reg [7:0]counter;
reg [3:0]state;
reg lcd_clk;
reg [7:0]lcd_data_r;
reg [4:0]addr_cnt;
assign lcd_rw = 1'b0;
//////////////////////////////////////////////////////////////////////////////////
always@(posedge sys_clk or negedge sys_rst_n)
	begin
		if(!sys_rst_n)
			begin
				counter <= 8'd0;
				lcd_clk  <= 1'b0;
			end
		else if(counter == 8'd249)
			begin
				counter <= 8'd0;
				lcd_clk  <= ~ lcd_clk;
			end
		else
			begin
				counter <= counter + 1'b1;
				lcd_clk  <= lcd_clk;
			end
	end
assign lcd_en = lcd_clk;
always@(posedge sys_clk or negedge sys_rst_n)
	begin
		if(!sys_rst_n)
			lcd_rs <= 1'b0;
		else if((state == data1_w)|(state == data2_w))
			lcd_rs <= 1'b1;
	end
parameter 
		idle			= 4'd0,
		clear			= 4'd1,
		homing		= 4'd2,
		input_mode 	= 4'd3,
		disp_switch	= 4'd4,
		shift_mode	= 4'd5,
		function_set= 4'd6,
		addr1_w		= 4'd7,
		addr2_w		= 4'd8,
		data1_w		= 4'd9,
		data2_w		= 4'd10;

		
always@(posedge lcd_clk or negedge sys_rst_n)
	begin
		if(!sys_rst_n)
			begin
				state	 	<= idle;
				addr_cnt	<= 5'd0;
			end
		else 
			case(state)
				idle: 
					begin
						state 	<= clear;
						lcd_data	<= 8'hz;
					end
				clear:
					begin
						state		<= homing;
						lcd_data	<= 8'h01;
					end
				homing:
					begin
						state		<= input_mode;
						lcd_data	<= 8'h03;
					end
				input_mode:
					begin
						state		<= disp_switch;
						lcd_data	<= 8'h07;
					end
				disp_switch:
					begin
						state		<= shift_mode;
						lcd_data	<= 8'h0d;
					end
				shift_mode:
					begin
						state		<= function_set;
						lcd_data	<= 8'h1c;
					end
				function_set:
					begin
						state		<= addr1_w;
						lcd_data	<= 8'h3c;
					end
				addr1_w:
					begin
						lcd_data	<= 8'h80;
						state		<= data1_w;
					end
				addr2_w:
					begin
						lcd_data	<= 8'hc0;
						state		<= data2_w;
					end
				data1_w:
					begin
						if(addr_cnt < 5'd14)
							begin
								addr_cnt <= addr_cnt + 1'b1;
								lcd_data <= lcd_data_r;
								state		<= data1_w;
							end
						else
							state	<= addr2_w;
					end
				data2_w:
					begin
						if(addr_cnt < 5'd27)
							begin
								addr_cnt <= addr_cnt + 1'b1;
								lcd_data <= lcd_data_r;
								state		<= data1_w;
							end
						else
							begin
								state	<= shift_mode;	
								addr_cnt	<= 5'd0;
							end
					end
				default:
					state <= idle ;
			endcase
end	
always@(addr_cnt)
			begin
				case(addr_cnt)
					5'd0: lcd_data_r <= "I";
					5'd1:	lcd_data_r <= " ";
					5'd2: lcd_data_r <= "r";
					5'd3:	lcd_data_r <= "u";
					5'd4: lcd_data_r <= "n";
					5'd5: lcd_data_r <= " ";
					5'd6: lcd_data_r <= "f";
					5'd7: lcd_data_r <= "o";
					5'd8: lcd_data_r <= "r";
					5'd9: lcd_data_r <= " ";
					5'd10:lcd_data_r <= "h";
					5'd11:lcd_data_r <= "o";
					5'd12:lcd_data_r <= "p";
					5'd13:lcd_data_r <= "e";
					5'd14:lcd_data_r <= "I";
					5'd15:lcd_data_r <= " ";
					5'd16:lcd_data_r <= "r";
					5'd17:lcd_data_r <= "u";
					5'd18:lcd_data_r <= "n";
					5'd19:lcd_data_r <= " ";
					5'd20:lcd_data_r <= "t";
					5'd21:lcd_data_r <= "o";
					5'd22:lcd_data_r <= " ";
					5'd23:lcd_data_r <= "f";
					5'd24:lcd_data_r <= "e";
					5'd25:lcd_data_r <= "e";
					5'd26:lcd_data_r <= "l";
					default:lcd_data_r <= "";
				endcase
			end
endmodule					
						