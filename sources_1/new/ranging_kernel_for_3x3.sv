`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2018 16:59:44
// Design Name: 
// Module Name: ranging_kernel_for_3x3
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


module ranging_kernel_for_3x3 #(

  parameter DATA_WIDTH  = 8,
  KERNEL_SIZE           = 3,
  SORT_BY_COLUMN        = 0

)(

  input  logic                  i_clk,
  input  logic                  i_aresetn,

  input  logic [DATA_WIDTH-1:0] i_image_kernel_buffer [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1],

  output logic [DATA_WIDTH-1:0] o_image_kernel_sorted [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1]

);

//SIGNALS
//instantiate sorting_module_3inputs for each line/column of image_kernel_buffer 
//if sort_by_column == 1 - generate sort_col instantiation, else - generate sort_line instantiation

generate
  if ( SORT_BY_COLUMN ) begin

  ///////COLUMN_SORTING///////	

    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_col_0 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[0][0] ),
      .in_2      ( i_image_kernel_buffer[1][0] ),
      .in_3      ( i_image_kernel_buffer[2][0] ),
                 
      .high      ( o_image_kernel_sorted[2][0] ),
      .med       ( o_image_kernel_sorted[1][0] ),
      .low       ( o_image_kernel_sorted[0][0] ) 

    );//sort_col_0

    
    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_col_1 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[0][1] ),
      .in_2      ( i_image_kernel_buffer[1][1] ),
      .in_3      ( i_image_kernel_buffer[2][1] ),
                 
      .high      ( o_image_kernel_sorted[2][1] ),
      .med       ( o_image_kernel_sorted[1][1] ),
      .low       ( o_image_kernel_sorted[0][1] ) 

    );//sort_col_1

    
    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_col_2 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[0][2] ),
      .in_2      ( i_image_kernel_buffer[1][2] ),
      .in_3      ( i_image_kernel_buffer[2][2] ),
                 
      .high      ( o_image_kernel_sorted[2][2] ),
      .med       ( o_image_kernel_sorted[1][2] ),
      .low       ( o_image_kernel_sorted[0][2] ) 

    );//sort_col_2


  end else begin
  	
  ///////LINE_SORTING///////

    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_line_0 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[0][0] ),
      .in_2      ( i_image_kernel_buffer[0][1] ),
      .in_3      ( i_image_kernel_buffer[0][2] ),
                 
      .high      ( o_image_kernel_sorted[0][2] ),
      .med       ( o_image_kernel_sorted[0][1] ),
      .low       ( o_image_kernel_sorted[0][0] ) 

    );//sort_line_0


    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_line_1 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[1][0] ),
      .in_2      ( i_image_kernel_buffer[1][1] ),
      .in_3      ( i_image_kernel_buffer[1][2] ),
                 
      .high      ( o_image_kernel_sorted[1][2] ),
      .med       ( o_image_kernel_sorted[1][1] ),
      .low       ( o_image_kernel_sorted[1][0] ) 

    );//sort_line_1


    sorting_module_3inputs#(

      .DATA_WIDTH ( DATA_WIDTH )

    ) sort_line_2 (

      .i_clk     ( i_clk                       ),
      .i_aresetn ( i_aresetn                   ),
      
      .in_1      ( i_image_kernel_buffer[2][0] ),
      .in_2      ( i_image_kernel_buffer[2][1] ),
      .in_3      ( i_image_kernel_buffer[2][2] ),
                 
      .high      ( o_image_kernel_sorted[2][2] ),
      .med       ( o_image_kernel_sorted[2][1] ),
      .low       ( o_image_kernel_sorted[2][0] ) 

    );//sort_line_2


  end//if ( sort_by_column )
endgenerate  

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
endmodule
