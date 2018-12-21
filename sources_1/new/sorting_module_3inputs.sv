`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 01:32:55 PM
// Design Name: 
// Module Name: sorting_module_3inputs
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


module sorting_module_3inputs#(

  parameter DATA_WIDTH = 8

)(

  input  logic                  i_clk,
  input  logic                  i_aresetn,
  
  input  logic [DATA_WIDTH-1:0] in_1,
  input  logic [DATA_WIDTH-1:0] in_2,
  input  logic [DATA_WIDTH-1:0] in_3,

  output logic [DATA_WIDTH-1:0] high,
  output logic [DATA_WIDTH-1:0] med,
  output logic [DATA_WIDTH-1:0] low 

);

//STAGE 1//
//signals 1st stage
logic [DATA_WIDTH-1:0] high_st1;
logic [DATA_WIDTH-1:0] low_st1;
logic [DATA_WIDTH-1:0] in_3_reg[0:1];

sorting_module_2inputs #(
  .DATA_WIDTH ( DATA_WIDTH )
) stage_1 (
  
  .i_clk      ( i_clk      ),
  .i_aresetn  ( i_aresetn  ),

  .in_1       ( in_1       ),
  .in_2       ( in_2       ),

  .high       ( high_st1   ),
  .low        ( low_st1    )   
);
//reg in_3 to sync it with the 1st stage
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      in_3_reg  <= '{default:'b0};
    end else begin
      in_3_reg  <= {in_3, in_3_reg[0]};
   end              
  end  


//STAGE 2//
//signals 2st stage
logic [DATA_WIDTH-1:0] high_st2;
logic [DATA_WIDTH-1:0] low_st2;

logic [DATA_WIDTH-1:0] high_st1_reg[0:1];

sorting_module_2inputs #(
  .DATA_WIDTH ( DATA_WIDTH )
) stage_2 (

  .i_clk      ( i_clk      ),
  .i_aresetn  ( i_aresetn  ),

  .in_1       ( low_st1     ),
  .in_2       ( in_3_reg[1] ),

  .high       ( high_st2 ),
  .low        ( low_st2  )   
);
//reg result of previus step
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      high_st1_reg  <= '{default:'b0};
    end else begin
      high_st1_reg  <= {high_st1, high_st1_reg[0]};
   end              
  end 


//STAGE 3//
//signals 2st stage
//logic [DATA_WIDTH-1:0] high_st3;
//logic [DATA_WIDTH-1:0] low_st3;
logic [DATA_WIDTH-1:0] reg_low_st2;

sorting_module_2inputs #(
  .DATA_WIDTH ( DATA_WIDTH )
) stage_3 (

  .i_clk      ( i_clk      ),
  .i_aresetn  ( i_aresetn  ),
  
  .in_1       ( high_st1_reg[1] ),
  .in_2       ( high_st2     ),

  .high       ( high         ),
  .low        ( med          )   
);
//reg result of previus step
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      reg_low_st2 <= '{default:'b0};
      low         <= '{default:'b0};
    end else begin
      reg_low_st2 <= low_st2;
      low         <= reg_low_st2;
   end              
  end 

endmodule
