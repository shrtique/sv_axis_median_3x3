`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 01:03:25 PM
// Design Name: 
// Module Name: sorting_module_2inputs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sorting_module_2inputs #(

  parameter DATA_WIDTH = 8

)(

  input  logic                  i_clk,
  input  logic                  i_aresetn, 

  input  logic [DATA_WIDTH-1:0] in_1,
  input  logic [DATA_WIDTH-1:0] in_2,

  output logic [DATA_WIDTH-1:0] high,
  output logic [DATA_WIDTH-1:0] low

);

//signals
logic [DATA_WIDTH-1:0] high_s;
logic [DATA_WIDTH-1:0] low_s;

logic [DATA_WIDTH-1:0] in_1_r;
logic [DATA_WIDTH-1:0] in_2_r;

always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      in_1_r <= '{default:'b0};
      in_2_r <= '{default:'b0};
    end else begin
      in_1_r <= in_1;
      in_2_r <= in_2;
   end              
  end  

always_comb
  begin
  	if ( in_1_r < in_2_r ) begin

  	  high_s = in_2_r;
  	  low_s  = in_1_r;

  	end else begin

      high_s = in_1_r;
      low_s  = in_2_r;
      
  	end	
  end

always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      high <= '{default:'b0};
      low  <= '{default:'b0};
    end else begin
      high <= high_s;
      low  <= low_s;
   end              
  end  	
endmodule
